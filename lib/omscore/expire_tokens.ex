defmodule Omscore.ExpireTokens do
  use GenServer
  import Ecto.Query, warn: false


  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    expire_mail_confirmations()
    expire_password_resets()
    expire_refresh_tokens()
    expire_memberships()

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  def expire_memberships() do
    now = Omscore.ecto_date_in_past(0)

    # This query holds all bms which do have a valid payment
    # Also this part doesn't need to be inside a transaction
    unexpire_query = from bm in Omscore.Members.BodyMembership,
      inner_join: p in Omscore.Finances.Payment, on: bm.member_id == p.member_id and bm.body_id == p.body_id,
      where: p.expires > ^now and bm.has_expired == true

    # These memberships should be set to unexpired
    Omscore.Repo.update_all(unexpire_query, set: [has_expired: false])
  
    {:ok, items} = Omscore.Repo.transaction(fn ->
      # This takes all body memberships and groups them with their payments, counting the valid payments
      # All which have 0 valid payments but are not set to expired yet are in this
      expire_query = from bm in Omscore.Members.BodyMembership, 
        left_lateral_join: p in fragment("SELECT COUNT(p.id) AS valid_payments FROM payments AS p WHERE p.body_id = ? AND p.member_id = ? AND p.expires > ?", bm.body_id, bm.member_id, ^now),
        where: p.valid_payments == 0 and bm.has_expired == false,
        preload: [member: [:user], body: []]

      # We need to first query them because we can't feed this complex query into an update statement
      items = Omscore.Repo.all(expire_query)
      |> Enum.filter(fn(x) -> x.body.pays_fees end)

      ids = Enum.map(items, fn(x) -> x.id end)

      Omscore.Repo.update_all(from(bm in Omscore.Members.BodyMembership, where: bm.id in ^ids), set: [has_expired: true])
      items
    end)

    items
    |> Enum.map(fn(x) -> 
      Omscore.Interfaces.Mail.send_mail(x.member.user.email, "Membership expired", "Your membership in body " <> x.body.name <> " has expired")
    end)
  end

  def expire_refresh_tokens() do
    expiry = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_refresh))
    query = from u in Omscore.Auth.RefreshToken,
      where: u.inserted_at < ^expiry

    Omscore.Repo.delete_all(query)
  end

  def expire_mail_confirmations() do
    # Pipeline of death to find a date in the past
    expiry = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_mail_confirmation)) 
    query = from u in Omscore.Registration.MailConfirmation,
      where: u.inserted_at < ^expiry

    confirmations = query
    |> Omscore.Repo.all()
    |> Enum.map(fn(x) -> Omscore.Repo.preload(x, [submission: [:user]]) end)

    confirmations
    |> Enum.map(fn(x) -> Omscore.Repo.delete(x) end)

    # Deleting the user object will cascade through to submission, mail_confirmation, member if already created and a lot more
    # Only delete the user where no confirmations are left and the mail wasn't confirmed manually
    confirmations
    |> Enum.map(fn(x) -> x.submission end) # Now we deal with submissions only
    |> Enum.map(fn(x) -> Omscore.Repo.preload(x, [:mail_confirmations]) end)
    |> Enum.filter(fn(x) -> x.mail_confirmations == [] && x.mail_confirmed == false end)
    |> Enum.map(fn(x) -> Omscore.Repo.delete(x.user) end)
  end

  def expire_password_resets() do
    expiry = Omscore.ecto_date_in_past(Application.get_env(:omscore, :ttl_password_reset))
    query = from u in Omscore.Auth.PasswordReset,
      where: u.inserted_at < ^expiry

    Omscore.Repo.delete_all(query)
  end


  defp schedule_work() do
    Process.send_after(self(), :work, Application.get_env(:omscore, :expiry_worker_freq)) # Every 5 minutes check for expired stuff
  end
end
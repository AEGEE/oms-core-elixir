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
    query = from u in Omscore.Members.BodyMembership,
      where: not is_nil(u.expiration) and u.expiration < ^now and u.has_expired != true

    {:ok, items} = Omscore.Repo.transaction(fn ->
      items = Omscore.Repo.all(query)  |> Omscore.Repo.preload([member: [:user], body: []])
      Omscore.Repo.update_all(query, set: [has_expired: true])
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

    # Deleting the user object will cascade through to submission, mail_confirmation, member if already created and a lot more
    confirmations = query
    |> Omscore.Repo.all()
    |> Enum.map(fn(x) -> Omscore.Repo.preload(x, [submission: [:user]]) end)

    confirmations
    |> Enum.map(fn(x) -> Omscore.Repo.delete(x) end)

    confirmations
    |> Enum.map(fn(x) -> x.submission end) # Now we deal with submissions only
    |> Enum.map(fn(x) -> Omscore.Repo.preload(x, [:mail_confirmations]) end)
    |> Enum.filter(fn(x) -> x.mail_confirmations == [] end)
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
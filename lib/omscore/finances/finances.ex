defmodule Omscore.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias Omscore.Repo

  alias Omscore.Finances.Payment

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments(params \\ %{}) do
    from(u in Payment, order_by: [:inserted_at])
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:comment, :invoice_name, :invoice_address], " ")
    |> OmscoreWeb.Helper.filter(params, Payment.__schema__(:fields))
    |> Repo.all()
  end

  def list_bound_payments(body_id, params \\ %{}) do
    from(u in Payment, order_by: [:inserted_at], where: u.body_id == ^body_id)
    |> OmscoreWeb.Helper.paginate(params)
    |> OmscoreWeb.Helper.search(params, [:comment, :invoice_name, :invoice_address], " ")
    |> OmscoreWeb.Helper.filter(params, Payment.__schema__(:fields))
    |> Repo.all()
  end

  @doc """
  Gets a single payment.

  Raises `Ecto.NoResultsError` if the Payment does not exist.

  ## Examples

      iex> get_payment!(123)
      %Payment{}

      iex> get_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment!(id), do: Repo.get!(Payment, id)

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(%Omscore.Core.Body{} = body, %Omscore.Members.Member{} = member, attrs \\ %{}) do
    changeset = %Payment{
      body_id: body.id,
      member_id: member.id
    }
    |> Payment.changeset(attrs)

    with {:ok, payment} <- Repo.insert(changeset) do
      # Unexpire the body membership in case it is expired
      Omscore.Members.get_body_membership(body, member)
      |> Ecto.Changeset.change(has_expired: false)
      |> Repo.update!()
      
      {:ok, payment}
    end
  end

  @doc """
  Updates a payment.

  ## Examples

      iex> update_payment(payment, %{field: new_value})
      {:ok, %Payment{}}

      iex> update_payment(payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment(%Payment{} = payment, attrs) do
    payment
    |> Payment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Payment.

  ## Examples

      iex> delete_payment(payment)
      {:ok, %Payment{}}

      iex> delete_payment(payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment(%Payment{} = payment) do
    Repo.delete(payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment changes.

  ## Examples

      iex> change_payment(payment)
      %Ecto.Changeset{source: %Payment{}}

  """
  def change_payment(%Payment{} = payment) do
    Payment.changeset(payment, %{})
  end
end

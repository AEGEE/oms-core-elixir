defmodule Omscore do
  @moduledoc """
  Omscore keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def random_url() do
    :crypto.strong_rand_bytes(30) |> Base.encode32
  end

  def hash_without_salt(data) do
    :crypto.hash(:sha256, data) |> Base.encode64
  end

  def ecto_date_in_past(offset_days) do
    Date.utc_today()
    |> Date.add(-offset_days)
  end

  def ecto_datetime_in_past(offset_seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-offset_seconds)
  end

  def test_nil(anything) when anything != nil, do: {:ok, anything}
  def test_nil(_anything), do: {:error, nil}

  def downcase_field(%Ecto.Changeset{} = changeset, field) do
    if Map.has_key?(changeset.changes, field) do
      value = String.downcase(Map.get(changeset.changes, field))
      Map.put(changeset, :changes, Map.put(changeset.changes, field, value))
    else
      changeset
    end
  end


end

defmodule Omscore.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Omscore.Repo

      def map_inclusion(map_to_check, should_be_in_there) when is_map(should_be_in_there) do
        should_be_in_there
        |> Map.keys
        |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) && Map.get(map_to_check, key) == Map.get(should_be_in_there, key) end)
      end

      def map_inclusion(map_to_check, should_be_in_there) when is_list(should_be_in_there) do
        should_be_in_there
        |> Enum.all?(fn(key) -> Map.has_key?(map_to_check, key) end)
      end

      def map_inclusion(map_to_check, should_be_in_there) do
        Map.has_key?(map_to_check, should_be_in_there)
      end


      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Omscore.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Omscore.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Omscore.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end

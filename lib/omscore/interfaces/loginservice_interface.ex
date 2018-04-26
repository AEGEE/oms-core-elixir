defmodule Omscore.Interfaces.Loginservice do
  @superadmin_user %{superadmin: true, id: 1, name: "microservice", email: "oms@aegee.eu"}

  defp fake_access_token() do
    {:ok, token, _claims} = Omscore.Guardian.encode_and_sign(@superadmin_user, %{name: @superadmin_user.name, email: @superadmin_user.email, superadmin: @superadmin_user.superadmin, refresh: nil}, token_type: "access", ttl: {15, :seconds})
    token  
  end

  def delete_user(member_id) do
    provider = Application.get_env(:omscore, Omscore.Interfaces.Loginservice)[:user_delete_provider]
    apply(Omscore.Interfaces.Loginservice, provider, [member_id])
  end

  def do_nothing(_id) do
    {:ok}
  end

  def delete_from_loginservice(member_id) do
    token = fake_access_token()
    res = HTTPoison.delete(Application.get_env(:omscore, Omscore.Interfaces.Loginservice)[:url] <> "/user/" <> to_string(member_id), 
                           [{"X-Auth-Token", token}, {"Accept", "application/json"}, {"Content-Type", "application/json"}])

    res |> IO.inspect
    case res do
      {:ok, %HTTPoison.Response{status_code: 204}} -> {:ok}
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found, "Could not delete user because user was not found"}
      {:ok, %HTTPoison.Response{status_code: 403}} -> {:error, :forbidden, "Loginservice didn't accept fake token."}
      res -> res
    end
  end

  
end
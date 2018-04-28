
defmodule Omscore.Guardian do
  use Guardian, otp_app: :omscore

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  defp parse_int(string) do
    {res, _} = Integer.parse(string)
    res
  end

  # The access token can be decoded without a db access
  defp access_from_claims(claims) do
    if Map.has_key?(claims, "sub") && Map.has_key?(claims, "name") && Map.has_key?(claims, "email") && Map.has_key?(claims, "superadmin") do
      user = %Omscore.Auth.User{id: parse_int(claims["sub"]), name: claims["name"], email: claims["email"], superadmin: claims["superadmin"]}
      {:ok, user}
    else
      {:error, "Not all fields present in token claims"}
    end
  end

  # For the refresh token we can check the db as performance is non-critical
  defp refresh_from_claims(claims) do
    user = Omscore.Auth.get_user!(claims["sub"])
    {:ok, user}
  end

  def resource_from_claims(claims) do
    case claims["typ"] do
      "access" -> access_from_claims(claims)
      "refresh" -> refresh_from_claims(claims)
      _ -> {:error, "No token type was set"}
    end
  end
end
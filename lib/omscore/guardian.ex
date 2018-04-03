
defmodule Omscore.Guardian do
  use Guardian, otp_app: :omscore

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  defp parse_int(string) do
    {res, _} = Integer.parse(string)
    res
  end

  def resource_from_claims(claims) do
    if Map.has_key?(claims, "sub") && Map.has_key?(claims, "name") && Map.has_key?(claims, "email") && Map.has_key?(claims, "superadmin") do
      user = %{id: parse_int(claims["sub"]), name: claims["name"], email: claims["email"], superadmin: claims["superadmin"]}
      {:ok, user}
    else
      {:error, "Not all fields present in token claims"}
    end
  end
end
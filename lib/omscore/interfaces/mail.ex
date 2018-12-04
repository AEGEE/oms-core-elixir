defmodule Omscore.Interfaces.Mail do

  use Tesla

  plug Tesla.Middleware.BaseUrl, Application.get_env(:omscore, Omscore.Interfaces.Mail)[:oms_mailer_dns]
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.Headers
  plug Tesla.Middleware.JSON, engine: Poison
  plug Tesla.Middleware.Retry, delay: 500, max_retries: 5



  # Define the different variants of send mail calls so we make sure we don't use any unknown templates or forget parameters
  def send_mail(to, "confirm_email", %{token: token}), do: dispatch_mail(to, "Confirm your email to join OMS", "confirm_email", %{token: token})
  def send_mail(to, "password_reset", %{token: token}), do: dispatch_mail(to, "Password reset in OMS", "password_reset", %{token: token})
  def send_mail(to, "membership_expired", %{body_name: body_name}), do: dispatch_mail(to, "Your membership in " <> body_name <> " has expired", "membership_expired", %{body_name: body_name})
  def send_mail(to, "welcome", %{body_name: body_name}), do: dispatch_mail(to, "Your new account in OMS", "welcome", %{body_name: body_name, email: to})
  def send_mail(to, "member_joined", %{body_name: body_name, member_firstname: member_firstname, member_lastname: member_lastname}), do: dispatch_mail(to, "A new join request was filed", "member_joined", %{body_name: body_name, member_firstname: member_firstname, member_lastname: member_lastname})

  defp dispatch_mail(to, subject, template, content) do
    body = %{
      template: template,
      to: to,
      subject: subject,
      parameters: content
    }

    case post("/", body) do
      {:ok, %{status: 200} = res} -> {:ok, res}
      {:ok, _} -> {:error, :internal_server_error, "Could not deliver email"}
      _error -> {:error, :internal_server_error, "Could not contact mail delivery service"}
    end
  end
end
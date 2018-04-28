defmodule Omscore.Interfaces.Mail do
  def send_mail(to, subject, content, content_type \\ "text/plain") do
    mail_service = Application.get_env(:omscore, Omscore.Interfaces.Mail)[:mail_service]
    apply(Omscore.Interfaces.Mail, mail_service, [to, subject, content, content_type])
  end

  def sendgrid(to, subject, content, content_type) do
    data = %{
      personalizations: [%{
        to: [%{email: to}],
        subject: subject
      }],
      from: %{email: Application.get_env(:omscore, Omscore.Interfaces.Mail)[:from]}, 
      content: [%{
        type: content_type,
        value: content
      }]
    } 

    case HTTPoison.post("https://api.sendgrid.com/v3/mail/send", Poison.encode!(data), [{"Authorization", "Bearer " <> Application.get_env(:omscore, Omscore.Interfaces.Mail)[:sendgrid_key]}, {"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 202}} -> {:ok}
      {:ok, %HTTPoison.Response{status_code: 400}} -> {:error, "Could not send mail, sendgrid token might be malconfigured"}
      _ -> {:error, "Could not send mail for unknown reason"}
    end
  end

  def consoleout(to, subject, content, content_type) do
    #IO.inspect("to:  " <> to)
    #IO.inspect("sub: " <> subject)
    #IO.inspect("content: " <> content)
    #IO.inspect("content_type: " <> content_type)

    # Save in ets so test can query it
    :ets.insert(:saved_mail, {to, subject, content, content_type})
    {:ok}
  end
end
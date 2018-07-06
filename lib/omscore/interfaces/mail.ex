defmodule Omscore.Interfaces.Mail do
  import Bamboo.Email

  def send_mail(to, subject, content, content_type \\ "text/plain") do
    mail_service = Application.get_env(:omscore, Omscore.Interfaces.Mail)[:mail_service]
    apply(Omscore.Interfaces.Mail, mail_service, [to, subject, content, content_type])
  end

  def sendgrid(to, subject, content, _content_type) do
    new_email(
      to: to,
      from: Application.get_env(:omscore, Omscore.Interfaces.Mail)[:from],
      subject: subject,
      html_body: content
    )
    |> Omscore.Mailer.deliver_later
    
    {:ok}
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
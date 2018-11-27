defmodule OmscoreWeb.MockServer do
  def mail_mock() do
    Tesla.Mock.mock(&OmscoreWeb.MockServer.handle/1)
  end

  def handle(%{url: "http://oms-mailer:4000/"} = env) do
    body = Poison.decode! env.body
    :ets.insert(:saved_mail, {body["to"], body["subject"], body["template"], body["parameters"]})
    if !Regex.match?(~r/^.*@.*$/, body["to"]) do
      %Tesla.Env{status: 422, body: Poison.encode!(%{success: false, errors: "invalid email address"})}
    else
      %Tesla.Env{status: 200, body: Poison.encode!(%{success: true})}
    end
  end
end
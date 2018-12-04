defmodule OmscoreWeb.MockServer do
  def mail_mock() do
    Tesla.Mock.mock(&OmscoreWeb.MockServer.handle/1)
  end

  def handle(%{url: "http://oms-mailer:4000/"} = env) do
    body = Poison.decode! env.body
    cond do
      is_list(body["to"]) -> 
        Enum.map(body["to"], fn(x) -> :ets.insert(:saved_mail, {x, body["subject"], body["template"], body["parameters"]}) end)
        %Tesla.Env{status: 200, body: Poison.encode!(%{success: true})}
      
      Regex.match?(~r/^.*@.*$/, body["to"]) -> 
        :ets.insert(:saved_mail, {body["to"], body["subject"], body["template"], body["parameters"]})
        %Tesla.Env{status: 200, body: Poison.encode!(%{success: true})}
      
      true -> 
        %Tesla.Env{status: 422, body: Poison.encode!(%{success: false, errors: "invalid email address"})}      
    end
  end
end
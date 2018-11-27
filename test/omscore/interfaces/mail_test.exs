defmodule Omscore.MailTest do
  use Omscore.DataCase

  test "sends mail" do
    :ets.delete_all_objects(:saved_mail)

    Omscore.Interfaces.Mail.send_mail("bla@test.de", "welcome", %{body_name: "Testbody"})

    assert :ets.lookup(:saved_mail, "bla@test.de")

  end

  test "rejects bad mail" do
    Omscore.Interfaces.Mail.send_mail("blaaaaa", "confirm_email", %{token: "12345678"})
  end
end
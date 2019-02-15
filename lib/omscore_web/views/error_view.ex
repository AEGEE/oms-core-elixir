defmodule OmscoreWeb.ErrorView do
  use OmscoreWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{success: false, errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def render("404.json", _assigns) do
    %{success: false, message: "Route or Template not found! Check your url and parameters"}
  end

  def render("error.json", %{msg: msg}) do
    %{success: false, message: msg}
  end
end

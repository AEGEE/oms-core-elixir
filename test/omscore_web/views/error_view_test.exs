defmodule OmscoreWeb.ErrorViewTest do
  use OmscoreWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(OmscoreWeb.ErrorView, "404.json", []) ==
           %{success: false, errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(OmscoreWeb.ErrorView, "500.json", []) ==
           %{success: false, errors: %{detail: "Internal Server Error"}}
  end
end

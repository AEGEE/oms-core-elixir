defmodule OmscoreWeb.PermissionView do
  use OmscoreWeb, :view
  alias OmscoreWeb.PermissionView

  def render("index.json", %{permissions: permissions}) do
    %{success: true, data: render_many(permissions, PermissionView, "permission.json")}
  end

  def render("show.json", %{permission: permission}) do
    %{success: true, data: render_one(permission, PermissionView, "permission.json")}
  end

  def render("permission.json", %{permission: permission}) do
    %{id: permission.id,
      scope: permission.scope,
      action: permission.action,
      object: permission.object,
      description: permission.description,
      combined: permission.scope <> ":" <> permission.action <> ":" <> permission.object,
      always_assigned: permission.always_assigned
    }
  end
end

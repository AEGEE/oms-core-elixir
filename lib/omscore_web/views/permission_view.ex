defmodule OmscoreWeb.PermissionView do
  use OmscoreWeb, :view
  alias OmscoreWeb.PermissionView
  alias OmscoreWeb.Helper

  def render("index.json", %{permissions: permissions, filters: filters}) do
    data = permissions
    |> render_many(PermissionView, "permission.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("index.json", %{permissions: permissions}), do: render("index.json", %{permissions: permissions, filters: []})

  def render("show.json", %{permission: permission, filters: filters}) do
    data = permission
    |> render_one(PermissionView, "permission.json")
    |> Omscore.Core.apply_attribute_filters(filters)

    %{success: true, data: data}
  end
  def render("show.json", %{permission: permission}), do: render("show.json", %{permission: permission, filters: []})

  def render("permission.json", %{permission: permission}) do
    %{id: permission.id,
      scope: permission.scope,
      action: permission.action,
      object: permission.object,
      description: permission.description,
      combined: permission.scope <> ":" <> permission.action <> ":" <> permission.object,
      always_assigned: permission.always_assigned,
      circles: Helper.render_assoc_many(permission.circles, OmscoreWeb.CircleView, "circle.json"),
      filters: Helper.render_assoc_many(permission.filters, OmscoreWeb.PermissionView, "filter.json")
    }
  end

  def render("filter.json", %{permission: filter}) do
    %{field: filter.field}
  end

  def render("permission_relations.json", %{hierarchies: hierarchies}) do
    %{success: true, 
      data: Enum.map(hierarchies, fn(hierarchy) -> Helper.render_assoc_many(hierarchy, OmscoreWeb.CircleView, "circle.json") end)
    }
  end
end

defmodule OmscoreWeb.MemberPermissionPlug do
  import Plug.Conn

  alias Omscore.Core.Permission

  def init(default), do: default

  # For foreign users we have to fetch the bodies of the foreign member to determine if the own member gets any permissions through any of them
  # There is quite some performance optimization potential here...
  def process_foreign(conn, member_id) do
    member = Omscore.Members.get_member!(member_id) 
    |> Omscore.Repo.preload([:bodies])

    permissions = member.bodies
    |> Enum.map(fn(body) -> Omscore.Members.get_local_permissions(conn.assigns.member, body) end)
    |> Enum.reduce([], fn(x, acc) -> x ++ acc end)
    |> Enum.concat(conn.assigns.permissions)
    |> Omscore.Core.reduce_permission_list()

    conn 
    |> assign(:target_member, member)
    |> assign(:permissions, permissions)
  end

  # If fetching own permissions, just add some things to the permission list
  @additional_permissions [%Permission{action: "view", object: "member", scope: "member"},
                           %Permission{action: "update", object: "member", scope: "member"},
                           %Permission{action: "delete", object: "user", scope: "member"}]
  def process_myself(conn) do
    permissions = conn.assigns.permissions ++ @additional_permissions
    conn 
    |> assign(:permissions, permissions)
    |> assign(:target_member, conn.assigns.member)
  end

  # This plug loads permissions towards another member object, e.g. member a trying to edit member b.
  # Member a can aquire additional permissions through the bodies member b is member of
  # Assumes member a was already fetched by a previous plug and stored in conn.assigns.member
  # Stores member b in target_member
  def call(%{path_params: %{"member_id" => member_id}} = conn, _) do
    if to_string(conn.assigns.member.id) == to_string(member_id) || "me" == to_string(member_id) || to_string(conn.assigns.member.seo_url) == to_string(member_id) do
      process_myself(conn)
    else
      process_foreign(conn, member_id)
    end
  end
end
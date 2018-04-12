# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Omscore.Repo.insert!(%Omscore.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Omscore.Core.Permission
alias Omscore.Members.Member
alias Omscore.Core
alias Omscore.Members
alias Omscore.Repo

# Seed permissions
if Repo.all(Permission) == [] do
  # Permissions
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "permission",
    description: "View permissions available in the system",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "permission",
    description: "Create new permission objects which haven't been in the system yet, usually only good for microservices"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update",
    object: "permission",
    description: "Change permissions, should generally happen very rarely as it could break the system"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "permission",
    description: "Delete a permission, should generally happen very rarely as it could break the system"
  })

  # Free circles
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "circle",
    description: "List and view the details of any circle, excluding members data",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create", 
    object: "free_circle",
    description: "Create free circles"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update",
    object: "circle",
    description: "Update any circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "put_parent",
    object: "circle",
    description: "Assign a parent to any circle. This permission should be granted only to trustworthy persons as it is possible to assign an own circle as child to a parent circle with a lot of permissions"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "put_parent",
    object: "bound_circle",
    description: "Assign a parent to a bound circle. This only allows to assign parents that are in the same body as the circle to migitate permission escalations where someone with this permission could assign his own circle to one with a lot of permissions"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "circle",
    description: "Delete any circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "view_members",
    object: "circle",
    description: "View members of any circle, even those you are not member of. Should only be given to very trusted people as this way big portions of the members database can be accessed directly"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "view_members",
    object: "circle",
    description: "View members of any circle in the body that you got this permission from"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update_members",
    object: "circle",
    description: "Update membership details of members of any circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update_members",
    object: "circle",
    description: "Update membership details of members of any circle in the body that you got this permission from, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete_members",
    object: "circle",
    description: "Delete any member from any free circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update_members",
    object: "circle",
    description: "Delete any member from any circle in the body that you got this permission from, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global", 
    action: "join",
    object: "circle",
    description: "Allows to join circles which are joinable. Non-joinable circles can never be joined",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "join",
    object: "circle",
    description: "Allows you to join joinable circles in the body where you got the permission from",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "create",
    object: "bound_circle",
    description: "Creating bound circles to the body the permission was granted in"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "put_permissions",
    object: "circle",
    description: "Assign permission to any circle. This is effectively superadmin permission, as a user holding this can assign all permissions in the system to a circle where he is member in"
  })

  # Bodies
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "body",
    description: "View body details, excluding the members list",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "body",
    description: "Create new bodies."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update",
    object: "body",
    description: "Update any body, even those that you are not member of. Try to use the local permission instead"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update",
    object: "body",
    description: "Update details of the body that you got the permission from. Might be good for boards but also allows changing the name"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "body",
    description: "Delete a body."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "view_members",
    object: "body",
    description: "View the members of any body in the system. Be careful with assigning this permission as it means basically disclosing the complete members list to persons holding it"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "view_members",
    object: "body",
    description: "View the members in the body that you got that permission from"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete_members", 
    object: "body",
    description: "Delete the membership status of any member in any body. Use the local permission for this if possible"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "delete_members",
    object: "body",
    description: "Delete membership status from members in the body that you got this permission from."
  })

  # Join requests
  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "join_request",
    description: "Allows users to request joining a body. Without these permissions the joining body process would be disabled",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "view",
    object: "join_request",
    description: "View join request to the body you got this permission from"
  })
  
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "join_request",
    description: "View join requests to any body in the system. This could disclose a bigger portion of the members database and thus should be assigned carefully"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "process",
    object: "join_request",
    description: "Process join requests in any body of the system, even those that you are not affiliated with."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "process",
    object: "join_request",
    description: "Process join requests in the body that you got the permission from"
  })

  # Members
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "member",
    description: "View all members in the system. Assign this role to trusted persons only to avoid disclosure. For local scope, use view_members:body"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "view",
    object: "members",
    description: "View basic information about all members in the body. This does not allow you to perform a members listing, you might however hold the list body_memberships permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "view_full",
    object: "member",
    description: "View all details of any member in the system. Assign this role to trusted persons only to avoid disclosure."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "view_full",
    object: "member",
    description: "View all details of any member in the body that you got this permission from"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "member",
    description: "Create members to the system. This is usually only assigned to the login microservice"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update",
    object: "member",
    description: "Update any member in the system. Don't assign this as any member can update his own profile anyways."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update",
    object: "member",
    description: "Update any member in the body you got this permission from. Notice that member information is global and several bodies might have the permission to access the same member. Also don't assign it when not necessary, the member can update his own profile anyways."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "member",
    description: "Remove an account from the system. Don't assign this as any member can delete his own account anyways."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "delete",
    object: "member",
    description: "Delete any member in your body from the system. This allows to also delete members that are in other bodies and have a quarrel in that one body with the board admin, so be careful in granting this permission. The member can delete his own profile anyways"
  })
end


# Create test-data so it's possible to experiment with the api without having to boot up the whole system
if Mix.env() == :dev && Repo.all(Member) == [] do
  {:ok, member} = Members.create_member(%{about_me: "I code shit", address: "Europe", date_of_birth: ~D[2010-04-17], first_name: "Nico", gender: "not specified", last_name: "Westerbeck", phone: "+1212345678", user_id: 1})
  {:ok, member2} = Members.create_member(%{about_me: "I also code shit", address: "Russian tundra", date_of_birth: ~D[2010-04-17], first_name: "Sergey", gender: "programmer", last_name: "Peshkov", phone: "+1212345678", user_id: 2})
  {:ok, body} = Core.create_body(%{address: "Dresden", description: "Very prehistoric antenna", email: "info@aegee-dresden.org", legacy_key: "DRE", name: "AEGEE-Dresden", phone: "don't call us"})
  {:ok, circle} = Core.create_circle(%{description: "basically doing nothing", joinable: false, name: "Board AEGEE-Dresden"}, body)
  {:ok, circle2} = Core.create_circle(%{description: "This is the toplevel circle for all boards in the system", joinable: false, name: "General board circle"})
  {:ok, _} = Members.create_body_membership(body, member)
  {:ok, _} = Members.create_circle_membership(circle, member)
  {:ok, _} = Core.put_parent_circle(circle, circle2)
  {:ok, permission1} = Repo.all(Permission) |> Core.search_permission_list("view_full", "member", "local")
  {:ok, permission2} = Repo.all(Permission) |> Core.search_permission_list("view", "join_request", "local")
  {:ok, permission3} = Repo.all(Permission) |> Core.search_permission_list("process", "join_request", "local")
  {:ok, permission4} = Repo.all(Permission) |> Core.search_permission_list("view_members", "body", "local")
  {:ok, permission5} = Repo.all(Permission) |> Core.search_permission_list("delete_members", "body", "local")
  {:ok, _} = Core.put_circle_permissions(circle2, [permission1, permission2, permission3, permission4, permission5])
  {:ok, token, _} = Omscore.Guardian.encode_and_sign(%{id: 1}, %{name: "some name", email: "some@email.com", superadmin: true}, token_type: "access", ttl: {100, :weeks})
  IO.inspect("Use this token with superadmin access if you want to test the api:")
  IO.inspect(token)
end
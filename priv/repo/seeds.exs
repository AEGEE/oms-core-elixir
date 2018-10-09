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
dump = true
alias Omscore.Core.Permission
alias Omscore.Members.Member
alias Omscore.Members
alias Omscore.Repo
alias Omscore.Auth.User

# Seed permissions
if Repo.all(Permission) == [] && !dump do
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
    action: "put_child",
    object: "circle",
    description: "Add any orphan circle in the system as a child to any circle you are circle admin in."
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
    action: "add_member",
    object: "circle",
    description: "Add anyone to any circle in the system, no matter if the circle is joinable or not but still respecting that bound circles can only hold members of the same body. This also allows to add yourself to any circle and thus can be used for a privilege escalation"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "add_member",
    object: "circle",
    description: "Add any member of the body you got this permission from to any bound circle in that body, no matter if the circle is joinable or not or if the member wants that or not. This also allows to add yourself to any circle so only give it to people who anyways have many rights in the body"
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
    action: "delete_members",
    object: "circle",
    description: "Delete any member from any circle in the body that you got this permission from, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global", 
    action: "join",
    object: "circle",
    description: "Allows to join circles which are joinable. Non-joinable circles can never be joined"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "join",
    object: "circle",
    description: "Allows you to join joinable circles in the body where you got the permission from",
    always_assigned: true
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "bound_circle",
    description: "Creating bound circles in any body of the system, even those you are not member in"
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
    action: "update_member",
    object: "body",
    description: "Change the data attached to a body membership in any body in the system"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update_member",
    object: "body",
    description: "Change the data attached to a body membership in the body you got this permission from"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete_member",
    object: "body",
    description: "Delete the membership status of any member in any body. Use the local permission for this if possible"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "delete_member",
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
    object: "member",
    description: "View information about all members in the body. This does not allow you to perform a members listing, you might however hold the list:body_memberships permission to perform a members listing of the members in the body"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "member",
    description: "Create members to any body in the system, even if you are not member in that body"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "create",
    object: "member",
    description: "Create members the body that you got this permission from."
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

  # User permissions
  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "user",
    description: "Remove an account from the system. Don't assign this as any member can delete his own account anyways."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "delete",
    object: "user",
    description: "Delete any member in your body from the system. This allows to also delete members that are in other bodies and have a quarrel in that one body with the board admin, so be careful in granting this permission. The member can delete his own profile anyways"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update_active",
    object: "user",
    description: "Allows to suspend or activate any user in the system"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "update_active",
    object: "user",
    description: "Allows to suspend or activate users that are member in the body that you got this permission from"
  })

  # Recruitment campaigns
  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "campaign",
    description: "View all campaigns in the system, no matter if active or not."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "campaign",
    description: "Create recruitment campaigns through which users can sign into the system."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update",
    object: "campaign",
    description: "Edit recruitment campaigns"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "campaign",
    description: "Delete a recruitment campaign"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "manage_event",
    object: "agora",
    description: "Create, edit and delete Agora statutory events."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "manage_event",
    object: "epm",
    description: "Create, edit and delete EPM statutory events."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "see_applications",
    object: "agora",
    description: "See all applications for Agora statutory events."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "see_applications",
    object: "epm",
    description: "See all applications for EPM statutory events."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "accept_applications",
    object: "agora",
    description: "Accept or reject applications for Agora statutory events. Would be useful for Chair Team."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "accept_applications",
    object: "epm",
    description: "Accept or reject applications for EPM statutory events. Would be useful for CD."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "manage_applications",
    object: "agora",
    description: "Set paid, cancelled or attended status for Agora statutory events. Would be useful for incoming organizers."
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "manage_applications",
    object: "epm",
    description: "Set paid, cancelled or attended status for EPM statutory events. Would be useful for incoming organizers."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "approve_members",
    object: "agora",
    description: "Approve participants and set participant types and statuses for specific boards for Agora statutory events. Would be useful for board members."
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "approve_members",
    object: "epm",
    description: "Approve participants and set participant types and statuses for specific boards for EPM statutory events. Would be useful for board members."
  })
end


# Create test-data so it's possible to experiment with the api without having to boot up the whole system
if Mix.env() == :dev && Repo.all(Member) == [] && !dump do
  Repo.insert!(%Omscore.Registration.Campaign{
    name: "Default recruitment campaign",
    url: "default",
    active: true,
    description_short: "Signup to our app!",
    description_long: "Really, sign up to our app!",
    activate_user: true,
  })

  Repo.insert!(%User{
    name: "admin",
    email: "admin@aegee.org",
    active: true,
    superadmin: true,
    id: 1
  } |> User.changeset(%{password: "admin1234"}))

  # By manually using ids we need to update the primary key sequence to not run into random errors later on
  qry = "SELECT setval('users_id_seq', (SELECT MAX(id) from \"users\"));"
  Ecto.Adapters.SQL.query!(Repo, qry, [])


  {:ok, _} = Members.create_member(%{about_me: "I am a microservice. I have a user account so the system can access itself from within, don't delete me.", address: "Europe", date_of_birth: ~D[2010-04-17], first_name: "Microservice", gender: "machine", last_name: "Microservice", phone: "+123456789", user_id: 1})
end

if Repo.all(Permission) == [] && dump do
  {:ok, qry} = File.read("dumps/dump.sql")
  qry
  |> String.split("\n", trim: true)
  |> Enum.map(fn(x) -> 
    Ecto.Adapters.SQL.query!(Repo, x, [])
  end)
end
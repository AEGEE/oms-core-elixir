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

# Create test-data so it's possible to experiment with the api without having to boot up the whole system
if Mix.env() == :dev && Repo.all(Member) == [] do
  {:ok, _member} = Members.create_member(1, %{about_me: "some about_me", address: "some address", date_of_birth: ~D[2010-04-17], first_name: "some first_name", gender: "some gender", last_name: "some last_name", phone: "+1212345678"})
  {:ok, body} = Core.create_body(%{address: "some address", description: "some description", email: "some email", legacy_key: "some legacy_key", name: "some name", phone: "some phone"})
  {:ok, _circle} = Core.create_circle(%{description: "some description", joinable: true, name: "some name"}, body)
  {:ok, token, _} = Omscore.Guardian.encode_and_sign(%{id: 1}, %{name: "some name", email: "some@email.com", superadmin: true}, token_type: "access", ttl: {100, :weeks})
  IO.inspect("Use this token with superadmin access if you want to test the api:")
  IO.inspect(token)
end

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
    object: "free_circle",
    description: "View free circles",
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
    object: "free_circle",
    description: "Update any free circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete",
    object: "free_circle",
    description: "Delete any free circle, even those that you are not in a circle_admin position in. Should only be assigned in case of an abandoned toplevel circle as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "view_members",
    object: "free_circle",
    description: "View members of any free circle, even those you are not member of. Should only be given to very trusted people as this way big portions of the members database can be accessed directly"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "update_members",
    object: "free_circle",
    description: "Update membership details of members of any free circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "delete_members",
    object: "free_circle",
    description: "Delete any member from any free circle, even those that you are not in a circle_admin position in or even have member status. Should never be assigned as circle_admins automatically get this permission"
  })

  Repo.insert!(%Permission{
    scope: "global", 
    action: "join",
    object: "free_circle",
    description: "Allows to join free circles which are joinable. Non-joinable circles can never be joined",
    always_assigned: true
  })
end
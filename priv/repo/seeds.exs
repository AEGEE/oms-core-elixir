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
alias Omscore.Repo

if Repo.all(Permission) == [] do
  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "circle",
    description: "Creating a free floating circle"
  })

  Repo.insert!(%Permission{
    scope: "local",
    action: "create",
    object: "circle",
    description: "Creating a circle inside a body"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "assign",
    object: "circle_permissions",
    description: "Decide which circle will infer which permissions"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "create",
    object: "permission",
    description: "Create new permission objects which haven't been in the system yet, usually only good for microservices"
    })

  Repo.insert!(%Permission{
    scope: "global",
    action: "view",
    object: "members",
    description: "View all members"
  })

  Repo.insert!(%Permission{
    scope: "global",
    action: "approve",
    object: "join_request",
    description: "Approve a join request to a body by a user"
  })

end
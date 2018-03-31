defmodule OmscoreWeb.Router do
  use OmscoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OmscoreWeb do
    pipe_through :api

    resources "/permissions", PermissionController, except: [:new, :edit]
    resources "/bodies", BodyController, except: [:new, :edit]
    resources "/circles", CircleController, except: [:new, :edit]
    resources "/members", MemberController, except: [:new, :edit]
    resources "/join_requests", JoinRequestController, except: [:new, :edit]
    resources "/circle_memberships", CircleMembershipController, except: [:new, :edit]

  end
end

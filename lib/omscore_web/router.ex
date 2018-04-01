defmodule OmscoreWeb.Router do
  use OmscoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OmscoreWeb do
    pipe_through :api

    resources "/permissions", PermissionController, except: [:new, :edit]
    resources "/bodies", BodyController, except: [:new, :edit] do
      resources "/join_requests", JoinRequestController, except: [:new, :edit]
      # TODO add bound circle routes
    end
    resources "/circles", CircleController, except: [:new, :edit]
    resources "/members", MemberController, except: [:new, :edit]
  end
end

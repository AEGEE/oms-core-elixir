defmodule OmscoreWeb.Router do
  use OmscoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorize do
    plug OmscoreWeb.AuthorizePlug
    plug OmscoreWeb.MemberFetchPlug
    plug OmscoreWeb.PermissionFetchPlug
  end

  pipeline :fetch_body do
    plug OmscoreWeb.BodyFetchPlug
  end

  scope "/api", OmscoreWeb do
    pipe_through :api

    resources "/bodies", BodyController, except: [:new, :edit] do
      resources "/join_requests", JoinRequestController, except: [:new, :edit]
      # TODO add bound circle router
    end
    resources "/members", MemberController, except: [:new, :edit]
  end

  scope "/api", OmscoreWeb do
    pipe_through [:api, :authorize]
    resources "/permissions", PermissionController, except: [:new, :edit]

    get "/circles", CircleController, :index
    post "/circles", CircleController, :create
    get "/circles/:id", CircleController, :show
    put "/circles/:id", CircleController, :update
    delete "/circles/:id", CircleController, :delete
    put "/circles/:id/parent", CircleController, :put_parent
    get "/circles/:id/members", CircleController, :show_members
    post "/circles/:id/members", CircleController, :join_circle
    put "/circles/:id/members/:membership_id", CircleController, :update_circle_membership
    delete "/circles/:id/members/:membership_id", CircleController, :delete_circle_membership
  end

  scope "/api/body/:body_id", OmscoreWeb, as: :body do
    pipe_through [:api, :authorize, :fetch_body]

    get "/circles", CircleController, :index_bound
    post "/circles", CircleController, :create_bound
    get "/circles/:id", CircleController, :show
    put "/circles/:id", CircleController, :update
    delete "/circles/:id", CircleController, :delete
    put "/circles/:id/parent", CircleController, :put_parent
    get "/circles/:id/members", CircleController, :show_members
  end
end

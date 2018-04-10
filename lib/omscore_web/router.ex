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

  pipeline :fetch_circle do
    plug OmscoreWeb.CircleFetchPlug
  end

  scope "/api", OmscoreWeb do
    pipe_through :api

    resources "/members", MemberController, except: [:new, :edit, :index]
  end

  scope "/api/bodies/:body_id", OmscoreWeb, as: :body do
    pipe_through [:api]
    resources "/join_requests", JoinRequestController, except: [:new, :edit, :show, :index, :create]
  end

  scope "/api", OmscoreWeb do
    pipe_through [:api, :authorize]
    resources "/permissions", PermissionController, except: [:new, :edit]
    get "/my_permissions", PermissionController, :index_permissions

    get "/circles", CircleController, :index
    post "/circles", CircleController, :create

    get "/bodies", BodyController, :index
    post "/bodies", BodyController, :create

    get "/members", MemberController, :index
  end

  scope "/api/circles/:circle_id", OmscoreWeb do
    pipe_through [:api, :authorize, :fetch_circle]

    get "/", CircleController, :show
    put "/", CircleController, :update
    delete "/", CircleController, :delete
    put "/parent", CircleController, :put_parent
    get "/members", CircleController, :show_members
    post "/members", CircleController, :join_circle
    put "/members/:membership_id", CircleController, :update_circle_membership
    delete "/members/:membership_id", CircleController, :delete_circle_membership
    get "/my_permissions", CircleController, :index_my_permissions
    get "/permissions", CircleController, :index_permissions
    put "/permissions", CircleController, :put_permissions
  end

  scope "/api/bodies/:body_id", OmscoreWeb, as: :body do
    pipe_through [:api, :authorize, :fetch_body]

    get "/circles", CircleController, :index_bound
    post "/circles", CircleController, :create_bound

    get "/", BodyController, :show
    put "/", BodyController, :update
    delete "/", BodyController, :delete
    get "/members", BodyController, :show_members
    delete "/members/:membership_id", BodyController, :delete_member
    delete "/members", BodyController, :delete_myself
    post "/members", JoinRequestController, :create

    get "/join_requests", JoinRequestController, :index
    get "/join_requests/:id", JoinRequestController, :show
    post "/join_requests/:id", JoinRequestController, :process
  end
end

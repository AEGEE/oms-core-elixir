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

  pipeline :authorize_bare do
    plug OmscoreWeb.AuthorizePlug
  end

  pipeline :fetch_body do
    plug OmscoreWeb.BodyFetchPlug
  end

  pipeline :fetch_circle do
    plug OmscoreWeb.CircleFetchPlug
  end

  pipeline :fetch_member do
    plug OmscoreWeb.MemberPermissionPlug
  end

  # Public requests without api authentication
  scope "/", OmscoreWeb do
    pipe_through [:api]

    post "/login", LoginController, :login
    post "/renew", LoginController, :renew_token
    get "/user_existence", LoginController, :check_user_existence
    post "/password_reset", LoginController, :password_reset
    post "/confirm_reset_password/:reset_url", LoginController, :confirm_password_reset

    get "/campaigns", CampaignController, :index
    get "/campaigns/:campaign_url", CampaignController, :show
    post "/campaigns/:campaign_url", CampaignController, :submit
    post "/confirm_mail/:confirmation_url", CampaignController, :confirm_mail
  end

  # For user-based request, don't fetch anything from the db but just validate the token
  scope "/", OmscoreWeb do
    pipe_through [:api, :authorize_bare]

    get "/user", LoginController, :user_data
    put "/user", LoginController, :edit_user
    post "/logout", LoginController, :logout
    post "/logout/all", LoginController, :logout_all
  end

  # More complex requests require the requesting user to have a member object so permissions can be granted
  scope "/", OmscoreWeb do
    pipe_through [:api, :authorize]
    resources "/permissions", PermissionController, except: [:new, :edit]
    get "/my_permissions", PermissionController, :index_permissions

    get "/circles", CircleController, :index
    post "/circles", CircleController, :create

    get "/bodies", BodyController, :index
    post "/bodies", BodyController, :create

    get "/members", MemberController, :index
    post "/members", MemberController, :create

    # Compatibility request to the old core
    post "/tokens/user", MemberController, :show_by_token

    delete "/user/:user_id", LoginController, :delete_user

    get "/backend_campaigns", CampaignController, :index_full
    post "/backend_campaigns", CampaignController, :create
    get "/backend_campaigns/:campaign_id", CampaignController, :show_full
    put "/backend_campaigns/:id", CampaignController, :update
    delete "/backend_campaigns/:id", CampaignController, :delete
  end

  # Operating on the member, permissions based on the bodies he is part in will be granted
  scope "/members/:member_id", OmscoreWeb do
    pipe_through [:api, :authorize, :fetch_member]

    get "/", MemberController, :show
    put "/", MemberController, :update
    get "/my_permissions", MemberController, :index_permissions
  end

  # In case the circle is bound, additional permissions through the body it is bound to will be granted
  scope "/circles/:circle_id", OmscoreWeb do
    pipe_through [:api, :authorize, :fetch_circle]

    get "/", CircleController, :show
    put "/", CircleController, :update
    delete "/", CircleController, :delete
    put "/parent", CircleController, :put_parent
    get "/members", CircleController, :show_members
    post "/members", CircleController, :join_circle
    post "/add_member", CircleController, :add_to_circle
    delete "/members", CircleController, :delete_myself
    put "/members/:membership_id", CircleController, :update_circle_membership
    delete "/members/:membership_id", CircleController, :delete_circle_membership
    get "/my_permissions", CircleController, :index_my_permissions
    get "/permissions", CircleController, :index_permissions
    put "/permissions", CircleController, :put_permissions
  end

  # Body-based request add permissions the user has in the body
  scope "/bodies/:body_id", OmscoreWeb, as: :body do
    pipe_through [:api, :authorize, :fetch_body]

    get "/circles", CircleController, :index_bound
    post "/circles", CircleController, :create_bound

    get "/", BodyController, :show
    put "/", BodyController, :update
    delete "/", BodyController, :delete
    get "/members", BodyController, :show_members
    put "/members/:membership_id", BodyController, :update_member
    delete "/members/:membership_id", BodyController, :delete_member
    delete "/members", BodyController, :delete_myself
    post "/members", JoinRequestController, :create
    get "/my_permissions", BodyController, :my_permissions

    get "/join_requests", JoinRequestController, :index
    get "/join_requests/:id", JoinRequestController, :show
    post "/join_requests/:id", JoinRequestController, :process
  end
end

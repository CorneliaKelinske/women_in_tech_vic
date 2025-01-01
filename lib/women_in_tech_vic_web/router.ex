defmodule WomenInTechVicWeb.Router do
  use WomenInTechVicWeb, :router

  import WomenInTechVicWeb.UserAuth,
    only: [
      redirect_if_user_is_authenticated: 2,
      require_authenticated_user: 2,
      fetch_current_user: 2
    ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WomenInTechVicWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WomenInTechVicWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", WomenInTechVicWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:women_in_tech_vic, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WomenInTechVicWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", WomenInTechVicWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    get "/", PageController, :home

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{WomenInTechVicWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", WomenInTechVicWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{WomenInTechVicWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/events", EventLive.Index, :index
      live "/events/create", EventLive.Index, :create
      live "/events/:id", EventLive.Show, :show
      live "/profiles/:id", ProfileLive.Show, :show
      live "/profiles/:id/edit", ProfileLive.Show, :edit
      live "/profiles/:id/create", ProfileLive.Create, :create
      live "/members", MemberLive.Index, :index
      live "/home", HomeLive
    end
  end

  scope "/", WomenInTechVicWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin, on_mount: {WomenInTechVicWeb.UserAuth, :admin} do
      live "/events/:id/edit", EventLive.Edit
      live "/users", UserLive.Index
    end
  end

  scope "/", WomenInTechVicWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{WomenInTechVicWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/contact", ContactLive, :new
    end
  end
end

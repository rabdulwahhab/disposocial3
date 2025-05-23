defmodule Disposocial3Web.Router do
  use Disposocial3Web, :router

  import Disposocial3Web.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Disposocial3Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Disposocial3Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", Disposocial3Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:disposocial3, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Disposocial3Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", Disposocial3Web do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{Disposocial3Web.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      live "/dispos/new", DispoLive.Form, :new
      live "/dispos/:id", DispoLive.Show, :show
      live "/dispos/:id/edit", DispoLive.Form, :edit
      # live "/posts", PostLive.Index, :index
      # live "/posts/new", PostLive.Form, :new
      # live "/posts/:id", PostLive.Show, :show
      # live "/posts/:id/edit", PostLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", Disposocial3Web do
    pipe_through [:browser]


    live_session :current_user,
      on_mount: [{Disposocial3Web.UserAuth, :mount_current_scope}] do
      live "/discover", DispoLive.Index, :index
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end

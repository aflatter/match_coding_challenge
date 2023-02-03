defmodule MatchWeb.Router do
  use MatchWeb, :router

  import MatchWeb.ApiAuth
  import MatchWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MatchWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_user_by_api_token
  end

  scope "/", MatchWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # API routes that require auth.
  scope "/api", MatchWeb do
    pipe_through [:api, :require_authenticated_token]

    resources "/orders", OrderController, only: [:create]
    resources "/products", ProductController, except: [:new, :edit]
    resources "/users", UserController, except: [:create, :new, :edit]
  end

  # API routes that do NOT require authentication.
  scope "/api", MatchWeb do
    pipe_through [:api]

    resources "/users", UserController, only: [:create]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:match, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MatchWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MatchWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", MatchWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/api_tokens", ApiTokenController, only: [:create, :index]
    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
  end

  scope "/", MatchWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end

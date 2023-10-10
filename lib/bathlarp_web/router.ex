defmodule BathLARPWeb.Router do
  use BathLARPWeb, :router
  use Pow.Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
    plug BathLARPWeb.APIAuthPlug, otp_app: :bathlarp
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: BathLARPWeb.APIAuthErrorHandler
  end

  scope "/v1", BathLARPWeb.V1, as: :api_v1 do
    pipe_through :api

    resources "/accounts", AccountsController, only: [:create] do
      resources "/confirmation", AccountConfirmationController, singleton: true, only: [:create]
    end

    resources "/session", SessionController, singleton: true, only: [:create, :delete, :update]
  end

  scope "/v1", BathLARPWeb.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]

    # Add protected endpoints here once they exist.

    resources "/ping", PingController, singleton: true, only: [:show]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bathlarp, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BathLARPWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

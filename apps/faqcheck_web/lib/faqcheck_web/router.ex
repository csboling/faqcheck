defmodule FaqcheckWeb.Router do
  use FaqcheckWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(SetLocale,
      gettext: FaqcheckWeb.Gettext,
      default_locale: "en"
    )
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FaqcheckWeb do
    pipe_through :browser
    get "/", PageController, :dummy
    get "/manage", ManageController, :dummy
    get "/search", SearchController, :dummy
  end

  scope "/:locale", FaqcheckWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/manage", ManageController, :index
    get "/search", SearchController, :index
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FaqcheckWeb.Telemetry
    end
  end
end

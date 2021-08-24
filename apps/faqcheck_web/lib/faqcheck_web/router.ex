defmodule FaqcheckWeb.Router do
  use FaqcheckWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

  import FaqcheckWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    # plug :put_secure_browser_headers,
    #   %{"content-security-policy" => "default-src 'self';"}
    plug :fetch_current_user
    plug :put_root_layout, {FaqcheckWeb.LayoutView, :root}
    plug(SetLocale,
      gettext: FaqcheckWeb.Gettext,
      default_locale: "en")
    plug FaqcheckWeb.Plugs.Breadcrumb
  end

  pipeline :skip_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
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

    scope "/:locale" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FaqcheckWeb.Telemetry
    end
  end

  # scope "/" do
  #   pipe_through :browser
  # end

  scope "/", FaqcheckWeb do
    pipe_through :browser
    get "/", PageController, :dummy

    get "/microsoft-callback", OidcController, :microsoft_callback
    get "/google-callback", OidcController, :microsoft_callback

  end

  scope "/", FaqcheckWeb do
    pipe_through :api

    post "/microsoft/messages", MicrosoftTeamsController, :message
  end

  scope "/:locale" do
    pipe_through :browser
    pow_routes()
    pow_assent_routes()
  end

  scope "/" do
    pipe_through :browser
    pow_routes()
    pow_assent_routes()
  end

  scope "/" do
    pipe_through :skip_csrf_protection
    pow_assent_authorization_post_callback_routes()
  end

  scope "/:locale", FaqcheckWeb do
    pipe_through :browser
    get "/", PageController, :index

    get "/microsoft-callback", OidcController, :microsoft_callback
    get "/google-callback", OidcController, :microsoft_callback

    scope "/help" do
      get "/", HelpController, :index
      get "/microsoft", HelpController, :microsoft
    end

    scope "/" do
      resources "/facilities", FacilityController, as: :facility do
      	get "/history", FacilityController, :history, as: :history
        resources "/feedback", FeedbackController, as: :feedback
      end

      scope "/live" do
	scope "/facilities" do
	  live "/", FacilitiesLive
        end
      end
    end

    scope "/" do
      pipe_through :require_authenticated_user

      get "/manage", ManageController, :index

      resources "/organizations", OrganizationController do
	get "/history", OrganizationController, :history, as: :history
      end

      scope "/live" do
	scope "/facilities" do
	  live "/upload", FacilityUploadLive
	  live "/select-import", FacilityImportSelectLive
	  live "/import", FacilityImportLive
	end
      end
    end

    ## Authentication routes
    scope "/user" do
      scope "/" do
        pipe_through :redirect_if_user_is_authenticated

        get "/register", UserRegistrationController, :new
        post "/register", UserRegistrationController, :create
        get "/log_in", UserSessionController, :new
        post "/log_in", UserSessionController, :create
        get "/reset_password", UserResetPasswordController, :new
        post "/reset_password", UserResetPasswordController, :create
        get "/reset_password/:token", UserResetPasswordController, :edit
        put "/reset_password/:token", UserResetPasswordController, :update
      end

      scope "/" do
        pipe_through :require_authenticated_user

        get "/settings", UserSettingsController, :edit
        put "/settings", UserSettingsController, :update
        get "/settings/confirm_email/:token", UserSettingsController, :confirm_email
      end

      scope "/" do
        delete "/log_out", UserSessionController, :delete
        get "/confirm", UserConfirmationController, :new
        post "/confirm", UserConfirmationController, :create
        get "/confirm/:token", UserConfirmationController, :confirm
      end
    end
  end
end

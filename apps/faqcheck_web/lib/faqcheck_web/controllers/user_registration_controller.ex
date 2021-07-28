defmodule FaqcheckWeb.UserRegistrationController do
  use FaqcheckWeb, :controller

  alias Faqcheck.Accounts
  alias Faqcheck.Accounts.User
  alias FaqcheckWeb.UserAuth

  def title(action) do
    case action do
      :new -> gettext "Register a user account"
      :create -> gettext "Error registering account"
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params, "locale" => locale}) do
    case Accounts.register_user(user_params) do
      {:ok, %{model: user}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, locale, &1)
          )

        conn
        |> put_flash(:info, gettext("User created successfully."))
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end

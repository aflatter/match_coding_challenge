defmodule MatchWeb.UserSettingsController do
  use MatchWeb, :controller

  alias Match.Accounts
  alias MatchWeb.UserAuth

  plug :assign_username_and_password_changesets

  def edit(conn, _params) do
    render(conn, :edit)
  end

  def update(conn, %{"action" => "update_username"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_username(user, password, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(
          :info,
          "Username changed successfully."
        )
        |> redirect(to: ~p"/users/settings")

      {:error, changeset} ->
        render(conn, :edit, username_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, ~p"/users/settings")
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, :edit, password_changeset: changeset)
    end
  end

  defp assign_username_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:username_changeset, Accounts.change_user_username(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end
end

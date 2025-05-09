defmodule WomenInTechVicWeb.UserSessionControllerTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, unconfirmed_user: 1]
  alias WomenInTechVic.Support.AccountsFixtures

  @valid_password AccountsFixtures.valid_user_password()
  setup [:user, :unconfirmed_user]

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => @valid_password}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) === ~p"/home"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/events")
      response = html_response(conn, 200)
      assert response =~ ~p"/users/settings"
      assert response =~ ~p"/users/log_out"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => @valid_password,
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_women_in_tech_vic_web_user_remember_me"]
      assert redirected_to(conn) === ~p"/home"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => @valid_password
          }
        })

      assert redirected_to(conn) === "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following password update", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/log_in", %{
          "_action" => "password_updated",
          "user" => %{
            "email" => user.email,
            "password" => @valid_password
          }
        })

      assert redirected_to(conn) === ~p"/users/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to user confirmation page when user is not confirmed", %{
      conn: conn,
      unconfirmed_user: unconfirmed_user
    } do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => unconfirmed_user.email, "password" => @valid_password}
        })

      assert redirected_to(conn) === ~p"/users/confirm"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Please confirm your account"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) === "Invalid email or password"
      assert redirected_to(conn) === ~p"/users/log_in"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) === ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) === ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end

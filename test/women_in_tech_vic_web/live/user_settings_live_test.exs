defmodule WomenInTechVicWeb.UserSettingsLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, subscription: 1, user_2: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Support.AccountsFixtures

  @valid_password AccountsFixtures.valid_user_password()
  @unique_user_email AccountsFixtures.unique_user_email()

  setup [:user, :user_2, :subscription]

  describe "Settings page" do
    test "renders settings page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn, user: user} do
      %{password: @valid_password}
      %{conn: log_in_user(conn, user), user: user, password: @valid_password}
    end

    test "updates the user email", %{conn: conn, password: password, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "user" => %{"email" => @unique_user_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Accounts.get_user_by_email(user.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "user" => %{"email" => user.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      user = AccountsFixtures.user_fixture(%{password: @valid_password})
      %{conn: log_in_user(conn, user), user: user, password: @valid_password}
    end

    test "updates the user password", %{conn: conn, user: user, password: password} do
      new_password = AccountsFixtures.valid_user_password()

      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "user" => %{
            "email" => user.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) === ~p"/users/settings"

      assert get_session(new_password_conn, :user_token) !== get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn, user: user} do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_update_email_instructions(
            %{user | email: @unique_user_email},
            user.email,
            url
          )
        end)

      %{conn: log_in_user(conn, user), token: token, email: @unique_user_email, user: user}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/settings"
      assert %{"info" => message} = flash
      assert message === "Email changed successfully."
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/settings"
      assert %{"error" => message} = flash
      assert message === "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/settings"
      assert %{"error" => message} = flash
      assert message === "Email change link is invalid or it has expired."
      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/users/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => message} = flash
      assert message === "You must log in to access this page."
    end
  end

  describe "delete account" do
    test "deletes account and redirects user to landing page when correct password is provided",
         %{conn: conn, user: user} do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/settings")

      assert html =~ "Delete Account"

      assert lv
             |> form("#delete_account_form", %{"password" => @valid_password})
             |> render_submit

      assert_redirected(lv, "/")
      assert {:error, %ErrorMessage{code: :not_found}} = Accounts.find_user(%{id: user.id})
    end

    test "provides error when wrong password is given", %{conn: conn, user: user} do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/settings")

      assert html =~ "Delete Account"

      assert lv
             |> form("#delete_account_form", %{"password" => "Invalid"})
             |> render_submit

      refute_redirected(lv, "/")
      assert {:ok, ^user} = Accounts.find_user(%{id: user.id})
    end
  end

  describe "update subscriptions" do
    test "removes subscriptions from user's subscriptions", %{
      conn: conn,
      user: user,
      subscription: subscription
    } do
      assert [^subscription] = Accounts.all_subscriptions(%{user_id: user.id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/settings")

      assert html =~ "Update your subscriptions"

      assert lv
             |> form("#subscriptions_form", %{"event" => false})
             |> render_submit

      assert [] = Accounts.all_subscriptions(%{user_id: user.id})
    end

    test "adds subscriptions", %{conn: conn, user_2: user_2} do
      assert [] = Accounts.all_subscriptions(%{user_id: user_2.id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/users/settings")

      assert html =~ "Update your subscriptions"

      assert lv
             |> form("#subscriptions_form", %{"event" => true})
             |> render_submit

      assert [:event] = Accounts.find_user_subscription_types(user_2.id)
    end
  end
end

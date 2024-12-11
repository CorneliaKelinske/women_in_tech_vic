defmodule WomenInTechVicWeb.UserConfirmationLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, unconfirmed_user: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Repo
  alias WomenInTechVic.Support.AccountsFixtures

  setup [:user, :unconfirmed_user]

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, unconfirmed_user: unconfirmed_user} do
      token =
        AccountsFixtures.extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(unconfirmed_user, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/users/log_in")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "User confirmed successfully"

      assert Accounts.get_user!(unconfirmed_user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) === []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "User confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_user(unconfirmed_user)

      {:ok, lv, _html} = live(conn, ~p"/users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{
      conn: conn,
      unconfirmed_user: unconfirmed_user
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "User confirmation link is invalid or it has expired"

      refute Accounts.get_user!(unconfirmed_user.id).confirmed_at
    end
  end
end

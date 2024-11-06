defmodule WomenInTechVicWeb.UserLive.IndexTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1]

  alias WomenInTechVic.Accounts

  setup [:user, :user_2]

  describe "Index page" do
    test "renders page to logged in Admin user", %{conn: conn, user: user, user_2: user_2} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users")

      assert html =~ "All Users"
      assert html =~ "#{user.username}"
      assert html =~ "#{user_2.username}"
      assert html =~ "hero-trash"
    end

    test "admin user can delete users", %{conn: conn, user: user, user_2: user_2} do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users")

      assert html =~ "All Users"
      assert html =~ "#{user.username}"
      assert html =~ "#{user_2.username}"
      assert html =~ "hero-trash"

      lv
      |> element("button[phx-click=delete-user][phx-value-id='#{user_2.id}']")
      |> render_click()

      assert {
               :error,
               %ErrorMessage{
                 code: :not_found,
                 message: "no records found"
               }
             } = Accounts.find_user(%{id: user_2.id})
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/users")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects non-admin users", %{conn: conn, user_2: user_2} do
      assert {:error, redirect} =
               conn
               |> log_in_user(user_2)
               |> live(~p"/users")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/"
      assert %{"error" => "Access denied."} = flash
    end
  end
end

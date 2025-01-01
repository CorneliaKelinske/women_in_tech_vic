defmodule WomenInTechVicWeb.HomeLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  setup :user

  describe "Home page" do
    test "renders page for logged in users", %{
      conn: conn,
      user: user
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/home")

      assert html =~ "Welcome Home!"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/members")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

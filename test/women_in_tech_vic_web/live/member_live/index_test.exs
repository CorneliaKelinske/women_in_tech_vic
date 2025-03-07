defmodule WomenInTechVicWeb.MemberLive.IndexTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1]

  setup [:user, :user_2]

  describe "Index page" do
    test "renders page listing users for logged in users", %{
      conn: conn,
      user: user,
      user_2: user_2
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/members")

      assert html =~ "Our Members"
      assert html =~ "#{user.username}"
      assert html =~ "#{user_2.username}"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/members")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

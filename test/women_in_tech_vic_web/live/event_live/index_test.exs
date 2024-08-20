defmodule WomenInTechVic.EventLive.IndexTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1]

  setup [:user, :online_event]

  describe "Index page" do
    test "renders settings page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      assert html =~ "meet.google"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/events")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

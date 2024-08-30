defmodule WomenInTechVicWeb.ContactLiveTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  setup [:user]

  describe "Contact form" do
    test "renders contact form", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/contact")

      assert html =~ "Contact the Admin"
      assert html =~ "Your email"

    end

    test "autofills email for logged in user", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/contact")

      assert html =~ user.email
    end
  end
end

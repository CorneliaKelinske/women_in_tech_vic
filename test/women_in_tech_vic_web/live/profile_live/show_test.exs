defmodule WomenInTechVicWeb.ProfileLive.ShowTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  setup [:user]

  describe "Show profile page" do
    test "renders show profile page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/profiles/show/#{user.username}")

      assert html =~ "User Profile"
    end
  end
end

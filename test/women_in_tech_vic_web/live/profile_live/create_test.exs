defmodule WomenInTechVicWeb.ProfileLive.CreateTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  setup [:user]

  describe "Create profile page" do
    test "renders create profile page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/profiles/create/#{user.username}")

      assert html =~ "Create Your User Profile"
    end
  end
end

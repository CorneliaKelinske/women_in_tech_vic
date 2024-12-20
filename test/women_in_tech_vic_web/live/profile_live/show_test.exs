defmodule WomenInTechVicWeb.ProfileLive.ShowTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1, profile: 1]

  setup [:user, :user_2, :profile]

  describe "Show profile page" do
    test "renders show profile page", %{conn: conn, user: user, profile: profile} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/profiles/show/#{user.id}")

      assert html =~ "#{user.username}&#39;s Profile"
      assert html =~ "LinkedIn"
      assert html =~ "#{profile.linked_in}"
    end

    test "redirects home when profile owner cannot be fetched", %{conn: conn, user: user} do
      assert {:error,
              {:live_redirect,
               %{to: "/", flash: %{"error" => "Something went wrong. Please try again"}}}} =
               conn
               |> log_in_user(user)
               |> live(~p"/profiles/show/#{user.id + 11}")
    end

    test "returns show page with Nothing to See info if profile doesn't exist yet", %{
      conn: conn,
      user_2: user_2
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/profiles/show/#{user_2.id}")

      assert html =~ "#{user_2.username}&#39;s Profile"
      assert html =~ "Nothing to see yet!"
    end
  end
end

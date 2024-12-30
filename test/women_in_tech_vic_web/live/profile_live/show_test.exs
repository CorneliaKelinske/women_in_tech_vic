defmodule WomenInTechVicWeb.ProfileLive.ShowTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1, profile: 1]

  alias WomenInTechVic.Accounts

  setup [:user, :user_2, :profile]

  describe "Show profile page" do
    test "renders show profile page including edit button to profile owner", %{
      conn: conn,
      user: user,
      profile: profile
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/profiles/#{user.id}")

      assert html =~ "#{user.username}&#39;s Profile"
      assert html =~ "LinkedIn"
      assert html =~ "#{profile.linked_in}"
      assert has_element?(lv, "button", "Edit Profile")
    end

    test "redirects home when profile owner cannot be fetched", %{conn: conn, user: user} do
      assert {:error,
              {:live_redirect,
               %{to: "/", flash: %{"error" => "Something went wrong. Please try again"}}}} =
               conn
               |> log_in_user(user)
               |> live(~p"/profiles/#{user.id + 11}")
    end

    test "returns show page with Nothing to See info if profile doesn't exist yet", %{
      conn: conn,
      user_2: user_2
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/profiles/#{user_2.id}")

      assert html =~ "#{user_2.username}&#39;s Profile"
      assert html =~ "Nothing to see yet!"
    end
  end

  test "shows delete button to profile owner and profile owner can delete profile", %{
    conn: conn,
    user: user,
    profile: profile
  } do
    assert {:ok, ^profile} = Accounts.find_profile(%{id: profile.id})

    {:ok, lv, html} =
      conn
      |> log_in_user(user)
      |> live(~p"/profiles/#{user.id}")

    assert html =~ "#{user.username}&#39;s Profile"
    assert html =~ "hero-trash"

    lv
    |> element("button[phx-click=delete_profile][phx-value-id='#{profile.id}']")
    |> render_click()

    assert {
             :error,
             %ErrorMessage{
               code: :not_found,
               message: "no records found"
             }
           } = Accounts.find_profile(%{id: profile.id})
  end

  test "does not show the delete and edit buttons to other users", %{
    conn: conn,
    user_2: user_2,
    user: user
  } do
    {:ok, lv, html} =
      conn
      |> log_in_user(user_2)
      |> live(~p"/profiles/#{user.id}")

    assert html =~ "#{user.username}&#39;s Profile"
    refute html =~ "hero-trash"
    refute has_element?(lv, "button", "Edit Profile")
  end

  test "other user would not be able to use the button to delete another user's profile", %{
    conn: conn,
    user_2: user_2,
    user: user,
    profile: profile
  } do
    {:ok, lv, html} =
      conn
      |> log_in_user(user_2)
      |> live(~p"/profiles/#{user.id}")

    assert html =~ "#{user.username}&#39;s Profile"

    assert {:ok, ^profile} = Accounts.find_profile(%{id: profile.id})

    assert lv
           |> element("button[phx-click=delete_profile][phx-value-id='#{profile.id}']")
           |> render_click() =~ "Could not delete profile"

    assert {:ok, ^profile} = Accounts.find_profile(%{id: profile.id})
  end
end

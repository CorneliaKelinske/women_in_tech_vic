defmodule WomenInTechVicWeb.ProfileLive.CreateTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1, profile: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.Profile

  setup [:user, :user_2, :profile]

  describe "Create profile page" do
    test "renders create profile page and creates new profile when none exists", %{
      conn: conn,
      user_2: user_2
    } do
      user_id = user_2.id

      assert {:error, %ErrorMessage{code: :not_found}} =
               Accounts.find_profile(%{user_id: user_id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/profiles/#{user_2.id}/create")

      assert html =~ "Create Your User Profile"

      profile_picture =
        file_input(lv, "#new-profile-form", :image, [
          %{
            last_modified: 1_594_171_879_000,
            name: "test_image.png",
            content: File.read!("test/support/fixtures_and_factories/test_image.png"),
            type: "image/jpeg"
          }
        ])

      assert render_upload(profile_picture, "test_image.png") =~ "100%"

      assert lv
             |> form("#new-profile-form", profile: %{"hobbies" => "coding"})
             |> render_submit()

      assert {:ok, %Profile{user_id: ^user_id, hobbies: "coding"}} =
               Accounts.find_profile(%{user_id: user_id})
    end

    test "redirects users with existing profile", %{conn: conn, user: user} do
      user_id = user.id
      assert {:ok, %Profile{user_id: ^user_id}} = Accounts.find_profile(%{user_id: user_id})

      assert {:error, redirect} =
               conn
               |> log_in_user(user)
               |> live(~p"/profiles/#{user.id}/create")

      assert {:live_redirect, %{to: path}} = redirect
      assert path === ~p"/profiles/#{user.id}"
    end

    test "redirects to home page if something goes wrong during user creation", %{
      conn: conn,
      user_2: user_2
    } do
      user_id = user_2.id

      assert {:error, %ErrorMessage{code: :not_found}} =
               Accounts.find_profile(%{user_id: user_id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/profiles/#{user_2.id}/create")

      assert html =~ "Create Your User Profile"
      assert {:ok, _} = Accounts.delete_user(user_id)

      assert {:error, redirect} =
               lv
               |> form("#new-profile-form", profile: %{"hobbies" => "coding"})
               |> render_submit()

      assert {:live_redirect, %{to: path}} = redirect
      assert path === ~p"/"
    end
  end
end

defmodule WomenInTechVicWeb.EventLive.EditTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.Event

  setup [:user, :user_2, :online_event]

  describe "Edit page" do
    test "renders page with event form to logged in user", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}/edit")

      assert html =~ "Edit Event"
    end

    test "leads back to index page if event does not exit", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      online_event = Map.put(online_event, :id, online_event.id + 100)

      assert {:error,
              {:live_redirect,
               %{to: "/events", flash: %{"error" => "Something went wrong. Please try again"}}}} ===
               conn
               |> log_in_user(user)
               |> live(~p"/events/#{online_event}/edit")
    end

    test "redirects if user is not logged in", %{conn: conn, online_event: online_event} do
      assert {:error, redirect} = live(conn, ~p"/events/#{online_event}/edit")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "redirects non-admin users", %{conn: conn, online_event: online_event, user_2: user_2} do
      assert {:error, redirect} =
               conn
               |> log_in_user(user_2)
               |> live(~p"/events/#{online_event}/edit")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/"
      assert %{"error" => "Access denied."} = flash
    end

    test "admin user can edit an event", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}/edit")

      assert html =~ "Edit Event"

      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})

      assert lv
             |> form("#event-form", event: %{"title" => "updated title"})
             |> render_submit()

      assert {:ok, %Event{title: "updated title"}} = Content.find_event(%{id: online_event.id})
    end
  end
end

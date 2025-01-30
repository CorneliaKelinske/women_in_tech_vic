defmodule WomenInTechVic.EventLive.IndexTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions, only: [assert_email_sent: 0]
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1, subscription: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1]

  alias WomenInTechVic.Content

  setup [:user, :user_2, :online_event, :subscription]

  describe "Index page" do
    test "renders page listing all events", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      refute html =~ "meet.google.com"
      assert html =~ "See details"
      assert html =~ "Create Event"
    end

    test "renders no Event scheduled if no event exists", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      assert {:ok, _} = Content.delete_event(online_event)

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      assert html =~ "No event scheduled"
    end

    test "does not show the Create Event button to non-admin users", %{conn: conn, user_2: user_2} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      refute html =~ "Create Event"
    end

    test "non_admin user would not be able to use the button to delete an event", %{
      conn: conn,
      user_2: user_2,
      online_event: online_event
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"

      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})

      assert lv
             |> element("button[phx-click=delete_event][phx-value-id='#{online_event.id}']")
             |> render_click() =~ "Could not delete event"

      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})
    end

    test "shows delete button to admin, admin can delete events and subscribers get notified", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      assert html =~ "hero-trash"

      lv
      |> element("button[phx-click=delete_event][phx-value-id='#{online_event.id}']")
      |> render_click()

      assert_email_sent()

      assert {
               :error,
               %ErrorMessage{
                 code: :not_found,
                 message: "no records found"
               }
             } = Content.find_event(%{id: online_event.id})
    end

    test "does not show the delete button to non-admin users", %{conn: conn, user_2: user_2} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      refute html =~ "hero-trash"
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/events")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

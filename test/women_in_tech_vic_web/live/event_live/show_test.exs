defmodule WomenInTechVicWeb.EventLive.ShowTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1, user_2: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1, in_person_event: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.Event

  setup [:user, :user_2, :online_event, :in_person_event]

  describe "Show page" do
    test "renders a page with event info", %{conn: conn, user: user, online_event: online_event} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      assert html =~ "meet.google"
      refute html =~ "Show details"
    end

    test "renders a page with event info for in person meetings", %{
      conn: conn,
      user: user,
      in_person_event: in_person_event
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{in_person_event}")

      assert html =~ "Pub around the Corner"
      refute html =~ "Show details"
    end

    test "adds a user to the list of event attendees when RSVP button is clicked", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      online_event_id = online_event.id

      assert {:ok, %Event{id: ^online_event_id, online: true, attendees: []}} =
               Content.find_event(id: online_event.id, preload: :attendees)

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      assert html =~ "RSVP"

      assert lv
             |> element("button[phx-click=\"rsvp\"]")
             |> render_click(%{
               "event_id" => to_string(online_event_id),
               "user_id" => to_string(user.id)
             })

      assert {:ok, %Event{id: ^online_event_id, online: true, attendees: [^user]}} =
               Content.find_event(id: online_event.id, preload: :attendees)
    end

    test "shows different buttons for users that are attending vs not attending", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      online_event_id = online_event.id

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      assert html =~ "I will be there"
      refute html =~ "I changed my mind"

      lv
      |> element("button[phx-click=\"rsvp\"]")
      |> render_click(%{
        "event_id" => to_string(online_event_id),
        "user_id" => to_string(user.id)
      })

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      refute html =~ "I will be there"
      assert html =~ "I changed my mind"
    end

    test "clicking All events button leads back to events index page", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      assert html =~ "All events"

      lv
      |> element("button[phx-click=\"all_events\"]")
      |> render_click()

      assert_redirect(lv, ~p"/events")
    end

    test "redirects if user is not logged in", %{conn: conn, online_event: online_event} do
      assert {:error, redirect} = live(conn, ~p"/events/#{online_event}")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
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
               |> live(~p"/events/#{online_event}")
    end

    test "non_admin user would not be able to use the button to delete an event", %{
      conn: conn,
      user_2: user_2,
      online_event: online_event
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/events/#{online_event}")

      assert html =~ "meet.google"

      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})

      assert lv
             |> element("button[phx-click=delete_event][phx-value-id='#{online_event.id}']")
             |> render_click() =~ "Could not delete event"

      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})
    end

    test "shows delete button to admin and admin can delete events", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      assert {:ok, ^online_event} = Content.find_event(%{id: online_event.id})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events/#{online_event}")

      assert html =~ "meet.google"
      assert html =~ "hero-trash"

      lv
      |> element("button[phx-click=delete_event][phx-value-id='#{online_event.id}']")
      |> render_click()

      assert {
               :error,
               %ErrorMessage{
                 code: :not_found,
                 message: "no records found"
               }
             } = Content.find_event(%{id: online_event.id})
    end

    test "does not show the delete button to non-admin users", %{
      conn: conn,
      user_2: user_2,
      online_event: online_event
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user_2)
        |> live(~p"/events/#{online_event}")

      assert html =~ "meet.google"
      refute html =~ "hero-trash"
    end
  end
end

defmodule WomenInTechVicWeb.EventLive.ShowTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1, in_person_event: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.Event

  setup [:user, :online_event, :in_person_event]

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
               "event_id" => to_string(online_event.id),
               "user_id" => to_string(user.id)
             })

      assert {:ok, %Event{id: ^online_event_id, online: true, attendees: [^user]}} =
               Content.find_event(id: online_event.id, preload: :attendees)
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
  end
end

defmodule WomenInTechVic.EventLive.IndexTest do
  use WomenInTechVicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.Event

  setup [:user, :online_event]

  describe "Index page" do
    test "renders page listing all events", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "Upcoming Events"
      assert html =~ "meet.google"
    end

    test "adds a user to the list of event attendees when RSVP button is clicked", %{
      conn: conn,
      user: user,
      online_event: online_event
    } do
      online_event_id = online_event.id
      assert [%Event{id: ^online_event_id, online: true, attendees: []}] = Content.all_events(%{})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/events")

      assert html =~ "RSVP"

      assert lv
             |> element("button[phx-click=\"rsvp\"]")
             |> render_click(%{
               "event_id" => to_string(online_event.id),
               "user_id" => to_string(user.id)
             })

      assert [%Event{id: ^online_event_id, online: true, attendees: [^user]}] =
               Content.all_events(%{})
    end

    test "redirects if user is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/events")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path === ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end
end

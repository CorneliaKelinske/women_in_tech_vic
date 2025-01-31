defmodule WomenInTechVicWeb.EventLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1, title_banner: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.{CalendarHelper, Event}

  @title "Event Details"
  @subscription_type :event

  @dialyzer {:nowarn_function, mount: 3}
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Content.subscribe_to_attendance_updates()
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => event_id}, _, socket) do
    case Content.find_event(%{id: event_id, preload: [attendees: :profile]}) do
      {:ok, %Event{attendees: attendees} = event} ->
        {:noreply,
         socket
         |> assign_event(event)
         |> assign(:attendees, attendees)
         |> assign(:title, @title)
         |> assign_button_text(socket.assigns.current_user, attendees)
         |> assign_google_calendar_url(event)}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong. Please try again")
         |> push_navigate(to: ~p"/events")}
    end
  end

  @impl true
  def handle_event("rsvp", %{"event_id" => event_id, "user_id" => user_id}, socket) do
    case Content.update_attendance(%{
           event_id: String.to_integer(event_id),
           user_id: String.to_integer(user_id)
         }) do
      {:ok, %Event{attendees: attendees} = event} ->
        {:noreply,
         socket
         |> assign_event(event)
         |> assign(:attendees, attendees)
         |> assign_button_text(socket.assigns.current_user, attendees)}

      # coveralls-ignore-start
      _ ->
        {:noreply, socket}
        # coveralls-ignore-stop
    end
  end

  @impl true
  def handle_event("delete_event", %{"id" => event_id}, socket) do
    case Content.delete_event_by_admin(String.to_integer(event_id), socket.assigns.current_user) do
      {:ok, %Event{}} ->
        @subscription_type
        |> Accounts.get_subscribers()
        |> Enum.each(
          &Accounts.deliver_event_update_notification(socket.assigns.event, &1, :delete)
        )

        {:noreply, push_navigate(socket, to: ~p"/events")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not delete event")}
    end
  end

  @impl true
  def handle_info({:attendance_updated, %Event{attendees: attendees}}, socket) do
    {:noreply, assign(socket, :attendees, attendees)}
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end

  defp assign_event(socket, event) do
    assign(socket, :event, prep_event_for_display(event))
  end

  defp assign_button_text(socket, %User{id: current_user_id}, attendees) do
    attendee_ids = Enum.map(attendees, & &1.id)

    if current_user_id in attendee_ids do
      assign(socket, :button_text, "I changed my mind")
    else
      assign(socket, :button_text, "I will be there")
    end
  end

  defp assign_google_calendar_url(socket, event) do
    assign(socket, :google_calendar_url, CalendarHelper.google_calendar_url(event))
  end
end

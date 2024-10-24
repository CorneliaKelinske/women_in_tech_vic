defmodule WomenInTechVicWeb.EventLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1]

  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => event_id}, _, socket) do
    case Content.find_event(%{id: event_id, preload: :attendees}) do
      {:ok, %Event{attendees: attendees} = event} ->
        {:noreply,
         socket
         |> assign_event(event)
         |> assign(:attendees, attendees)
         |> assign_button_text(socket.assigns.current_user, attendees)}

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
  def handle_event("all_events", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/events")}
  end

  @impl true
  def handle_event("delete_event", %{"id" => event_id}, socket) do
    case Content.delete_event_by_admin(event_id, socket.assigns.current_user) do
      {:ok, %Event{}} ->
        {:noreply, push_navigate(socket, to: ~p"/events")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not delete event")}
    end
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end

  defp assign_event(socket, event) do
    assign(socket, :event, prep_event_for_display(event))
  end

  defp assign_button_text(socket, user, attendees) do
    if user in attendees do
      assign(socket, :button_text, "I changed my mind")
    else
      assign(socket, :button_text, "I will be there")
    end
  end
end

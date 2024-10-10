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
         |> assign(:attendees, attendees)}

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
         |> assign(:attendees, attendees)}

      # coveralls-ignore-start
      _ ->
        {:noreply, socket}
        # coveralls-ignore-stop
    end
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end

  defp assign_event(socket, event) do
    assign(socket, :event, prep_event_for_display(event))
  end
end

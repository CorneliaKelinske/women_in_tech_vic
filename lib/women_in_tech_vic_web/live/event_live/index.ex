defmodule WomenInTechVicWeb.EventLive.Index do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1]

  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  @title "Upcoming Events"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)
     |> assign_events()}
  end

  @impl true
  def handle_event("rsvp", %{"event_id" => event_id, "user_id" => user_id}, socket) do
    case Content.update_attendance(%{
           event_id: String.to_integer(event_id),
           user_id: String.to_integer(user_id)
         }) do
      {:ok, %Event{}} ->
        {:noreply, assign_events(socket)}

      _ ->
        # coveralls-ignore-start
        {:noreply, socket}
        # coveralls-ignore-stop
    end
  end

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_events(socket) do
    events =
      %{scheduled_at: %{gte: DateTime.utc_now()}, order_by: :scheduled_at}
      |> Content.all_events()
      |> case do
        [] -> "No event scheduled"
        [%Event{} | _] = events -> Enum.map(events, &prep_event_for_display/1)
      end

    assign(socket, events: events)
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    event
    |> Map.from_struct()
    |> Map.put(:scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end
end

defmodule WomenInTechVicWeb.EventLive.Index do
  use WomenInTechVicWeb, :live_view

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
    |> Map.put(:scheduled_at, format_scheduled_at(scheduled_at))
  end

  defp format_scheduled_at(scheduled_at) do
    scheduled_at
    |> Utils.utc_timestamp_to_pacific!()
    |> Utils.format_timestamp()
  end
end

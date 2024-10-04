defmodule WomenInTechVicWeb.EventLive.Index do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User
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
    with {:ok, %Event{} = event} <- Content.find_event(%{id: String.to_integer(event_id)}),
         {:ok, %User{} = user} <- Accounts.find_user(%{id: String.to_integer(user_id)}),
         {:ok, %Event{}} <- Content.update_attendance(event, user) do
      {:noreply, assign_events(socket)}
    else
      _ -> {:noreply, socket}
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

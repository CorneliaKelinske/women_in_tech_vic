defmodule WomenInTechVicWeb.PageController do
  use WomenInTechVicWeb, :controller

  alias WomenInTechVic.Content.Event
  alias WomenInTechVic.{Content, Utils}

  def home(conn, _params) do
    online_event =
      %{online: true, scheduled_at: %{gte: DateTime.utc_now()}, order_by: :scheduled_at, limit: 1}
      |> Content.all_events()
      |> case do
        [] -> "No event scheduled"
        [event] -> prep_event_for_display(event)
      end

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, event: online_event)
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    event
    |> Map.from_struct()
    |> Map.put(:scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end
end

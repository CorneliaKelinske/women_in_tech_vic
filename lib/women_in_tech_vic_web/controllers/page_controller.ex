defmodule WomenInTechVicWeb.PageController do
  use WomenInTechVicWeb, :controller

  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  def home(conn, _params) do
    event =
      %{scheduled_at: %{gte: DateTime.utc_now()}, order_by: :scheduled_at, limit: 1}
      |> Content.all_events()
      |> List.first()
      |> prep_event_for_display()

    year = Date.utc_today().year

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, event: event, year: year)
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end

  defp prep_event_for_display(event), do: event
end

defmodule WomenInTechVicWeb.PageController do
  use WomenInTechVicWeb, :controller

  alias WomenInTechVic.Content

  def home(conn, _params) do
    online_event =
      %{online: true, order_by: :scheduled_at, limit: 1}
      |> Content.all_events()
      |> case do
        [] -> "No event scheduled"
        [event] -> event
      end

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false, event: online_event)
  end
end

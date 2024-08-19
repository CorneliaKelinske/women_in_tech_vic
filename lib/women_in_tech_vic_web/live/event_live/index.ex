defmodule WomenInTechVicWeb.EventLive.Index do
  use WomenInTechVicWeb, :live_view

  @title "Upcoming Events"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title(@title)}
  end

  defp assign_title(socket, title), do: assign(socket, title: title)
end

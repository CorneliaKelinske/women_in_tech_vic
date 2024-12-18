defmodule WomenInTechVicWeb.ProfileLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  @title "User Profile"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_title(socket, @title)}
  end

  defp assign_title(socket, title), do: assign(socket, title: title)
end

defmodule WomenInTechVicWeb.HomeLive do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  @title "Welcome Home!"

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_title()
     |> assign_invite_link()}
  end

  defp assign_title(socket) do
    assign(socket, title: @title)
  end

  defp assign_invite_link(socket) do
    assign(socket, slack_invite_link: WomenInTechVic.Config.slack_invite_link())
  end
end

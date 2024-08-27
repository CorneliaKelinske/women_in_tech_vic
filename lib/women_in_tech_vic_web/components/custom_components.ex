defmodule WomenInTechVicWeb.CustomComponents do
  @moduledoc "Custom components for the Women in Tech website"

  use Phoenix.Component

  attr :event, :map, required: true

  @doc """
  Renders an event.

  ## Example

    <.event_display event={event} />

  """
  def event_display(assigns) do
    ~H"""
    <div class="p-6">
      <p class="text-3xl font-bold text-center mb-2"><%= @event.title %></p>
      <p class="text-xl text-center mb-2"><%= @event.scheduled_at %></p>
      <p class="text-lg text-center mb-4">
        <%= if @event.online do %>
          <.online_event_link event={@event} />
        <% else %>
          <.in_person_event_address event={@event} />
        <% end %>
      </p>
    </div>
    <div class="bg-gray-200 bg-opacity-50 p-4 rounded-b-lg">
      <p class="text-sm text-justify"><%= @event.description %></p>
    </div>
    """
  end

  defp online_event_link(assigns) do
    ~H"""
    <.link
      href={@event.address}
      class="text-purple-700 hover:underline"
      target="_blank"
      rel="noopener noreferrer"
    >
      <%= @event.address %>
    </.link>
    """
  end

  defp in_person_event_address(assigns) do
    ~H"""
    <.link
      href={"https://www.google.com/maps/search/?api=1&query=#{URI.encode(@event.address)}"}
      class="text-purple-700 hover:underline"
      target="_blank"
      rel="noopener noreferrer"
    >
      <%= @event.address %>
    </.link>
    """
  end
end

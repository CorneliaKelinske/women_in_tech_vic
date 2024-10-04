defmodule WomenInTechVicWeb.CustomComponents do
  @moduledoc "Custom components for the Women in Tech website"

  use Phoenix.Component

  attr :user, :map, required: true
  attr :event, :map, required: true
  attr :show_attendees, :boolean, default: false

  @doc """
  Renders an event.

  ## Example

    <.event_display event={event} />

  """
  def event_display(assigns) do
    ~H"""
    <div class="p-6 rounded-lg shadow-md mb-8 border border-gray-300 bg-gradient-to-r from-pink-200 via-gray-100 to-pink-300">
      <p class="text-3xl font-bold text-center mb-2"><%= @event.title %></p>
      <p class="text-xl text-center mb-2"><%= @event.scheduled_at %></p>
      <p class="text-lg text-center mb-4">
        <%= if @event.online do %>
          <.online_event_link event={@event} />
        <% else %>
          <.in_person_event_address event={@event} />
        <% end %>
      </p>
      <!-- Description with light grey background -->
      <div>
        <p class="text-sm text-justify"><%= @event.description %></p>
      </div>
      <%= if @show_attendees do %>
        <div class="mt-4 flex justify-center">
          <button
            phx-click="rsvp"
            phx-value-event_id={@event.id}
            phx-value-user_id={@user.id}
            class="px-6 py-2 bg-purple-700 text-white rounded-lg hover:bg-purple-800"
          >
            RSVP
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp online_event_link(assigns) do
    ~H"""
    <.link
      href={@event.address}
      class="text-purple-700 hover:underline hover:text-blue-800"
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
      class="text-purple-700 hover:underline hover:text-blue-800"
      target="_blank"
      rel="noopener noreferrer"
    >
      <%= @event.address %>
    </.link>
    """
  end
end

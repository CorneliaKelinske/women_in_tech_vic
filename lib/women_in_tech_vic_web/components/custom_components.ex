defmodule WomenInTechVicWeb.CustomComponents do
  @moduledoc "Custom components for the Women in Tech website"

  use Phoenix.Component
  use WomenInTechVicWeb, :live_view

  attr :user, :map, required: true
  attr :event, :map, required: true
  attr :show_address, :boolean, default: false
  attr :link_details, :boolean, default: true

  @doc """
  Renders an event.

  ## Example

    <.event_display event={event} />

  """
  def event_display(assigns) do
    ~H"""
    <div class="break-words group relative p-6 rounded-lg shadow-md mb-8 border border-gray-300 bg-gradient-to-r from-pink-200 via-gray-100 to-pink-300">
      <p class="text-3xl font-bold text-center mb-2"><%= @event.title %></p>
      <p class="text-xl text-center mb-2"><%= @event.scheduled_at %></p>
      <%= if @show_address do %>
        <p class="text-lg text-center mb-4">
          <%= if @event.online do %>
            <.online_event_link event={@event} />
          <% else %>
            <.in_person_event_address event={@event} />
          <% end %>
        </p>
      <% end %>
      <!-- Description with light grey background -->
      <div>
        <p class="text-sm text-justify"><%= @event.description %></p>
      </div>
      <%= if @link_details do %>
        <div class="mt-4 flex justify-center">
          <.link
            navigate={~p"/events/#{@event}"}
            class="text-gray-600 font-semibold hover:text-gray-500"
          >
            See details
          </.link>
        </div>
      <% end %>
      <%!-- button for logged in admin only --%>
      <button
        :if={@user}
        class="absolute bottom-4 right-4 text-gray-700 hover:text-red-800 cursor-pointer hidden group-hover:block"
        phx-click="delete_event"
        phx-value-id={@event.id}
      >
        <%!-- only shows for user who created the event or admin--%>
        <.icon :if={@user.role === :admin} name="hero-trash" class="h-5 w-5" />
      </button>
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

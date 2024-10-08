defmodule WomenInTechVicWeb.EventLive.Show do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1]

  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  @impl true
  def render(assigns) do
    ~H"""
    <.event_display user={@current_user} event={@event} show_attendees={true} />
    <div class="p-6 rounded-lg shadow-md mb-8 border border-gray-300 bg-gradient-to-r from-blue-200 via-gray-100 to-blue-300">
      <p class="text-2xl font-bold text-center mb-4">Attendees</p>
      <%= if Enum.empty?(@attendees) do %>
        <p class="text-lg text-center text-gray-500">No one there yet</p>
      <% else %>
        <ul class="list-disc list-inside">
          <%= for attendee <- @attendees do %>
            <li class="text-lg text-center"><%= attendee.username %></li>
          <% end %>
        </ul>
      <% end %>
    </div>
    <button
      phx-click="rsvp"
      phx-value-event_id={@event.id}
      phx-value-user_id={@current_user.id}
      class="px-6 py-2 bg-purple-700 text-white rounded-lg hover:bg-purple-800"
    >
      RSVP
    </button>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => event_id}, _, socket) do
    case Content.find_event(%{id: event_id, preload: :attendees}) do
      {:ok, %Event{attendees: attendees} = event} ->
        event = prep_event_for_display(event)

        {:noreply,
         socket
         |> assign(:event, event)
         |> assign(:attendees, attendees)}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong. Please try again")
         |> push_navigate(to: ~p"/events")}
    end
  end

  @impl true
  def handle_event("rsvp", %{"event_id" => event_id, "user_id" => user_id}, socket) do
    case Content.update_attendance(%{
           event_id: String.to_integer(event_id),
           user_id: String.to_integer(user_id)
         }) do
      {:ok, %Event{attendees: attendees} = event} ->
        {:noreply,
         socket
         |> assign(:event, event)
         |> assign(:attendees, attendees)}

         # coveralls-ignore-start
      _ ->
        {:noreply, socket}
        # coveralls-ignore-stop
    end
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end
end

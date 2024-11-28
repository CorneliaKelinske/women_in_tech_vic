defmodule WomenInTechVicWeb.EventLive.Index do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [event_display: 1, title_banner: 1]

  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  @title "Upcoming Events"

  @impl true
  def mount(_params, _session, socket) do
    timezone = get_connect_params(socket)["timezone"]

    {:ok,
     socket
     |> assign_title(@title)
     |> assign_timezone(timezone)
     |> assign_event_form(Content.event_changeset(%Event{}))
     |> assign_events()}
  end

  # coveralls-ignore-start
  @impl true
  def handle_event("save-event", %{"event" => event_params}, socket) do
    scheduled_at =
      event_params
      |> Map.fetch!("scheduled_at")
      |> Utils.pacific_input_to_utc_timestamp(socket.assigns.timezone)

    event_params =
      Map.merge(event_params, %{
        "scheduled_at" => scheduled_at,
        "user_id" => socket.assigns.current_user.id
      })

    case Content.create_event(event_params) do
      {:ok, %Event{}} ->
        {:noreply,
         socket
         |> put_flash(:info, "Created event")
         |> push_navigate(to: ~p"/events")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_event_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("delete_event", %{"id" => event_id}, socket) do
    case Content.delete_event_by_admin(event_id, socket.assigns.current_user) do
      {:ok, %Event{}} ->
        {:noreply, assign_events(socket)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not delete event")}
    end
  end

  # coveralls-ignore-stop

  defp assign_title(socket, title), do: assign(socket, title: title)

  defp assign_timezone(socket, timezone), do: assign(socket, timezone: timezone)

  defp assign_events(socket) do
    events =
      %{scheduled_at: %{gte: DateTime.utc_now()}, order_by: :scheduled_at}
      |> Content.all_events()
      |> Enum.map(&prep_event_for_display/1)

    assign(socket, events: events)
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end

  # coveralls-ignore-start
  defp prep_event_for_display(event), do: event
  # coveralls-ignore-stop

  defp assign_event_form(socket, changeset) do
    assign(socket, :new_event_form, to_form(changeset))
  end
end

defmodule WomenInTechVicWeb.EventLive.Edit do
  use WomenInTechVicWeb, :live_view

  import WomenInTechVicWeb.CustomComponents, only: [title_banner: 1]

  alias WomenInTechVic.Accounts
  alias WomenInTechVic.{Content, Utils}
  alias WomenInTechVic.Content.Event

  @title "Edit Event"
  @subscription_type :event

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Content.find_event(%{id: id}) do
      {:ok, event} ->
        event = shift_to_pacific(event)
        timezone = get_connect_params(socket)["timezone"] || "America/Vancouver"

        changeset =
          Content.event_changeset(event)

        {:ok,
         socket
         |> assign(title: @title, event: event, timezone: timezone)
         |> assign_form(changeset)}

      _ ->
        {:ok,
         socket
         |> put_flash(:error, "Something went wrong. Please try again")
         |> push_navigate(to: ~p"/events")}
    end
  end

  @impl true
  def handle_event("save-event", %{"event" => event_params}, socket) do
    scheduled_at =
      event_params
      |> Map.fetch!("scheduled_at")
      |> Utils.pacific_input_to_utc_timestamp(socket.assigns.timezone)

    # FOR LATER: once more than one user can create events, this logic of moving the current user id
    # and checking via changeset will have to be revisited.
    event_params =
      Map.merge(event_params, %{
        "scheduled_at" => scheduled_at,
        "user_id" => socket.assigns.current_user.id
      })

    case Content.update_event(socket.assigns.event, event_params) do
      {:ok, %Event{} = event} ->
        @subscription_type
        |> get_subscribers()
        |> Enum.each(
          &Accounts.deliver_event_update_notification(prep_event_for_display(event), &1, :update)
        )

        {:noreply,
         socket
         |> put_flash(:info, "Updated event successfully")
         |> push_navigate(to: ~p"/events/#{event}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not edit event")
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp shift_to_pacific(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.utc_timestamp_to_pacific!(scheduled_at))
  end

  defp get_subscribers(subscription_type) do
    subscription_type
    |> Accounts.find_subscribers()
    |> then(&Accounts.all_users(%{id: &1}))
  end

  defp prep_event_for_display(%Event{scheduled_at: scheduled_at} = event) do
    Map.put(event, :scheduled_at, Utils.timestamp_to_formatted_pacific(scheduled_at))
  end
end

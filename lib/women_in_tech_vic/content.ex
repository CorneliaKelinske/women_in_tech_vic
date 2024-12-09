defmodule WomenInTechVic.Content do
  @moduledoc """
  Content context functions.
  """

  alias EctoShorts.Actions
  alias Phoenix.PubSub
  alias WomenInTechVic.Accounts
  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Content.Event
  alias WomenInTechVic.Repo

  @pubsub WomenInTechVic.PubSub
  @topic "attendance"
  @type change_res(type) :: ErrorMessage.t_res(type) | {:error, Ecto.Changeset.t()}

  # EVENTS

  @doc false
  @spec create_event(map) :: change_res(Event.t())
  def create_event(params) do
    Actions.create(Event, params)
  end

  @doc false
  @spec find_event(map) :: ErrorMessage.t_res(Event.t())
  def find_event(params) do
    Actions.find(Event, params)
  end

  @doc false
  @spec all_events(map()) :: [Event.t()]
  def all_events(params) do
    params = Map.put(params, :preload, [:attendees])
    Actions.all(Event, params)
  end

  @doc false
  @spec update_event(pos_integer(), map()) :: change_res(Event.t())
  @spec update_event(Event.t(), map()) :: change_res(Event.t())
  def update_event(id_or_schema, params) do
    Actions.update(Event, id_or_schema, params)
  end

  @spec update_attendance(map()) :: change_res(Event.t())
  def update_attendance(%{event_id: event_id, user_id: user_id}) do
    with {:ok, %Event{} = event} <- find_event(%{id: event_id}),
         {:ok, %User{} = attendee} <- Accounts.find_user(%{id: user_id}),
         %Event{attendees: attendees} = event = Repo.preload(event, :attendees),
         updated_attendees = update_attendance_list(attendees, attendee),
         {:ok, event} = result <-
           event
           |> Event.update_changeset(%{attendees: updated_attendees})
           |> Repo.update() do
      _ = PubSub.broadcast(@pubsub, "attendance", {:attendance_updated, event})
      result
    end
  end

  @doc "called in the event handlers; checking that user is allowed to delete the event"
  @spec delete_event_by_admin(pos_integer(), User.t()) :: change_res(Event.t())
  def delete_event_by_admin(event_id, %User{role: :admin}) do
    Actions.delete(Event, event_id)
  end

  def delete_event_by_admin(_event, _user),
    do: {:error, ErrorMessage.unauthorized("Not authorized to delete this event")}

  @doc false
  @spec delete_event(Event.t()) :: change_res(Event.t())
  def delete_event(event) do
    Actions.delete(event)
  end

  @doc "creates an Event changeset with nil values"
  @spec event_changeset(Event.t(), map()) :: Ecto.Changeset.t()
  @spec event_changeset(Event.t()) :: Ecto.Changeset.t()
  def event_changeset(event, params \\ %{}) do
    Event.changeset(event, params)
  end

  @spec subscribe_to_attendance_updates() :: :ok | {:error, term()}
  def subscribe_to_attendance_updates do
    PubSub.subscribe(@pubsub, @topic)
  end

  defp update_attendance_list(attendance_list, attendee) do
    case Enum.find_index(attendance_list, &(&1.id === attendee.id)) do
      nil -> [attendee | attendance_list]
      index -> List.delete_at(attendance_list, index)
    end
  end
end

defmodule WomenInTechVic.Content do
  @moduledoc """
  Content context functions.
  """

  alias EctoShorts.Actions
  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Content.Event
  alias WomenInTechVic.Repo

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

  @spec update_attendance(Event.t(), User.t()) :: change_res(Event.t())
  def update_attendance(event, %User{} = attendee) do
    %Event{attendees: attendees} = event = Repo.preload(event, :attendees)

    updated_attendees =
      case Enum.find_index(attendees, &(&1.id === attendee.id)) do
        nil -> [attendee | attendees]
        index -> List.delete_at(attendees, index)
      end

    event
    |> Event.update_changeset(%{attendees: updated_attendees})
    |> Repo.update()
  end

  @doc false
  @spec delete_event(Event.t()) :: change_res(Event.t())
  def delete_event(event) do
    Actions.delete(event)
  end
end

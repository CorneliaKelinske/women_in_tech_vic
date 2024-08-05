defmodule WomenInTechVic.Content do
  @moduledoc """
  Content context functions.
  """

  alias EctoShorts.Actions
  alias WomenInTechVic.Content.Event

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
    Actions.all(Event, params)
  end

  @doc false
  @spec update_event(pos_integer(), map()) :: change_res(Event.t())
  @spec update_event(Event.t(), map()) :: change_res(Event.t())
  def update_event(id_or_schema, params) do
    Actions.update(Event, id_or_schema, params)
  end

  @doc false
  @spec delete_event(Event.t()) :: change_res(Event.t())
  def delete_event(event) do
    Actions.delete(event)
  end
end

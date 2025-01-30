defmodule WomenInTechVic.Content.Event do
  @moduledoc """
  An scheduled event for the Women in Tech Vic meetup group.
  Can be either in-person or online
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias WomenInTechVic.Accounts.User
  alias WomenInTechVic.Repo

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          title: String.t() | nil,
          scheduled_at: DateTime.t() | nil | String.t(),
          online: boolean() | nil,
          address: String.t() | nil,
          description: String.t() | nil,
          user_id: pos_integer() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          attendees: [User.t()] | Ecto.Association.NotLoaded.t(),
          updated_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil
        }

  @required [:title, :scheduled_at, :online, :address, :description, :user_id]

  schema "events" do
    field :title, :string
    field :scheduled_at, :utc_datetime_usec
    field :online, :boolean
    field :address, :string
    field :description, :string

    belongs_to :user, User
    many_to_many :attendees, User, join_through: "events_users", on_replace: :delete

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec create_changeset(map) :: Ecto.Changeset.t()
  def create_changeset(attrs) do
    @required
    |> Map.new(&{&1, nil})
    |> then(&struct!(__MODULE__, &1))
    |> changeset(attrs)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t(t)
  def changeset(%__MODULE__{} = event, params \\ %{}) do
    event
    |> cast(params, @required)
    |> validate_required(@required)
    |> maybe_validate_online_address()
    |> validate_user_role()
    |> unique_constraint(:scheduled_at)
    |> foreign_key_constraint(:user_id)
  end

  def update_changeset(event, %{attendees: attendees} = params) do
    event
    |> changeset(params)
    |> put_assoc(:attendees, attendees)
  end

  defp maybe_validate_online_address(%Ecto.Changeset{valid?: true} = changeset) do
    online = fetch_field!(changeset, :online)

    if online do
      validate_format(
        changeset,
        :address,
        ~r|https\:\/\/meet.google.com\/|,
        message: "Valid google meet link required for online meeting"
      )
    else
      changeset
    end
  end

  defp maybe_validate_online_address(changeset), do: changeset

  defp validate_user_role(%Ecto.Changeset{valid?: true} = changeset) do
    user_id = fetch_field!(changeset, :user_id)

    case Repo.get(User, user_id) do
      %User{role: :admin} -> changeset
      _ -> add_error(changeset, :user_id, "You're not authorized to create events")
    end
  end

  defp validate_user_role(changeset), do: changeset
end

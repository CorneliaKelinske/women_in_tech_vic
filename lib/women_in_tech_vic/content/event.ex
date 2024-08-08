defmodule WomenInTechVic.Content.Event do
  @moduledoc """
  An scheduled event for the Women in Tech Vic meetup group.
  Can be either in-person or online
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          title: String.t(),
          scheduled_at: DateTime.t(),
          online: boolean(),
          address: String.t(),
          description: String.t(),
          updated_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil
        }

  @required [:title, :scheduled_at, :online, :address, :description]
  @enforce_keys @required

  schema "events" do
    field :title, :string
    field :scheduled_at, :utc_datetime_usec
    field :online, :boolean
    field :address, :string
    field :description, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  @spec create_changeset(map) :: Ecto.Changeset.t()
  def create_changeset(attrs) do
    @enforce_keys
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
    |> unique_constraint(:scheduled_at)
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
    end
  end

  defp maybe_validate_online_address(changeset), do: changeset
end

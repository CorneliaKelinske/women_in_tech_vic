defmodule WomenInTechVic.Accounts.Profile do
  @moduledoc """
  Each registered Women in Tech Vic user has the option to
  create a user profile
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias WomenInTechVic.Accounts.User

  @type t :: %__MODULE__{
          id: pos_integer() | nil,
          user_id: pos_integer(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          linked_in: String.t() | nil,
          github: String.t() | nil,
          workplace: String.t(),
          hobbies: String.t(),
          other: String.t()
        }

  @required [:user_id]
  @cast [:linked_in, :github, :workplace, :hobbies, :projects, :other] ++ @required

  schema "profiles" do
    field :linked_in, :string
    field :github, :string
    field :workplace, :string
    field :hobbies, :string
    field :projects, :string
    field :other, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  @spec create_changeset(map) :: Ecto.Changeset.t()
  def create_changeset(attrs) do
    @cast
    |> Map.new(&{&1, nil})
    |> then(&struct!(__MODULE__, &1))
    |> changeset(attrs)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t(t)
  def changeset(%__MODULE__{} = profile, params \\ %{}) do
    profile
    |> cast(params, @cast)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
    |> unique_constraint(:github)
    |> unique_constraint(:linked_in)
  end
end

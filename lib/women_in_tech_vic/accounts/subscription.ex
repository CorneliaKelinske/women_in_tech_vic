defmodule WomenInTechVic.Accounts.Subscription do
  @moduledoc """
  A user can subscribe to various email notifications.
  The subscriptions table keeps track of what users are subscribed to.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias WomenInTechVic.Accounts.User

  @type t :: %__MODULE__{
          id: pos_integer(),
          user_id: pos_integer(),
          subscription_type: subscription_type(),
          updated_at: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil
        }

  @type subscription_type :: :event

  @subscription_types [:event]
  @required [:user_id, :subscription_type]
  @cast @required

  schema "subscriptions" do
    field :subscription_type, Ecto.Enum, values: @subscription_types
    belongs_to :user, User

    timestamps(type: :utc_datetime_usec)
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
  def changeset(%__MODULE__{} = subscription, params \\ %{}) do
    subscription
    |> cast(params, @cast)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> validate_inclusion(:subscription_type, @subscription_types)
    |> unique_constraint([:user_id, :subscription_type])
  end
end

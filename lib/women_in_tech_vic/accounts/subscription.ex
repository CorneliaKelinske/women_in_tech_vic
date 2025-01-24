defmodule WomenInTechVic.Accounts.Subscription do
  @moduledoc """
  A user can subscribe to various email notifications.
  The subscriptions table keeps track of what users are subscribed to.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias WomenInTechVic.Accounts.User

  @type t :: %__MODULE__{
          id: pos_integer(),
          user_id: pos_integer(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
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

  @spec by_user(pos_integer()) :: Ecto.Query.t()
  @spec by_user(Ecto.Queryable.t(), pos_integer()) :: Ecto.Query.t()
  def by_user(query \\ Subscription, user_id) do
    where(query, [s], s.user_id == ^user_id)
  end

  @spec by_subscription_type(subscription_type()) :: Ecto.Query.t()
  @spec by_subscription_type(Ecto.Queryable.t(), subscription_type()) :: Ecto.Query.t()
  def by_subscription_type(query \\ Subscription, subscription_type) do
    where(query, [s], s.subscription_type == ^subscription_type)
  end

  @spec return_user_ids :: Ecto.Queryable.t()
  @spec return_user_ids(Ecto.Queryable.t()) :: Ecto.Query.t()
  def return_user_ids(query \\ Subscription) do
    select(query, [s], s.user_id)
  end

  @spec return_subscription_types :: Ecto.Queryable.t()
  @spec return_subscription_types(Ecto.Queryable.t()) :: Ecto.Query.t()
  def return_subscription_types(query \\ Subscription) do
    select(query, [s], s.subscription_type)
  end

  @spec subscription_types :: [subscription_type()]
  def subscription_types do
    @subscription_types
  end
end

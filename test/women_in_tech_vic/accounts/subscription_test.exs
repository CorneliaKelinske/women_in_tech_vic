defmodule WomenInTechVic.Accounts.SubscriptionTest do
  use WomenInTechVic.DataCase, async: true

  alias WomenInTechVic.Accounts.Subscription

  describe "changeset/2" do
    test "validates required" do
      assert %Ecto.Changeset{errors: errors} = Subscription.create_changeset(%{})

      [
        {:user_id, {"can't be blank", [validation: :required]}},
        {:subscription_type, {"can't be blank", [validation: :required]}}
      ] = errors
    end
  end
end

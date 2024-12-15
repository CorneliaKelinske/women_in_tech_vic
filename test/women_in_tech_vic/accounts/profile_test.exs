defmodule WomenInTechVic.Accounts.ProfileTest do
  use WomenInTechVic.DataCase, async: true

  alias WomenInTechVic.Accounts.Profile

  describe "changeset/2" do
    test "validates required" do
      assert %Ecto.Changeset{errors: errors} = Profile.create_changeset(%{})

      assert [user_id: {"can't be blank", validation: :required}] = errors
    end
  end
end

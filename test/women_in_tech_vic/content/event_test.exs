defmodule WomenInTechVic.Content.EventTest do
  use WomenInTechVic.DataCase, async: true

  alias WomenInTechVic.Content.Event

  describe "changeset/2" do
    test "validates required" do
      assert %Ecto.Changeset{errors: errors} = Event.create_changeset(%{})

      assert [
               title: {"can't be blank", [validation: :required]},
               scheduled_at: {"can't be blank", [validation: :required]},
               online: {"can't be blank", [validation: :required]},
               address: {"can't be blank", [validation: :required]},
               description: {"can't be blank", [validation: :required]}
             ] = errors
    end

    test "validates google meet link for online meetings" do
      params = %{
        title: "Online meeting",
        description: "Another online meeting",
        online: true,
        address: "meet.google.com/",
        scheduled_at: DateTime.utc_now()
      }

      assert %Ecto.Changeset{valid?: true} = Event.create_changeset(params)

      faulty_params = Map.put(params, :address, "not a valid google meet address")
      assert %Ecto.Changeset{errors: errors} = Event.create_changeset(faulty_params)

      assert [
               address:
                 {"Valid google meet link required for online meeting", [validation: :format]}
             ] = errors
    end
  end
end

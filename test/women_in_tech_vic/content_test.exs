defmodule WomenInTechVic.ContentTest do
  use WomenInTechVic.DataCase, async: true

  import WomenInTechVic.Support.Factory, only: [build: 1]
  import WomenInTechVic.Support.ContentTestSetup, only: [online_event: 1]
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.Event

  setup [:user, :online_event]

  describe "create_event/1" do
    test "successfully creates event when given correct params but does not create 2 events at the same date",
         %{user: user} do
      event_params =
        :online_event
        |> build()
        |> Map.put(:user_id, user.id)

      assert {:ok, %Event{online: true}} = Content.create_event(event_params)
      assert {:error, %Ecto.Changeset{errors: errors}} = Content.create_event(event_params)

      assert [
               scheduled_at:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "events_scheduled_at_index"]}
             ] = errors
    end
  end

  describe "find_event/1" do
    test "finds event by ID", %{online_event: online_event} do
      event_id = online_event.id
      assert {:ok, %Event{id: ^event_id, online: true}} = Content.find_event(%{id: event_id})
    end

    test "returns error if no event is found", %{online_event: online_event} do
      assert {:error, %ErrorMessage{code: :not_found, message: "no records found"}} =
               Content.find_event(%{id: online_event.id + 11})
    end
  end

  describe "all events/2" do
    test "returns a list of  all events", %{online_event: online_event} do
      event_id = online_event.id
      assert [%Event{id: ^event_id, online: true}] = Content.all_events(%{})
    end

    test "returns empty list when no event found" do
      assert [] = Content.all_events(%{online: false})
    end
  end

  describe "update_event/2" do
    test "updates an event by id", %{online_event: online_event} do
      event_id = online_event.id
      update_params = %{title: "new title"}

      assert {:ok, %Event{online: true, id: ^event_id, title: "new title"}} =
               Content.update_event(event_id, update_params)
    end

    test "updates an event by schema", %{online_event: online_event} do
      event_id = online_event.id
      update_params = %{title: "new title"}

      assert {:ok, %Event{online: true, id: ^event_id, title: "new title"}} =
               Content.update_event(online_event, update_params)
    end

    test "returns error when event does not exist", %{online_event: online_event} do
      event_id = online_event.id
      update_params = %{title: "new title"}

      assert {:error, %ErrorMessage{code: :not_found}} =
               Content.update_event(event_id + 11, update_params)
    end

    test "returns error when invalid params are passed in does not exist", %{
      online_event: online_event
    } do
      event_id = online_event.id
      update_params = %{address: "new address"}

      assert {:error, %Ecto.Changeset{valid?: false}} =
               Content.update_event(event_id, update_params)
    end
  end

  describe "delete event/1" do
    test "deletes an event", %{online_event: online_event} do
      assert {:ok, %Event{}} = Content.delete_event(online_event)
    end
  end
end

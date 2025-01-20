defmodule WomenInTechVic.Content.CalendarHelperTest do
  use WomenInTechVic.DataCase, async: true
  import WomenInTechVic.Support.Factory, only: [build: 1]
  import WomenInTechVic.Support.AccountsTestSetup, only: [user: 1]

  alias WomenInTechVic.Content
  alias WomenInTechVic.Content.CalendarHelper

  setup [:user]

  describe "google_calendar_url/1" do
    test "returns a Google Calendar URL with a one hour duration for an online event", %{
      user: user
    } do
      event_params = %{
        title: "Event title",
        description: "Event description",
        address: "https://meet.google.com/",
        scheduled_at: ~U[2021-01-01T00:00:00Z],
        user_id: user.id
      }

      online_event_params =
        :online_event
        |> build()
        |> Map.merge(event_params)

      assert {:ok, online_event} = Content.create_event(online_event_params)

      expected_url =
        "https://calendar.google.com/calendar/render?location=https%3A%2F%2Fmeet.google.com%2F&text=Event+title&action=TEMPLATE&details=Event+description&dates=20210101T000000Z%2F20210101T010000Z"

      assert CalendarHelper.google_calendar_url(online_event) === expected_url
    end

    test "returns a Google Calendar URL with a two hour duration for an in-person event", %{
      user: user
    } do
      event_params = %{
        title: "Event title",
        description: "Event description",
        address: "https://meet.google.com/",
        scheduled_at: ~U[2021-01-01T00:00:00Z],
        user_id: user.id
      }

      in_person_event_params =
        :in_person_event
        |> build()
        |> Map.merge(event_params)

      assert {:ok, online_event} = Content.create_event(in_person_event_params)

      expected_url =
        "https://calendar.google.com/calendar/render?location=https%3A%2F%2Fmeet.google.com%2F&text=Event+title&action=TEMPLATE&details=Event+description&dates=20210101T000000Z%2F20210101T020000Z"

      assert CalendarHelper.google_calendar_url(online_event) === expected_url
    end
  end
end

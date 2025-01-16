defmodule WomenInTechVic.Content.CalendarHelper do
  @moduledoc """
  Helper module for generating Google Calendar URLS
  """

  alias WomenInTechVic.Content.Event

  @base_url "https://calendar.google.com/calendar/render"

  @spec google_calendar_url(Event.t()) :: String.t()
  # Calculate the end time by adding 3600 seconds (1 hour) to the start time
  def google_calendar_url(event) do
    end_time =
      DateTime.add(event.scheduled_at, 3600, :second)

    params = %{
      action: "TEMPLATE",
      text: event.title,
      dates: format_dates(event.scheduled_at, end_time),
      details: event.description,
      location: event.address
    }

    query_string = URI.encode_query(params)
    "#{@base_url}?#{query_string}"
  end

  defp format_dates(start_time, end_time) do
    start_str = format_datetime(start_time)
    end_str = format_datetime(end_time)
    "#{start_str}/#{end_str}"
  end

  defp format_datetime(datetime) do
    datetime
    |> DateTime.to_iso8601()
    |> String.replace(~r/[-:]/, "")
    |> String.replace(~r/\.\d+Z/, "Z")
  end
end

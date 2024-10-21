defmodule WomenInTechVic.Utils do
  @moduledoc """
  Holds helper functions that can be used across the project
  """

  @pacific "America/Vancouver"
  @timezone_db Tzdata.TimeZoneDatabase

  @doc false
  @spec utc_timestamp_to_pacific!(DateTime.t()) :: DateTime.t()
  def utc_timestamp_to_pacific!(timestamp) do
    DateTime.shift_zone!(timestamp, @pacific, @timezone_db)
  end

  @doc "formats a given timestamp into a Weekday, Date, Time, Timezone format"
  @spec format_timestamp(DateTime.t()) :: String.t()
  def format_timestamp(timestamp) do
    Calendar.strftime(timestamp, "%a, %d %B %Y %I:%M %p, %Z")
  end

  @doc "converts UTC timestamp into Weekday, Date, Time, Timezone format in Pacific Time"
  @spec timestamp_to_formatted_pacific(DateTime.t()) :: String.t()
  def timestamp_to_formatted_pacific(timestamp) do
    timestamp
    |> utc_timestamp_to_pacific!()
    |> format_timestamp()
  end

  @doc "converts a time and date in PT send via a form input into an UTC Timestamp"
  @spec pacific_input_to_utc_timestamp(String.t(), String.t()) :: DateTime.t()
  def pacific_input_to_utc_timestamp(pacific_input, timezone) do
    (pacific_input <> ":00")
    |> NaiveDateTime.from_iso8601!()
    |> DateTime.from_naive!(timezone, @timezone_db)
    |> DateTime.shift_zone!("Etc/UTC")
  end
end

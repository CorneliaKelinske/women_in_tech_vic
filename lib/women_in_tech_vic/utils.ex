defmodule WomenInTechVic.Utils do
  @moduledoc """
  Holds helper functions that can be used across the project
  """

  @doc false
  @spec utc_timestamp_to_pacific!(DateTime.t()) :: DateTime.t()
  def utc_timestamp_to_pacific!(timestamp) do
    DateTime.shift_zone!(timestamp, "America/Vancouver", Tzdata.TimeZoneDatabase)
  end

  @doc "formats a given timestamp into a Weekday, Date, Time, Timezone format"
  @spec format_timestamp(DateTime.t()) :: String.t()
  def format_timestamp(timestamp) do
    Calendar.strftime(timestamp, "%a, %d %B %Y %I:%M %p, %Z")
  end
end

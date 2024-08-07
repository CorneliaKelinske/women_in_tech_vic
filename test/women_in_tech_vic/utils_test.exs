defmodule WomenInTechVic.UtilsTest do
  use ExUnit.Case, async: true

  alias WomenInTechVic.Utils

  @timestamp ~U[2024-08-08 15:03:30.357348Z]

  describe "utc_timestamp_to_pacific/1" do
    test "turns utc timestamp into pacific time stamp" do
      assert %DateTime{} = datetime = Utils.utc_timestamp_to_pacific!(@timestamp)
      assert "America/Vancouver" === datetime.time_zone
    end
  end

  describe "format_timestamp/1" do
    test "turns timestamp into weekday - date -time - timezone format" do
      assert "Thu, 08 August 2024 03:03 PM, UTC" === Utils.format_timestamp(@timestamp)

      assert "Thu, 08 August 2024 08:03 AM, PDT" =
               Utils.format_timestamp(Utils.utc_timestamp_to_pacific!(@timestamp))
    end
  end
end

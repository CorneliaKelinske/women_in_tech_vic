defmodule WomenInTechVic.FileCompressorTest do
  use ExUnit.Case, async: true
  alias WomenInTechVic.FileCompressor

  @test_image "test/support/fixtures_and_factories/test_image.jpg"

test "compress_image/1 compresses the JPG image successfully" do
  temp_file = "test/support/fixtures_and_factories/temp_test_image.jpg"
  File.cp!(@test_image, temp_file)

  assert %Mogrify.Image{} = result = FileCompressor.compress_image(temp_file)

  assert String.starts_with?(result.path, System.tmp_dir())
    original_size = File.stat!(@test_image).size
    compressed_size = File.stat!(result.path).size
    assert compressed_size < original_size

    File.rm!(temp_file)
    File.rm!(result.path)
  end
end

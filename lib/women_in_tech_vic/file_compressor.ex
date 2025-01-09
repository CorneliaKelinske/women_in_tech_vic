defmodule WomenInTechVic.FileCompressor do
  @moduledoc """
  Compresses files uploaded by the user before they are stored.
  """

  @spec compress_image(String.t()) :: Mogrify.Image.t()
  def compress_image(path) do
    path
    |> Mogrify.open()
    |> Mogrify.resize_to_limit("900x900")
    |> Mogrify.save()
  end
end

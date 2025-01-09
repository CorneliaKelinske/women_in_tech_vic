defmodule WomenInTechVicWeb.ProfileLive.UploadUtils do
  @moduledoc """
  This module is home of the functionalities needed for the upload of profile pictures.
  """
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.FileCompressor

  alias WomenInTechVic.Config
  @spec create_image_upload_with_path(Phoenix.LiveView.Socket.t()) :: String.t() | nil
  def create_image_upload_with_path(socket) do
    socket
    |> consume_uploaded_entries(:image, fn %{path: path}, _entry ->
      %Mogrify.Image{path: new_path} = FileCompressor.compress_image(path)

      dest =
        Path.join(
          Config.upload_path(),
          Path.basename(new_path)
        )

      File.cp!(new_path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)
    |> List.first()
  end
end

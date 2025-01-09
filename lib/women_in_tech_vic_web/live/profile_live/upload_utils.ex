defmodule WomenInTechVicWeb.ProfileLive.UploadUtils do
  use WomenInTechVicWeb, :live_view

  alias WomenInTechVic.Config
  @spec create_image_upload_with_path(Phoenix.LiveView.Socket.t()) :: String.t() | nil
  def create_image_upload_with_path(socket) do
    socket
    |> consume_uploaded_entries(:image, fn %{path: path}, _entry ->
      dest =
        Path.join(
          Config.upload_path(),
          Path.basename(path)
        )

      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)
    |> List.first()
  end
end

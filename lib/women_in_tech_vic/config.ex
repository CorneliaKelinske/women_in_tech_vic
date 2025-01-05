defmodule WomenInTechVic.Config do
  @moduledoc """
  Fetches environmental variables from config.exs
  """

  @app :women_in_tech_vic

  @spec upload_path :: String.t()
  def upload_path do
    Application.fetch_env!(@app, :upload_path)
  end
end

defmodule WomenInTechVic.Config do
  @moduledoc """
  Fetches environmental variables from config.exs
  """

  @app :women_in_tech_vic

  @spec upload_path :: String.t()
  def upload_path do
    Application.fetch_env!(@app, :upload_path)
  end

  @spec slack_invite_link :: String.t()
  def slack_invite_link do
    Application.fetch_env!(@app, :slack_invite_link)
  end
end

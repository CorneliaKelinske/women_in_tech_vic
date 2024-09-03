defmodule WomenInTechVic.Email.Contact do
  @moduledoc """
  Contact form email to be sent to the site admin
  """

  alias WomenInTechVic.Email.Content
  import Ecto.Changeset

  @required [:from_email, :name, :subject, :message]

  @doc "Ensure that data is valid before sending"
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    {%Content{}, Content.types()}
    |> cast(attrs, @required)
    |> validate_required(@required, message: "This box must not be empty!")
    |> validate_length(:message,
      min: 10,
      max: 1000,
      message: "Message needs to be between 10 and 1000 characters"
    )
  end
end

# credo:disable-for-this-file
defmodule WomenInTechVic.Email.Builder do
  @moduledoc """
  Builds an email that can be sent by Swoosh mailer from a passed in map
  """

  import Swoosh.Email

  @doc false
  @spec create_email(map()) :: Swoosh.Email.t()
  def create_email(%{from_email: from_email, name: name, subject: subject, message: message}) do
    new()
    |> to({"Cornelia", "corneliakelinske@gmail.com"})
    |> from({name, from_email})
    |> subject(subject)
    |> html_body("<h1>#{message}</h1>")
    |> text_body("#{message}\n")
  end
end

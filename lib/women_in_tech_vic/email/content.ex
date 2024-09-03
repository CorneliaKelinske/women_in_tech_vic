defmodule WomenInTechVic.Email.Content do
  @moduledoc """
  Defines the shape of an email's content
  """
  @type t :: %__MODULE__{
          from_email: String.t() | nil,
          to_email: String.t() | nil,
          name: String.t() | nil,
          subject: String.t() | nil,
          message: String.t() | nil
        }

  @spec types :: %{
          from_email: :string,
          message: :string,
          name: :string,
          to_email: :string,
          subject: :string
        }

  defstruct from_email: nil,
            to_email: nil,
            name: nil,
            subject: nil,
            message: nil

  def types do
    %{
      from_email: :string,
      to_email: :string,
      name: :string,
      subject: :string,
      message: :string
    }
  end
end

defmodule WomenInTechVic.Email.ContentTest do
  use WomenInTechVic.DataCase, async: true

  alias WomenInTechVic.Email.Contact

  describe "changeset/1" do
    test "validates required" do
      assert %Ecto.Changeset{errors: errors} = Contact.changeset(%{})

      assert [
               from_email: {"This box must not be empty!", [validation: :required]},
               name: {"This box must not be empty!", [validation: :required]},
               subject: {"This box must not be empty!", [validation: :required]},
               message: {"This box must not be empty!", [validation: :required]}
             ] = errors
    end

    test "validates message length" do
      params = %{from_email: "abc@d.com", name: "abc", subject: "abc", message: "abc"}

      assert %Ecto.Changeset{errors: errors} = Contact.changeset(params)

      assert [
               message:
                 {"Message needs to be between 10 and 1000 characters",
                  [{:count, 10}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
             ] = errors
    end
  end
end

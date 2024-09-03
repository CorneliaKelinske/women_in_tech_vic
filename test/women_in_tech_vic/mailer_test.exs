defmodule WomenInTechVic.MailerTest do
  use WomenInTechVic.DataCase, async: true
  alias WomenInTechVic.Email.Builder
  alias WomenInTechVic.Mailer
  import Swoosh.TestAssertions, only: [assert_email_sent: 1]

  @valid_params %{
    from_email: "tester@test.com",
    name: "testy McTestface",
    subject: "Testing, testing",
    message: "Hello, this is a test"
  }

  test "deliver/1 delivers an email from a user to a mailbox" do

    email =  Builder.create_email(@valid_params)
    assert {:ok, %{}} = Mailer.deliver(email)
    assert_email_sent(email)

  end
end

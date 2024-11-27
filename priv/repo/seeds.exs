alias WomenInTechVic.Accounts
alias WomenInTechVic.Content

IO.puts("Seeding a user")

Accounts.register_user(%{
  first_name: "Cornelia",
  last_name: "Kelinske",
  username: "connie",
  role: :admin,
  email: "corneliakelinske@gmail.com",
  password: "Password1234"
})

user = Accounts.get_user_by_email("corneliakelinske@gmail.com")

IO.puts("Seeding data")

Content.create_event(%{
  user_id: user.id,
  title: "Bi-weekly online meeting",
  scheduled_at: "2025-08-14T00:00:00Z",
  online: true,
  address: "https://meet.google.com/uam-eyys-bxs",
  description: "Our bi-weekly online meetup where we can hang out and chat.
                  This meeting is one of the more technical, code-heavy meetings. We'll continue exploring RUST. During the last technical meeting, we did a basic initial exploration using https://exercism.org/tracks/rust.
                  This time, we'll be a bit more hands-on. We are going to use
                  https://github.com/rust-lang/rustlings
                  To make this work on your computer, you'd need a code editor (e.g., VS code), clone our copy of the Rustlings repo at https://github.com/CorneliaKelinske/rustlings_meetup and install Rust plus Rustlings. Install instructions are linked in the Rustling GitHub Repo.
                  Let me (Cornelia) know if you need help with the installation or if there are any questions/concerns.
                  If this seems intimidating, don't worry! We can help you get set up during the meet-up, plus we'll have someone screen share so we can work through the exercises together.
                  "
})

Content.create_event(%{
  user_id: user.id,
  title: "Bi-weekly online meeting",
  scheduled_at: "2025-09-25T00:00:00Z",
  online: true,
  address: "https://meet.google.com/uam-eyys-bxs",
  description:
    "Our bi-weekly online meetup where we can hang out and chat.
    This meeting is a more technical, hands-on coding meeting. We'll continue exploring RUST. For this, we use https://github.com/rust-lang/rustlings.
    To make this work on your computer, you will need a code editor
    (e.g., VS code) . The Rustlings repo linked above has excellent instructions for what to do to get set up.
    Follow those, and you are good to go!
    Let me (Cornelia) know if you need help with the installation or have any questions or concerns.
    If this seems intimidating, don't worry! We can help you get set up during the meet-up, plus we'll have someone screen share so we can work through the exercises together.
    If you missed the last meeting, don't worry! The progress we make in each meeting will be committed to this repo: https://github.com/CorneliaKelinske/rustlings_meetup"
})

Content.create_event(%{
  user_id: user.id,
  title: "Nachos and Beer",
  scheduled_at: "2025-10-20T00:00:00Z",
  online: false,
  address: "109-3680 Uptown Blvd · Victoria, BC",
  description: "Our next in-person meeting!
                  We will meet outside Brown's Social House at Uptown Mall and let the people at the restaurant know who we are in case we have late-comers who are looking for us!
                  To make it easier for us to decide how big a table we need, please only RSVP if you are actually intending to join and kindly click on 'Not Attending' if you said 'Yes' before and your plans have changed. Thank you!
                  "
})

Content.create_event(%{
  user_id: user.id,
  title: "Bi-weekly online meeting",
  scheduled_at: "2025-10-09T00:00:00Z",
  online: true,
  address: "https://meet.google.com/uam-eyys-bxs",
  description:
    "Our bi-weekly online meetup where we can hang out and chat.
    This meeting is a more technical, hands-on coding meeting. We'll continue exploring RUST. For this, we use https://github.com/rust-lang/rustlings.
    To make this work on your computer, you will need a code editor
    (e.g., VS code) . The Rustlings repo linked above has excellent instructions for what to do to get set up.
    Follow those, and you are good to go!
    Let me (Cornelia) know if you need help with the installation or have any questions or concerns.
    If this seems intimidating, don't worry! We can help you get set up during the meet-up, plus we'll have someone screen share so we can work through the exercises together.
    If you missed the last meeting, don't worry! The progress we make in each meeting will be committed to this repo: https://github.com/CorneliaKelinske/rustlings_meetup"
})

Content.create_event(%{
  user_id: user.id,
  title: "Bi-weekly online meeting",
  scheduled_at: "2025-10-23T00:00:00Z",
  online: true,
  address: "https://meet.google.com/uam-eyys-bxs",
  description:
    "Our bi-weekly online meetup where we can hang out and chat.
    This meeting is a more technical, hands-on coding meeting. We'll continue exploring RUST. For this, we use https://github.com/rust-lang/rustlings.
    To make this work on your computer, you will need a code editor
    (e.g., VS code) . The Rustlings repo linked above has excellent instructions for what to do to get set up.
    Follow those, and you are good to go!
    Let me (Cornelia) know if you need help with the installation or have any questions or concerns.
    If this seems intimidating, don't worry! We can help you get set up during the meet-up, plus we'll have someone screen share so we can work through the exercises together.
    If you missed the last meeting, don't worry! The progress we make in each meeting will be committed to this repo: https://github.com/CorneliaKelinske/rustlings_meetup"
})

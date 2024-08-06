if Mix.env() !== :test do
  alias WomenInTechVic.Content

  Content.create_event(%{
    title: "Bi-weekly online meeting",
    scheduled_at: "2024-08-14T00:00:00Z",
    online: true,
    address: "meet.google.com/uam-eyys-bxs",
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
    title: "Bi-weekly online meeting",
    scheduled_at: "2024-08-28T00:00:00Z",
    online: true,
    address: "meet.google.com/uam-eyys-bxs",
    description: "Our bi-weekly online meetup where we can hang out and chat.
                  This meeting is one of the more technical, code-heavy meetings. We'll continue exploring RUST. During the last technical meeting, we did a basic initial exploration using https://exercism.org/tracks/rust.
                  This time, we'll be a bit more hands-on. We are going to use
                  https://github.com/rust-lang/rustlings
                  To make this work on your computer, you'd need a code editor (e.g., VS code), clone our copy of the Rustlings repo at https://github.com/CorneliaKelinske/rustlings_meetup and install Rust plus Rustlings. Install instructions are linked in the Rustling GitHub Repo.
                  Let me (Cornelia) know if you need help with the installation or if there are any questions/concerns.
                  If this seems intimidating, don't worry! We can help you get set up during the meet-up, plus we'll have someone screen share so we can work through the exercises together.
                  "
  })
end

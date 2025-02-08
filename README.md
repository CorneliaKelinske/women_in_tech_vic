# WomenInTechVic

This website is still in its infancy.
But feel free to check out https://women-in-tech-vic.fly.dev/ to see it grow over time.


## How to run this application 

### Quickstart

If you're already familiar with how to run Elixir/Phoenix applications, this section is for you!
Just do the usual 😃 
Make sure you have the correct `Erlang`, `Elixir` and `Node.js` versions installed. There is a `.too-versions` file, so if you're using `asdf`, you can run `asdf install`.

There is one gotcha:
The Slack invite link is set as an environment variable in `config.exs`. 
To bypass the need of setting up an environment variable, just replace this line

```Elixir
config :women_in_tech_vic, slack_invite_link: System.get_env("SLACK_INVITE_LINK")
```

with 
```Elixir
config :women_in_tech_vic, slack_invite_link: "www.slack.com`
```
This will just lead to the Slack homepage.

### Prerequisites

Ensure you have the following installed on your system: 

- Erlang
- Elixir 
- Node.js 

The required versions are specified in the `.tool-versions` file. It's recommended to use [asdf](https://asdf-vm.com/) for
version control. [Here](https://www.gigalixir.com/blog/a-beginners-guide-to-installing-elixir-with-asdf/) for how to install Elixir and Phoenix.
You will also need to install the `Node.js` plugin.
Using `asdf` allows you to run `asdf install` from the root of the directory to get the correct versions of everything.


- PostgreSQL or Docker and Docker Compose to create and run the Postgres database.

If you opt for the Docker solution, you can run `docker compose up` from root to get Postgres started. If you're running Postgres locally, make sure you use the version specified in `compose.yaml`.

### Development

To start the app up locally, there are a few set-up steps:

- install Elixir dependencies: `mix deps.get`
- set up the development database: `mix ecto.setup`
- install JavaScript dependencies: `cd assets && npm install && cd ..`
- tweak the `config.exs` file as follows:

Replace this line


```Elixir
config :women_in_tech_vic, slack_invite_link: System.get_env("SLACK_INVITE_LINK")
```

with 
```Elixir
config :women_in_tech_vic, slack_invite_link: "www.slack.com`
```

Now you can run `mix phx.server` and the application will be available at `http://localhost:4000`.


### Tests

To run the tests successfully, you will need to set up the test database by running:
`MIX_ENV=test mix ecto.setup`, after which you can run `mix test` to run the test suite.

# credo:disable-for-this-file
defmodule WomenInTechVic.Support.Factory do
  @moduledoc """
  Factory code for building test resources
  """
  use ExMachina.Ecto, repo: WomenInTechVic.Repo

  def online_event_factory do
    %{
      title: Faker.Company.bs(),
      scheduled_at: DateTime.add(DateTime.utc_now(), 5, :minute),
      online: true,
      description: Faker.Lorem.paragraph(),
      address: "https://meet.google.com/"
    }
  end

  def in_person_event_factory do
    %{
      title: Faker.Company.bs(),
      scheduled_at: DateTime.add(DateTime.utc_now(), 5, :minute),
      online: false,
      description: Faker.Lorem.paragraph(),
      address: "Pub around the Corner"
    }
  end

  def profile_factory do
    %{
      linked_in: "https://www.linkedin.com/in/" <> Faker.Person.name(),
      github: "https://www.github.com/" <> Faker.Pokemon.name(),
      workplace: Faker.Company.name(),
      hobbies: Faker.StarWars.planet(),
      projects: Faker.Company.bs(),
      other: Faker.Lorem.Shakespeare.romeo_and_juliet()
    }
  end
end

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
end

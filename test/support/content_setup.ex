defmodule WomenInTechVic.Support.ContentTestSetup do
  @moduledoc """
  Used for importing pre-created content resources in content tests:

  ```
  import WomenInTechVic.Support.ContentTestSetup, only: [event: 1]
  ```

  """

  import WomenInTechVic.Support.Factory, only: [insert: 1, build: 1]
  alias WomenInTechVic.Content.Event

  def online_event(_) do
    online_event =
      :online_event
      |> build()
      |> then(&struct!(Event, &1))
      |> insert()

    %{online_event: online_event}
  end

  def in_person_event(_) do
    in_person_event =
      :in_person_event
      |> build()
      |> then(&struct!(Event, &1))
      |> insert()

    %{in_person_event: in_person_event}
  end
end

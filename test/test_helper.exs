# credo:disable-for-this-file
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(WomenInTechVic.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(WomenInTechVic.Repo, :manual)
Code.put_compiler_option(:warnings_as_errors, true)
{:ok, _} = Application.ensure_all_started(:ex_machina)

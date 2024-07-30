defmodule LcHookTest.Repo do
  use Ecto.Repo,
    otp_app: :lc_hook_test,
    adapter: Ecto.Adapters.Postgres
end

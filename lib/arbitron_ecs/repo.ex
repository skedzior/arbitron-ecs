defmodule Arbitron.Repo do
  use Ecto.Repo,
    otp_app: :arbitron_ecs,
    adapter: Ecto.Adapters.Postgres
end

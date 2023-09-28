defmodule BathLARP.Repo do
  use Ecto.Repo,
    otp_app: :bathlarp,
    adapter: Ecto.Adapters.Postgres
end

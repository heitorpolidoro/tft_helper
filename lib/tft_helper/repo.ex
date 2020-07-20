defmodule TftHelper.Repo do
  use Ecto.Repo,
    otp_app: :tft_helper,
    adapter: Ecto.Adapters.Postgres
end

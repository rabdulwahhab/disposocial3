defmodule Disposocial3.Repo do
  use Ecto.Repo,
    otp_app: :disposocial3,
    adapter: Ecto.Adapters.SQLite3
end

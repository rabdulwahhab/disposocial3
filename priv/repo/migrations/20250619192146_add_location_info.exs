defmodule Disposocial3.Repo.Migrations.AddLocationInfo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :location, :string
      add :timezone, :string
      add :latitude, :float
      add :longitude, :float
    end
  end
end

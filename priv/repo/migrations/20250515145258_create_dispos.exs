defmodule Disposocial3.Repo.Migrations.CreateDispos do
  use Ecto.Migration

  def change do
    create table(:dispos) do
      add :death, :utc_datetime
      add :latitude, :float
      add :longitude, :float
      add :location, :string
      add :name, :string
      add :is_public, :boolean, default: true, null: false
      add :password, :string
      add :hashed_password, :string
      add :description, :string
      add :user_id, references(:users, type: :id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:dispos, [:user_id])
  end
end

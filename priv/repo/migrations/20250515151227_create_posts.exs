defmodule Disposocial3.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text, null: false
      add :user_id, references(:users, type: :id, on_delete: :nothing)
      add :dispo_id, references(:dispos, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:user_id])
    create index(:posts, [:dispo_id])
  end
end

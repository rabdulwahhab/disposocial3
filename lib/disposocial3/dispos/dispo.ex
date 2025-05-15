defmodule Disposocial3.Dispos.Dispo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dispos" do
    field :death, :utc_datetime
    field :latitude, :float
    field :longitude, :float
    field :location, :string
    field :name, :string
    field :is_public, :boolean, default: false
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :description, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dispo, attrs, user_scope) do
    dispo
    |> cast(attrs, [:death, :latitude, :longitude, :location, :name, :is_public, :password, :hashed_password, :description])
    |> validate_required([:death, :latitude, :longitude, :location, :name, :is_public, :password, :hashed_password, :description])
    |> validate_length(:name, min: 4, max: 30)
    |> validate_length(:description, min: 4, max: 400)
    |> put_change(:user_id, user_scope.user.id)
  end
end

defmodule Disposocial3.Dispos.Dispo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Disposocial3.Accounts.User
  alias Disposocial3.Posts.Post

  schema "dispos" do
    field :death, :utc_datetime
    field :latitude, :float
    field :longitude, :float
    field :location, :string
    field :name, :string
    field :is_public, :boolean, default: true
    field :password, :string, virtual: true, redact: true
    field :duration, :integer, virtual: true
    field :hashed_password, :string, redact: true
    field :description, :string
    belongs_to :user, User
    has_many :posts, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(dispo, attrs, user_scope) do
    dispo
    |> cast(attrs, [:death, :duration, :latitude, :longitude, :location, :name, :is_public, :password, :hashed_password, :description])
    |> validate_required([:death, :latitude, :longitude, :is_public, :description])
    |> validate_length(:name, min: 4, max: 30)
    |> validate_length(:description, min: 4, max: 400)
    |> put_change(:user_id, user_scope.user.id)
  end
end

defmodule Disposocial3.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :user_id, :id
    field :dispo_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, user_scope) do
    post
    |> cast(attrs, [:body, :dispo_id])
    |> validate_required([:body, :dispo_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end

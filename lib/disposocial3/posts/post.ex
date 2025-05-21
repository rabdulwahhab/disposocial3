defmodule Disposocial3.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Disposocial3.Accounts.User
  alias Disposocial3.Dispos.Dispo

  schema "posts" do
    field :body, :string
    belongs_to :user, User
    belongs_to :dispo, Dispo

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

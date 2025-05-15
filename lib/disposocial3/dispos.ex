defmodule Disposocial3.Dispos do
  @moduledoc """
  The Dispos context.
  """

  import Ecto.Query, warn: false
  alias Disposocial3.Repo

  alias Disposocial3.Dispos.Dispo
  alias Disposocial3.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any dispo changes.

  The broadcasted messages match the pattern:

    * {:created, %Dispo{}}
    * {:updated, %Dispo{}}
    * {:deleted, %Dispo{}}

  """
  def subscribe_dispos(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Disposocial3.PubSub, "user:#{key}:dispos")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Disposocial3.PubSub, "user:#{key}:dispos", message)
  end

  @doc """
  Returns the list of dispos.

  ## Examples

      iex> list_dispos(scope)
      [%Dispo{}, ...]

  """
  def list_dispos(%Scope{} = scope) do
    Repo.all(from dispo in Dispo, where: dispo.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single dispo.

  Raises `Ecto.NoResultsError` if the Dispo does not exist.

  ## Examples

      iex> get_dispo!(123)
      %Dispo{}

      iex> get_dispo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_dispo!(%Scope{} = scope, id) do
    Repo.get_by!(Dispo, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a dispo.

  ## Examples

      iex> create_dispo(%{field: value})
      {:ok, %Dispo{}}

      iex> create_dispo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_dispo(%Scope{} = scope, attrs) do
    with {:ok, dispo = %Dispo{}} <-
           %Dispo{}
           |> Dispo.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Updates a dispo.

  ## Examples

      iex> update_dispo(dispo, %{field: new_value})
      {:ok, %Dispo{}}

      iex> update_dispo(dispo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_dispo(%Scope{} = scope, %Dispo{} = dispo, attrs) do
    true = dispo.user_id == scope.user.id

    with {:ok, dispo = %Dispo{}} <-
           dispo
           |> Dispo.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Deletes a dispo.

  ## Examples

      iex> delete_dispo(dispo)
      {:ok, %Dispo{}}

      iex> delete_dispo(dispo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_dispo(%Scope{} = scope, %Dispo{} = dispo) do
    true = dispo.user_id == scope.user.id

    with {:ok, dispo = %Dispo{}} <-
           Repo.delete(dispo) do
      broadcast(scope, {:deleted, dispo})
      {:ok, dispo}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking dispo changes.

  ## Examples

      iex> change_dispo(dispo)
      %Ecto.Changeset{data: %Dispo{}}

  """
  def change_dispo(%Scope{} = scope, %Dispo{} = dispo, attrs \\ %{}) do
    true = dispo.user_id == scope.user.id

    Dispo.changeset(dispo, attrs, scope)
  end
end

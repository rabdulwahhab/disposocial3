defmodule Disposocial3.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `Disposocial3.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias Disposocial3.Accounts.User
  alias Disposocial3.Dispos.Dispo

  defstruct user: nil, dispo: nil

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user) do
    %__MODULE__{user: user}
  end

  def for_user(nil), do: nil

  def update_user(current_scope, %User{} = new_user) do
    %{current_scope | user: new_user}
  end

  def update_dispo(current_scope, %Dispo{} = dispo) do
    %__MODULE__{current_scope | dispo: dispo}
  end

end

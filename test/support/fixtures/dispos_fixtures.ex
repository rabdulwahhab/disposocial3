defmodule Disposocial3.DisposFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Disposocial3.Dispos` context.
  """

  @doc """
  Generate a dispo.
  """
  def dispo_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        death: ~U[2025-05-14 14:52:00Z],
        description: "some description",
        hashed_password: "some hashed_password",
        is_public: true,
        latitude: 120.5,
        location: "some location",
        longitude: 120.5,
        name: "some name",
        password: "some password"
      })

    {:ok, dispo} = Disposocial3.Dispos.create_dispo(scope, attrs)
    dispo
  end
end

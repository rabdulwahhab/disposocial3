defmodule Disposocial3.DisposTest do
  use Disposocial3.DataCase

  alias Disposocial3.Dispos

  describe "dispos" do
    alias Disposocial3.Dispos.Dispo

    import Disposocial3.AccountsFixtures, only: [user_scope_fixture: 0]
    import Disposocial3.DisposFixtures

    @invalid_attrs %{name: nil, description: nil, location: nil, password: nil, death: nil, latitude: nil, longitude: nil, is_public: nil, hashed_password: nil}

    test "list_dispos/1 returns all scoped dispos" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      other_dispo = dispo_fixture(other_scope)
      assert Dispos.list_dispos(scope) == [dispo]
      assert Dispos.list_dispos(other_scope) == [other_dispo]
    end

    test "get_dispo!/2 returns the dispo with given id" do
      scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      other_scope = user_scope_fixture()
      assert Dispos.get_dispo!(scope, dispo.id) == dispo
      assert_raise Ecto.NoResultsError, fn -> Dispos.get_dispo!(other_scope, dispo.id) end
    end

    test "create_dispo/2 with valid data creates a dispo" do
      valid_attrs = %{name: "some name", description: "some description", location: "some location", password: "some password", death: ~U[2025-05-14 14:52:00Z], latitude: 120.5, longitude: 120.5, is_public: true, hashed_password: "some hashed_password"}
      scope = user_scope_fixture()

      assert {:ok, %Dispo{} = dispo} = Dispos.create_dispo(scope, valid_attrs)
      assert dispo.name == "some name"
      assert dispo.description == "some description"
      assert dispo.location == "some location"
      assert dispo.password == "some password"
      assert dispo.death == ~U[2025-05-14 14:52:00Z]
      assert dispo.latitude == 120.5
      assert dispo.longitude == 120.5
      assert dispo.is_public == true
      assert dispo.hashed_password == "some hashed_password"
      assert dispo.user_id == scope.user.id
    end

    test "create_dispo/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Dispos.create_dispo(scope, @invalid_attrs)
    end

    test "update_dispo/3 with valid data updates the dispo" do
      scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", location: "some updated location", password: "some updated password", death: ~U[2025-05-15 14:52:00Z], latitude: 456.7, longitude: 456.7, is_public: false, hashed_password: "some updated hashed_password"}

      assert {:ok, %Dispo{} = dispo} = Dispos.update_dispo(scope, dispo, update_attrs)
      assert dispo.name == "some updated name"
      assert dispo.description == "some updated description"
      assert dispo.location == "some updated location"
      assert dispo.password == "some updated password"
      assert dispo.death == ~U[2025-05-15 14:52:00Z]
      assert dispo.latitude == 456.7
      assert dispo.longitude == 456.7
      assert dispo.is_public == false
      assert dispo.hashed_password == "some updated hashed_password"
    end

    test "update_dispo/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      dispo = dispo_fixture(scope)

      assert_raise MatchError, fn ->
        Dispos.update_dispo(other_scope, dispo, %{})
      end
    end

    test "update_dispo/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Dispos.update_dispo(scope, dispo, @invalid_attrs)
      assert dispo == Dispos.get_dispo!(scope, dispo.id)
    end

    test "delete_dispo/2 deletes the dispo" do
      scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      assert {:ok, %Dispo{}} = Dispos.delete_dispo(scope, dispo)
      assert_raise Ecto.NoResultsError, fn -> Dispos.get_dispo!(scope, dispo.id) end
    end

    test "delete_dispo/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      assert_raise MatchError, fn -> Dispos.delete_dispo(other_scope, dispo) end
    end

    test "change_dispo/2 returns a dispo changeset" do
      scope = user_scope_fixture()
      dispo = dispo_fixture(scope)
      assert %Ecto.Changeset{} = Dispos.change_dispo(scope, dispo)
    end
  end
end

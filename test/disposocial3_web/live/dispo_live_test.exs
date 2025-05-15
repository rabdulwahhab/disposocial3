defmodule Disposocial3Web.DispoLiveTest do
  use Disposocial3Web.ConnCase

  import Phoenix.LiveViewTest
  import Disposocial3.DisposFixtures

  @create_attrs %{name: "some name", description: "some description", location: "some location", password: "some password", death: "2025-05-14T14:52:00Z", latitude: 120.5, longitude: 120.5, is_public: true, hashed_password: "some hashed_password"}
  @update_attrs %{name: "some updated name", description: "some updated description", location: "some updated location", password: "some updated password", death: "2025-05-15T14:52:00Z", latitude: 456.7, longitude: 456.7, is_public: false, hashed_password: "some updated hashed_password"}
  @invalid_attrs %{name: nil, description: nil, location: nil, password: nil, death: nil, latitude: nil, longitude: nil, is_public: false, hashed_password: nil}

  setup :register_and_log_in_user

  defp create_dispo(%{scope: scope}) do
    dispo = dispo_fixture(scope)

    %{dispo: dispo}
  end

  describe "Index" do
    setup [:create_dispo]

    test "lists all dispos", %{conn: conn, dispo: dispo} do
      {:ok, _index_live, html} = live(conn, ~p"/discover")

      assert html =~ "Listing Dispos"
      assert html =~ dispo.location
    end

    test "saves new dispo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/discover")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Dispo")
               |> render_click()
               |> follow_redirect(conn, ~p"/dispos/new")

      assert render(form_live) =~ "New Dispo"

      assert form_live
             |> form("#dispo-form", dispo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#dispo-form", dispo: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/discover")

      html = render(index_live)
      assert html =~ "Dispo created successfully"
      assert html =~ "some location"
    end

    test "updates dispo in listing", %{conn: conn, dispo: dispo} do
      {:ok, index_live, _html} = live(conn, ~p"/discover")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#dispos-#{dispo.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/dispos/#{dispo}/edit")

      assert render(form_live) =~ "Edit Dispo"

      assert form_live
             |> form("#dispo-form", dispo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#dispo-form", dispo: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/discover")

      html = render(index_live)
      assert html =~ "Dispo updated successfully"
      assert html =~ "some updated location"
    end

    test "deletes dispo in listing", %{conn: conn, dispo: dispo} do
      {:ok, index_live, _html} = live(conn, ~p"/discover")

      assert index_live |> element("#dispos-#{dispo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#dispos-#{dispo.id}")
    end
  end

  describe "Show" do
    setup [:create_dispo]

    test "displays dispo", %{conn: conn, dispo: dispo} do
      {:ok, _show_live, html} = live(conn, ~p"/dispos/#{dispo}")

      assert html =~ "Show Dispo"
      assert html =~ dispo.location
    end

    test "updates dispo and returns to show", %{conn: conn, dispo: dispo} do
      {:ok, show_live, _html} = live(conn, ~p"/dispos/#{dispo}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/dispos/#{dispo}/edit?return_to=show")

      assert render(form_live) =~ "Edit Dispo"

      assert form_live
             |> form("#dispo-form", dispo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#dispo-form", dispo: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/dispos/#{dispo}")

      html = render(show_live)
      assert html =~ "Dispo updated successfully"
      assert html =~ "some updated location"
    end
  end
end

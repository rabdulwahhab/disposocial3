# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Disposocial3.Repo.insert!(%Disposocial3.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Disposocial3.{Accounts, Accounts.Scope, Dispos, Posts}

future_death = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.add(120) # 600 secs == 10 min
# 39.1806976, -77.2440064
{:ok, user1} = Accounts.register_user(%{id: 1, username: "Rayyan", email: "r@r.com", password: "testtesttest"})
{:ok, user2} = Accounts.register_user(%{id: 2, username: "Man", email: "m@m.com", password: "testtesttest"})
scope1 = Scope.for_user(user1)
scope2 = Scope.for_user(user2)
{:ok, _} = Dispos.create_dispo(scope1, %{id: 1, name: "Dispo1", description: "I am a description", latitude: 39.002, longitude: -77.00, is_public: true, user_id: 1, death: future_death, location: "Germantown, MD, USA"})
{:ok, _} = Dispos.create_dispo(scope2, %{id: 2, name: "Dispo2", description: "Description1", latitude: 23.232, longitude: 51.0, is_public: true, user_id: 2, death: future_death, location: "Jackson, TN, USA"})
{:ok, _} = Posts.create_post(scope1, %{body: "Hello world!", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope1, %{body: "Just some text", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope1, %{body: "Just some text", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope1, %{body: "Just some text", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope1, %{body: "Just some text", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope2, %{body: "La ilaha ila Allah", user_id: 1, dispo_id: 1})
{:ok, _} = Posts.create_post(scope2, %{body: "La ilaha ila Allah", user_id: 2, dispo_id: 2})
{:ok, _} = Posts.create_post(scope2, %{body: "La ilaha ila Allah", user_id: 2, dispo_id: 2})
{:ok, _} = Posts.create_post(scope2, %{body: "There is nothing worthy of worship in truth except Allah", user_id: 2, dispo_id: 1})

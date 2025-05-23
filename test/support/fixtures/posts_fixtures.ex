defmodule Disposocial3.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Disposocial3.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body"
      })

    {:ok, post} = Disposocial3.Posts.create_post(scope, attrs)
    post
  end
end

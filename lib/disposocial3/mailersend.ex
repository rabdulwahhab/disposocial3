defmodule Disposocial3.Mailersend do
  @moduledoc """
  This module contains the Elixir API for Mailersend's Email API. They dont have a Swoosh adapter so
  this will do as a drop in replacement.
  """
  require Logger

  def deliver(%Swoosh.Email{
        subject: subject,
        from: {name, from},
        to: [{_, to}],
        text_body: text_body,
        html_body: html_body
      }) do
    body = %{
      "from" => %{
        "email" => from,
        "name" => name
      },
      "to" => [
        %{"email" => to}
      ],
      "subject" => subject,
      "text" => text_body,
      "html" => html_body
    }

    options =
      [
        headers: [
          {"Content-Type", "application/json"},
          {"X-Requested-With", "XMLHttpRequest"},
          {"Authorization",
           "Bearer #{Application.get_env(:disposocial3, Disposocial3.Mailersend)[:api_key]}"}
        ],
        body: Jason.encode!(body)
      ]

    {_, response} = Req.post("https://api.mailersend.com/v1/email", options)
    Logger.info(inspect(response, pretty: true))

    case response.status do
      202 -> {:ok, response}
      _ -> {:error, response}
    end
  end
end

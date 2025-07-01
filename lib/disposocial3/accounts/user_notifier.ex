defmodule Disposocial3.Accounts.UserNotifier do
  import Swoosh.Email

  require Logger
  alias Disposocial3.Mailer
  alias Disposocial3.Mailersend
  alias Disposocial3.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    Logger.info("Sending email (#{subject})")

    email =
      new()
      |> to(recipient)
      |> from({"Disposocial", "noreply@disposocial.com"})
      |> subject(subject)
      |> text_body(body)

    if Mix.env() == :dev do
      with {:ok, _metadata} <- Mailer.deliver(email) do
        {:ok, email}
      end
    else
      with {:ok, _metadata} <- Mailersend.deliver(email) do
        {:ok, email}
      end
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    Hi,

    You can update your email address by visiting the URL below:

    #{url}

    If you didn't request this change, you can safely ignore this message.

    Thanks,
    The Disposocial Team
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """

    Hi,

    You can log into your Disposocial account by visiting the URL below:

    #{url}

    If you didn't request this email, you can safely ignore this message.

    Thanks,
    The Disposocial Team
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    Hi,

    You can confirm your Disposocial account by visiting the link below:

    #{url}

    If you didn't create an account with us, you can safely ignore this message.

    Thanks,
    The Disposocial Team
    """)
  end
end

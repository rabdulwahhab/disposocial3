defmodule Disposocial3Web.Presence do
  use Phoenix.Presence,
    otp_app: :disposocial3,
    pubsub_server: Disposocial3.PubSub
end

defmodule Faqcheck.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Faqcheck.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Faqcheck.PubSub},
      # Start a worker by calling: Faqcheck.Worker.start_link(arg)
      # {Faqcheck.Worker, arg}
      {OpenIDConnect.Worker, Application.get_env(:faqcheck, :openid_connect_providers)},
      Faqcheck.Scheduler,
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Faqcheck.Supervisor)
  end
end

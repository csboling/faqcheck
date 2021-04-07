defmodule FaqcheckWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    version = load_version()
    Logger.info("loaded app version: #{inspect(version)}")
    Application.put_env(:faqcheck_web, :version, version)

    children = [
      # Start the Telemetry supervisor
      FaqcheckWeb.Telemetry,
      # Start the Endpoint (http/https)
      FaqcheckWeb.Endpoint
      # Start a worker by calling: FaqcheckWeb.Worker.start_link(arg)
      # {FaqcheckWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FaqcheckWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FaqcheckWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def load_version() do
    [hash, date] = case File.read(Path.join([File.cwd!, "VERSION.txt"])) do
      {:ok, data} -> data |> String.split("\n")
      _ -> [nil, nil]
    end
    %{gitsha: hash, date: date}
  end
end

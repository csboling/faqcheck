defmodule Faqcheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :faqcheck,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Faqcheck.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ecto_interval, "~> 0.2.3"},
      {:ecto_sql, "~> 3.4"},
      {:enum_type, "~> 1.1.3"},
      {:filterable, "~> 0.7.3"},
      {:geo_postgis, "~> 3.3.1"},
      {:httpoison, "~> 1.8.0"},
      {:jason, "~> 1.0"},
      {:paper_trail, "~> 0.12.3"},
      {:poison, "~> 4.0.1"},
      {:pow, "~> 1.0.24"},
      {:openid_connect, "~> 0.2.2"},
      {:pbkdf2_elixir, "~> 1.4.1"},
      {:phoenix_pubsub, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:quarto, "~> 1.1.5"},
      {:xlsxir, "~> 1.6.4"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end

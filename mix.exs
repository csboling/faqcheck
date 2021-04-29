defmodule Faqcheck.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
    ]
  end

  # thanks to https://fiqus.coop/en/2019/07/15/add-git-commit-info-to-your-elixir-phoenix-app/
  defp update_version(_) do
    contents = write_version()
    Mix.shell().info("updated app version: #{inspect(contents)}")
  end

  defp get_commit_sha() do
    System.cmd("git", ["describe", "--always", "--dirty"])
    |> elem(0)
    |> String.trim()
  end

  defp get_commit_date() do
    [sec, tz] =
      System.cmd("git", ~w|log -1 --date=raw --format=%cd|)
      |> elem(0)
      |> String.split(~r/\s+/, trim: true)
      |> Enum.map(&String.to_integer/1)

    DateTime.from_unix!(sec + tz * 36)
  end

  defp write_version() do
    contents = [
      get_commit_sha(),
      get_commit_date(),
    ]
    File.write("VERSION.txt", Enum.join(contents, "\n"), [:write])
    contents
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp deps do
    []
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"],
      compile: ["compile --all-warnings --warnings-as-errors", &update_version/1],
    ]
  end
end

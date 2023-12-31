defmodule Arbitron.MixProject do
  use Mix.Project

  def project do
    [
      app: :arbitron_ecs,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
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
      mod: {Arbitron.Application, []},
      extra_applications: [:logger, :runtime_tools, :wx, :observer]
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
      {:phoenix, "~> 1.6.14"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:gettext, "~> 0.18"},
      {:plug_cowboy, "~> 2.5"},
      {:broadway, "~> 1.0.7"},
      {:broadway_dashboard, "~> 0.3.0"},
      {:redix, "~> 1.2"},
      {:poison, "~> 5.0"},
      {:websockex, "~> 0.4.3"},
      {:jason, "~> 1.4"},
      {:decimal, "~> 2.0"},
      {:ex2ms, "~> 1.6"},
      # {:ethereumex, "~> 0.7.0"},
      {:ex_abi, "~> 0.6.3"},
      # {:exw3, "~> 0.6"},
      # {:web3x, "~> 0.6.4"},
      {:math, "~> 0.6.0"},
      # {:ex_keccak, "~> 0.2.0"},
      {:castore, ">= 0.0.0"},
      {:httpoison, "~> 1.8"},
      {:typed_struct, "~> 0.1.4"},
      {:contex, git: "https://github.com/mindok/contex"},
      {:cachex, "~> 3.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end

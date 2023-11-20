defmodule PlugStream.MixProject do
  use Mix.Project

  def project do
    [
      app: :plug_stream,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PlugStream.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_csv, "~> 1.2.0"},
      {:plug_cowboy, "~> 2.6"}
    ]
  end
end

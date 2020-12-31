defmodule Marvin.MixProject do
  use Mix.Project

  def project do
    [
      app: :marvin_load_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: description(),
      package: package(),
      name: "Marvin Load Test",
      source_url: "https://github.com/cardinalblue/marvin"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:finch, "~> 0.6"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "A light-weight load testing tool."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cardinalblue/marvin"}
    ]
  end

  defp escript do
    [main_module: Marvin.CLI]
  end

  defp elixirc_paths(_), do: ["lib"]
end

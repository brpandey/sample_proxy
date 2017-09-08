defmodule SampleProxy.Mixfile do
  use Mix.Project


  def project do
    [
      app: :sample_proxy,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end


  def application do
    [
      applications: [:logger, :httpoison, :cowboy, :plug],
      mod: {SampleProxy, nil}
    ]
  end


  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "1.0.4"},
      {:plug, "~> 1.3"}, 
      {:httpoison, "~> 0.11.0"},
      {:poison, "~> 3.0"}
    ]
  end
end

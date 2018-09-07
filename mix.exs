defmodule ExGun.MixProject do
  use Mix.Project


  def project do
    [
      app: :ex_gun,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end


  # Application Structure
  def application do
    [
      extra_applications: [:logger],
      mod: {ExGun.Application, []}
    ]
  end


  # Dependencies
  defp deps do
    [
      {:httpoison,     "~> 1.2.0"},
      {:jason,         "~> 1.1.0"},
      {:cowboy,        "~> 2.4.0"},
      {:plug,          "~> 1.6.2"},
      {:better_params, "~> 0.5.0"},
    ]
  end
end

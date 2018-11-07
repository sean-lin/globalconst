defmodule GlobalConst.MixProject do
  use Mix.Project

  def project do
    [
      app: :globalconst,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      name: :globalconst,
      source_url: "https://github.com/sean-lin/globalconst"
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
      {:fastglobal, "~> 1.0", only: :dev},
      {:benchfella, "~> 0.3.0", only: :dev}
    ]
  end

  defp package do
    [
      name: :globalconst,
      description:
        "GlobalConst converts large Key-Value entities to a module to make fast accessing by thousands of processes.",
      maintainers: [],
      licenses: ["MIT"],
      files: ["lib/*", "mix.exs", "README*", "LICENSE*"],
      links: %{
        "GitHub" => "https://github.com/sean-lin/globalconst"
      }
    ]
  end
end

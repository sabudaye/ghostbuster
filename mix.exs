defmodule Ghostbuster.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Set of useful functions to catch leaked processes in runtime"

  def project do
    [
      app: :ghostbuster,
      version: @version,
      elixir: "~> 1.8",
      deps: deps(),
      description: @description,
      package: package(),
      docs: [
        extras: [
          "README.md",
        ],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/sabudaye/ghostbuster"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Stanislav Budaev"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/elixir-ecto/postgrex"}
    ]
  end
end

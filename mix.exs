defmodule ExOSC.MixProject do
  use Mix.Project

  @github_url "https://github.com/wisq/ex_osc"

  def project do
    [
      app: :ex_osc,
      version: "0.1.1",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps(),
      source_url: @github_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    ExOSC is a library for sending and receiving messages to/from audio
    hardware that supports the OpenSoundControl 1.0 protocol.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md", "LICENSE"],
      maintainers: ["Adrian Irving-Beer"],
      licenses: ["MIT"],
      links: %{GitHub: @github_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      groups_for_modules: [
        "Client API": ~r/^ExOSC\./,
        "OSC Protocol": ~r/^OSC\./
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:gen_stage, "~> 1.2.1"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_git_test, github: "wisq/ex_git_test", tag: "main", only: :test, runtime: false}
    ]
  end
end

defmodule Noizu.RuleEngine.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_rule_engine,
     version: "0.1.0",
     elixir: "~> 1.3",
     package: package(),
     deps: deps(),
     description: "Noizu Rule Engine",
     docs: docs()
   ]
  end # end project

  defp package do
    [
      maintainers: ["noizu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/noizu/RuleEngine"}
    ]
  end # end package

  def application do
    [ applications: [:logger] ]
  end # end application

  defp deps do
    [
      {:ex_doc, "~> 0.16.2", only: [:dev], optional: true}, # Documentation Provider
      {:markdown, github: "devinus/markdown", only: [:dev], optional: true}, # Markdown processor for ex_doc
    ]
  end # end deps

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu/RuleEngine/blob/master/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end # end docs
end # end defmodule

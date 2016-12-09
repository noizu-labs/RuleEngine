defmodule Noizu.RuleEngine.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_rule_engine,
     version: "0.0.1",
     elixir: "~> 1.3",
     package: package(),
     deps: deps(),
     description: "Noizu Rule Engine"
   ]
  end

  defp package do
    [
      maintainers: ["noizu"],
      licenses: ["Apache License 2.0"],
      links: %{"GitHub" => "https://github.com/noizu/RuleEngine"}
    ]
  end

  def application do
    [ applications: [:logger] ]
  end

  defp deps do
    [ { :ex_doc, "~> 0.11", only: [:dev] } ]
  end


end

#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_rule_engine,
     version: "0.2.3",
     elixir: "~> 1.13",
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
    [ applications: [:logger] ++ (Mix.env in [:dev, :test] && [:ex_doc] || []) ]
  end # end application

  defp deps do
    [
      {:ex_doc, "~> 0.28.3", only: [:dev, :test], runtime: false}, # Documentation Provider
      {:noizu_core, "~> 1.0"},
      {:plug, "~> 1.0", optional: true},
      {:elixir_uuid, "~> 1.2", only: :test, optional: true}
    ]
  end # end deps

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu-labs/RuleEngine/blob/master/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end # end docs
end # end defmodule

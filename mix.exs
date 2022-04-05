#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_rule_engine,
     version: "0.2.1",
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
    [ applications: [:logger] ]
  end # end application

  defp deps do
    [
      {:ex_doc, "~> 0.28.3", only: [:dev, :test], optional: true}, # Documentation Provider
      {:markdown, github: "devinus/markdown", only: [:dev], optional: true}, # Markdown processor for ex_doc
      {:noizu_core, github: "noizu/ElixirCore", tag: "1.0.12", optional: true},
      {:plug, "~> 1.0", optional: true},
      {:elixir_uuid, "~> 1.2", only: :test, optional: true}
    ]
  end # end deps

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu/RuleEngine/blob/master/%{path}#L%{line}",
      extras: ["README.md"]
    ]
  end # end docs
end # end defmodule

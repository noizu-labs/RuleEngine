#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Node.NotNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    negate: Noizu.RuleEngine.Behaviour.Node.t
  }

  defstruct [
    name: nil,
    negate: nil
  ]

  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.NotNode{negate: %Noizu.RuleEngine.Node.ScalarNode{value: false}}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.NotNode{negate: %Noizu.RuleEngine.Node.ScalarNode{value: true}}, %{})
    {:ok, false}
  """
  def execute(node = %Noizu.RuleEngine.Node.NotNode{}, context) do
    case Noizu.RuleEngine.NodeProtocol.execute(node.negate, context) do
      {:ok, true} -> {:ok, false}
      {:ok, false} -> {:ok, true}
      _unexpected ->
        error = Noizu.RuleEngine.Exception.Basic.new(:unexpected_value, "Xor recieved non boolean response from argument")
       {:error, error}
    end
  end

  def definition(node = %Noizu.RuleEngine.Node.NotNode{}, _level) do
    if node.name != nil do
      "#{node.name}:Not(?)"
    else
      "Not(?)"
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.NotNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.NotNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.NotNode.definition(node, detail_level)
  end
end

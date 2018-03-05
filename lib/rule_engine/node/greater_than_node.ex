#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Node.GreaterThanNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    lhs: Noizu.RuleEngine.Behaviour.Node.t,
    rhs: Noizu.RuleEngine.Behaviour.Node.t,
  }

  defstruct [
    name: nil,
    lhs: nil,
    rhs: nil,
  ]

  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.GreaterThanNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: 6}  }, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.GreaterThanNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: 8}  }, %{})
    {:ok, false}

    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.GreaterThanNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}  }, %{})
    {:ok, false}
  """
  def execute(node = %Noizu.RuleEngine.Node.GreaterThanNode{}, context) do
    lhs = Noizu.RuleEngine.NodeProtocol.execute(node.lhs, context)
    rhs = Noizu.RuleEngine.NodeProtocol.execute(node.rhs, context)

    case {lhs, rhs} do
      {{:ok, lhs_value}, {:ok, rhs_value}} ->
        {:ok, lhs_value > rhs_value}
      _ ->
        error = Noizu.RuleEngine.Exception.Basic.new(:arguement_error, "Unable to process LHS and RHS arguments of GreaterThanNode")
        {:error, error}
    end
  end

  def definition(node = %Noizu.RuleEngine.Node.GreaterThanNode{}, _level) do
    if node.name != nil do
      "#{node.name}:GreaterThan(?,?)"
    else
      "GreaterThan(?,?)"
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.GreaterThanNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.GreaterThanNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.GreaterThanNode.definition(node, detail_level)
  end
end

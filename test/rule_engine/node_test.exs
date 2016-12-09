defmodule Noizu.RuleEngine.NodeTest do
  use ExUnit.Case
  doctest Noizu.RuleEngine.Node.ScalarNode
  doctest Noizu.RuleEngine.Node.CalculatedValueNode
  doctest Noizu.RuleEngine.Node.AndNode
  doctest Noizu.RuleEngine.Node.OrNode
  doctest Noizu.RuleEngine.Node.XorNode
  doctest Noizu.RuleEngine.Node.NotNode
  doctest Noizu.RuleEngine.Node.IfNode
  doctest Noizu.RuleEngine.Node.EqualsNode
  doctest Noizu.RuleEngine.Node.NotEqualsNode

  doctest Noizu.RuleEngine.Node.LessThanNode
  doctest Noizu.RuleEngine.Node.GreaterThanNode
  doctest Noizu.RuleEngine.Node.LessThanOrEqualNode
  doctest Noizu.RuleEngine.Node.GreaterThanOrEqualNode

  doctest Noizu.RuleEngine.Node.UserDefinedNode


  test "Not Node Illegal Value" do
    {:error, _details} = Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.NotNode{negate: %Noizu.RuleEngine.Node.ScalarNode{value: 1234}}, %{})
  end

end

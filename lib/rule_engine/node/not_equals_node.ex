defmodule Noizu.RuleEngine.Node.NotEqualsNode do
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
    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.NotEqualsNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}  }, %{})
    {:ok, false}

    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.NotEqualsNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: :not_seven}  }, %{})
    {:ok, true}
  """
  def execute(node = %Noizu.RuleEngine.Node.NotEqualsNode{}, context) do
    {:ok, Noizu.RuleEngine.NodeProtocol.execute(node.lhs, context) != Noizu.RuleEngine.NodeProtocol.execute(node.rhs, context)}
  end

  def definition(node = %Noizu.RuleEngine.Node.NotEqualsNode{}, _level) do
    if node.name != nil do
      "#{node.name}:NotEquals(?,?)"
    else
      "NotEquals(?,?)"
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.NotEqualsNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.NotEqualsNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.NotEqualsNode.definition(node, detail_level)
  end
end



defmodule Noizu.RuleEngine.Node.EqualsNode do
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
    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.EqualsNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}  }, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.EqualsNode{lhs: %Noizu.RuleEngine.Node.ScalarNode{value: 7}, rhs: %Noizu.RuleEngine.Node.ScalarNode{value: :not_seven}  }, %{})
    {:ok, false}
  """
  def execute(node = %Noizu.RuleEngine.Node.EqualsNode{}, context) do
    {:ok, Noizu.RuleEngine.NodeProtocol.execute(node.lhs, context) == Noizu.RuleEngine.NodeProtocol.execute(node.rhs, context)}
  end

  def definition(node = %Noizu.RuleEngine.Node.EqualsNode{}, _level) do
    if node.name != nil do
      "#{node.name}:Equals(?,?)"
    else
      "Equals(?,?)"
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.EqualsNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.EqualsNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.EqualsNode.definition(node, detail_level)
  end
end

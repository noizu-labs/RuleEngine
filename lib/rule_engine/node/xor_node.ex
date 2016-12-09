defmodule Noizu.RuleEngine.Node.XorNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    arguments: [Noizu.RuleEngine.Behaviour.Node.t]
  }

  defstruct [
    name: nil,
    arguments: []
  ]


  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.XorNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.XorNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}, %Noizu.RuleEngine.Node.ScalarNode{value: false}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.XorNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}, %Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, false}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.XorNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: false}, %Noizu.RuleEngine.Node.ScalarNode{value: false}]}, %{})
    {:ok, false}
  """
  def execute(node = %Noizu.RuleEngine.Node.XorNode{}, context) do
      {:ok, check_children(node.arguments, context)}
  end

  def definition(node = %Noizu.RuleEngine.Node.XorNode{}, _level) do
    if node.name != nil do
      "#{node.name}:Xor(?)"
    else
      "Xor(?)"
    end
  end

  # Helpers
  defp check_children(:nil, _acc, _context) do
    false
  end

  defp check_children([], 1, _context) do
    true
  end

  defp check_children([], _acc, _context) do
    false
  end

  defp check_children([h|t], acc = 1, context) do
    case Noizu.RuleEngine.NodeProtocol.execute(h, context) do
      {:ok, true} -> false
        _ -> check_children(t,  acc, context)
    end
  end

  defp check_children([h|t], acc = 0, context) do
    case Noizu.RuleEngine.NodeProtocol.execute(h, context) do
      {:ok, true} -> check_children(t, acc + 1, context)
        _ -> check_children(t,  acc, context)
    end
  end

  defp check_children(children, context) do
    check_children(children, 0, context)
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.XorNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.XorNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.XorNode.definition(node, detail_level)
  end
end

defmodule Noizu.RuleEngine.Node.OrNode do
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
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.OrNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.OrNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}, %Noizu.RuleEngine.Node.ScalarNode{value: false}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.OrNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: false}, %Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.OrNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: false}, %Noizu.RuleEngine.Node.ScalarNode{value: false}]}, %{})
    {:ok, false}
  """
  def execute(node = %Noizu.RuleEngine.Node.OrNode{}, context) do
      {:ok, check_children(node.arguments, context)}
  end

  def definition(node = %Noizu.RuleEngine.Node.OrNode{}, _level) do
    if node.name != nil do
      "#{node.name}:Or(?)"
    else
      "Or(?)"
    end
  end

  # Helpers
  defp check_children(:nil, _context) do
    false
  end

  defp check_children([], _context) do
    false
  end

  defp check_children([h|t], context) do
    case Noizu.RuleEngine.NodeProtocol.execute(h, context) do
      {:ok, true} -> true
        _ -> check_children(t, context)
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.OrNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.OrNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.OrNode.definition(node, detail_level)
  end
end

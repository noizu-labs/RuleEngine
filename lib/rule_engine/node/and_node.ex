defmodule Noizu.RuleEngine.Node.AndNode do
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
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.AndNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, true}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.AndNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}, %Noizu.RuleEngine.Node.ScalarNode{value: false}]}, %{})
    {:ok, false}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.AndNode{arguments: [%Noizu.RuleEngine.Node.ScalarNode{value: true}, %Noizu.RuleEngine.Node.ScalarNode{value: true}]}, %{})
    {:ok, true}
  """
  def execute(node = %Noizu.RuleEngine.Node.AndNode{}, context) do
      {:ok, check_children(node.arguments, context)}
  end

  def definition(node = %Noizu.RuleEngine.Node.AndNode{}, _level) do
    if node.name != nil do
      "#{node.name}:And(?)"
    else
      "And(?)"
    end
  end

  # Helpers
  defp check_children(:nil, _context) do
    false
  end

  defp check_children([], _context) do
    true
  end

  defp check_children([h|t], context) do
    case Noizu.RuleEngine.NodeProtocol.execute(h, context) do
      {:ok, true} -> check_children(t, context)
        _ -> false
    end
  end



end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.AndNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.AndNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.AndNode.definition(node, detail_level)
  end
end

defmodule Noizu.RuleEngine.Node.CalculatedValueNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    key: any
  }

  defstruct [
    name: nil,
    key: nil
  ]

  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.CalculatedValueNode{key: :test}, %{test: 1234})
    {:ok, 1234}

  """
  def execute(node = %Noizu.RuleEngine.Node.CalculatedValueNode{}, context) do
    if Map.has_key?(context, node.key) do
      {:ok, context[node.key]}
    else
       error = Noizu.RuleEngine.Exception.Basic.new(:key_not_found, "Unable to find key[#{inspect node.key}] in context")
      {:error, error}
    end
  end

  def definition(node = %Noizu.RuleEngine.Node.CalculatedValueNode{}, _level) do
    if node.name != nil do
      "#{node.name}:CalculatedValue(#{inspect node.key})"
    else
      "CalculatedValue(#{inspect node.key})"
    end # end if ndoe.name != nil
  end #end def definition/2

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.CalculatedValueNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.CalculatedValueNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.CalculatedValueNode.definition(node, detail_level)
  end
end

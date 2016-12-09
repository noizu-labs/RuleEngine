defmodule Noizu.RuleEngine.Node.IfNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    constraint: Noizu.RuleEngine.Behaviour.Node.t,
    if_then: Noizu.RuleEngine.Behaviour.Node.t,
    else_then: Noizu.RuleEngine.Behaviour.Node.t
  }

  defstruct [
    name: nil,
    constraint: nil,
    if_then: nil,
    else_then: nil,
  ]


  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.IfNode{constraint: %Noizu.RuleEngine.Node.ScalarNode{value: true}, if_then: %Noizu.RuleEngine.Node.ScalarNode{value: "IfBlockHit"}, else_then: %Noizu.RuleEngine.Node.ScalarNode{value: "ElseBlockHit"} }, %{})
    {:ok, "IfBlockHit"}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.IfNode{constraint: %Noizu.RuleEngine.Node.ScalarNode{value: false}, if_then: %Noizu.RuleEngine.Node.ScalarNode{value: "IfBlockHit"}, else_then: %Noizu.RuleEngine.Node.ScalarNode{value: "ElseBlockHit"} }, %{})
    {:ok, "ElseBlockHit"}

    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.IfNode{constraint: %Noizu.RuleEngine.Node.ScalarNode{value: false}, if_then: %Noizu.RuleEngine.Node.ScalarNode{value: "IfBlockHit"}}, %{})
    {:ok, :no_else_block}
  """
  def execute(node = %Noizu.RuleEngine.Node.IfNode{}, context) do
      case Noizu.RuleEngine.NodeProtocol.execute(node.constraint, context) do

        {:ok, true} ->
          Noizu.RuleEngine.NodeProtocol.execute(node.if_then, context)

        {:ok, false} ->
          if (node.else_then != nil) do
            Noizu.RuleEngine.NodeProtocol.execute(node.else_then, context)
          else
            {:ok, :no_else_block}
          end

        _unexpected ->
          error = Noizu.RuleEngine.Exception.Basic.new(:unexpected_value, "Xor recieved non boolean response from argument")
         {:error, error}
      end
  end

  def definition(node = %Noizu.RuleEngine.Node.IfNode{}, _level) do
    if node.name != nil do
      "#{node.name}:If(?) Then ? Else ?"
    else
      "If(?) Then ? Else ?"
    end
  end

end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.IfNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.IfNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.IfNode.definition(node, detail_level)
  end
end

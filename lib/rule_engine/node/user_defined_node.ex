defmodule Noizu.RuleEngine.Node.UserDefinedNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    method: Any, # Todo lookup typespec for lambda
  }

  defstruct [
    name: nil,
    method: nil
  ]

  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute( %Noizu.RuleEngine.Node.UserDefinedNode{method: fn(_c) -> {:ok, :executed_lambda} end}, %{})
    {:ok, :executed_lambda}
  """
  def execute(%Noizu.RuleEngine.Node.UserDefinedNode{method: method}, context) when is_function(method) do
    method.(context)
  end

  def execute(%Noizu.RuleEngine.Node.UserDefinedNode{}, _context) do
    error = Noizu.RuleEngine.Exception.Basic.new(:user_defined_method_not_callable, "UserDefinedNodes require that their method property be a function/callable.")
    {:error, error}
  end

  def definition(node = %Noizu.RuleEngine.Node.UserDefinedNode{}, _level) do
    if node.name != nil do
      "#{node.name}:UserDefined(?)"
    else
      "UserDefined(?)"
    end
  end
end

# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.UserDefinedNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.UserDefinedNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.UserDefinedNode.definition(node, detail_level)
  end
end

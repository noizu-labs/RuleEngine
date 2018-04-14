defmodule Noizu.RuleEngine.Op.GetOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    entity: any,
    field: any,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    entity: :global,
    field: nil,
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.GetOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, _options) do
    #@TODO support for deep lookup entity[p][a][t][h]
    cond do
      this.entity == :global -> Noizu.RuleEngine.StateProtocol.get!(state, this.field, context)
      true -> Noizu.RuleEngine.StateProtocol.get!(state, this.entity, this.field, context)
    end
  end

  #---------------------
  # identifier/3
  #---------------------
  def identifier(node, _state, _context), do: Noizu.RuleEngine.Script.Helper.identifier(node)

  #---------------------
  # identifier/4
  #---------------------
  def identifier(node, _state, _context, _options), do: Noizu.RuleEngine.Script.Helper.identifier(node)

  #---------------------
  # render/3
  #---------------------
  def render(node, state, context), do: render(node, state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(node, state, context, options) do
    depth = options[:depth] || 0
    prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
    id = identifier(node, state, context, options)
    "#{prefix}#{id} [GET #{inspect node.entity}.#{node.field}]\n"
  end
end
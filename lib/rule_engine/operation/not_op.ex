defmodule Noizu.RuleEngine.Op.NotOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    argument: any,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    argument: nil,
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.AndOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, options) do
    {o, s} = Noizu.RuleEngine.ScriptProtocol.execute!(this.argument, state, context, options)
    {!o, s}
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
  def render(node, state, context), do: Helper.render_arg_list("[NOT]", identifier(node), [node.argument], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(node, state, context, options), do: Helper.render_arg_list("[NOT]", identifier(node), [node.argument], state, context, options)
end
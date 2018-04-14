defmodule Noizu.RuleEngine.Op.UserDefinedOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    user_defined: any, # MFA or function
    arguments: list
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    user_defined: nil,
    arguments: list,
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.UserDefinedOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, options) do
    case this.user_defined do
      {m, f, 3} ->
        :erlang.apply(m, f, [state, context, options])
      {m, f, 4} ->
        :erlang.apply(m, f, [this.arguments, state, context, options])
      l when is_function(l, 3) ->
        l.(state, context, options)
      l when is_function(l, 4) ->
        l.(this.arguments, state, context, options)
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
  def render(node, state, context), do: Helper.render_arg_list("[USER_DEFINED #{inspect node.name || node.user_defined}]", identifier(node), node.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(node, state, context, options), do: Helper.render_arg_list("[USER_DEFINED #{inspect node.name || node.user_defined}]", identifier(node), node.arguments || [], state, context, options)
end
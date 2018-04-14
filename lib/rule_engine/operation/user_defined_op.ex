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
    arguments: [],
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
  def identifier(this, _state, _context), do: Helper.identifier(this)

  #---------------------
  # identifier/4
  #---------------------
  def identifier(this, _state, _context, _options), do: Helper.identifier(this)

  #---------------------
  # render/3
  #---------------------
  def render(this, state, context), do: Helper.render_arg_list("[USER_DEFINED #{inspect this.name || this.user_defined}]", identifier(this, state, context), this.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(this, state, context, options), do: Helper.render_arg_list("[USER_DEFINED #{inspect this.name || this.user_defined}]", identifier(this, state, context, options), this.arguments || [], state, context, options)
end
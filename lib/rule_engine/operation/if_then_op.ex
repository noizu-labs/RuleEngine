defmodule Noizu.RuleEngine.Op.IfThenOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    condition_clause: any,
    then_clause: any,
    else_clause: any,
    settings: Keyword.t,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    condition_ckayse: nil,
    then_clause: nil,
    else_clause: nil,
    settings: [async?: :auto, raise_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.IfThenOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, options) do
    async? = cond do
      Enum.member?([true, :auto, :required], this.settings[:async?]) && (options[:settings][:supports_async?] == true) -> true
      this.settings[:async?] == :required -> raise "[ScriptError] Unable to perform required async execute on #{this.__struct__} - #{identifier(this, state, context)}"
      true -> false
    end

    {condition, s} = Noizu.RuleEngine.ScriptProtocol.execute!(this.condition_clause, state, context, options)
    options_b = put_in(options, [:list_async?], async?)
    if condition do
      Noizu.RuleEngine.ScriptProtocol.execute!(this.then_clause, state, context, options_b)
    else
      Noizu.RuleEngine.ScriptProtocol.execute!(this.else_clause, state, context, options_b)
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
      options_b = put_in(options, [:depth], depth + 1)
      id = identifier(node, state, context, options)
      """
      #{prefix}#{id} [if]
      #{prefix} (CONDITION CLAUSE)
      #{Noizu.RuleEngine.ScriptProtocol.render(node.condition_clause, state, context, options_b)}
      #{prefix} (THEN CLAUSE)
      #{Noizu.RuleEngine.ScriptProtocol.render(node.then_clause, state, context, options_b)}
      #{prefix} (ELSE CLAUSE)
      #{Noizu.RuleEngine.ScriptProtocol.render(node.else_clause, state, context, options_b)}
      """
  end
end
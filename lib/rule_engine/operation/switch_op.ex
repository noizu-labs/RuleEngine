#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Op.SwitchOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    condition_clause: any,
    switch: Map.t,
    default: any,
    settings: Keyword.t,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    condition_clause: nil,
    switch: %{},
    default: nil,
    settings: [async?: :auto, throw_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.SwitchOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, options) do
    {selector, state} = Noizu.RuleEngine.ScriptProtocol.execute!(this.condition_clause, state, context, options)
    cond do
      Map.has_key?(this.switch, selector) ->
        Noizu.RuleEngine.ScriptProtocol.execute!(this.switch[selector], state, context, options)
      this.default ->
        Noizu.RuleEngine.ScriptProtocol.execute!(this.default, state, context, options)
      true ->
        throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] #{identifier(this, state, context, options)} No Switch Clause Matches #{inspect selector} and no default provided")
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
  def render(this, state, context), do: render(this, state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(this, state, context, options) do
    tag = "Switch"
    identifier = identifier(this, state, context, options)
    depth = options[:depth] || 0
    prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
    options_b = put_in(options, [:depth], depth + 1)
    c = Noizu.RuleEngine.ScriptProtocol.render(this.argument, state, context, options_b)
    r = Enum.map(this.switch, fn({k,v}) -> Noizu.RuleEngine.ScriptProtocol.render(v && update_in(v, [Access.key(:identifier)], &("#{inspect k} #{inspect &1}")), state, context, options_b) end)
    """
    #{prefix}#{identifier} [#{tag}]
    #{prefix} arg
    #{c}
    #{prefix} clauses
    #{Enum.join(r, "")}
    """
  end
end
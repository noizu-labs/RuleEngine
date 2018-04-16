#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Op.ArithmeticOp do
  @type t :: %__MODULE__{
               name: String.t | nil,
               description: String.t | nil,
               identifier: String.t | list | tuple, # Materialized Path.
               arguments: list,
               operation: :"+" | :"-" | :"*" | :"/" | :"^",
               arithmetic_strategy: any,
               settings: Keyword.t,
             }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    arguments: [],
    operation: :"+",
    arithmetic_strategy: :default,
    settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.ArithmeticOp do
  alias Noizu.RuleEngine.Helper

  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, context, options) do
    cond do
      Enum.member?([true, :auto, :required], this.settings[:async?]) && (options[:settings] && options.settings.supports_async? == true) -> execute!(:async, this, state, context, options)
      this.settings[:async?] == :required -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] Unable to perform required async execute on #{this.__struct__} - #{identifier(this, state, context)}", 310)
      true -> execute!(:sync, this, state, context, options)
    end
  end

  def perform_arithmetic(left_arg, right_arg, this, state, context, options) do
    cs = this.arithmetic_strategy || :default
    cond do
      cs == :default ->
        c = case this.operation do
          :"+" -> left_arg + right_arg
          :"-" -> left_arg - right_arg
          :"*" -> left_arg * right_arg
          :"/" -> left_arg / right_arg
          :"^" -> :math.pow(left_arg, right_arg)
        end
        {c, nil}
      match?({_,_,3}, cs) ->
        {m,f,3} = cs
        {:erlang.apply(m, f, [this.operation, left_arg, right_arg]), nil}
      match?({_,_,6}, cs) ->
        {m,f,6} = cs
        :erlang.apply(m, f, [this.operation, left_arg, right_arg, state, context, options])
      is_function(cs, 3) -> {cs.(this.operation, left_arg, right_arg), nil}
      is_function(cs, 6) -> cs.(this.operation, left_arg, right_arg, state, context, options)
      true -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Invalid comparison strategy #{inspect cs}", 404)
    end
  end

  #-----------------
  # execute!/5
  #-----------------
  def execute!(:sync, this, state, context, options) do
    [h|t] = this.arguments
    {first_arg, state} = Noizu.RuleEngine.ScriptProtocol.execute!(h, state, context, options)
    cs = this.arithmetic_strategy || :default
    {product, state} = Enum.reduce(t, {first_arg, state},
      fn(child, {left_arg, state}) ->
          {right_arg, state} = Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options)
          {product, s} = perform_arithmetic(left_arg, right_arg, this, state, context, options)
          {product, s || state}
      end
    )
    {product, state}
  end

  def execute!(:async, this, state, context, options) do
    yield_wait = this.settings[:timeout] || options[:timeout] || 15_000
    [first_arg|remaining_args] = this.arguments
               |> Enum.map(fn(child) -> Task.async(fn -> (Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options)) end) end)
               |> Task.yield_many(yield_wait)
               |> Enum.map(
                    fn({task, res}) ->
                      case res do
                        {:ok, {o, _s}} -> o
                        _ ->
                          Task.shutdown(task, yield_wait)
                          {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}}
                      end
                    end)

    if match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, first_arg) do
      {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} = first_arg
      throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}", 404)
    end

    {product, _} = Enum.reduce(remaining_args || [], first_arg,
      fn(right_arg, left_arg) ->
        cond do
          match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, right_arg) ->
            {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} = right_arg
            throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}", 404)
          true -> elem(perform_arithmetic(left_arg, right_arg, this, state, context, options), 0)
        end
      end)
    {product, state}
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
  def render(this, state, context), do: Helper.render_arg_list("CMP #{this.comparison}", identifier(this, state, context), this.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(this, state, context, options), do: Helper.render_arg_list("CMP #{this.comparison}", identifier(this, state, context, options), this.arguments || [], state, context, options)
end
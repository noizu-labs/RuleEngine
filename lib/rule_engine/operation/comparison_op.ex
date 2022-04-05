#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Op.ComparisonOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    arguments: list,
    comparison: :"==" | :"<>" | :"<=" | :">=" | :"<" | :">",
    comparison_strategy: any,
    settings: Keyword.t,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    arguments: [],
    comparison: :"==",
    comparison_strategy: :default,
    settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.ComparisonOp do
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
      this.settings[:short_circuit?] == :required -> execute!(:short_circuit, this, state, context, options) # Ignore Async settings when short_circuit is mandatory
      Enum.member?([true, :auto, :required], this.settings[:async?]) && (options[:settings] && options.settings.supports_async? == true) -> execute!(:async, this, state, context, options)
      this.settings[:async?] == :required -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] Unable to perform required async execute on #{this.__struct__} - #{identifier(this, state, context)}", 310)
      Enum.member?([true, :auto, nil], this.settings[:short_circuit?]) -> execute!(:short_circuit, this, state, context, options)
      true -> execute!(:all, this, state, context, options)
    end
  end

  def perform_comparison(left_arg, right_arg, this, state, context, options) do
    cs = this.comparison_strategy || :default
    cond do
      cs == :default ->
        c = case this.comparison do
          :"==" -> left_arg == right_arg
          :"<>" -> left_arg != right_arg
          :"<" -> left_arg < right_arg
          :">" -> left_arg > right_arg
          :"<=" -> left_arg <= right_arg
          :">=" -> left_arg >= right_arg
        end
        {c, nil}
      match?({_,_,3}, cs) ->
        {m, f, 3} = cs
        {:erlang.apply(m, f, [this.comparison, left_arg, right_arg]), nil}
      match?({_,_,6}, cs) ->
        {m, f, 6} = cs
        :erlang.apply(m, f, [this.comparison, left_arg, right_arg, state, context, options])
      is_function(cs, 3) -> {cs.(this.comparison, left_arg, right_arg), nil}
      is_function(cs, 6) -> cs.(this.comparison, left_arg, right_arg, state, context, options)
      true -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Invalid comparison strategy #{inspect cs}", 404)
    end
  end

  #-----------------
  # execute!/5
  #-----------------
  def execute!(:short_circuit, this, state, context, options) do
    cond do
      length(this.arguments || []) < 2 -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} ComparisonOp requires at least 2 arguments", 311)
      true ->
        [h|t] = this.arguments
        p = Noizu.RuleEngine.ScriptProtocol.execute!(h, state, context, options)
        # cs = this.comparison_strategy || :default
        {sentinel, {_o, updated_state}} = Enum.reduce(t, {true, p},
          fn(child, {sentinel, {o, s}}) ->
            if sentinel do
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c, s} = perform_comparison(o, c_o, this, c_s, context, options)
              {c, {c_o, s || c_s}}
            else
              {sentinel, {o, s}}
            end
          end
        )
        {sentinel, updated_state}
    end
  end

  def execute!(:all, this, state, context, options) do
    cond do
      length(this.arguments || []) < 2 -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} ComparisonOp requires at least 2 arguments", 311)
      true ->
        [h|t] = this.arguments
        p = Noizu.RuleEngine.ScriptProtocol.execute!(h, state, context, options)
        #cs = this.comparison_strategy || :default
        {sentinel, {_o, updated_state}} = Enum.reduce(t, {true, p},
          fn(child, {sentinel, {o, s}}) ->
            if sentinel do
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c, s} = perform_comparison(o, c_o, this, c_s, context, options)
              {c, {c_o, s || c_s}}
            else
              {_, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {sentinel, {o, c_s}}
            end
          end
        )
        {sentinel, updated_state}
    end
  end

  def execute!(:async, this, state, context, options) do
    cond do
      length(this.arguments || []) < 2 -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} ComparisonOp requires at least 2 arguments", 311)
      true ->
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

        {product, _} = Enum.reduce(remaining_args || [], {true, first_arg},
          fn(right_arg, {product, left_arg}) ->
            cond do
              match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, right_arg) ->
                {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} = right_arg
                throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}", 404)
              product -> {elem(perform_comparison(left_arg, right_arg, this, state, context, options), 0), right_arg}
              true -> {product, nil}
            end
          end)
        {product, state}
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
  def render(this, state, context), do: Helper.render_arg_list("CMP #{this.comparison}", identifier(this, state, context), this.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(this, state, context, options), do: Helper.render_arg_list("CMP #{this.comparison}", identifier(this, state, context, options), this.arguments || [], state, context, options)
end
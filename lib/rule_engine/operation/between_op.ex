#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Op.BetweenOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    settings: Keyword.t,
    strict: boolean,
    argument: any,
    lower_bound: any,
    upper_bound: any,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    comparison_strategy: :default,
    settings: [async?: :auto, throw_on_timeout?: :auto],
    strict: false,
    argument: nil,
    lower_bound: nil,
    upper_bound: nil
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.BetweenOp do
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

  #-----------------
  # execute!/5
  #-----------------
  def execute!(:sync, this, state, context, options) do
    {arg, state} = Noizu.RuleEngine.ScriptProtocol.execute!(this.argument, state, context, options)
    {lb, state} = Noizu.RuleEngine.ScriptProtocol.execute!(this.lower_bound, state, context, options)
    {ub, state} = Noizu.RuleEngine.ScriptProtocol.execute!(this.upper_bound, state, context, options)
    perform_check!(arg, lb, ub, this, state, context, options)
  end

  def execute!(:async, this, state, context, options) do
    yield_wait = this.settings[:timeout] || options[:timeout] || 15_000
    # Async execute arguments
    tasks = [
              Task.async(fn -> Noizu.RuleEngine.ScriptProtocol.execute!(this.argument, state, context, options) |> elem(0) end),
              Task.async(fn -> Noizu.RuleEngine.ScriptProtocol.execute!(this.lower_bound, state, context, options)  |> elem(0) end),
              Task.async(fn -> Noizu.RuleEngine.ScriptProtocol.execute!(this.upper_bound, state, context, options)  |> elem(0) end),
            ]
    [arg, lb, ub] = tasks
                    |> Task.yield_many(yield_wait)
                    |> Enum.map(
                         fn({task, res}) ->
                           case res do
                             {:ok, v} -> v
                             _ ->
                               Task.shutdown(task, yield_wait)
                               {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}}
                           end
                         end)
    perform_check!(arg, lb, ub, this, state, context, options)
  end

  #-----------------
  # perform_check!/7
  #-----------------
  defp perform_check!(arg, lb, ub, this, state, context, options) do
    # Comparison Strategy
    cs = this.comparison_strategy || :default
    {lb_c, ub_c} = this.strict && {:">", :"<"} || {:">=", :"<="}

    # Perform Comparison / Error Check
    outcome = cond do
      match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, arg) -> arg
      match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, lb) -> lb
      match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, ub) -> ub
      cs == :default && this.strict -> (arg > lb && arg < ub)
      cs == :default -> (arg >= lb && arg <= ub)
      match?({_, _, 3}, cs) -> :erlang.apply(elem(cs, 0), elem(cs, 1), [lb_c, arg, lb]) && :erlang.apply(elem(cs, 0), elem(cs, 1), [ub_c, arg, ub])
      match?({_, _, 6}, cs) -> :erlang.apply(elem(cs, 0), elem(cs, 1), [lb_c, arg, lb, state, context, options]) && :erlang.apply(elem(cs, 0), elem(cs, 1), [ub_c, arg, ub, state, context, options])
      is_function(cs, 3) -> cs.(lb_c, arg, lb) && cs.(ub_c, arg, ub)
      is_function(cs, 6) -> elem(cs.(lb_c, arg, lb, state, context, options), 0) && elem(cs.(ub_c, arg, ub, state, context, options), 0)
      true -> throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Invalid comparison strategy #{inspect cs}", 404)
    end

    case outcome do
      {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} ->
        throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}", 404)
      _ -> {outcome, state}
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
    Helper.render_arg_list("BETWEEN", identifier(this, state, context, options), [this.argument, this.lower_bound, this.upper_bound], state, context, options)
  end
end
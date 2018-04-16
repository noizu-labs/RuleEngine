#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Op.StrictOrOp do
  @type t :: %__MODULE__{
               name: String.t | nil,
               description: String.t | nil,
               identifier: String.t | list | tuple, # Materialized Path.
               arguments: list,
               settings: Keyword.t,
             }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    arguments: [],
    settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.StrictOrOp do
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

  #-----------------
  # execute!/5
  #-----------------
  def execute!(:short_circuit, this, state, context, options) do
    n_children = length(this.arguments || [])
    cond do
      n_children == 0 -> {false, state}
      true -> Enum.reduce(this.arguments, {false, state}, fn(child, {o, s}) ->
        case o do
          true -> {o, s}
          false -> Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
        end
      end)
    end
  end

  def execute!(:all, this, state, context, options) do
    n_children = length(this.arguments || [])
    cond do
      n_children == 0 -> {false, state}
      true ->
        Enum.reduce(this.arguments, {false, state},
          fn(child, {o, s}) ->
            {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
            {o or c_o, c_s}
          end)
    end
  end

  def execute!(:async, this, state, context, options) do
    n_children = length(this.arguments || [])
    cond do
      n_children == 0 -> {nil, state}
      true ->
        yield_wait = this.settings[:timeout] || options[:timeout] || 15_000
        if Enum.member?([true, :required], this.settings[:throw_on_timeout?]) do
          v = this.arguments
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
              |> Enum.reduce(true,
                   fn(right_arg, left_arg) ->
                     if match?({:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _}}}, right_arg) do
                       {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} = right_arg
                       throw Noizu.RuleEngine.Error.Basic.new("[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}", 404)
                     end
                     left_arg or right_arg
                   end)
          {v, state}
        else
          v = this.arguments
              |> Enum.map(fn(child) -> Task.async(fn -> (Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options)) end) end)
              |> Task.yield_many(yield_wait)
              |> Enum.reduce(true,
                   fn({task, res}, acc) ->
                     case res do
                       {:ok, {o, _s}} -> acc or o
                       _ ->
                         Task.shutdown(task, yield_wait)
                         acc
                     end
                   end)
          {v, state}
        end
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
  def render(this, state, context), do: Helper.render_arg_list("STRICT_OR", identifier(this, state, context), this.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(this, state, context, options), do: Helper.render_arg_list("STRICT_OR", identifier(this, state, context, options), this.arguments || [], state, context, options)
end
defmodule Noizu.RuleEngine.Op.XorOp do
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
    settings: [short_circuit?: :auto, async?: :auto, raise_on_timeout?: :auto]
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.XorOp do
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
      Enum.member?([true, :auto, :required], this.settings[:async?]) && (options[:settings][:supports_async?] == true) -> execute!(:async, this, state, context, options)
      this.settings[:async?] == :required -> raise "[ScriptError] Unable to perform required async execute on #{this.__struct__} - #{identifier(this, state, context)}"
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
      true ->
        {outcome, updated_state} = Enum.reduce(this.arguments, {[], state}, fn(child, {o, s}) ->
          case o do
            [] ->
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c_o == true && (o ++ [c_o]) || o, c_s}
            [_a] ->
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c_o == true && (o ++ [c_o]) || o, c_s}
            [_a, _b] ->
              {o, s}
          end
        end)

        case outcome do
          [xor] -> {xor, updated_state}
          _ -> {false, updated_state}
        end
    end
  end

  def execute!(:all, this, state, context, options) do
    n_children = length(this.arguments || [])
    cond do
      n_children == 0 -> {false, state}
      true ->
        {outcome, updated_state} = Enum.reduce(this.arguments, {[], state}, fn(child, {o, s}) ->
          case o do
            [] ->
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c_o == true && (o ++ [c_o]) || o, c_s}
            [_a] ->
              {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {c_o == true && (o ++ [c_o]) || o, c_s}
            [_a, _b] ->
              {_c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
              {o, c_s}
          end
        end)

        case outcome do
          [xor] -> {xor, updated_state}
          _ -> {false, updated_state}
        end
    end
  end

  def execute!(:async, this, state, context, options) do
    n_children = length(this.arguments || [])
    cond do
      n_children == 0 -> {false, state}
      true ->
        yield_wait = this.settings[:timeout] || options[:timeout] || 15_000
        if Enum.member?([true, :required], this.settings[:raise_on_timeout?]) do
          outcome = this.arguments
                    |> Enum.map(fn(child) -> Task.async(&(Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options))) end)
                    |> Task.yield_mand(yield_wait)
                    |> Enum.reduce([],
                         fn({task, res}, acc) ->
                           case res do
                             {:ok, {o, _s}} ->
                               case acc do
                                 {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _task}}} -> acc
                                 _ -> (o == true && length(acc) < 2) && (acc ++ [o]) || acc
                               end
                             _ ->
                               Task.shutdown(task, yield_wait)
                               {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}}
                           end
                         end)
          case outcome do
            {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}} -> raise "[ScriptError] - #{identifier(this)} Execute Child Task Failed to Complete #{inspect task}"
            [xor] -> {xor, state}
            _ -> {false, state}
          end
        else
          outcome = this.arguments
                    |> Enum.map(fn(child) -> Task.async(&(Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options))) end)
                    |> Task.yield_mand(yield_wait)
                    |> Enum.reduce([],
                         fn({task, res}, acc) ->
                           case res do
                             {:ok, {o, _s}} -> (o == true && length(acc) < 2) && (acc ++ [o]) || acc
                             _ ->
                               Task.shutdown(task, yield_wait)
                               acc
                           end
                         end)
          case outcome do
            [xor] -> {xor, state}
            _ -> {false, state}
          end
        end
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
  def render(node, state, context), do: Helper.render_arg_list("[STRICT_XOR]", identifier(node), node.arguments || [], state, context, %{})

  #---------------------
  # render/4
  #---------------------
  def render(node, state, context, options), do: Helper.render_arg_list("[STRICT_XOR]", identifier(node), node.arguments || [], state, context, options)
end
if Application.get_env(:noizu_rule_engine, :default_implementation)[:atom_case] != false do
  defimpl Noizu.RuleEngine.ScriptProtocol, for: Atom do
    #-----------------
    # execute!/3
    #-----------------
    def execute!(this, state, _context), do: {this, state}

    #-----------------
    # execute!/4
    #-----------------
    def execute!(this, state, _context, _options), do: {this, state}

    #---------------------
    # identifier/3
    #---------------------
    def identifier(_this, _state, _context), do: "??ATOM??"

    #---------------------
    # identifier/4
    #---------------------
    def identifier(_this, _state, _context, _options), do: "??ATOM??"

    #---------------------
    # render/3
    #---------------------
    def render(this, state, context), do: render(this, state, context, %{})

    #---------------------
    # render/4
    #---------------------
    def render(this, _state, _context, options) do
      depth = options[:depth] || 0
      prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
      v = "#{inspect this}"
      t = String.slice(v, 0..32)
      t = if (t != v), do: t <> "...", else: t
      id = "???"
      "#{prefix}#{id} [ATOM #{inspect t}]\n"
    end
  end
end

if Application.get_env(:noizu_rule_engine, :default_implementation)[:list_case] != false do
  defimpl Noizu.RuleEngine.ScriptProtocol, for: List do
    #-----------------
    # execute!/3
    #-----------------
    def execute!(this, state, context), do: execute!(this, state, context, %{})

    #-----------------
    # execute!/4
    #-----------------
    def execute!(this, state, context, options) do
      cond do
        options[:list_async?] && (options[:settings][:supports_async?] == true) -> execute!(:async, this, state, context, options)
        true -> execute!(:sync, this, state, context, options)
      end
    end

    #-----------------
    # execute!/5
    #-----------------
    def execute!(:sync, this, state, context, options) do
      Enum.reduce(this, {[], state}, fn(child, {a, s}) ->
        {c_o, c_s} = Noizu.RuleEngine.ScriptProtocol.execute!(child, s, context, options)
        {a ++ [c_o], c_s}
      end)
    end

    def execute!(:async, this, state, context, options) do
      yield_wait = this.settings[:timeout] || options[:timeout] || 15_000

      outcome = this
      |> Enum.map(fn(child) -> Task.async(fn ->(Noizu.RuleEngine.ScriptProtocol.execute!(child, state, context, options)) end) end)
      |> Task.yield_many(yield_wait)
      |> Enum.reduce(fn({task, res}) ->
        case res do
          {:ok, {o, _s}} ->
            o
          _ ->
            Task.shutdown(task, yield_wait)
            {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}}
        end
      end)

      errors = Enum.filter(outcome, fn(x) ->
        case x do
          {:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, _task}}} -> true
          _ -> false
        end
      end)

      case errors do
        [{:error, {Noizu.RuleEngine.ScriptProtocol, {:timeout, task}}}|_t] -> raise "[ScriptError] - #{identifier(this, state, context, options)} Execute Child Task Failed to Complete #{inspect task}"
        _ -> {outcome, state}
      end
    end

    #---------------------
    # identifier/3
    #---------------------
    def identifier(this, _state, _context), do: "[LIST(#{length(this)})]"

    #---------------------
    # identifier/4
    #---------------------
    def identifier(this, _state, _context, _options), do: "[LIST(#{length(this)})]"

    #---------------------
    # render/3
    #---------------------
    def render(this, state, context), do: render(this, state, context, %{})

    #---------------------
    # render/4
    #---------------------
    def render(children, state, context, options) do
      depth = options[:depth] || 0
      prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
      options_b = put_in(options, [:depth], depth + 1)
      r = Enum.map(children, &(Noizu.RuleEngine.ScriptProtocol.render(&1, state, context, options_b)))
      "#{prefix}LIST(#{length(children)}) [\n" ++ Enum.join(r, "\n") ++ "#{prefix}] LIST\n"
    end
  end
end

if Application.get_env(:noizu_rule_engine, :default_implementation)[:any_case] != false do
  defimpl Noizu.RuleEngine.ScriptProtocol, for: Any do
    #-----------------
    # execute!/3
    #-----------------
    def execute!(this, state, _context), do: {this, state}

    #-----------------
    # execute!/4
    #-----------------
    def execute!(this, state, _context, _options), do: {this, state}

    #---------------------
    # identifier/3
    #---------------------
    def identifier(_this, _state, _context), do: "???"

    #---------------------
    # identifier/4
    #---------------------
    def identifier(_this, _state, _context, _options), do: "???"

    #---------------------
    # render/3
    #---------------------
    def render(this, state, context), do: render(this, state, context, %{})

    #---------------------
    # render/4
    #---------------------
    def render(this, _state, _context, options) do
      depth = options[:depth] || 0
      prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
      v = "#{inspect this}"
      t = String.slice(v, 0..32)
      t = if (t != v), do: t <> "...", else: t
      id = "???"
      "#{prefix}#{id} [ANY #{inspect t}]\n"
    end
  end
end
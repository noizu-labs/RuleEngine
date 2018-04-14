defmodule Noizu.RuleEngine.Helper do
  def identifier(node) do
    case node.identifier do
      v when is_bitstring(v) -> v
      v when is_list(v) -> Enum.join(v, ".")
      v when is_tuple(v) -> :erlang.tuple_to_list(v) |> Enum.join(".")
      _ -> "#{inspect node.identifier}"
    end
  end

  def render_arg_list(tag, identifier, children, state, context, options) do
    depth = options[:depth] || 0
    prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
    options_b = put_in(options, [:depth], depth + 1)
    r = Enum.map(children, &(Noizu.RuleEngine.ScriptProtocol.render(&1, state, context, options_b)))
    "#{prefix}#{identifier} [#{tag}] (#{length(children)})\n" ++ Enum.join(r, "\n")
  end
end
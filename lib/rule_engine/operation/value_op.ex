defmodule Noizu.RuleEngine.Op.AndOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    value: v,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    value: nil,
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.AndOp do
  alias Noizu.RuleEngine.Helper
  #-----------------
  # execute!/3
  #-----------------
  def execute!(this, state, context), do: execute!(this, state, context, %{})

  #-----------------
  # execute!/4
  #-----------------
  def execute!(this, state, _context, _options) do
    {this.value, state}
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
    id = identifier(node, state, context, options)
    v = "#{inspect node.value}"
    t = Enum.slice(v, 0..32)
    t = if (t != v), do: t <> "...", else: t
    "#{prefix}#{id} [VALUE #{t}]\n"
  end
end
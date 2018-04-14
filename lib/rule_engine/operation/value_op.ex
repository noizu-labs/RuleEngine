defmodule Noizu.RuleEngine.Op.ValueOp do
  @type t :: %__MODULE__{
    name: String.t | nil,
    description: String.t | nil,
    identifier: String.t | list | tuple, # Materialized Path.
    value: any,
  }

  defstruct [
    name: nil,
    description: nil,
    identifier: nil,
    value: nil,
  ]
end

defimpl Noizu.RuleEngine.ScriptProtocol, for: Noizu.RuleEngine.Op.ValueOp do
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
    depth = options[:depth] || 0
    prefix = (depth == 0) && (">> ") || (String.duplicate(" ", ((depth - 1) * 4) + 3) <> "|-- ")
    id = identifier(this, state, context, options)
    v = "#{inspect this.value}"
    t = String.slice(v, 0..32)
    t = if (t != v), do: t <> "...", else: t
    "#{prefix}#{id} [VALUE #{t}]\n"
  end
end
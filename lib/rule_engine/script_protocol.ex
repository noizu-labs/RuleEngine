defprotocol Noizu.RuleEngine.ScriptProtocol do

  @doc """
    Execute Node, return result or error details.
  """
  def execute!(node, state, context)
  def execute!(node, state, context, options)

  @doc """
    Return script/node identifier
  """
  def identifier(node, state, context)
  def identifier(node, state, context, options)

  @doc """
    Outputs a textual representation of node for debugging, etc.
  """
  def render(node, state, context)
  def render(node, state, context, options)
end
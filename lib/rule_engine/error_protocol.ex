defprotocol Noizu.RuleEngine.ErrorProtocol do
  @doc """
    Retrieve Error Code
  """
  def code(error)

  @doc """
    Retrieve Error Message
  """
  def message(error, options)
end

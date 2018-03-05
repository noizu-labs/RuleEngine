#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.RuleEngine.NodeProtocol do
  @doc """
    Execute Node, return result or error details.
  """
  def execute(node, context)

  @doc """
    Outputs a textual representation of node for debugging, etc.
  """
  def definition(node, detail_level)
end

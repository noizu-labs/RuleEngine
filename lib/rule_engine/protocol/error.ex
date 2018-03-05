#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.RuleEngine.ErrorProtocol do


  @doc """
    Retrieve Error Code
  """
  def code(error)

  @doc """
    Retrieve Error Message
  """
  def message(error, detail_level)


end

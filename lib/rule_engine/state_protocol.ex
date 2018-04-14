#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defprotocol Noizu.RuleEngine.StateProtocol do

  def setting(entry, setting, context)
  def settings(entry, context)

  def put!(entry, field, value, context)
  def put!(entry, entity, field, value, context)

  def get!(entry, field, context)
  def get!(entry, entity, field, context)

end
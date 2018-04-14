#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Error.Basic do
  defexception message: "Basic Exception", code: -1
  def raise(msg \\ "Basic Exception", code \\ -1) do
    Kernel.raise Noizu.RuleEngine.Error.Basic, message: msg, code: code
  end

  def new(msg \\ "Basic Exception", code \\ -1) do
    %__MODULE__{
      message: msg,
      code: code
    }
  end
end

defimpl Noizu.RuleEngine.ErrorProtocol, for: Noizu.RuleEngine.Error.Basic do
  def code(error), do: error.code

  def message(error), do: error.message
  def message(error, _options), do: error.message
end
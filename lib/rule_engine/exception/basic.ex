#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Exception.Basic do
  @behaviour Noizu.RuleEngine.Behaviour.Error

    @type t :: %__MODULE__{
      code: atom | integer,
      msg: String.t
    }

    defstruct [
      code: nil,
      msg: nil
    ]

  def new(code, message) do
    %__MODULE__{
      code: code,
      msg: message,
    }
  end

  def code(error = %Noizu.RuleEngine.Exception.Basic{}) do
    error.code
  end

  def message(error = %Noizu.RuleEngine.Exception.Basic{}, _detail_level) do
    error.msg
  end

end


# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.ErrorProtocol, for: Noizu.RuleEngine.Exception.Basic do
  def code(error) do
    Noizu.RuleEngine.Exception.Basic.code(error)
  end
  def message(error, detail_level) do
    Noizu.RuleEngine.Exception.Basic.message(error, detail_level)
  end
end

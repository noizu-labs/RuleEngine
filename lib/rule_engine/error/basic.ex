defmodule Noizu.RuleEngine.Error.Basic do
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
end

defimpl Noizu.RuleEngine.ErrorProtocol, for: Noizu.RuleEngine.Error.Basic do
  def code(error) do
    error.code
  end

  def message(error, _options) do
    error.msg
  end
end

defmodule Noizu.RuleEngine.StateSettings do
  @type t :: %__MODULE__{
               supports_async?: boolean,
               supports_transactions?: boolean,
               user_settings: Map.t,
             }

  defstruct [
    supports_async?: false,
    supports_transactions?: false,
    user_settings: %{}
  ]
end
defmodule Noizu.RuleEngine.State.Inline do

  @type t :: %__MODULE__{
               settings: Noizu.RuleEngine.ScriptSettings.t,
               global_state: %{},
               entity_state: %{any => %{}}
             }

  @default_settings %Noizu.RuleEngine.ScriptSettings{
    async?: false,
    short_circuit?: true,
    transactions?: true,
    user_settings: %{}
  }

  defstruct [
    settings: @default_settings,
    entity_state: %{},
    global_state: %{}
  ]
end

defimpl Noizu.RuleEngine.StateProtocol, for: Noizu.RuleEngine.State.Inline do
  #-------------------------
  #
  #-------------------------
  def settings(entry, _context) do
    entry.settings
  end

  #-------------------------
  #
  #-------------------------
  def setting(entry, setting, _context) do
    cond do
      Map.has_key(entry.settings, setting) -> Map.get(entry.settings, setting)
      true -> entry.settings.user_settings[setting]
    end
  end

  #-------------------------
  #
  #-------------------------
  def put!(entry, field, value, _context) do
    put_in(entry, [Access.key(:global_state), field], value)
  end

  #-------------------------
  #
  #-------------------------
  def put!(entry, entity, field, value, _context) do
    cond do
      entry.entity_state[entity] -> put_in(entry, [Access.key(:entity_state), entity, field], value)
      true -> put_in(entry, [Access.key(:entity_state), entity], %{field => value})
    end
  end

  #-------------------------
  #
  #-------------------------
  def get!(entry, field, _context) do
    {entry.global_state[field], entry}
  end

  #-------------------------
  #
  #-------------------------
  def get!(entry, entity, field, _context) do
    {entry.entity_state[entity][field], entry}
  end
end
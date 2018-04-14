defmodule Noizu.RuleEngine.Operation.GetOperationTest do
  alias Noizu.RuleEngine.Op.GetOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - get global" do
    script = %GetOp{
      identifier: "1",
      field: :a
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 1
  end

  test "Execute! - get entity" do
    script = %GetOp{
      identifier: "1",
      entity: :entity_module,
      field: :b
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 2
  end

end
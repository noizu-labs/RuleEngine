defmodule Noizu.RuleEngine.Operation.NotOperationTest do
  alias Noizu.RuleEngine.Op.NotOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - true" do
    script = %NotOp{
      identifier: "1",
      argument: %ValueOp{identifier: "1.1", value: false}
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - false" do
    script = %NotOp{
      identifier: "1",
      argument: %ValueOp{identifier: "1.1", value: true}
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

end
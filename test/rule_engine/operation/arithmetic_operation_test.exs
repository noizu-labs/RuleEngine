#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.ArithmeticOperationTest do
  alias Noizu.RuleEngine.Op.ArithmeticOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - addition" do
    script = %ArithmeticOp{
      identifier: "1",
      operation: :"+",
      arguments: [%ValueOp{identifier: "1.1", value: 3}, %ValueOp{identifier: "1.2", value: 2}, %ValueOp{identifier: "1.3", value: 1}]
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 6
  end

  test "Execute! - subtraction" do
    script = %ArithmeticOp{
      identifier: "1",
      operation: :"-",
      arguments: [%ValueOp{identifier: "1.1", value: 3}, %ValueOp{identifier: "1.2", value: 2}, %ValueOp{identifier: "1.3", value: 1}]
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 0
  end

  test "Execute! - multiplication" do
    script = %ArithmeticOp{
      identifier: "1",
      operation: :"*",
      arguments: [%ValueOp{identifier: "1.1", value: 3}, %ValueOp{identifier: "1.2", value: 2}, %ValueOp{identifier: "1.3", value: 1}]
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 6
  end

  test "Execute! - division" do
    script = %ArithmeticOp{
      identifier: "1",
      operation: :"/",
      arguments: [%ValueOp{identifier: "1.1", value: 3}, %ValueOp{identifier: "1.2", value: 2}, %ValueOp{identifier: "1.3", value: 1}]
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 1.5
  end

  test "Execute! - power" do
    script = %ArithmeticOp{
      identifier: "1",
      operation: :"^",
      arguments: [%ValueOp{identifier: "1.1", value: 3}, %ValueOp{identifier: "1.2", value: 2}, %ValueOp{identifier: "1.3", value: 1}]
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 9
  end

end
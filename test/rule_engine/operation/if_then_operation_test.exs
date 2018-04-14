#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.IfThenOperationTest do
  alias Noizu.RuleEngine.Op.IfThenOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - conditional true" do
    script = %IfThenOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: true},
      then_clause: %ValueOp{identifier: "1.2", value: 123},
      else_clause: %ValueOp{identifier: "1.3", value: 321},
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 123
  end

  test "Execute! - conditional false" do
    script = %IfThenOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: false},
      then_clause: %ValueOp{identifier: "1.2", value: 123},
      else_clause: %ValueOp{identifier: "1.3", value: 321},
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 321
  end

  test "Execute! - nil clause" do
    script = %IfThenOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: false},
      then_clause: %ValueOp{identifier: "1.2", value: 123},
      else_clause: nil,
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == nil
  end

end
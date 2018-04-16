#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.BetweenOperationTest do
  alias Noizu.RuleEngine.Op.BetweenOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - less than range" do
    script = %BetweenOp{
      identifier: "1",
      argument: %ValueOp{identifier: "1.1", value: 1.0},
      lower_bound: %ValueOp{identifier: "1.2", value: 2.0},
      upper_bound: %ValueOp{identifier: "1.3", value: 3.0},
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - greater than range" do
    script = %BetweenOp{
      identifier: "1",
      argument: %ValueOp{identifier: "1.1", value: 4.0},
      lower_bound: %ValueOp{identifier: "1.2", value: 2.0},
      upper_bound: %ValueOp{identifier: "1.3", value: 3.0},
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - inside range" do
    script = %BetweenOp{
      identifier: "1",
      argument: %ValueOp{identifier: "1.1", value: 2.5},
      lower_bound: %ValueOp{identifier: "1.2", value: 2.0},
      upper_bound: %ValueOp{identifier: "1.3", value: 3.0},
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - perimeter not strict" do
    script = %BetweenOp{
      identifier: "1",
      strict: false,
      argument: %ValueOp{identifier: "1.1", value: 2.0},
      lower_bound: %ValueOp{identifier: "1.2", value: 2.0},
      upper_bound: %ValueOp{identifier: "1.3", value: 3.0},
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - perimeter strict" do
    script = %BetweenOp{
      identifier: "1",
      strict: true,
      argument: %ValueOp{identifier: "1.1", value: 2.0},
      lower_bound: %ValueOp{identifier: "1.2", value: 2.0},
      upper_bound: %ValueOp{identifier: "1.3", value: 3.0},
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

end
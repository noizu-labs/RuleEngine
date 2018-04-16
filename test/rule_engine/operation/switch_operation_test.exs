#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.SwitchOperationTest do
  alias Noizu.RuleEngine.Op.SwitchOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - match" do
    script = %SwitchOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: :apple},
      switch: %{
        apple: %ValueOp{identifier: "1.2", value: :foo},
        bananna: %ValueOp{identifier: "1.3", value: :bar}
      }
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == :foo
  end

  test "Execute! - no match with default" do
    script = %SwitchOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: :no_match},
      switch: %{
        apple: %ValueOp{identifier: "1.2", value: :foo},
        bananna: %ValueOp{identifier: "1.3", value: :bar}
      },
      default: %ValueOp{identifier: "1.4", value: :default}
    }
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == :default
  end

  test "Execute! - no match with no default" do
    script = %SwitchOp{
      identifier: "1",
      condition_clause: %ValueOp{identifier: "1.1", value: :no_match},
      switch: %{
        apple: %ValueOp{identifier: "1.2", value: :foo},
        bananna: %ValueOp{identifier: "1.3", value: :bar}
      },
    }

    response = try do
      Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
      :no_throw
    catch
      _e -> :throw
    end
    assert response == :throw
  end
end
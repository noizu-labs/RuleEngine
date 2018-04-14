#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.BasicRenderTest do
  alias Noizu.RuleEngine.Op.AndOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Render! - 3 layer nesting" do
    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 1.0},
        %AndOp{
          identifier: "1.2",
          arguments: [
            %ValueOp{identifier: "1.2.1", value: 2.0},
            %ValueOp{identifier: "1.2.2", value: 3.0},
            %ValueOp{identifier: "1.2.3", value: 4.0},
          ]
        },
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    r = Noizu.RuleEngine.ScriptProtocol.render(script, @fixture, @context)

    expected = """
    >> 1 [AND] (3)
       |-- 1.1 [VALUE 1.0]
       |-- 1.2 [AND] (3)
           |-- 1.2.1 [VALUE 2.0]
           |-- 1.2.2 [VALUE 3.0]
           |-- 1.2.3 [VALUE 4.0]
       |-- 1.3 [VALUE 5.0]
    """

    assert r == expected
  end

end
#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.UserDefinedOperationTest do
  alias Noizu.RuleEngine.Op.UserDefinedOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  def stub(state, _context, _options) do
    {true, state}
  end

  def stub(args, state, _context, _options) do
    {length(args), state}
  end

  test "Execute! - lambda - no args" do
    script = %UserDefinedOp{
      identifier: "1",
      user_defined:
        fn(state, _context, _options) ->
        {true, state}
      end
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - lambda - args" do
    script = %UserDefinedOp{
      identifier: "1",
      user_defined:
        fn(arguments, state, _context, _options) ->
          {length(arguments), state}
        end,
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 2
  end

  test "Execute! - mfa - no args" do
    script = %UserDefinedOp{
      identifier: "1",
      user_defined: {Noizu.RuleEngine.Operation.UserDefinedOperationTest, :stub, 3}
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - mfa - args" do
    script = %UserDefinedOp{
      identifier: "1",
      user_defined: {Noizu.RuleEngine.Operation.UserDefinedOperationTest, :stub, 4},
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 2
  end

end
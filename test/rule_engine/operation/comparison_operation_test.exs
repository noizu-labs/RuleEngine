#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Operation.ComparisonOperationTest do
  alias Noizu.RuleEngine.Op.ComparisonOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.State.InlineStateManager
  alias Noizu.RuleEngine.State.AgentStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @agent_fixture @fixture |> put_in([Access.key(:settings), Access.key(:supports_async?)], true)

  @context Noizu.ElixirCore.CallingContext.admin()


  test "Execute! custom strategy/3" do

    comparison_strategy = fn(comparison, [_a, a], [_b, b]) ->
      case comparison do
        :"==" -> a == b
        :"<>" -> a != b
        :"<" -> a < b
        :">" -> a > b
        :"<=" -> a <= b
        :">=" -> a >= b
      end
    end

    script = %ComparisonOp{
      identifier: "1",
      comparison: :"==",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto, comparison_strategy: comparison_strategy],
      arguments: [
        %ValueOp{identifier: "1.1", value: [1, 5]},
        %ValueOp{identifier: "1.2", value: [6, 5]},
        %ValueOp{identifier: "1.3", value: [2, 5]},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true


    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto, comparison_strategy: comparison_strategy],
      arguments: [
        %ValueOp{identifier: "1.1", value: [1, 1]},
        %ValueOp{identifier: "1.2", value: [6, 2]},
        %ValueOp{identifier: "1.3", value: [2, 3]},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end


  test "Execute! custom strategy/6" do

    comparison_strategy = fn(comparison, [_a, a], [_b, b], state, _context, _options) ->
      r = case comparison do
        :"==" -> a == b
        :"<>" -> a != b
        :"<" -> a < b
        :">" -> a > b
        :"<=" -> a <= b
        :">=" -> a >= b
      end
      {r, state}
    end

    script = %ComparisonOp{
      identifier: "1",
      comparison: :"==",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto, comparison_strategy: comparison_strategy],
      arguments: [
        %ValueOp{identifier: "1.1", value: [1, 5]},
        %ValueOp{identifier: "1.2", value: [6, 5]},
        %ValueOp{identifier: "1.3", value: [2, 5]},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true


    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: :auto, comparison_strategy: comparison_strategy],
      arguments: [
        %ValueOp{identifier: "1.1", value: [1, 1]},
        %ValueOp{identifier: "1.2", value: [6, 2]},
        %ValueOp{identifier: "1.3", value: [2, 3]},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end



  test "Execute! == (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings, throw_on_timeout?: true}


    script = %ComparisonOp{
      identifier: "1",
      comparison: :"==",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == true
  end




  test "Execute! == (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"==",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! == (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"==",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! <> (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<>",
      arguments: [
        %ValueOp{identifier: "1.1", value: 4.9},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! <> (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<>",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! <= (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<=",
      arguments: [
        %ValueOp{identifier: "1.1", value: 4.9},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! <= (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<=",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! < (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<",
      arguments: [
        %ValueOp{identifier: "1.1", value: 4.9},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! < (false - eq)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<",
      arguments: [
        %ValueOp{identifier: "1.1", value: 4.9},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end


  test "Execute! < (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :"<",
      arguments: [
        %ValueOp{identifier: "1.1", value: 4.9},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 4.9},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! >= (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :">=",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 4.9},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! >= (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :">=",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! > (true)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :">",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 4.9},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! > (false - eq)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :">",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end


  test "Execute! > (false)" do
    script = %ComparisonOp{
      identifier: "1",
      comparison: :">",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.1},
        %ValueOp{identifier: "1.2", value: 5.0},
        %ValueOp{identifier: "1.3", value: 5.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end




end
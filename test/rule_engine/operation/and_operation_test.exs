defmodule Noizu.RuleEngine.Operation.AndOperationTest do
  alias Noizu.RuleEngine.Op.AndOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.Op.UserDefinedOp
  alias Noizu.RuleEngine.State.InlineStateManager
  alias Noizu.RuleEngine.State.AgentStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @agent_fixture @fixture |> put_in([Access.key(:settings), Access.key(:supports_async?)], true)

  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - true" do
    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.5},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == 3.1
  end

  test "Execute! - false" do
    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - nil" do
    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: nil},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == nil
  end

  test "Execute! - true (async)" do

    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: 5.5},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == 3.1
  end

  test "Execute! - false (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == false
  end

  test "Execute! - nil (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %ValueOp{identifier: "1.2", value: nil},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == nil
  end

  test "Execute! - nil (timeout - no throw)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %AndOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %UserDefinedOp{identifier: "1.2", user_defined: fn(state, _context, _options) ->
          Process.sleep(500)
          {7, state}
        end},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == nil

    options = %{timeout: 750, settings: settings}
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == 3.1
  end


  test "Execute! - nil (timeout - throw)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings, throw_on_timeout?: true}

    script = %AndOp{
      identifier: "1",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: true],
      arguments: [
        %ValueOp{identifier: "1.1", value: 5.0},
        %UserDefinedOp{identifier: "1.2", user_defined: fn(state, _context, _options) ->
                                                          Process.sleep(500)
                                                          {7, state}
        end},
        %ValueOp{identifier: "1.3", value: 3.1},
      ]
    }

    r = try do
      Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    catch
      e -> e
    end
    assert Noizu.RuleEngine.ErrorProtocol.code(r) == 404

    options = %{timeout: 750, settings: settings}
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == 3.1
  end

end
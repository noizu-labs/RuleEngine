defmodule Noizu.RuleEngine.Operation.StrictXorOperationTest do
  alias Noizu.RuleEngine.Op.StrictXorOp
  alias Noizu.RuleEngine.Op.ValueOp
  alias Noizu.RuleEngine.Op.UserDefinedOp
  alias Noizu.RuleEngine.State.InlineStateManager
  alias Noizu.RuleEngine.State.AgentStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @agent_fixture @fixture |> put_in([Access.key(:settings), Access.key(:supports_async?)], true)

  @context Noizu.ElixirCore.CallingContext.admin()

  test "Execute! - true" do
    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: false},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == true
  end

  test "Execute! - all false" do
    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: false},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: false},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - non exclusive" do
    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - all truthy" do
    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %ValueOp{identifier: "1.2", value: true},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, @fixture, @context)
    assert response == false
  end

  test "Execute! - true (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: false},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == true
  end

  test "Execute! - all false (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: false},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: false},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == false # @note return type is tricky on non strict xor.
  end

  test "Execute! - non exclusive (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %ValueOp{identifier: "1.2", value: false},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == false
  end

  test "Execute! - all truthy (async)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %ValueOp{identifier: "1.2", value: true},
        %ValueOp{identifier: "1.3", value: true},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == false
  end

  test "Execute! - true (timeout - no throw)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings}

    script = %StrictXorOp{
      identifier: "1",
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %UserDefinedOp{
          identifier: "1.2",
          user_defined:
            fn(state, _context, _options) ->
              Process.sleep(500)
              {false, state}
            end},
        %ValueOp{identifier: "1.3", value: false},
      ]
    }

    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == true

    options = %{timeout: 750, settings: settings}
    {response, _state} = Noizu.RuleEngine.ScriptProtocol.execute!(script, fixture, @context, options)
    assert response == true
  end


  test "Execute! - nil (timeout - throw)" do
    fixture = AgentStateManager.new(@agent_fixture)
    settings = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    options = %{timeout: 250, settings: settings, throw_on_timeout?: true}

    script = %StrictXorOp{
      identifier: "1",
      settings: [short_circuit?: :auto, async?: :auto, throw_on_timeout?: true],
      arguments: [
        %ValueOp{identifier: "1.1", value: true},
        %UserDefinedOp{
          identifier: "1.2",
          user_defined:
            fn(state, _context, _options) ->
              Process.sleep(500)
              {false, state}
            end},
        %ValueOp{identifier: "1.3", value: false},
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
    assert response == true
  end

end
defmodule Noizu.RuleEngine.State.AgentStateManagerTest do
  alias Noizu.RuleEngine.State.AgentStateManager
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @inline %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Get Setting - core" do
    fixture = AgentStateManager.new(@inline)
    sut = Noizu.RuleEngine.StateProtocol.setting(fixture, :supports_async?, @context)
    assert sut == false
  end

  test "Get Setting - user" do
    fixture = AgentStateManager.new(@inline)
    sut = Noizu.RuleEngine.StateProtocol.setting(fixture, :user_setting, @context)
    assert sut == :foo
  end

  test "Get Settings" do
    fixture = AgentStateManager.new(@inline)
    sut = Noizu.RuleEngine.StateProtocol.settings(fixture, @context)
    assert sut.user_settings.user_setting == :foo
  end

  test "Get Global Field (existing)" do
    fixture = AgentStateManager.new(@inline)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :a, @context)
    assert sut == 1
  end

  test "Get Entity Field (existing)" do
    fixture = AgentStateManager.new(@inline)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module, :b, @context)
    assert sut == 2
  end

  test "Put Global Field (existing)" do
    fixture = AgentStateManager.new(@inline)
    Noizu.RuleEngine.StateProtocol.put!(fixture, :a, 5, @context)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :a, @context)
    assert sut == 5
  end

  test "Put Entity Field (existing)" do
    fixture = AgentStateManager.new(@inline)
    Noizu.RuleEngine.StateProtocol.put!(fixture, :entity_module, :b, 7, @context)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module, :b, @context)
    assert sut == 7
  end

  test "Get Global Field (blank)" do
    fixture = AgentStateManager.new(@inline)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :not_found, @context)
    assert sut == nil
  end

  test "Get Entity Field (blank field)" do
    fixture = AgentStateManager.new(@inline)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module, :not_found, @context)
    assert sut == nil
  end

  test "Get Entity Field (blank entity)" do
    fixture = AgentStateManager.new(@inline)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module_b, :not_found, @context)
    assert sut == nil
  end

  test "Put Global Field (blank)" do
    fixture = AgentStateManager.new(@inline)
    Noizu.RuleEngine.StateProtocol.put!(fixture, :c, 5, @context)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :c, @context)
    assert sut == 5
  end

  test "Put Entity Field (blank field)" do
    fixture = AgentStateManager.new(@inline)
    Noizu.RuleEngine.StateProtocol.put!(fixture, :entity_module, :d, 7, @context)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module, :d, @context)
    assert sut == 7
  end

  test "Put Entity Field (blank entity)" do
    fixture = AgentStateManager.new(@inline)
    Noizu.RuleEngine.StateProtocol.put!(fixture, :entity_module_b, :e, 7, @context)
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(fixture, :entity_module_b, :e, @context)
    assert sut == 7
  end

end
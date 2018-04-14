defmodule Noizu.RuleEngine.State.InlineStateManagerTest do
  alias Noizu.RuleEngine.State.InlineStateManager
  use ExUnit.Case

  @fixture %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}} |> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)
  @context Noizu.ElixirCore.CallingContext.admin()

  test "Get Setting - core" do
    sut = Noizu.RuleEngine.StateProtocol.setting(@fixture, :supports_async?, @context)
    assert sut == false
  end

  test "Get Setting - user" do
    sut = Noizu.RuleEngine.StateProtocol.setting(@fixture, :user_setting, @context)
    assert sut == :foo
  end

  test "Get Settings" do
    sut = Noizu.RuleEngine.StateProtocol.settings(@fixture, @context)
    assert sut.user_settings.user_setting == :foo
  end

  test "Get Global Field (existing)" do
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(@fixture, :a, @context)
    assert sut == 1
  end

  test "Get Entity Field (existing)" do
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(@fixture, :entity_module, :b, @context)
    assert sut == 2
  end

  test "Put Global Field (existing)" do
    sut = Noizu.RuleEngine.StateProtocol.put!(@fixture, :a, 5, @context)
    assert sut.global_state.a == 5
  end

  test "Put Entity Field (existing)" do
    sut = Noizu.RuleEngine.StateProtocol.put!(@fixture, :entity_module, :b, 7, @context)
    assert sut.entity_state.entity_module.b == 7
  end

  test "Get Global Field (blank)" do
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(@fixture, :not_found, @context)
    assert sut == nil
  end

  test "Get Entity Field (blank field)" do
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(@fixture, :entity_module, :not_found, @context)
    assert sut == nil
  end

  test "Get Entity Field (blank entity)" do
    {sut, _state} = Noizu.RuleEngine.StateProtocol.get!(@fixture, :entity_module_b, :not_found, @context)
    assert sut == nil
  end

  test "Put Global Field (blank)" do
    sut = Noizu.RuleEngine.StateProtocol.put!(@fixture, :c, 5, @context)
    assert sut.global_state.c == 5
  end

  test "Put Entity Field (blank field)" do
    sut = Noizu.RuleEngine.StateProtocol.put!(@fixture, :entity_module, :d, 7, @context)
    assert sut.entity_state.entity_module.d == 7
  end

  test "Put Entity Field (blank entity)" do
    sut = Noizu.RuleEngine.StateProtocol.put!(@fixture, :entity_module_b, :e, 7, @context)
    assert sut.entity_state.entity_module_b.e == 7
  end

end
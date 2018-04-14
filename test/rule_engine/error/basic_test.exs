defmodule Noizu.RuleEngine.Error.BasicTest do
  alias Noizu.RuleEngine.Error.Basic
  use ExUnit.Case

  test "ErrorProtocol - Error Code (Excpetion)" do
    sut = try do
      Basic.raise("ABC", 123)
    rescue
      e -> e
    end
    assert Noizu.RuleEngine.ErrorProtocol.code(sut) == 123
  end

  test "ErrorProtocol - Error Msg (Exception)" do
    sut = try do
      Basic.raise("ABC", 123)
    rescue
      e -> e
    end
    assert Noizu.RuleEngine.ErrorProtocol.message(sut) == "ABC"
    assert Noizu.RuleEngine.ErrorProtocol.message(sut, %{}) == "ABC"
  end

  test "ErrorProtocol - Error Code (Throw)" do
    sut = try do
      throw Basic.new("ABC", 123)
    catch
      e -> e
    end
    assert Noizu.RuleEngine.ErrorProtocol.code(sut) == 123
  end

  test "ErrorProtocol - Error Msg (Throw)" do
    sut = try do
      throw Basic.new("ABC", 123)
    catch
      e -> e
    end
    assert Noizu.RuleEngine.ErrorProtocol.message(sut) == "ABC"
    assert Noizu.RuleEngine.ErrorProtocol.message(sut, %{}) == "ABC"
  end
end
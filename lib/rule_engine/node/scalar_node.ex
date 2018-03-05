#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Node.ScalarNode do
  @behaviour Noizu.RuleEngine.Behaviour.Node

  @type t :: %__MODULE__{
    name: String.t | nil,
    value: any
  }

  defstruct [
    name: nil,
    value: nil
  ]

  @doc """

  ## Examples
    iex> Noizu.RuleEngine.NodeProtocol.execute(%Noizu.RuleEngine.Node.ScalarNode{value: true}, %{})
    {:ok, true}

  """
  def execute(node = %Noizu.RuleEngine.Node.ScalarNode{}, _context) do
    {:ok,  node.value}
  end

  def definition(node = %Noizu.RuleEngine.Node.ScalarNode{}, level) do
    content = if Enum.member?([:very_verbose, :verbose, :info, :debug], level) do
      if Enum.member?([:very_verbose, :debug], level) do
        "#{inspect node.value, pretty: true, limit: :infinity}"
      else
        "#{inspect node.value}"
      end #end if Enum.member([:very_verbose, :debug], level) do
    else # else Enum.member([:very_verbose, :verbose, :info, :debug], level)
      case node.value do
        value when is_bitstring(value) ->
          if (String.length(value) <= 30) do
            value
          else
            String.slice(value, 0..30) <> "..."
          end # end if (String.length(value) <= 30)

        value when is_boolean(value) ->
          if value == true do
            "true"
          else
            "false"
          end # end if value == true

        value when is_integer(value) or is_float(value) or is_atom(value) or is_nil(value) or is_pid(value) or is_port(value) ->
          "#{inspect value}"

        _other_types -> "?"

      end # end case node.value
    end # end if  Enum.member([:very_verbose, :verbose, :info, :debug], level)

    if node.name != nil do
      "#{node.name}:Scalar(#{content})"
    else
      "Scalar(#{content})"
    end # end if ndoe.name != nil
  end #end def definition/2

end


# @TODO add this via metaprogramming
defimpl Noizu.RuleEngine.NodeProtocol, for: Noizu.RuleEngine.Node.ScalarNode do
  def execute(node, context) do
    Noizu.RuleEngine.Node.ScalarNode.execute(node, context)
  end
  def definition(node, detail_level) do
    Noizu.RuleEngine.Node.ScalarNode.definition(node, detail_level)
  end
end

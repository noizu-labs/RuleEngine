#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Behaviour.Node do
  alias Noizu.RuleEngine.Behaviour.Node
  alias Noizu.RuleEngine.Behaviour.Error
  @moduledoc """
    Defines Formula Engine Node
  """

  @type t :: module
  @type context :: Map.t
  @type detail_level :: :verbose | :very_verbose | :debug | :standard | :minimal
  @type image_format :: any # PNG or SVG eventually.
  @doc """
    Execute Node, return result or error details.
  """
  @callback execute(Node.t, context) :: {:ok, any} | {:error, Error.t}

  @doc """
    Outputs a textual representation of node for debugging, etc.
  """
  @callback definition(Node.t, detail_level) :: String.t

end

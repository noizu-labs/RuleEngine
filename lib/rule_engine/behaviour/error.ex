#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.RuleEngine.Behaviour.Error do
  alias Noizu.RuleEngine.Behaviour.Error
  @moduledoc """
    Defines Formula Engine Error Response
  """

  @type t :: module
  @type error_type :: atom
  @type error_code :: atom | integer | String.t
  @type detail_level :: :verbose | :very_verbose | :debug | :standard | :minimal

  @doc """
    Retrieve Error Code
  """
  @callback code(Error.t) :: {error_type, error_code}

  @doc """
    Retrieve Error Message
  """
  @callback message(Error.t, detail_level) :: String.t


end

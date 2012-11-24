defmodule Elixirbot do
  def start do
    :ok = :application.start(:elixirbot)
  end
end

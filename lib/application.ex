defmodule Ircbot.Application do
  @moduledoc """
  Defines the Ircbot Application.
  """

  use Application.Behaviour

  require :application

  require Application
  require IO
  require String
  require OptionParser
  require Enum
  require System

  @doc """
  Starts the Ircbot application in a permanent state.
  """
  @spec start(), do: :ok
  def start() do
    :ok = Application.start(:ircbot, [type: :permanent])
  end

  @spec main([char]), do: no_return()
  def main(args) do
    args = lc arg inlist args, do: list_to_binary(arg)

    {opts, _} = OptionParser.parse(args, [flags: [:help,
                                                  :version],
                                          aliases: [h: :help,
                                                    v: :version]])
    if opts[:version] do
      IO.puts("Simple IRCbot written in Elixir - 0.1")
    end

    if opts[:help] do
      IO.puts("General:")
      IO.puts("")
      IO.puts("    -v|--version: Show program version.")
      IO.puts("    -h|--help: Show command line help.")
    end

    if opts[:help] || opts[:version] do
      System.halt(2)
    end

    start()
  end

  @doc """
  Sets up the Ircbot config
  """
  @spec init_config(), do: :ok
  def init_config() do
    cfg = [ircbot_application: :hybrid,
           ircbot_nickname: "Wafflebot",
           ircbot_channels: ["#merc-devel"],
           ircbot_server: {"irc.freenode.net", nil}]

    Enum.each(cfg, fn({name, default}) ->
      case :application.get_env(name) do
        :undefined -> :application.set_env(:ircbot, name, default)
        {:ok, _} -> :ok
      end
    end)
  end

  @doc """
  Starts the Ircbot supervision tree.
  """
  @spec start(:normal |
              {:takeover, node()} |
              {:failover, node()}, []), do: {:ok, pid(), nil}
  def start(_, []) do
   :ok = init_config()

   {:ok, sup} = case :application.get_env(:ircbot_application) do
     {:ok, :hybrid} -> Ircbot.HybridSupervisor.start_link()
   end

   {:ok, sup, nil}
  end
end

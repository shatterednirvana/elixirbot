defmodule Elixirbot.Listener.Bot do

  require :application

  require System

  import Elixirbot.Client

  @doc"""
  Connects to the irc server and starts the handler loop.
  """
  def start() do
    {:ok, server} = :application.get_env(:ircbot, :ircbot_server)
    case server do
      {serv, nil} ->
        {:ok, socket} = Elixirbot.Client.connect(serv)
      {serv, port} ->
        {:ok, socket} = Elixirbot.Client.connect(serv, port)
    end

    handle(socket)
  end

  @doc"""
  Handles incoming TCP messages on the same port.
  """
  def handle(socket) do
    receive do
      {:tcp, ^socket, data} ->
        IO.puts(data)
        Elixirbot.Client.parse_line(socket, :string.tokens(data, ': '))
        handle(socket)
    end
  end
end

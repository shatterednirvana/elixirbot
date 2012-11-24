defmodule Elixirbot.Listener.Bot do

  require :application

  require System

  import Elixirbot.Client

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

  def handle(socket) do
    receive do
      {:tcp, sock, data} ->
        IO.puts(data)
        Elixirbot.Client.parse_line(sock, :string.tokens(data, ': '))
        handle(sock)
    end
  end
end

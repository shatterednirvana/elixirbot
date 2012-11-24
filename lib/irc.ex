defmodule Ircbot.Client do
  @moduledoc """
  Responsible for connecting and disconnecting to a server
  as well as sending and retrieving data.
  """

  import Enum

  @doc """
  Connets to the given address and return the socket.

    address - 'irc.freenode.net' or {199, 195, 193, 196}
    port    - 6697
  """
  def connect(address, port // 6697) do
    case :gen_tcp.connect(address, port, [{:packet, :line}])  do
      {:ok, socket} ->
        IO.puts("Connected to #{address}:#{port}")
        socket
      {:error, reason} ->
        IO.puts("Connection could not be established.")
        IO.puts(reason)
    end
  end

  @doc """
  Closes a connection.
  """
  def close(socket) do
    {:ok, {t_address, port}} = :inet.peername(socket)
    address = join(tuple_to_list(t_address), ".")
    :gen_tcp.close(socket)
    IO.puts("Closed connection on #{address}:#{port}")
  end

  @doc """
  Send data and wait for a reply.
  """
  def send(socket, data) do
    :ok = :gen_tcp.send(socket, data)
    :gen_tcp.recv(socket, 0)
  end

  def parse_line(socket, [_,"376"|_]) do
    Enum.each(:application.get_env(:ircbot_channels),
              fn(channel) ->
                TCP.send(socket, "JOIN :" <> channel <> "\r\n")
              end
    )
  end

  def parse_line(socket, ["PING"|rest]) do
    TCP.send(socket, "PONG" <> rest <> "\r\n")
  end

  def parse_line(_, _) do
    0
  end

end

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
  @spec connect(String.t(), non_neg_integer()), do: {:ok, :gen_tcp.socket()} | {:error, term()}
  def connect(address, port // 6697) do
    case :gen_tcp.connect(binary_to_list(address), port, [{:packet, :line}])  do
      {:ok, socket} ->
        IO.puts("Connected to #{address}:#{port}")

        {:ok, nick} = :application.get_env(:ircbot, :ircbot_nickname)
        nickname = binary_to_list(nick)
        :gen_tcp.send(socket, 'NICK' ++ nickname ++ '\r\n')
        :gen_tcp.send(socket, 'USER' ++ nickname ++ '\r\n')

        {:ok, socket}
      {:error, reason} ->
        IO.puts("Connection could not be established.")
        IO.puts(reason)
        {:error, reason}
    end
  end

  @doc """
  Closes a connection.
  """
  @spec close(:gen_tcp.socket()), do: :ok | {:error, term()}
  def close(socket) do
    case :int.peername(socket) do
      {:ok, {t_address, port}} ->
        address = join(tuple_to_list(t_address), ".")
        :gen_tcp.close(socket)
        IO.puts("Closed connection on #{address}:#{port}")
        :ok
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Send data and wait for a reply.
  """
  def send(socket, data) do
    :ok = :gen_tcp.send(socket, data)
    :gen_tcp.recv(socket, 0)
  end

  def parse_line(socket, [_,"376"|_]) do
    {:ok, channels} = :application.get_env(:ircbot, :ircbot_channels)

    Enum.each(channels,
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

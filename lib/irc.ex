defmodule Ircbot.Client do
  @moduledoc """
  Responsible for connecting and disconnecting to a server
  as well as sending and retrieving data.
  """

  require Enum

  @doc """
  Connets to the given address and return the socket.

    address - 'irc.freenode.net' or {199, 195, 193, 196}
    port    - 6697
  """
  @spec connect(char_list(), non_neg_integer()), do: {:ok, :gen_tcp.socket()} |
                                                     {:error, char_list()}
  def connect(address, port // 6697) do
    case :gen_tcp.connect(address, port, [{:packet, :line}]) do
      {:ok, socket} ->
        IO.puts("Connected to #{address}:#{port}")

        {:ok, nickname} = :application.get_env(:ircbot, :ircbot_nickname)
        send(socket, 'NICK' ++ nickname ++ '\r\n')
        send(socket, 'USER' ++ nickname ++ '\r\n')

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
  @spec close(:gen_tcp.socket()), do: :ok | {:error, char_list()}
  def close(socket) do
    case :int.peername(socket) do
      {:ok, {t_address, port}} ->
        address = Enum.join(tuple_to_list(t_address), ".")
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
  @spec send(:gen_tcp.socket(), :gen_tcp.packet()), do:
                                              {:ok, :gen_tcp.packet()} |
                                              {:error, :gen_tcp.reason()}
  def send(socket, data) do
    :ok = :gen_tcp.send(socket, data)
    :gen_tcp.recv(socket, 0)
  end

  @spec parse_line(:gen_tcp.socket(), char_list()), do: :ok
  def parse_line(socket, [_,'376'|_]) do
    {:ok, channels} = :application.get_env(:ircbot, :ircbot_channels)

    Enum.each(channels,
              fn(channel) ->
                send(socket, 'JOIN :' ++ channel ++ '\r\n')
                IO.puts("Joined #{channel}")
              end
    )

    :ok
  end

  @spec parse_line(:gen_tcp.socket(), char_list()), do: :ok
  def parse_line(socket, ['PING'|rest]) do
    send(socket, 'PONG' ++ rest ++ '\r\n')

    :ok
  end


  @spec parse_line(:gen_tcp.socket(), char_list()), do: :ok
  def parse_line(_, _) do
    :ok
  end

end

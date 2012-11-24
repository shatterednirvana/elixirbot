defmodule Elixirbot.HybridSupervisor do
  use Supervisor.Behaviour

  import GenX.Supervisor

  @spec start_link(), do: pid()
  def start_link() do
    children = [GenX.Supervisor.Child.new(id: :ircbot_listener_sup,
                                          start_func:
                                            {Elixirbot.Listener.Bot,
                                             :start, []},
                                          modules:
                                            [Elixirbot.Listener.Bot],
                                          shutdown: :infinity,
                                          type: :worker)]
    sup = GenX.Supervisor.OneForOne.new(children: children)
    {:ok, _} = GenX.Supervisor.start_link(sup, {__MODULE__, nil})
  end

  @spec init({term(), nil}), do: {:ok, {{:supervisor.strategy(),
                                         non_neg_integer(),
                                         non_neg_integer()},
                                        [:supervisor.child_spec()]}}
  def init(tup) do
    GenX.Supervisor.init(tup)
  end
end

defmodule Elixirbot.Mixfile do
  use Mix.Project

  def project do
    [ app: :elixirbot,
      version: "0.0.1",
      deps: deps ]
  end

  def application do
    [applications: [:genx,
                    :lager,
                    :exlager,
                    :jsx]]
  end

  defp deps do
    [{:genx, github: "yrashk/genx"},
     {:lager, github: "basho/lager"},
     {:exlager, github: "khia/exlager"},
     {:jsx, github: "talentdeficit/jsx"}]
  end
end

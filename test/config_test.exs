defmodule FutureEchoes.ConfigTest do
  use ExUnit.Case

  test "config stuff" do
    configs = [
      future_echoes: Application.get_all_env(:future_echoes),
      libcluster: Application.get_all_env(:libcluster)
    ]

    IO.inspect(configs, pretty: true, limit: :infinity)
  end
end

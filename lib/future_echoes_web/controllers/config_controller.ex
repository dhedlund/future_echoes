defmodule FutureEchoesWeb.ConfigController do
  use FutureEchoesWeb, :controller

  def show(conn, _params) do
    configs = [
      future_echoes: Application.get_all_env(:future_echoes),
      libcluster: Application.get_all_env(:libcluster)
    ]

    text(conn, inspect(configs, limit: :infinity, pretty: true))
  end
end

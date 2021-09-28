defmodule FutureEchoesWeb.Router do
  use FutureEchoesWeb, :router

  alias FutureEchoesWeb.ConfigController

  get "/config", ConfigController, :show
end

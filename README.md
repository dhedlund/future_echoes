# FutureEchoes

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Configuration

This app uses Vapor to read configuration from the environment, then uses Elixir's `Config` module to consume the output from Vapor and configure the application.

### .env File hierarchy

If no file is specified then the dotenv provider will load these files in this order. Each proceeding file is loaded over the previous. In these examples ENV will be the current mix environment: dev, test, or prod.

  * `.env`
  * `.env.ENV`
  * `.env.local`
  * `.env.ENV.local`

You should commit .env and .env.ENV files to your project and ignore any .local files. This allows users to provide a custom setup if they need to do that.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

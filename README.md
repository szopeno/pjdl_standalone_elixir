# Lexer

Run ''mix escript.build'' to create a standalone executable.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `lexer` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:lexer, "~> 0.1.0"}]
    end
    ```

  2. Ensure `lexer` is started before your application:

    ```elixir
    def application do
      [applications: [:lexer]]
    end
    ```


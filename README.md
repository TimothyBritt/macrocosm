# Macrocosm

Macrocosm is a predictable state container for Elixir. It is heavily influenced by the Redux JavaScript library.

It helps you write applications that behave consistently and are easy to test.

Macrocosm only takes a few minutes to get started with and understand.

## Installation

The package can be installed by adding `macrocosm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:macrocosm, "~> 0.1.0"}
  ]
end
```
<!-- Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/macrocosm](https://hexdocs.pm/macrocosm). -->

## or, try it in the shell...

Alternatively, if you'd like to tinker with the tool in the shell, you can clone this repository:

```shell
  git clone https://github.com/TimothyBritt/macrocosm.git
  cd macrocosm
```

Then fire up an `iex` repl with the library using:

```shell
  iex -S mix
```

## Usage

The `Macrocosm` is a singleton. Since it is implemented as an erlang `GenServer`, once it has been created, you can access it directly. The `Macrocosm` public functions reference the GenServer itself from within. This makes accessing and working with the `Macrocosm` accessible and easy:

```elixir
  counter = fn(state, action) ->
    case action[:type] do
      'INCREMENT' -> state + 1
      'DECREMENT' -> state - 1
      _ -> state
    end
  end

  Macrocosm.create(counter, 0)
  Macrocosm.animate(%{type: 'INCREMENT'})
```

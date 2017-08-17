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
The entire state of your application is a map stored in a struct inside the `Macrocosm`.
The only way to change the state of the `Macrocosm` is to emit an *action*, a map describing exactly what happened.
You specify how actions should transform the state map by writing *reducers*.

The `Macrocosm` is a singleton. Since it is implemented as an erlang `GenServer`, once it has been created, you can access it directly. The `Macrocosm` public functions reference the GenServer itself from within. This makes accessing and working with the `Macrocosm` accessible and easy:

```elixir
  # This is a reducer. It is a pure function with a (state, action) -> state
  # signature. It describes how an action that is animating the Macrocosm
  # transforms one state into the next.

  counter = fn(state, action) ->
    case action[:type] do
      'INCREMENT' -> state + 1
      'DECREMENT' -> state - 1
      _ -> state
    end
  end

  # Implement the big bang. Create the Macrocosm by passing the reducer function
  # and the initial state like: Macrocosm.create(reducer, initial_state)

  Macrocosm.create(counter, 0)

  # The only way to mutate the state of the Macrocosm is to animate it with an
  # action.

  Macrocosm.animate(%{type: 'INCREMENT'})
  #1
  Macrocosm.animate(%{type: 'INCREMENT'})
  #2
  Macrocosm.animate(%{type: 'DECREMENT'})
  #1
```
Instead of mutating the state of the `Macrocosm` directly, you specify the mutations you want to happen with plain maps called *actions*. These actions get passed to a special function called the *reducer* to decide how every action transforms the state.

## Contribute

Have some ideas? Feedback? Something broken? No workie?

If you have a question, please create an issue and I'll have a look ASAP.
If you'd like to contribute, please feel free to fork the project, make some changes and create a pull request. Please ensure that you are following some basic guidelines:

* Write tests. The code is well-covered and there are plenty of examples.
* Write documentation. The project uses [ExDoc](https://github.com/elixir-lang/ex_doc) to automate the generation of documentation.
* Write examples and DocTests.
* Keep it clean.

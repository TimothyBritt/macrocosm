defmodule MacrocosmTest do
  use ExUnit.Case
  doctest Macrocosm

  test 'it throws if the reducer is not a function' do
    assert_raise RuntimeError, "Expected the reducer to be a function.", fn -> Macrocosm.create(1) end
  end

  test 'it passes the initial_state' do
    initial_state = [id: 1, message: "hello"]
    reducer = fn(store, action) -> {store, action} end
    Macrocosm.create(reducer, initial_state)

    assert Macrocosm.get_state == initial_state
  end

  test 'it applies the reducer to the previous state' do
    Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})
    assert Macrocosm.get_state == %{todos: []}

    assert Macrocosm.animate(Test.ActionCreators.unknown_action) == %{todos: []}
    assert Macrocosm.animate(Test.ActionCreators.add_todo("Hello")) == %{todos: [%{id: 1, text: "Hello"}]}
    assert Macrocosm.get_state == %{todos: [%{id: 1, text: "Hello"}]}
  end

  # test 'it supports multiple subscriptions' do
  #
  #   Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})
  #   listenerA = fn() -> a_calls = a_calls + 1 end
  #   listenerB = fn() -> b_calls = b_calls + 1 end
  # end
end

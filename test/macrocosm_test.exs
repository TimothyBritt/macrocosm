defmodule MacrocosmTest do
  use ExUnit.Case, async: true
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

  test 'it supports multiple subscriptions' do
    Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})

    Test.Listeners.create
    listener_a = &Test.Listeners.listener_a/0
    listener_b = &Test.Listeners.listener_b/0

    unsubscribe_a = Macrocosm.subscribe(listener_a)
    assert is_function(unsubscribe_a) == true

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 1
    assert Test.Listeners.b_calls == 0

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 2
    assert Test.Listeners.b_calls == 0

    unsubscribe_b = Macrocosm.subscribe(listener_b)
    assert is_function(unsubscribe_b) == true

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 1

    unsubscribe_a.()
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 1

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 2

    unsubscribe_b.()
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 2

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 2

    Macrocosm.subscribe(listener_a)
    assert Test.Listeners.a_calls == 3
    assert Test.Listeners.b_calls == 2

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 4
    assert Test.Listeners.b_calls == 2
  end

  test 'it removes listener only once when unsubscribe is called' do
    Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})

    Test.Listeners.create
    listener_a = &Test.Listeners.listener_a/0
    listener_b = &Test.Listeners.listener_b/0

    unsubscribe_a = Macrocosm.subscribe(listener_a)
    Macrocosm.subscribe(listener_b)

    unsubscribe_a.()
    unsubscribe_a.()

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 0
    assert Test.Listeners.b_calls == 1
  end

  test 'it removes only the relevant listener when unsubscribe is called' do
    Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})

    Test.Listeners.create
    listener_a = &Test.Listeners.listener_a/0

    Macrocosm.subscribe(listener_a)
    unsubscribe_second = Macrocosm.subscribe(listener_a)

    unsubscribe_second.()
    unsubscribe_second.()

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    assert Test.Listeners.a_calls == 1
  end

  test 'it supports removing a subscription within a subscription' do
    Macrocosm.create(&Test.Reducers.todos/2, %{todos: []})

    Test.Listeners.create
    listener_a = &Test.Listeners.listener_a/0
    listener_b = &Test.Listeners.listener_b/0
    listener_c = &Test.Listeners.listener_c/0

    Macrocosm.subscribe(listener_a)
    Macrocosm.subscribe_once(listener_b)
    Macrocosm.subscribe(listener_c)

    Macrocosm.animate(Test.ActionCreators.unknown_action)
    Macrocosm.animate(Test.ActionCreators.unknown_action)

    assert Test.Listeners.a_calls == 2
    assert Test.Listeners.b_calls == 1
    assert Test.Listeners.c_calls == 2
  end


end

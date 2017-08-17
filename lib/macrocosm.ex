defmodule Macrocosm do
  use GenServer

  def create(reducer, initial_state \\ nil) do
    unless is_function(reducer) do
      raise "Expected the reducer to be a function."
    end

    matter = %Macrocosm.Struct{reducer: reducer, state: initial_state, listeners: []}
    GenServer.start_link(__MODULE__, matter, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def get_reducer do
    GenServer.call(__MODULE__, :get_reducer)
  end

  def animate(action) do
    GenServer.call(__MODULE__, {:animate, action})
  end

  def handle_call(:get_state, _from, %Macrocosm.Struct{state: current_state} = store) do
    {:reply, current_state, store}
  end

  def handle_call(:get_reducer, _from, %Macrocosm.Struct{reducer: reducer} = store) do
    {:reply, reducer, store}
  end

  def handle_call({:animate, action}, _from, %Macrocosm.Struct{reducer: reducer, state: current_state} = store) do
    new_state = reducer.(current_state, action)
    {:reply, new_state, %Macrocosm.Struct{ store | reducer: reducer, state: new_state }}
  end
end

defmodule Macrocosm do
  use GenServer

  def create(reducer, initial_state \\ nil) do
    unless is_function(reducer) do
      raise "Expected the reducer to be a function."
    end

    matter = %Macrocosm.Struct{
      reducer: reducer,
      state: initial_state,
      next_listeners: [],
      current_listeners: []
    }
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

  def detach_listener(listener) do
    GenServer.call(__MODULE__, {:detach_listener, listener})
  end

  def ensure_can_mutate_next_listeners() do
    %Macrocosm.Struct{
      next_listeners: next_listeners,
      current_listeners: current_listeners
    } = GenServer.call(__MODULE__, :get_store)

    if (next_listeners === current_listeners) do
      GenServer.call(__MODULE__, :copy_listeners)
    end
  end

  def subscribe(listener) do
    unless is_function(listener) do
      raise "Expected listener to be a function."
    end

    Macrocosm.ensure_can_mutate_next_listeners()
    GenServer.call(__MODULE__, {:attach_listener, listener})

    fn () ->
      Macrocosm.ensure_can_mutate_next_listeners()
      Macrocosm.detach_listener(listener)
    end
  end

  #-----------------------------------------------------------------------------
  # GenServer Callbacks
  #-----------------------------------------------------------------------------

  def handle_call(:get_store, _from, %Macrocosm.Struct{} = store) do
    {:reply, store, store}
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

  def handle_call(:copy_listeners, _from, %Macrocosm.Struct{current_listeners: current_listeners} = store) do
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: current_listeners }}
  end

  def handle_call({:attach_listener, listener}, _from, %Macrocosm.Struct{next_listeners: next_listeners} = store) do
    new_listeners = [ listener | next_listeners ]
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: new_listeners }}
  end

  def handle_call({:detach_listener, listener}, _from, %Macrocosm.Struct{next_listeners: next_listeners} = store) do
    new_listeners = List.delete(next_listeners, listener)
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: new_listeners }}
  end
end

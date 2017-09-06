defmodule Macrocosm do
  use GenServer

  @doc """
  Creates the Macrocosm
  """
  def create(reducer, initial_state \\ nil) do
    unless is_function(reducer) do
      raise "Expected the reducer to be a function."
    end

    matter = %Macrocosm.Struct{
      reducer: reducer,
      state: initial_state,
      next_listeners: [],
      current_listeners: [],
      listeners_marked_for_unsub: [],
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
    %Macrocosm.Struct{
      listeners_marked_for_unsub: marked_for_unsub,
    } = GenServer.call(__MODULE__, :get_store)

    if Enum.count(marked_for_unsub) > 0 do
      Enum.each(marked_for_unsub, fn(listener_struct) ->
          GenServer.call(__MODULE__, {:detach_listener, listener_struct})
        end
      )
    end

    GenServer.call(__MODULE__, :clean_up)
  end

  def detach_listener(listener) do
    GenServer.call(__MODULE__, {:detach_listener, listener})
  end

  def ensure_can_mutate_next_listeners() do
    %Macrocosm.Struct{
      next_listeners: next_listeners,
      current_listeners: current_listeners
    } = GenServer.call(__MODULE__, :get_store)

    if (next_listeners == current_listeners) do
      GenServer.call(__MODULE__, :copy_listeners)
    end
  end

  def subscribe(listener) do
    unless is_function(listener) do
      raise "Expected listener to be a function."
    end

    listener_struct = %Macrocosm.Listener{uuid: UUID.uuid1(), callback: listener}

    Macrocosm.ensure_can_mutate_next_listeners()
    GenServer.call(__MODULE__, {:attach_listener, listener_struct})

    fn () ->
      Macrocosm.ensure_can_mutate_next_listeners()
      Macrocosm.detach_listener(listener_struct)
    end
  end

  def subscribe_once(listener) do
    unless is_function(listener) do
      raise "Expected listener to be a function."
    end

    listener_struct = %Macrocosm.Listener{uuid: UUID.uuid1(), callback: listener, unsub_on_run: true}

    Macrocosm.ensure_can_mutate_next_listeners()
    GenServer.call(__MODULE__, {:attach_listener, listener_struct})

    fn () ->
      Macrocosm.ensure_can_mutate_next_listeners()
      Macrocosm.detach_listener(listener_struct)
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

  def handle_call({:animate, action}, _from, %Macrocosm.Struct{reducer: reducer, state: current_state, next_listeners: next_listeners} = store) do
    new_state = reducer.(current_state, action)

    next_store = %Macrocosm.Struct{ store | reducer: reducer,
      state: new_state,
      current_listeners: next_listeners,
      next_listeners: next_listeners
    }

    Enum.each(next_listeners, fn(listener_struct) ->
        listener_struct.callback.()
      end
    )

    marked_for_unsub = Enum.map(next_listeners, fn(listener_struct) ->
        if listener_struct.unsub_on_run do
          listener_struct
        end
      end
    )

    next_store = %Macrocosm.Struct{ next_store | listeners_marked_for_unsub: marked_for_unsub}

    {:reply, new_state, next_store}
  end

  def handle_call(:copy_listeners, _from, %Macrocosm.Struct{current_listeners: current_listeners} = store) do
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: current_listeners }}
  end

  def handle_call({:attach_listener, listener_struct}, _from, %Macrocosm.Struct{next_listeners: next_listeners} = store) do
    new_listeners = [ listener_struct | next_listeners ]
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: new_listeners }}
  end

  def handle_call({:detach_listener, listener_struct}, _from, %Macrocosm.Struct{next_listeners: next_listeners} = store) do
    new_listeners = List.delete(next_listeners, listener_struct)
    {:reply, :ok, %Macrocosm.Struct{ store | next_listeners: new_listeners }}
  end

  def handle_call(:clean_up, _from, store) do
    next_store = %Macrocosm.Struct{ store | listeners_marked_for_unsub: [] }
    {:reply, next_store.state, next_store}
  end
end

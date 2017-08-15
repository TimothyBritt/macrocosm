defmodule Store do
  use GenServer

  def create(initial_state \\ []) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def set_state(state) do
    GenServer.call(__MODULE__, {:set_state, state})
  end

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  def handle_call({:set_state, new_state}, _from, _current_state) do
    {:reply, new_state, new_state}
  end
end

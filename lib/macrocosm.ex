defmodule Macrocosm do
  use GenServer

  def create(reducer, initial_state \\ []) do
    GenServer.start_link(__MODULE__, {reducer, initial_state}, name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def get_reducer do
    GenServer.call(__MODULE__, :get_reducer)
  end

  def set_state(new_state) do
    GenServer.call(__MODULE__, {:set_state, new_state})
  end

  def animate(action) do
    GenServer.call(__MODULE__, {:animate, action})
  end

  def handle_call(:get_state, _from, {reducer, current_state}) do
    {:reply, current_state, {reducer, current_state}}
  end

  def handle_call({:set_state, new_state}, _from, {reducer, _current_state}) do
    {:reply, new_state, {reducer, new_state}}
  end

  def handle_call(:get_reducer, _from, {reducer, current_state}) do
    {:reply, reducer, {reducer, current_state}}
  end

  def handle_call({:animate, action}, _from, {reducer, current_state}) do
    {new_state, _action} = reducer.(current_state, action)
    {:reply, {new_state, action}, {reducer, new_state}}
  end
end

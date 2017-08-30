defmodule Test.Listeners do
  use GenServer

  def create() do
    GenServer.start_link(__MODULE__, %{a_calls: 0, b_calls: 0}, name: __MODULE__)
  end

  def a_calls do
    GenServer.call(__MODULE__, :a_calls)
  end

  def b_calls do
    GenServer.call(__MODULE__, :b_calls)
  end

  def listener_a do
    GenServer.call(__MODULE__, :listener_a)
  end

  def listener_b do
    GenServer.call(__MODULE__, :listener_b)
  end

  #-----------------------------------------------------------------------------
  # GenServer Callbacks
  #-----------------------------------------------------------------------------

  def handle_call(:listener_a, _from, %{a_calls: a_calls, b_calls: _} = state) do
    next_state = %{ state | a_calls: a_calls + 1 }
    {:reply, :ok, next_state}
  end

  def handle_call(:listener_b, _from, %{a_calls: _, b_calls: b_calls} = state) do
    next_state = %{ state | b_calls: b_calls + 1 }
    {:reply, :ok, next_state}
  end

  def handle_call(:a_calls, _from, %{a_calls: a_calls, b_calls: _} = state) do
    {:reply, a_calls, state}
  end

  def handle_call(:b_calls, _from, %{a_calls: _, b_calls: b_calls} = state) do
    {:reply, b_calls, state}
  end
end

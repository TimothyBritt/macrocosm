defmodule Macrocosm.Struct do
  defstruct reducer: nil, state: nil, next_listeners: [], current_listeners: [], listeners_marked_for_unsub: []
end

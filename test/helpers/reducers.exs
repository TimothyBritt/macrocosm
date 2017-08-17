defmodule Test.Reducers do
  def id(state) do
    if state[:todos] == nil do
      1
    else
      Enum.reduce(state[:todos], 0, fn(item, result) ->
          if item[:id] > result do
            item[:id]
          else
            result
          end
        end
      ) + 1
    end
  end

  def todos(state \\ %{todos: []}, action) do
    case action[:type] do
      "ADD_TODO" ->
        item = %{id: id(state), text: action[:text]}

        current_todos =
          case state[:todos] do
            nil -> []
            _ -> Enum.reverse(state[:todos])
          end

        next_todos = Enum.reverse([ item | current_todos ])
        %{todos: next_todos}

      _ ->
        state
    end
  end
end

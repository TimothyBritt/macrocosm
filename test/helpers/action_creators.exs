defmodule Test.ActionCreators do
  def add_todo(text) do
    %{type: "ADD_TODO", text: text}
  end

  def unknown_action do
    %{type: "UNKNOWN_ACTION"}
  end
end

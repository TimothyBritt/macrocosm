defmodule MacrocosmTest do
  use ExUnit.Case
  doctest Macrocosm

  test "greets the world" do
    assert Macrocosm.hello() == :world
  end
end

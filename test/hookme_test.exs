defmodule HookmeTest do
  use ExUnit.Case
  doctest Hookme

  test "greets the world" do
    assert Hookme.hello() == :world
  end
end

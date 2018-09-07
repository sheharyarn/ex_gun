defmodule ExGunTest do
  use ExUnit.Case
  doctest ExGun

  test "greets the world" do
    assert ExGun.hello() == :world
  end
end

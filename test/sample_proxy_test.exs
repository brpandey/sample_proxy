defmodule SampleProxyTest do
  use ExUnit.Case
  doctest SampleProxy

  test "greets the world" do
    assert SampleProxy.hello() == :world
  end
end

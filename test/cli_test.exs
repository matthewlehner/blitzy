defmodule BlitzyTest do
  use ExUnit.Case
  doctest Blitzy

  import Blitzy.CLI
  test "the truth" do
    assert 1 + 1 == 2
  end
end

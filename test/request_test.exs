defmodule BlitzyRequestTest do
  use ExUnit.Case
  doctest Blitzy
  import Blitzy.Request
  import Mock

  test "with 2 2 get example.com" do
    with_mock HTTPoison,
        [get: fn("http://example.com") ->
            {:ok, %HTTPoison.Response{status_code: 200}} end] do
            assert do_requests([],2,2,"get_mock","http://example.com",[node],[]) == :ok
    end
  end
end

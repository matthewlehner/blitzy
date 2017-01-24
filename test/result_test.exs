defmodule BlitzyResultTest do
  use ExUnit.Case
  doctest Blitzy
  import Blitzy.Result
  import Mock

  test "average" do
    assert average([1,2,3,4.3]) == 2.575
  end
  test "average zero" do
    assert average([1,2,3,-5,-4.44]) == 0
  end
  test "read and parse results" do
    with_mock File,
      [read: fn("results.txt") ->
          {:ok, "ok,0.083,200,1483802531706,get\nerror,0.04,500,1483802531706,get\n"} end] do
            assert read_results == [{:ok, 0.083, "200", 1483802531706, "get"}, {:error, 0.04, "500", 1483802531706, "get"}]
    end
  end
  test "write results" do
    write_results [{:ok, 0.083, 200, 1483802531706, "get"}, {:error, 0.04, 500, 1483802531706, "get"}]
    assert read_results == [{:ok, 0.083, "200", 1483802531706, "get"}, {:error, 0.04, "500", 1483802531706, "get"}]
  end
  test "filter success" do
    input = [{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"},{:error, 0.04, 500, 1483802531706, "get"}]
    assert filter_success(input) == [{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"}]
  end
  test "filter success durations" do
    input = [{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531706, "get"}]
    assert filter_success_durations(input) == [0.083,0.083,0.083]
  end
  test "calc stats" do
    input = [{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531707, "get"},{:ok, 0.083, 200, 1483802531706, "get"},{:error, 0.04, 500, 1483802531708, "get"}]
    assert calc_stats(input,4) == {4, 4, 3, 1, 0.083, 0.083, 0.083, 2}
  end
  test "calc stats all errors" do
    input = [{:error, 0.083, 200, 1483802531706, "get"},{:error, 0.083, 200, 1483802531707, "get"},{:error, 0.083, 200, 1483802531708, "get"},{:error, 0.04, 500, 1483802531709, "get"}]
    assert calc_stats(input,4) == {4, 4, 0, 4, 0, 0, 0, 3}
  end
  test "parse results" do
    input = [[{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531707, "get"}],{:ok, 0.083, 200, 1483802531708, "get"},{:error, 0.04, 500, 1483802531709, "get"}]
    assert parse_results(input,4) == [{:ok, 0.083, 200, 1483802531706, "get"},{:ok, 0.083, 200, 1483802531707, "get"},{:ok, 0.083, 200, 1483802531708, "get"},{:error, 0.04, 500, 1483802531709, "get"}]
  end
end

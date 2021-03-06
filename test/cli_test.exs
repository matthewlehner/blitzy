defmodule BlitzyCLITest do
  use ExUnit.Case
  doctest Blitzy
  import Blitzy.CLI

  test "graph args" do
    assert parse_args(["-o","report.html", "-s", "get"]) == {[graph_name: "report.html", scenario: "get"], [], []}
  end
  test "pummel args" do
    assert parse_args(["-n","1", "-r", "2", "-s", "get", "url"]) == {[requests: 1, repeats: 2, scenario: "get"], ["url"], []}
  end

  test "help" do
    assert parse_args(["--help"]) == {[], [], [{"--help", nil}]}
  end

  test "graph through main" do
    assert main(["-o","report.html", "-s", "get"]) == :ok
  end

end

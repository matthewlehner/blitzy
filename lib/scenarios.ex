defmodule Blitzy.Scenarios do
  use Timex

  def get url do
    Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.get url end, "get")
  end
  def scenario_01 url do
    results = []
    results = [step_01(url)|results]
    results = [step_02(url)|results]
    results
  end

  defp step_01 url do
    Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.get(url, [], params: %{s: "selenium"}) end, "step_01")
    
  end
  defp step_02 url do
    Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.get(url, [], params: %{s: "grinder"}) end, "step_02")
  end
end

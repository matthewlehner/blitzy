defmodule Blitzy.Scenarios do

  def post site do
    Blitzy.Measure.duration_of_http_poison(fn ->
      HTTPoison.post(
        "https://pixelpop-loading.herokuapp.com/api/client/instances",
        [],
        [{"Origin", site}, {"Referer", site}]
      )
    end, "post")
  end

  def get url do
    Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.get(url,[],hackney: [:insecure]) end, "get")
  end
  
  def get_mock url do
    Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.get(url) end, "get_mock")
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

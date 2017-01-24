defmodule Blitzy.Scenarios do
  use Timex
  
  @headers %{"Accept-Encoding" => "gzip, deflate, br","Accept-Language" => "hr-HR,hr;q=0.8,en-US;q=0.6,en;q=0.4",
               "User-Agent" => "blitzy", "Content-Type" => "application/json;charset=UTF-8",
               "Accept" => "application/json, text/plain, */*", "Connection" => "keep-alive"}
  @no_of_users 50

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
  
  def auth(url) do    
    body = %{username: "user#{user_no_str(:rand.uniform(@no_of_users))}@tentamen.eu", password: "Opatija11!"}
	|> Poison.encode!
	Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.post(Enum.join([to_string(url),'/api-token-auth'],""), body, @headers, hackney: [:insecure]) end, "auth")
  end
  
  def auth_01(url) do    
    body = %{username: "karlo.smid@ericsson.com", password: "Opatija11!"}
	|> Poison.encode!
	Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.post(Enum.join([to_string(url),'/admin-api-token-auth'],""), body, @headers, hackney: [:insecure]) end, "auth")
  end
  
  def license_generate(url) do
    body = %{username: "user#{user_no_str(:rand.uniform(@no_of_users))}@tentamen.eu", password: "Opatija11!", hwid: "iphone9999999"}
	|> Poison.encode!	
	Blitzy.Measure.duration_of_http_poison(fn -> HTTPoison.post(Enum.join([to_string(url),'/sllicensing/generate'],""), body, @headers, hackney: [:insecure]) end, "license_generate")
  end
  
  def user_no_str(n) when n < 10, do: "0#{n}"
  def user_no_str(n), do: "#{n}"
end

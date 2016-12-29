defmodule Blitzy.Measure do
  use Timex
  require Logger
  def duration_of_http_poison(poison,name) do
    start_time = start
    {timestamp, response} = Duration.measure(poison)
    handle_poison_response({Duration.to_milliseconds(timestamp), response})
    |> Tuple.append(start_time)
    |> Tuple.append(name)
  end
  
  def start do
    Duration.now(:milliseconds)
  end
  defp handle_poison_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}})
  when code >= 200 and code <= 304 do
    Logger.info "worker [#{node}-#{inspect self}] completed in #{msecs} msecs"
    {:ok, msecs}
  end

  defp handle_poison_response({_msecs, {:error, reason}}) do
     Logger.info "worker [#{node}-#{inspect self}] error due to #{inspect reason}"
    {:error, reason}
  end

  defp handle_poison_response({_msecs, _}) do
     Logger.info "worker [#{node}-#{inspect self}] unknown error"
    {:error, :unknown}
  end
end

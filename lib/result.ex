defmodule Blitzy.Result do

  def parse_results(results,n_requests) do
    results = List.flatten(results)
    {successes, _failures} =
      results
        |> Enum.partition(fn x ->
             case x do
               {:ok, _, _,_} -> true
               _        -> false
           end
         end)
    total_results = Enum.count(results)
    total_workers = n_requests
    total_success = Enum.count(successes)
    total_failure = total_results - total_success

    data = successes |> Enum.map(fn {:ok, time, _start, _name} -> time end)
    average_time  = average(data)
    longest_time  = Enum.max(data)
    shortest_time = Enum.min(data)

    IO.puts """
    Total requests    : #{total_results}
    Total workers    : #{total_workers}
    Successful reqs  : #{total_success}
    Failed reqs      : #{total_failure}
    Average (msecs)  : #{average_time}
    Longest (msecs)  : #{longest_time}
    Shortest (msecs) : #{shortest_time}
    """
    results
  end

  def write_results results do
    {:ok, file} = File.open "results.txt", [:write, :utf8]
    results
    |> Enum.map(fn x -> IO.write(file, "#{Tuple.to_list(x) |> Enum.join(",")}\n") end)
    :ok = File.close file
  end

  def read_results do
    {:ok, file} = File.read "results.txt"
    file
    |> String.slice(0..-2)
    |> String.split("\n")
    |> Enum.map(fn x -> String.split(x,",") end)
    |> Enum.map(fn x -> {String.to_atom(Enum.at(x,0)),String.to_float(Enum.at(x,1)),String.to_integer(Enum.at(x,2)),Enum.at(x,3)} end)
  end

  defp average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end
end

defmodule Blitzy.Result do

  def parse_results(results,n_requests) do
    results = List.flatten(results)
    {total_results,total_workers,total_success,total_failure,average_time,longest_time,shortest_time,duration} = calc_stats results,n_requests

    IO.puts """
    Total requests    : #{total_results}
    Total workers    : #{total_workers}
    Successful reqs  : #{total_success}
    Failed reqs      : #{total_failure}
    Average (msecs)  : #{average_time}
    Longest (msecs)  : #{longest_time}
    Shortest (msecs) : #{shortest_time}
	RPS (secs)       : #{total_results/duration * 1000}
    """
    results
  end

  def calc_stats results,n_requests do
    successes = filter_success results
    total_results = Enum.count(results)
    total_workers = n_requests
    total_success = Enum.count(successes)
    total_failure = total_results - total_success

    data = filter_success_durations successes
    average_time  = average(data)
    {longest_time,shortest_time} = case Enum.empty?(data) do
      false ->
        {Enum.max(data),Enum.min(data)}
      true ->
        {0,0}
    end
	duration =
	  case Blitzy.Graph.last_req(results) - Blitzy.Graph.first_req(results) do
	    0 ->
	      1
	    x ->
	      x
	  end
    {total_results,total_workers,total_success,total_failure,average_time,longest_time,shortest_time,duration}
  end

  def filter_success_durations successes do
    successes |> Enum.map(fn {:ok, time, _code, _start, _name} -> time end)
  end

  def filter_success results do
    {successes, _failures} =
      results
        |> Enum.partition(fn x ->
             case x do
               {:ok, _, _,_, _} -> true
               _        -> false
           end
         end)
    successes
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
    |> Enum.map(fn x -> {String.to_atom(Enum.at(x,0)),String.to_float(Enum.at(x,1)),Enum.at(x,2),String.to_integer(Enum.at(x,3)), Enum.at(x,4)} end)
  end

  def average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end
end

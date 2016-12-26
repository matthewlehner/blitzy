defmodule Blitzy.CLI do
  alias Blitzy.TasksSupervisor
  require Logger

  def main(args) do
    Application.get_env(:blitzy, :master_node)
      |> Node.start

    Application.get_env(:blitzy, :slave_nodes)
      |> Enum.each(&Node.connect(&1))

    args
      |> parse_args
      |> process_options([node|Node.list])
  end

  defp parse_args(args) do
    OptionParser.parse(args, aliases: [n: :requests, r: :repeats],
                              strict: [requests: :integer, repeats: :integer])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n, repeats: r], [url], []} ->
        do_requests([], n, r, url, nodes,[])

      _ ->
        IO.inspect options
        do_help

    end
  end

  defp do_requests(results, n_requests, r_repeats, url, nodes, accumulator) when r_repeats < 1 do
    Logger.info "Finished pummelling #{url} with #{n_requests} workers for #{div(Enum.count(accumulator),n_requests) * Enum.count(nodes)} times over #{Enum.count(nodes)} nodes."
    results ++ accumulator |> parse_results(n_requests)
  end
  defp do_requests(results, n_requests, r_repeats, url, nodes, accumulator) do
    accumulator = results ++ accumulator
    total_nodes  = Enum.count(nodes)
    req_per_node = div(n_requests, total_nodes)

    nodes
    |> Enum.flat_map(fn node ->
         1..req_per_node |> Enum.map(fn _ ->
           Task.Supervisor.async({TasksSupervisor, node}, Blitzy.Worker, :start, [url])
         end)
       end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> do_requests(n_requests, (r_repeats - 1), url, nodes, accumulator)
  end

  defp do_help do
    IO.puts """
    Usage:
    blitzy -n [requests] -r [repeats] [url]

    Options:
    -n, [--requests]      # Number of requests
    -r, [--repeats]      # Number of repeats

    Example:
    ./blitzy -n 100 -r 2 http://www.bieberfever.com
    """
    System.halt(0)
  end

  defp parse_results(results,n_requests) do
    {successes, _failures} =
      results
        |> Enum.partition(fn x ->
             case x do
               {:ok, _} -> true
               _        -> false
           end
         end)

    total_results = Enum.count(results)
    total_workers = n_requests
    total_success = Enum.count(successes)
    total_failure = total_results - total_success

    data = successes |> Enum.map(fn {:ok, time} -> time end)
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

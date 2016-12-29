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
    OptionParser.parse(args, aliases: [n: :requests, r: :repeats, s: :scenario, o: :graph_name],
                              strict: [requests: :integer, repeats: :integer, scenario: :string, graph_name: :string])
  end

  defp process_options(options, nodes) do
    case options do
      {[requests: n, repeats: r, scenario: s], [url], []} ->
        do_requests([], n, r, s, url, nodes,[])
      {[graph_name: o, scenario: s], [], []} ->
        create_graph_data(s)
        |> create_graph(s,o)

      _ ->
        do_help

    end
  end

  defp do_requests(results, n_requests, r_repeats, s_scenario, url, nodes, accumulator) when r_repeats < 1 do
    Logger.info "Finished pummelling #{url} with #{s_scenario} scenario and with #{n_requests} workers for #{div(Enum.count(accumulator),n_requests) * Enum.count(nodes)} times over #{Enum.count(nodes)} nodes."
    results ++ accumulator
    |> parse_results(n_requests)
    |> write_results
  end
  defp do_requests(results, n_requests, r_repeats, s_scenario, url, nodes, accumulator) do
    accumulator = results ++ accumulator
    total_nodes  = Enum.count(nodes)
    req_per_node = div(n_requests, total_nodes)

    nodes
    |> Enum.flat_map(fn node ->
         1..req_per_node |> Enum.map(fn _ ->
           Task.Supervisor.async({TasksSupervisor, node}, Blitzy.Worker, :start, [s_scenario, url])
         end)
       end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> do_requests(n_requests, (r_repeats - 1), s_scenario, url, nodes, accumulator)
  end

  defp do_help do
    IO.puts """
    Usage:
    blitzy -n [requests] -r [repeats] -s [scenario] [url]

    Options:
    -n, [--requests]      # Number of requests
    -r, [--repeats]       # Number of repeats
    -s, [--scenario]      # Your scenario module function
    -o, [--graph_name]    # output graph file name

    Example:
    ./blitzy -n 100 -r 2 -s Blitzy.Scenarios.get http://www.bieberfever.com
    ./blitzy -o graph_step_01.html -s step_01
    """
    System.halt(0)
  end

  defp parse_results(results,n_requests) do
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

  defp write_results results do
    {:ok, file} = File.open "results.txt", [:write, :utf8]
    results
    |> Enum.map(fn x -> IO.write(file, "#{Tuple.to_list(x) |> Enum.join(",")}\n") end)
    :ok = File.close file
  end

  defp create_graph_data name do
    results = read_results
    results = List.flatten results
    results = Enum.filter(results, fn {_,_,_,step} -> step == name end)
    first = results |> Enum.map(fn {_, _time, start, _name} -> start end) |> Enum.min
    results
    |> Enum.map(fn x ->
             case x do
               {:ok, duration, start, _} -> [start - first, duration,0]
               {_, duration, start, _} -> [start - first, 0, duration]
           end
         end)
    |> Enum.map(fn x -> "[#{Enum.join(x,",")}]" end)
    |> Enum.join(",")
  end

  defp create_graph(data,scenario,name) do
    {:ok, file} = File.open name, [:write]
    IO.binwrite file, Blitzy.Graph.graph(data,scenario)
    :ok = File.close file
  end

  defp read_results do
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

defmodule Blitzy.Request do

  alias Blitzy.TasksSupervisor
  require Logger

  def do_requests(results, n_requests, r_repeats, s_scenario, url, nodes, accumulator) when r_repeats < 1 do
    Logger.info "Finished pummelling #{url} with #{s_scenario} scenario and with #{n_requests} workers for #{div(Enum.count(accumulator),n_requests) * Enum.count(nodes)} times over #{Enum.count(nodes)} nodes."
    results ++ accumulator
    |> Blitzy.Result.parse_results(n_requests)
    |> Blitzy.Result.write_results
  end

  def do_requests(results, n_requests, r_repeats, s_scenario, url, nodes, accumulator) do
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
end

defmodule Blitzy.Graph do

  def create_graph_data name do
    results = Blitzy.Result.read_results
    results = filter_out_step results,name
    first = first_req results
    results
    |> create_graph_data(first)
  end

  def create_graph_data results, first do
    results
    |> Enum.map(fn x ->
             case x do
               {:ok, duration, _code, start, _} -> [start - first, duration,0]
               {_, duration, _code, start, _} -> [start - first, 0, duration]
           end
         end)
    |> Enum.map(fn x -> "[#{Enum.join(x,",")}]" end)
    |> Enum.join(",")
  end

  def first_req results do
    results |> Enum.map(fn {_, _time, _reason, start, _name} -> start end) |> Enum.min
  end
  
  def last_req results do
    results |> Enum.map(fn {_, _time, _reason, start, _name} -> start end) |> Enum.max
  end

  def filter_out_step results, name do
    Enum.filter(results, fn {_,_,_,_,step} -> step == name end)
  end

  def create_graph(data,scenario,name) do
    {:ok, file} = File.open name, [:write]
    IO.binwrite file, Blitzy.Graph.graph(data,scenario)
    :ok = File.close file
  end

  def graph(data,name) do
    data
    |> script(name)
    |> html
  end
  
  def html(script) do
    """
    <html>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
    #{script}
    </script>
  </head>
  <body>
    <div id="chart_div" style="width: 900px; height: 500px"></div>
  </body>
</html>
   """
  end
  def script(data,name) do
    """
    google.charts.load('current', {packages: ['corechart', 'line']});
google.charts.setOnLoadCallback(drawCrosshairs);

function drawCrosshairs() {
      var data = new google.visualization.DataTable();
      data.addColumn('number', 'start');
      data.addColumn('number', 'ok-#{name}');
      data.addColumn('number', 'error-#{name}');

      data.addRows([
      #{data}
      ]);

      var options = {
        hAxis: {
          title: 'time/[milliseconds]'
        },
        vAxis: {
          title: 'duration/[milliseconds]'
        },
        colors: ['#097138', '#a52714'],
        crosshair: {
          color: '#000',
          trigger: 'selection'
        }
      };

      var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      chart.draw(data, options);
      chart.setSelection([{row: 38, column: 1}]);
    }
    """
  end
end

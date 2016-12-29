defmodule Blitzy.Graph do

  def graph(data,name) do
    data
    |> script(name)
    |> html
  end
  
  defp html(script) do
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
  defp script(data,name) do
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

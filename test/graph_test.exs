defmodule BlitzyGraphTest do
  use ExUnit.Case
  doctest Blitzy
  import Blitzy.Graph
  import Mock

  test "script" do
    assert script('post','data value') == "google.charts.load('current', {packages: ['corechart', 'line']});\ngoogle.charts.setOnLoadCallback(drawCrosshairs);\n\nfunction drawCrosshairs() {\n  var data = new google.visualization.DataTable();\n  data.addColumn('number', 'start');\n  data.addColumn('number', 'ok-data value');\n  data.addColumn('number', 'error-data value');\n\n  data.addRows([\n  post\n  ]);\n\n  var options = {\n    hAxis: {\n      title: 'time/[milliseconds]'\n    },\n    vAxis: {\n      title: 'duration/[milliseconds]'\n    },\n    colors: ['#097138', '#a52714'],\n    crosshair: {\n      color: '#000',\n      trigger: 'selection'\n    }\n  };\n\n  var chart = new google.visualization.LineChart(document.getElementById('chart_div'));\n  chart.draw(data, options);\n  chart.setSelection([{row: 38, column: 1}]);\n}\n"
  end
  test "html" do
    assert html("injection") == " <html>\n<head>\n <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>\n <script type=\"text/javascript\">\n injection\n </script>\n</head>\n<body>\n <div id=\"chart_div\" style=\"width: 900px; height: 500px\"></div>\n</body>\n</html>\n"
  end
  test 'graph' do
    assert graph("post", "data value") == " <html>\n<head>\n <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>\n <script type=\"text/javascript\">\n google.charts.load('current', {packages: ['corechart', 'line']});\ngoogle.charts.setOnLoadCallback(drawCrosshairs);\n\nfunction drawCrosshairs() {\n  var data = new google.visualization.DataTable();\n  data.addColumn('number', 'start');\n  data.addColumn('number', 'ok-data value');\n  data.addColumn('number', 'error-data value');\n\n  data.addRows([\n  post\n  ]);\n\n  var options = {\n    hAxis: {\n      title: 'time/[milliseconds]'\n    },\n    vAxis: {\n      title: 'duration/[milliseconds]'\n    },\n    colors: ['#097138', '#a52714'],\n    crosshair: {\n      color: '#000',\n      trigger: 'selection'\n    }\n  };\n\n  var chart = new google.visualization.LineChart(document.getElementById('chart_div'));\n  chart.draw(data, options);\n  chart.setSelection([{row: 38, column: 1}]);\n}\n\n </script>\n</head>\n<body>\n <div id=\"chart_div\" style=\"width: 900px; height: 500px\"></div>\n</body>\n</html>\n"
  end
  test 'filter out steps' do
    input = [{:ok, 0.083, 200, 1483802531706, "get"}, {:error, 0.04, 500, 1483802531706, "geti"}]
    assert filter_out_step(input, "get") == [{:ok, 0.083, 200, 1483802531706, "get"}]
  end
  test 'first request' do
    input = [{:ok, 0.083, 200, 1483802531706, "get"}, {:error, 0.04, 500, 1483802531707, "geti"}]
    assert first_req(input) == 1483802531706
  end
  test 'last request' do
    input = [{:ok, 0.083, 200, 1483802531706, "get"}, {:error, 0.04, 500, 1483802531707, "geti"}]
    assert last_req(input) == 1483802531707
  end
  test 'create graph data' do
    input = [{:ok, 0.083, 200, 1483802531706, "get"}, {:error, 0.04, 500, 1483802531707, "get"}]
    assert create_graph_data(input,1483802531706) == "[0,0.083,0],[1,0,0.04]"
  end
end

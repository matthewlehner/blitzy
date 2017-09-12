use Mix.Config
# import_config "secrets.exs"
config :blitzy, master_node: :"a@127.0.0.1"

config :blitzy, slave_nodes: [:"b@127.0.0.1",
                              :"c@127.0.0.1",
                              :"d@127.0.0.1"]



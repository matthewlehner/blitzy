Blitzy - A simple HTTP load tester in Elixir
============================================

![](http://i.imgur.com/Z8zyXZu.gif)

Inspired by this [post](http://www.watchsumo.com/posts/introduction-to-elixir-v1-0-0-by-example-i) by Victor Martinez of WatchSumo.

```
% ./blitzy -n 100 -r 2 http://www.bieberfever.com
```

## Distributed Blitzy

It is _way_ more fun to start distributed. Edit the provided `config/config.exs` with whatever node name suits your fancy. This is optional, and you can stick to the provided one.

```elixir
config :blitz, master_node: :"a@127.0.0.1"

config :blitz, slave_nodes: [:"b@127.0.0.1", 
                             :"c@127.0.0.1",
                             :"d@127.0.0.1"] 
```

Here, the master node is `:a@127.0.0.1`; the rest are slave nodes.

Start up a couple of nodes, and name them accordingly. For example, here's how to start one of them:

```
% iex --name b@127.0.0.1 -S mix
```

Now, when you run the the command

```
% ./blitzy -n 2 -r 2 http://www.bieberfever.com
```

the requests will be split across the number of nodes you created, including the master node. Here's an example run:

```
15:00:34.777 [info]  worker [a@127.0.0.1-#PID<0.113.0>] completed in 711.052 msecs

15:00:35.092 [info]  worker [a@127.0.0.1-#PID<0.118.0>] completed in 313.951 msecs

15:00:35.107 [info]  Finished pummelling https://www.tentamen.hr with 2 workers for 2 times over 2 nodes.
Total requests    : 4
Total workers    : 2
Successful reqs  : 4
Failed reqs      : 0
Average (msecs)  : 467.3647500000001
Longest (msecs)  : 711.052
Shortest (msecs) : 313.951


15:00:34.574 [info]  worker [b@127.0.0.1-#PID<0.178.0>] completed in 517.94 msecs

15:00:35.105 [info]  worker [b@127.0.0.1-#PID<0.185.0>] completed in 326.516 msecs
```

## Building the Executable

```
mix escript.build
```



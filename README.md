# Ghostbuster

Set of useful functions to catch leaked processes in runtime.

## Installation

```elixir
def deps do
  [
    {:ghostbuster, "~> 0.1.0"}
  ]
end
```

## Usage

### !!!WARNING!!!
Check amount of processes on your production node!
this tool uses Process.list() and Enum, so IT CAN SIGNIFICANTLY SLOW DOWN YOUR APPLICATION
if you have a lot of processes, 10k of shouldn't create a problem
but if you have more - run it on your own risk.

To get list of unlinked processes:
```elixir
  Ghostbuster.get_unlinked_pids()
  #[#<0.45.0>]
```

To get 5 most used initial function calls
```elixir
  Ghostbuster.get_top_init_calls()
  #[
  #  {{:application_master, :init, 4}, 5},
  #  {{:application_master, :start_it, 4}, 5},
  #  {{:supervisor, Supervisor.Default, 1}, 4},
  #  {{:gen_event, :init_it, 6}, 3},
  #  {{:erts_dirty_process_signal_handler, :start, 0}, 3}
  #]
```

To get all pids with given initial call
```elixir
  Ghostbuster.get_pids_by_init_call({:application_master, :init, 4})
  # [#<0.45.0>]
```

To get initical call for given pid
```elixir
  '<0.45.0>' |> :erlang.list_to_pid() |> Ghostbuster.get_init_call()
  # {:application_master, :init, 4}
```



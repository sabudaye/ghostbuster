defmodule Ghostbuster do
  @moduledoc """
  Module provides functions to search for ghost processes in runtime.
  Ghost processes don't have ancesstors and do nothing,
  they always in waiting state and they live until system restart
  """

  @initial_call_info_keys [:initial_call, :dictionary, :current_function]
  @unlinked_info_keys [:links, :monitors]

  @doc """
  `get_top_init_calls` returns sorted list of initial call functions with number of processes

  ## Example:

    iex> Ghostbuster.get_top_init_calls()
    [
      {{:application_master, :init, 4}, 5},
      {{:application_master, :start_it, 4}, 5},
      {{:supervisor, Supervisor.Default, 1}, 4},
      {{:gen_event, :init_it, 6}, 3},
      {{:erts_dirty_process_signal_handler, :start, 0}, 3}
    ]
  """
  @spec get_top_init_calls() :: list()
  def get_top_init_calls do
    Process.list()
    |> Enum.map(&get_info(&1, @initial_call_info_keys))
    |> Enum.reduce(%{}, &count_initial_calls/2)
    |> Enum.sort(fn {_k1, c1}, {_k2, c2} -> c1 > c2 end)
    |> Enum.take(5)
  end

  @doc """
  `get_pids_by_init_call` returns list of pids by given {module, function, args} tuple

  ## Example:

    iex> Ghostbuster.get_pids_by_init_call({:application_master, :init, 4})
    [:erlang.list_to_pid('<0.45.0>')]
  """
  @spec get_pids_by_init_call({atom, atom, integer}) :: list(pid)
  def get_pids_by_init_call(function) do
    Process.list()
    |> Enum.map(&get_info(&1, @initial_call_info_keys))
    |> Enum.filter(&initial_call_eq?(&1, function))
    |> Enum.map(& &1[:pid])
  end

  @doc """
  `get_unlinked_pids` returns list of pids which don't have links or monitors

  ## Example:

    iex> Ghostbuster.get_unlinked_pids()
    [:erlang.list_to_pid('<0.45.0>')]
  """
  @spec get_unlinked_pids() :: list(pid)
  def get_unlinked_pids do
    Process.list()
    |> Enum.map(&get_info(&1, @unlinked_info_keys))
    |> Enum.filter(&no_links?/1)
    |> Enum.map(& &1[:pid])
  end

  @doc """
  `get_init_call` returns {module, function, args} tuple for given pid

  ## Example:

    iex> '<0.45.0>' |> :erlang.list_to_pid() |> Ghostbuster.get_init_call()
    {:application_master, :init, 4}
  """
  @spec get_init_call(pid) :: tuple
  def get_init_call(pid) do
    pid
    |> get_info(@initial_call_info_keys)
    |> get_initial_call()
  end

  defp get_info(pid, keys) do
    pid
    |> Process.info(keys)
    |> put_in([:pid], pid)
  end

  defp count_initial_calls(info, acc) do
    ic = get_initial_call(info)
    Map.update(acc, ic, 1, &(&1 + 1))
  end

  defp get_initial_call(pid: _, initial_call: ic, dictionary: dict, current_function: fun) do
    get_initial_call(ic, dict, fun)
  end

  defp get_initial_call({:proc_lib, :init_p, _} = call, [], _) do
    call
  end

  defp get_initial_call({:proc_lib, :init_p, _}, dict, _) do
    dict[:"$initial_call"]
  end

  defp get_initial_call({:erlang, :apply, _} = call, _, fun) when fun in [nil, "", []] do
    call
  end

  defp get_initial_call({:erlang, :apply, _}, _, fun) do
    fun
  end

  defp get_initial_call(call, _, _), do: call

  defp initial_call_eq?(
         [pid: _pid, initial_call: ic, dictionary: dict, current_function: fun],
         function
       ) do
    get_initial_call(ic, dict, fun) == function
  end

  defp no_links?(pid: _, links: [], monitors: []), do: true
  defp no_links?(_), do: false
end

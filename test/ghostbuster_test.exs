defmodule GhostbusterTest do
  use ExUnit.Case

  doctest Ghostbuster,
    except: [get_top_init_calls: 0, get_pids_by_init_call: 1, get_unlinked_pids: 0]

  test "get_top_init_calls/1 returns list of processes initial call with counter" do
    function = {{:application_master, :init, 4}, 4}
    assert function in Ghostbuster.get_top_init_calls()
  end

  test "get_pids_by_init_call/1 returns pid for given {moudle, function, args}" do
    function = {:application_master, :init, 4}
    assert Enum.all?(Ghostbuster.get_pids_by_init_call(function), &is_pid/1)
  end

  test "get_unlinked_pids/0 returns list of pids for unlinked processes" do
    assert Enum.all?(Ghostbuster.get_unlinked_pids(), &is_pid/1)
  end
end

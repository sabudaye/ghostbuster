defmodule GhostbusterTest do
  use ExUnit.Case

  doctest Ghostbuster, only: [get_init_call: 1]

  setup do
    pid = spawn(fn -> 1 end)
    pid2 = spawn(fn -> receive(do: (_ -> "test")) end)
    fun = {GhostbusterTest, :"-__ex_unit_setup_0/1-fun-1-", 0}
    Process.exit(pid, :kill)

    {:ok, pids: [pid, pid2], fun: fun}
  end

  test "get_top_init_calls/1 returns list of processes initial call with counter", %{
    pids: pids,
    fun: fun
  } do
    assert {fun, 1} in Ghostbuster.get_top_init_calls(pids)
  end

  test "get_pids_by_init_call/1 returns pid for given {moudle, function, args} tuple", %{
    pids: pids,
    fun: fun
  } do
    assert Enum.all?(Ghostbuster.get_pids_by_init_call(pids, fun), &is_pid/1)
  end

  test "get_unlinked_pids/0 returns list of pids for unlinked processes" do
    assert Enum.all?(Ghostbuster.get_unlinked_pids(), &is_pid/1)
  end

  test "filters dead processes", %{pids: pids, fun: fun} do
    assert !Enum.empty?(Ghostbuster.get_top_init_calls(pids))
    assert !Enum.empty?(Ghostbuster.get_pids_by_init_call(pids, fun))
    assert !Enum.empty?(Ghostbuster.get_unlinked_pids(pids))
  end
end

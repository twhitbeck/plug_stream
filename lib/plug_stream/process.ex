defmodule PlugStream.Process do
  use GenServer

  require Logger

  def create_for_conn(conn_pid, query) do
    DynamicSupervisor.start_child(
      PlugStream.DynamicSupervisor,
      {__MODULE__,
       [
         conn_pid: conn_pid,
         query: query
       ]}
    )
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def get_data(pid) do
    GenServer.call(pid, :get_data)
  end

  def init(opts) do
    Process.flag(:trap_exit, true)

    conn_pid = Keyword.get(opts, :conn_pid)

    if not is_nil(conn_pid) do
      Logger.info("Monitoring connection process: #{inspect(conn_pid)}")
      Process.monitor(conn_pid)
    end

    query = Keyword.fetch!(opts, :query)

    {:ok, {query, nil, conn_pid}, {:continue, :get_pit}}
  end

  def handle_continue(:get_pit, {query, _, conn_pid}) do
    # Make an HTTP call to create a point in time
    pit = 0

    {:noreply, {query, pit, conn_pid}}
  end

  def handle_call(:get_data, _from, {query, pit, conn_pid}) do
    # Fake lag for an HTTP call to get data
    Process.sleep(500)

    if pit < 20 do
      pit = pit + 1
      {:reply, {:cont, "#{pit},Blake"}, {query, pit, conn_pid}}
    else
      {:stop, :normal, {:error, :halt}, {query, pit, conn_pid}}
    end
  end

  def handle_info({:DOWN, _ref, :process, conn_pid, _reason}, {_, _, conn_pid} = state) do
    Logger.warning("Plug connection terminated")
    {:stop, :normal, state}
  end

  def terminate(_reason, {_, pit, _}) do
    Logger.info("Terminating process for PIT: #{pit}")
    # Make HTTP cal to delete point in time
  end
end

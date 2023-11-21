defmodule PlugStream.Plug do
  require Logger

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> send_chunked(200)

    Logger.info("writing header")
    {:ok, ^conn} = chunk(conn, "id,name\n")

    parent = self()

    Task.Supervisor.async_nolink(parent, fn ->
      ref = Process.monitor(parent)

      receive do
        {:DOWN, ^ref, :process, ^parent, reason} ->
          Logger.info("Cleanup: #{reason}")
      end
    end)

    Process.sleep(1000)
    Logger.info("writing row 1")
    {:ok, ^conn} = chunk(conn, "1,Tim\n")

    Process.sleep(1000)
    Logger.info("writing row 2")
    {:ok, ^conn} = chunk(conn, "2,Zane\n")

    Process.sleep(1000)
    Logger.info("writing row 3")
    {:ok, ^conn} = chunk(conn, "3,Jim\n")

    conn
  end

  def terminate(reason, _state) do
    Logger.warning("#{inspect(reason)} in terminate")
  end
end

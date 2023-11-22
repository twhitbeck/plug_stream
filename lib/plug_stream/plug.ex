defmodule PlugStream.Plug do
  require Logger

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn =
      conn
      |> put_resp_content_type("text/csv")
      |> send_chunked(200)

    Logger.info("Creating Process for Elasticsearch")
    query = ""
    {:ok, pid} = PlugStream.Process.create_for_conn(self(), query)

    Logger.info("Creating stream of data")

    stream =
      Stream.resource(
        fn -> [] end,
        fn lines ->
          case PlugStream.Process.get_data(pid) do
            {:cont, line} -> {[line], lines ++ [line]}
            {:error, :halt} -> {:halt, lines}
          end
        end,
        fn lines -> lines end
      )

    Logger.info("Streaming data to connection")
    {:ok, ^conn} = chunk(conn, "id,name\n")

    conn =
      Enum.reduce_while(stream, conn, fn line, conn ->
        IO.inspect(line, label: "sending line")

        case chunk(conn, "#{line}\n") do
          {:ok, conn} ->
            {:cont, conn}

          {:error, :closed} ->
            {:halt, conn}

          {:error, error} ->
            Logger.error("Error chunking response: #{inspect(error)}")
            {:halt, conn}
        end
      end)

    conn
  end
end

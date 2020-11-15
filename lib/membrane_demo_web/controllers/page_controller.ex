defmodule MembraneDemoWeb.PageController do
  use MembraneDemoWeb, :controller

  alias MembraneDemoWeb.Endpoint

  @id "song"

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def audio(conn, _params) do
    conn =
      conn
      |> put_resp_content_type("audio/mpeg")
      |> send_chunked(200)

    :ok = Endpoint.subscribe(@id)
    send_chunk_to_connection(conn, @id)
  end

  defp send_chunk_to_connection(conn, id) do
    receive do
      %Phoenix.Socket.Broadcast{
        event: "chunk",
        payload: %{
          data: buffer
        },
        topic: id
      } ->
        case chunk(conn, buffer) do
          {:ok, conn} ->
            send_chunk_to_connection(conn, id)

          {:error, _err} ->
            send_chunk_to_connection(conn, id)
        end

      %Phoenix.Socket.Broadcast{
        event: "done"
      } ->
        conn

      _data ->
        send_chunk_to_connection(conn, id)
    end
  end
end

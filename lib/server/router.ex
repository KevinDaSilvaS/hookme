defmodule Server.Router do
  use Plug.Router
  use Plug.ErrorHandler
  import Plug.Conn
  alias Server.Validators.TaskValidators

  plug(:match)
  plug(:dispatch)
  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  post "/taskS" do
    {:ok, req_body, conn} = Plug.Conn.read_body(conn, opts)
    {result, body} = Jason.decode!(req_body) |> TaskValidators.map_fields()

    case result do
      :error ->
        code = Map.get(body, :code)
        response(conn, code, Jason.encode!(body))

      :ok ->
        Hookme.Sender.send_info(body)
        response(conn, 200, Jason.encode!(%{ok: "task succesfully scheduled"}))
    end
  end

  match _ do
    send_resp(conn, 404, "route not found")
  end

  def response(conn, code, data) do
    put_resp_content_type(conn, "application/json")
    |> send_resp(code, data)
  end
end

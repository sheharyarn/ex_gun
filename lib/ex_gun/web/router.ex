defmodule ExGun.Web.Router do
  use Plug.Router
  use Plug.ErrorHandler
  require Logger





  # Plug Specification
  # ------------------


  @atomize_config [drop_string_keys: true]
  @parser_config [
    parsers: [:urlencoded, :json, :multipart],
    pass: ["text/*", "application/json"],
    json_decoder: Jason
  ]


  plug :match
  plug Plug.Parsers, @parser_config
  plug BetterParams, @atomize_config
  plug :dispatch







  # OTP Specification
  # -----------------


  def spec do
    Plug.Adapters.Cowboy2.child_spec(
      scheme: :http,
      plug: __MODULE__,
      options: Application.get_env(:ex_gun, :web)
    )
  end






  # Routes
  # ------



  # Default Page
  get "/" do
    render_json(conn, 200, %{
      message: "Make a POST request to '/send-email' for sending emails"
    })
  end


  # Handle request to send emails
  post "/send-email" do
    case ExGun.Client.send_email(conn.params) do
      {:ok, response} ->
        Logger.info("[Router]: Email sent to Mailgun!")
        render_json(conn, 200, response)

      {:error, reason} ->
        Logger.error("[Router]: Sending Email Failed: #{inspect(reason)}")
        render_json(conn, 400, build_error("Could not send email. See Logs."))
    end
  end


  # Handle all other Routes
  match _ do
    render_json(conn, 404, %{message: "Not Found"})
  end





  # Private Helpers
  # ---------------



  # Handle Errors
  defp handle_errors(conn, error) do
    Logger.error("[Router]: Web Request Failed:\n#{inspect(error)}")
    render_json(conn, conn.status, build_error("Something Went Wrong. See Logs."))
  end


  # Render JSON
  defp render_json(conn, code, map) do
    body = Jason.encode!(map)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, body)
  end


  # Build Error
  defp build_error(message) do
    %{status: "failed", message: message}
  end


end

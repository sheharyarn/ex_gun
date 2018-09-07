defmodule ExGun.Client.Request do
  @moduledoc """
  Helper module to build requests and parse their responses
  for the Mailgun API
  """

  @post_headers [
    {"Content-Type", "application/x-www-form-urlencoded"},
    {"Accept", "application/json"},
  ]




  # Public API
  # ----------


  @doc """
  Build the Request URL from a given path, and automatically
  loading the base_url and domain.
  """
  def build_url(path, params \\ []) do
    base_url = config(:base_url)
    domain   = config(:domain)
    params   = "?" <> URI.encode_query(params)

    Path.join([base_url, domain, path]) <> params
  end




  @doc "Perform GET request"
  def get(url) do
    HTTPoison.get(url, [], build_http_options())
  end




  @doc "Perform POST request"
  def post(url, params \\ []) do
    params  = URI.encode_query(params)
    options = build_http_options()

    HTTPoison.post(url, params, @post_headers, options)
  end




  @doc """
  Handle a HTTPoison request response

  Returns the parsed JSON response if the status code is between
  200 & 300, otherwise an error tuple. Will also return error if
  an error message is returned from the Mailgun API.
  """
  def handle_response({:ok, %{status_code: code, body: body}})
  when code >= 200 and code < 300 do
    case parse_body(body) do
      %{error: %{message: message}} ->
        {:error, {:mailgun, message}}

      body ->
        {:ok, body}
    end
  end

  def handle_response({:ok, %{status_code: code}}) do
    {:error, {:status_code, code}}
  end

  def handle_response({:error, %{reason: reason}}) do
    {:error, {:request, reason}}
  end





  # Private Helpers
  # ---------------


  # Get Configs
  defp config,        do: Application.get_env(:ex_gun, :mailgun)
  defp config(key),   do: config()[key]


  # Parse a JSON response body
  defp parse_body(binary) do
    binary
    |> Jason.decode!
    |> symbolize
  end


  # Build HTTP Options
  defp build_http_options do
    username = "api"
    password = config(:api_key)

    [hackney: [basic_auth: {username, password}]]
  end


  # Note: This is a potential DoS attack vector. Should
  # explicitly specify which fields should be atomized.
  defp symbolize({k, v}),                  do: {String.to_atom(k), symbolize(v)}
  defp symbolize(list) when is_list(list), do: Enum.map(list, &symbolize/1)
  defp symbolize(map)  when is_map(map),   do: Map.new(map, &symbolize/1)
  defp symbolize(term),                    do: term

end



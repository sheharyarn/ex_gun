defmodule ExGun.Client do
  alias ExGun.Client.Request
  alias ExGun.Client.Template


  @moduledoc """
  Module exposing methods to communicate with the Mailgun API
  """

  @from_email "ExGun App <noreply@test.mailgun.org>"





  # Public API
  # ----------


  @doc "Get Domain Logs"
  def logs do
    "/log"
    |> Request.build_url
    |> Request.get
    |> Request.handle_response
  end



  @doc "Send Email with pure JSON params"
  def send_email_json(params) do
    params
    |> Request.parse_body
    |> send_email
  rescue
    Jason.DecodeError -> {:error, "Malformed JSON"}
  end



  @doc "Send an Email when body is specified"
  def send_email(%{to: to, subject: subject, body: body}) do
    params = [to: to, subject: subject, html: body, from: @from_email]

    "/messages"
    |> Request.build_url
    |> Request.post(params)
    |> Request.handle_response
  end



  @doc "Send an Email when template is specified"
  def send_email(%{to: to, subject: subject, template: name} = params) do
    attrs = Map.get(params, :attributes, [])

    with {:ok, body} <- Template.load(name, attrs) do
      params = [to: to, subject: subject, html: body, from: @from_email]

      "/messages"
      |> Request.build_url
      |> Request.post(params)
      |> Request.handle_response
    end
  end



  # Handle unspecified parameters
  def send_email(_term) do
    {:error, "Required Parameters Missing"}
  end


end

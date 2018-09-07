defmodule ExGun.Client do
  alias ExGun.Client.Request


  @moduledoc """
  Module exposing methods to communicate with the Mailgun API
  """

  @from_email "noreply@test.mailgun.org"





  # Public API
  # ----------


  @doc "Get Domain Logs"
  def logs do
    "/log"
    |> Request.build_url
    |> Request.get
    |> Request.handle_response
  end




  @doc "Send an Email when body is specified"
  def send_email(%{to: to, subject: subject, body: body}) do
    params = [to: to, subject: subject, html: body, from: @from_email]

    "/messages"
    |> Request.build_url
    |> Request.post(params)
    |> Request.handle_response
  end



  # Raise Error
  def send_email(_term) do
    raise "Invalid Parameters specified for Sending Email"
  end


end

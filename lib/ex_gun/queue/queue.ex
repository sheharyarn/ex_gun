defmodule ExGun.Queue do
  use GenServer
  require Logger


  @moduledoc """
  Long-running process that listens to a RabbitMQ queue for email
  requests, and sends them to the Mailgun server.
  """

  @config   Application.get_env(:ex_gun, :queue)
  @queue    @config[:queue_name]
  @exchange @config[:exchange_name]





  # Public API
  # ----------


  @doc "Start the Queue GenServer"
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end


  @doc "Add an email request to the queue"
  def enqueue(params) do
    GenServer.cast(__MODULE__, {:enqueue, params})
  end






  # Callbacks
  # ---------


  # Initialize State
  @doc false
  def init(:ok) do
    # Create Connection & Channel
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel}    = AMQP.Channel.open(connection)

    # Declare Exchange & Queue
    AMQP.Exchange.declare(channel, @exchange, :direct)
    AMQP.Queue.declare(channel, @queue, durable: false)
    AMQP.Queue.bind(channel, @queue, @exchange, routing_key: @queue)

    # Start Consuming
    AMQP.Basic.consume(channel, @queue, nil, no_ack: true)

    {:ok, channel}
  end



  # Handle cast for :enqueue
  @doc false
  def handle_cast({:enqueue, payload}, channel) do
    AMQP.Basic.publish(channel, @exchange, @queue, payload)
    {:noreply, channel}
  end



  # Receive Messages
  @doc false
  def handle_info({:basic_deliver, payload, _meta}, channel) do
    Logger.debug("Received Payload: #{inspect payload}")

    spawn fn ->
      consume(payload)
    end

    {:noreply, channel}
  end



  # Discard all other messages
  @doc false
  def handle_info(message, state) do
    Logger.debug("Received info: #{inspect message}")
    {:noreply, state}
  end






  # Private Helpers
  # ---------------


  defp consume(payload) do
    case ExGun.Client.send_email_json(payload) do
      {:ok, response} ->
        Logger.info("[Queue]: Email sent to Mailgun! Response:\n#{inspect(response)}")

      {:error, reason} ->
        Logger.error("[Queue]: Sending Email Failed: #{inspect(reason)}")
    end
  end


end

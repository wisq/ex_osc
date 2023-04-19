defmodule ExOSC.Client do
  @moduledoc """
  A module for sending and receiving messages to/from an OSC server.

  Starting a client will create a UDP socket on an arbitrary (system-assigned)
  port and then wait for messages to be sent or received.  No initial
  negotiation is performed.

  The client will act as a `GenStage` producer.  To receive responses to your
  requests, you should create a `GenStage` consumer (or consumer-producer) and
  subscribe it to the PID returned by `start_link/1`.  Each event will be a
  decoded `OSC.Message` structure.

  Due to the stateless nature of the OSC protocol, it is up to the user of this
  library to ensure there is actually an OSC server at the target IP and port.
  Failure to do so will not cause any errors on startup, nor prevent sending
  messages, but will simply result in no actions being performed and no replies
  being received.
  """
  require Logger
  use GenStage

  alias OSC.Message

  defmodule State do
    @moduledoc false
    @enforce_keys [:socket, :target]
    defstruct(
      socket: nil,
      target: nil
    )
  end

  @typedoc "Options used by `start_link/1`"
  @type options :: [option]

  @typedoc "Option values used by `start_link/1`"
  @type option :: {:ip, :inet.ip_address()} | {:port, :inet.port_number()} | GenServer.option()

  @doc """
  Starts a client that will send and receive OSC messages to/from a target IP and port.

  ## Options

    * `:ip` (required) - target IP in tuple form
    * `:port` (required) - target UDP port

  This function also accepts all the options accepted by `GenServer.start_link/3`.

  ## Return values

  Same as `GenServer.start_link/3`.
  """
  @spec start_link(options) :: GenServer.on_start()
  def start_link(opts) do
    {ip, opts} = Keyword.pop!(opts, :ip)
    {port, opts} = Keyword.pop!(opts, :port)

    GenStage.start_link(__MODULE__, {ip, port}, opts)
  end

  @doc """
  Encodes and sends an `OSC.Message` to the target.
  """
  @spec send_message(pid, %Message{}) :: :ok
  def send_message(pid, %Message{} = msg) do
    GenStage.cast(pid, {:send_message, Message.to_packet(msg)})
  end

  @impl true
  def init({_ip, _port} = target) do
    {:ok, socket} = :gen_udp.open(0, [:binary, {:active, true}])
    {:producer, %State{socket: socket, target: target}}
  end

  @impl true
  def handle_cast({:send_message, packet}, state) do
    :gen_udp.send(state.socket, state.target, packet)
    {:noreply, [], state}
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, %State{socket: socket} = state) do
    case state.target do
      {^ip, ^port} ->
        {:noreply, [OSC.Message.parse(data)], state}

      {_, _} ->
        Logger.warn("Ignoring message from unknown sender #{inspect(ip)}:#{inspect(port)}")
        {:noreply, [], state}
    end
  end

  @impl true
  def handle_demand(_demand, state) do
    # We produce events as they come in, so we don't care about demand.
    {:noreply, [], state}
  end
end

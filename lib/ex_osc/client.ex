defmodule ExOSC.Client do
  require Logger
  use GenStage

  defmodule State do
    @enforce_keys [:socket, :target]
    defstruct(
      socket: nil,
      target: nil
    )
  end

  def start_link(ip, port) when is_tuple(ip) and is_integer(port) do
    GenStage.start_link(__MODULE__, {ip, port})
  end

  def send_message(pid, %OSC.Message{} = msg) do
    GenStage.cast(pid, {:send_message, OSC.Message.to_packet(msg)})
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

# ExOSC

[![Hex.pm Version](https://img.shields.io/hexpm/v/ex_osc.svg?style=flat-square)](https://hex.pm/packages/ex_osc)

ExOSC is a library for sending and receiving messages to/from audio hardware that supports the [OpenSoundControl 1.0](https://opensoundcontrol.stanford.edu/spec-1_0.html) protocol.

The exact capabilities of this library will depend on what hardware it's talking to.  For example, when talking to an audio mixer, you'll likely be able to control the volume levels of the various faders, what audio gets routed to what outputs, etc.

[x32_remote][x32r] is an example of a library that uses ExOSC to talk to Behringer X32/M32 digital mixing consoles.

## What is OSC?

OSC is a stateless protocol that typically operates over UDP.  Messages have an *address pattern* string (or *path*, for short) that typically points to a resource or a command, and an *arguments* list comprised of zero or more supported OSC datatypes.

The OSC protocol is the same in both directions, i.e. simply passing messages back and forth.  While there is no explicit request-reply mechanism — nor any built-in acknowledgement of requests — a typical pattern is for the local agent to issue a request with a given `path`, and the remote agent to respond using a message with an identical `path`.

A partial list of devices that support OSC can be found on the OSC [Wikipedia page](https://en.wikipedia.org/wiki/Open_Sound_Control).

## Installation

ExOSC requires Elixir v1.14.  To use it, add `:ex_osc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_osc, "~> 0.1.0"}
  ]
end
```

## Usage

Here's an example of using ExOSC to request some basic info from a Behringer X32 digital rackmount mixer:

```elixir
defmodule MyConsumer do
  use GenStage

  def init(:ok) do
    {:consumer, nil}
  end

  def handle_events(events, {_, _}, state) do
    events |> Enum.each(&IO.inspect/1)
    {:noreply, [], state}
  end
end

{:ok, client} = ExOSC.Client.start_link(ip: {192, 168, 1, 123}, port: 10023)
{:ok, consumer} = GenStage.start_link(MyConsumer, :ok, [])
{:ok, _} = GenStage.sync_subscribe(consumer, to: client)

ExOSC.Client.send_message(client, %OSC.Message{path: "/info"})
ExOSC.Client.send_message(client, %OSC.Message{path: "/ch/01/mix/fader"})
ExOSC.Client.send_message(client, %OSC.Message{path: "/ch/01/mix/pan"})
Process.sleep(100) # give it some time to reply
```

Output:

```elixir
%OSC.Message{path: "/info", args: ["V2.07", "osc-server", "X32RACK", "4.06-8"]}
%OSC.Message{path: "/ch/01/mix/fader", args: [1.0]}
%OSC.Message{path: "/ch/01/mix/pan", args: [0.5]}
```

Of course, for this particular hardware, you should probably use [x32_remote][x32r] instead.

## Documentation

Full documentation can be found at <https://hexdocs.pm/ex_osc>.

## Legal stuff

Copyright © 2023, Adrian Irving-Beer.

ExOSC is released under the [MIT license](https://github.com/wisq/ex_osc/blob/main/LICENSE) and is provided with **no warranty**.  Be careful with what commands you issue to your (usually expensive) audio hardware.

[x32r]: https://github.com/wisq/x32_remote

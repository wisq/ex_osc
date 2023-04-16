defmodule OSC.MessageTest do
  use ExUnit.Case, async: true
  alias OSC.Message
  alias OSC.Types

  test "Message.to_packet/1 encodes path and arguments" do
    msg = %Message{path: "/1/2/3", args: ["arg1", 123, "arg3"]}

    assert Message.to_packet(msg) ==
             [
               Types.String.encode("/1/2/3"),
               Types.String.encode(",sis"),
               Types.String.encode("arg1"),
               Types.Integer.encode(123),
               Types.String.encode("arg3")
             ]
             |> Enum.join("")
  end
end

defmodule OSC.MessageTest do
  use ExUnit.Case, async: true
  alias OSC.Message
  alias OSC.Types

  test "Message.to_packet/1 encodes path and arguments" do
    msg = %Message{path: "/1/2/3", args: ["arg1", 123, "arg3", 456.789]}

    assert Message.to_packet(msg) ==
             [
               Types.String.encode("/1/2/3"),
               Types.String.encode(",sisf"),
               Types.String.encode("arg1"),
               Types.Integer.encode(123),
               Types.String.encode("arg3"),
               Types.Float.encode(456.789)
             ]
             |> Enum.join("")
  end

  test "Message.parse/1 decodes path and arguments" do
    packet =
      [
        Types.String.encode("/1/2/3"),
        Types.String.encode(",sisf"),
        Types.String.encode("arg1"),
        Types.Integer.encode(123),
        Types.String.encode("arg3"),
        Types.Float.encode(456.789)
      ]
      |> Enum.join("")

    assert %Message{path: path, args: args} = Message.parse(packet)
    assert path == "/1/2/3"
    assert ["arg1", 123, "arg3", float] = args
    assert_in_delta float, 456.789, 0.001
  end
end

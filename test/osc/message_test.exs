defmodule OSC.MessageTest do
  use ExUnit.Case, async: true
  alias OSC.Message
  alias OSC.Types

  test "Message.construct/2 creates message" do
    assert msg = Message.construct("/some/path", ["args"])
    assert %Message{path: "/some/path", args: ["args"]} = msg
  end

  test "Message.construct/2 validates argument types" do
    assert_raise ArgumentError, fn -> Message.construct("/some/path", [:atom]) end
  end

  test "Message.construct/1 creates message with no args" do
    assert msg = Message.construct("/another/path")
    assert %Message{path: "/another/path", args: []} = msg
  end

  test "Message.to_packet/1 encodes path and arguments" do
    msg = %Message{path: "/1/2/3", args: ["arg1", 123, [3], "arg3", 456.789]}

    assert Message.to_packet(msg) ==
             [
               Types.String.encode("/1/2/3"),
               Types.String.encode(",sibsf"),
               Types.String.encode("arg1"),
               Types.Integer.encode(123),
               Types.Blob.encode([3]),
               Types.String.encode("arg3"),
               Types.Float.encode(456.789)
             ]
             |> Enum.join("")
  end

  test "Message.parse/1 decodes path and arguments" do
    packet =
      [
        Types.String.encode("/1/2/3"),
        Types.String.encode(",sibsf"),
        Types.String.encode("arg1"),
        Types.Integer.encode(123),
        Types.Blob.encode([3]),
        Types.String.encode("arg3"),
        Types.Float.encode(456.789)
      ]
      |> Enum.join("")

    assert %Message{path: path, args: args} = Message.parse(packet)
    assert path == "/1/2/3"
    assert ["arg1", 123, [3], "arg3", float] = args
    assert_in_delta float, 456.789, 0.001
  end
end

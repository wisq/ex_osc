defmodule OSC.MessageTest do
  use ExUnit.Case, async: true
  alias OSC.Message

  test "Message.to_packet/1 encodes path and arguments" do
    msg = %Message{path: "/1/2/3", args: ["list", "of", "strings"]}

    assert Message.to_packet(msg) == "/1/2/3\0\0,sss\0\0\0\0list\0\0\0\0of\0\0strings\0"
  end
end

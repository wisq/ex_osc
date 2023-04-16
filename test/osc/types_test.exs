defmodule OSC.TypesTest do
  use ExUnit.Case, async: true
  alias OSC.Types

  test "Types.encode_args/1 with an args list returns a tag string and encoded args list" do
    {tags, encodes} = Types.encode_args(["first", 999, 123.45, "last"])

    assert tags == ",sifs"

    assert encodes == [
             Types.String.encode("first"),
             Types.Integer.encode(999),
             Types.Float.encode(123.45),
             Types.String.encode("last")
           ]
  end

  test "Types.decode_args/1 with tag string and encoded args list returns decoded args" do
    encoded =
      [
        Types.Integer.encode(123),
        Types.Float.encode(3.14159),
        Types.String.encode("string")
      ]
      |> Enum.join("")

    assert {[int, float, str], "rest"} = Types.decode_args(",ifs", encoded <> "rest")
    assert int == 123
    assert_in_delta float, 3.14159, 0.00001
    assert str == "string"
  end
end

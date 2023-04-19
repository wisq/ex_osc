defmodule OSC.TypesTest do
  use ExUnit.Case, async: true
  alias OSC.Types
  doctest Types

  test "Types.validate_args/1 raises on invalid argument" do
    assert_raise ArgumentError, fn -> Types.validate_args([1, :atom, 12]) end
    assert_raise ArgumentError, fn -> Types.validate_args([%{map: 1}]) end
    assert_raise ArgumentError, fn -> Types.validate_args(keyword: 1) end
  end

  test "Types.encode_args/1 with an args list returns a tag string and encoded args list" do
    {tags, encodes} = Types.encode_args([[1, 2, 3], 45, 6.7, 8.9, "last"])

    assert tags == ",biffs"

    assert encodes == [
             Types.Blob.encode([1, 2, 3]),
             Types.Integer.encode(45),
             Types.Float.encode(6.7),
             Types.Float.encode(8.9),
             Types.String.encode("last")
           ]
  end

  test "Types.decode_args/1 with tag string and encoded args list returns decoded args" do
    encoded =
      [
        Types.Float.encode(3.14159),
        Types.Integer.encode(123),
        Types.Blob.encode([99]),
        Types.String.encode("string")
      ]
      |> Enum.join("")

    assert {[float, int, blob, str], "rest"} = Types.decode_args(",fibs", encoded <> "rest")
    assert_in_delta float, 3.14159, 0.00001
    assert int == 123
    assert blob == [99]
    assert str == "string"
  end
end

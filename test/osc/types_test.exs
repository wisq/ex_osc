defmodule OSC.TypesTest do
  use ExUnit.Case, async: true
  alias OSC.Types

  test "Types.encode_args/1 returns a tag list and encoded args" do
    {tags, encodes} = Types.encode_args(["first", 999, "last"])

    assert tags == ",sis"

    assert encodes == [
             Types.String.encode("first"),
             Types.Integer.encode(999),
             Types.String.encode("last")
           ]
  end
end

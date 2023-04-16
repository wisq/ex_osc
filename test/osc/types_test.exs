defmodule OSC.TypesTest do
  use ExUnit.Case, async: true
  alias OSC.Types

  test "Types.encode_args/1 returns a tag list and encoded args" do
    {tags, encodes} = Types.encode_args(["a", "list", "of", "strings"])

    assert tags == ",ssss"

    assert encodes == [
             Types.String.encode("a"),
             Types.String.encode("list"),
             Types.String.encode("of"),
             Types.String.encode("strings")
           ]
  end
end

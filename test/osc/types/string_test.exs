defmodule OSC.Types.StringTest do
  use ExUnit.Case, async: true
  alias OSC.Types.String, as: S

  test "Types.String.type_tag/1 is s" do
    assert S.type_tag() == "s"
  end

  test "Types.String.encode/1 adds nulls to pad to 32-bit chunks" do
    assert S.encode("a") == "a\0\0\0"
    assert S.encode("ab") == "ab\0\0"
    assert S.encode("abc") == "abc\0"
  end

  test "Types.String.encode/1 always adds at least one null" do
    assert S.encode("abcd") == "abcd\0\0\0\0"
  end

  test "Types.String.encode/1 uses raw byte size" do
    assert S.encode("\u{F8}") == "\xc3\xb8\0\0"
    assert S.encode("\u{1F4A9}") == "\xf0\x9f\x92\xa9\0\0\0\0"
  end

  test "Types.String.decode/1 reads up until first block that ends with null" do
    assert S.decode("a\0\0\0everything") == {"a", "everything"}
    assert S.decode("ab\0\0after") == {"ab", "after"}
    assert S.decode("abc\0first") == {"abc", "first"}
    assert S.decode("abcd\0\0\0\0null") == {"abcd", "null"}
    assert S.decode("abcde\0\0\0block") == {"abcde", "block"}
  end

  @random_chars [?a..?z, ?A..?Z, ?0..?9]
                |> Enum.map(&Enum.to_list/1)
                |> List.flatten()

  def random_string(len) do
    1..len
    |> Enum.map(fn _ -> Enum.random(@random_chars) end)
    |> Enum.join("")
  end

  test "Types.String.decode/1 can read output of S.encode/1" do
    str1 = Enum.random(1..10) |> random_string()
    str2 = Enum.random(1..10) |> random_string()
    str3 = Enum.random(1..10) |> random_string()

    combined = S.encode(str1) <> S.encode(str2) <> S.encode(str3) <> "rest"

    assert {^str1, rest} = S.decode(combined)
    assert {^str2, rest} = S.decode(rest)
    assert {^str3, rest} = S.decode(rest)

    assert rest == "rest"
    assert byte_size(combined) |> rem(4) == 0
  end
end

defmodule OSC.Types.IntegerTest do
  use ExUnit.Case, async: true
  alias OSC.Types.Integer, as: I
  doctest I

  test "Types.Integer.type_tag/1 is i" do
    assert I.type_tag() == ?i
  end

  test "Types.Integer.encode/1 encodes as 32-bit big-endian signed binary" do
    assert I.encode(123) == <<0, 0, 0, 123>>
    assert I.encode(12345) == <<0, 0, 48, 57>>
    assert I.encode(1_234_567) == <<0, 18, 214, 135>>
    assert I.encode(123_456_789) == <<7, 91, 205, 21>>
    assert I.encode(-1) == <<255, 255, 255, 255>>
  end

  test "Types.Integer.encode/1 fails on integers out of range" do
    assert I.encode(-2_147_483_648) == <<128, 0, 0, 0>>
    assert I.encode(2_147_483_647) == <<127, 255, 255, 255>>
    assert_raise FunctionClauseError, fn -> I.encode(-2_147_483_649) end
    assert_raise FunctionClauseError, fn -> I.encode(2_147_483_648) end
  end

  test "Types.Integer.decode/1 reads a 32-bit big-endian signed binary" do
    assert I.decode(<<1, 2, 3, 4, "rest">>) == {16_909_060, "rest"}
    assert I.decode(<<0, 0, 123, 45>>) == {31533, ""}
    assert I.decode(<<200, 0, 0, 0, "after">>) == {-939_524_096, "after"}
    assert I.decode(<<255, 255, 255, 255, 0>>) == {-1, "\0"}
  end

  test "Types.Integer.decode/1 reads output of Types.Integer.encode/1" do
    1..100
    |> Enum.each(fn _ ->
      int = Enum.random(-2_000_000_000..2_000_000_000)
      assert I.encode(int) |> I.decode() == {int, ""}
    end)
  end
end

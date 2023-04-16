defmodule OSC.Types.FloatTest do
  use ExUnit.Case, async: true
  alias OSC.Types.Float, as: F

  test "Types.Float.type_tag/1 is `f`" do
    assert F.type_tag() == "f"
  end

  test "Types.Float.encode/1 encodes as 32-bit float" do
    assert F.encode(1.0) == <<63, 128, 0, 0>>
    assert F.encode(0.5) == <<63, 0, 0, 0>>
    assert F.encode(0.75) == <<63, 64, 0, 0>>
    assert F.encode(123.456) == <<66, 246, 233, 121>>
  end

  test "Types.Float.decode/1 reads a 32-bit float" do
    assert {f, ""} = F.decode(<<64, 12, 34, 56>>)
    assert_in_delta f, 2.18958, 0.00001

    assert {f, "rest"} = F.decode(<<70, 60, 50, 40, "rest">>)
    assert_in_delta f, 12044.53906, 0.00001
  end

  test "Types.Float.decode/1 reads output of Types.Float.encode/1" do
    1..100
    |> Enum.each(fn _ ->
      input = Enum.random(-1_000_000..1_000_000) / 1000
      assert {output, ""} = F.encode(input) |> F.decode()
      assert_in_delta input, output, 0.0001
    end)
  end
end

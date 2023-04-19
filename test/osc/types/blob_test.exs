defmodule OSC.Types.BlobTest do
  use ExUnit.Case, async: true
  alias OSC.Types.Blob, as: B
  doctest B

  test "Types.Blob.encode/1 converts to binary and prepends size" do
    assert B.encode([1, 2, 3, 4]) == <<0, 0, 0, 4, 1, 2, 3, 4>>
    assert B.encode([8, 7, 6, 5, 4, 3, 2, 1]) == <<0, 0, 0, 8, 8, 7, 6, 5, 4, 3, 2, 1>>
  end

  test "Types.Blob.encode/1 pads to 32-bit chunks" do
    assert B.encode([1, 2]) == <<0, 0, 0, 2, 1, 2, 0, 0>>
    assert B.encode([3, 4, 5, 6, 7]) == <<0, 0, 0, 5, 3, 4, 5, 6, 7, 0, 0, 0>>
  end

  test "Types.Blob.encode/1 rejects bytes outside of range 0..255" do
    assert B.encode([0]) == <<0, 0, 0, 1, 0, 0, 0, 0>>
    assert_raise ArgumentError, fn -> B.encode([-1]) end

    assert B.encode([255]) == <<0, 0, 0, 1, 255, 0, 0, 0>>
    assert_raise ArgumentError, fn -> B.encode([256]) end
  end

  test "Types.Blob.encode/1 handles zero-length blobs" do
    # I have no idea if this is legal; the spec doesn't say either way.
    assert B.encode([]) == <<0, 0, 0, 0>>
  end

  test "Types.Blob.decode/1 reads size, then reads that many values" do
    assert {[123], _} = B.decode(<<0, 0, 0, 1, 123, 0, 0, 0>>)
    assert {[12, 34, 56], _} = B.decode(<<0, 0, 0, 3, 12, 34, 56, 0>>)
    assert {[12, 34, 56, 78, 90], _} = B.decode(<<0, 0, 0, 5, 12, 34, 56, 78, 90, 0, 0, 0>>)
  end

  test "Types.Blob.decode/1 always reads 32-bit chunks" do
    assert {_, "rest"} = B.decode(<<0, 0, 0, 1, "junk", "rest">>)
    assert {_, "after"} = B.decode(<<0, 0, 0, 14, "16 bytes of data", "after">>)
  end

  test "Types.Blob.decode/1 handles zero-length blobs" do
    # Again, no idea if this is legal.
    assert B.decode(<<0, 0, 0, 0, "rest">>) == {[], "rest"}
  end

  defp random_blob(size) do
    1..size
    |> Enum.map(fn _ -> Enum.random(0..255) end)
  end

  test "Types.Blob.decode/1 can read output of B.encode/1" do
    blob1 = Enum.random(1..32) |> random_blob()
    blob2 = Enum.random(1..32) |> random_blob()
    blob3 = Enum.random(1..32) |> random_blob()

    combined = B.encode(blob1) <> B.encode(blob2) <> B.encode(blob3) <> "rest"

    assert {^blob1, rest} = B.decode(combined)
    assert {^blob2, rest} = B.decode(rest)
    assert {^blob3, rest} = B.decode(rest)

    assert rest == "rest"
    assert byte_size(combined) |> rem(4) == 0
  end
end

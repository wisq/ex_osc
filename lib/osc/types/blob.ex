defmodule OSC.Types.Blob do
  alias OSC.Types

  def type_tag, do: "b"

  def encode(list) when is_list(list) do
    length = Enum.count(list)
    binary = :binary.list_to_bin(list) |> pad_to_32bit()

    Types.Integer.encode(length) <> pad_to_32bit(binary)
  end

  def decode(binary) do
    {length, rest} = Types.Integer.decode(binary)
    drop = round_to_32bit(length)

    {
      binary_part(rest, 0, length) |> :binary.bin_to_list(),
      binary_slice(rest, drop, byte_size(rest))
    }
  end

  defp pad_to_32bit(binary) do
    case byte_size(binary) |> rem(4) do
      0 -> binary
      1 -> binary <> <<0, 0, 0>>
      2 -> binary <> <<0, 0>>
      3 -> binary <> <<0>>
    end
  end

  defp round_to_32bit(number) do
    case number |> rem(4) do
      0 -> number
      1 -> number + 3
      2 -> number + 2
      3 -> number + 1
    end
  end
end

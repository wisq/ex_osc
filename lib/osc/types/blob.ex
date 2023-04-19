defmodule OSC.Types.Blob do
  @moduledoc """
  Encoding and decoding of the OSC blob type.

  Blobs are of a list of arbitrary bytes of a given length.  Their encoded form
  consists of an OSC integer indicating the length, followed by the bytes in
  raw binary format, then padded with null characters (`"\\0"`) until the result
  is 32-bit aligned (like all OSC datatypes).

  As such, this is a composite type that also uses the encoding and decoding
  functions from `OSC.Types.Integer`.
  """

  alias OSC.Types

  @typedoc "An OSC blob represented as a list of bytes"
  @type t :: [:erlang.byte()]

  @doc """
  Returns `?b`, the type tag for the OSC blob type

      iex> <<OSC.Types.Blob.type_tag()>>
      "b"
  """
  def type_tag, do: ?b

  @doc """
  Encodes a list of bytes to an OSC blob type.

  The encoded data consists of the number of bytes encoded as an OSC integer
  (see `Types.Integer.encode/1`), followed by the bytes in raw binary format,
  followed by zero or more null characters until 32-bit aligned.

  ## Examples

      iex> [1, 2, 3, 4] |> OSC.Types.Blob.encode()
      <<0, 0, 0, 4, 1, 2, 3, 4>>

      iex> [1, 2, 3, 4, 5] |> OSC.Types.Blob.encode()
      <<0, 0, 0, 5, 1, 2, 3, 4, 5, 0, 0, 0>>

      iex> 'hello world' |> OSC.Types.Blob.encode()
      <<0, 0, 0, 11, 104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 0>>
  """
  @spec encode(t) :: binary
  def encode(list) when is_list(list) do
    length = Enum.count(list)
    binary = :binary.list_to_bin(list) |> pad_to_32bit()

    Types.Integer.encode(length) <> pad_to_32bit(binary)
  end

  @doc """
  Decodes an OSC blob to a list of bytes.

  The blob must start with an OSC integer (see `Types.Integer.decode/1`) that
  indicates the number of bytes in the blob.  After reading the blob contents,
  some additional bytes may be consumed (but discarded) as needed to reach the
  next 32-bit boundary.

  Returns `{blob, rest}` where `blob` is a list of bytes and `rest` is a binary
  containing any data not consumed by the decoder.

  ## Examples

      iex> <<0, 0, 0, 5, 1, 2, 3, 4, 5, 0, 0, 0, 123>> |> OSC.Types.Blob.decode()
      {[1, 2, 3, 4, 5], <<123>>}

      iex> <<0, 0, 0, 7, "goodbye world">> |> OSC.Types.Blob.decode()
      {'goodbye', "world"}
  """
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

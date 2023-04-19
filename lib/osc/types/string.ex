defmodule OSC.Types.String do
  @moduledoc """
  Encoding and decoding of the OSC string type.

  There's minimal encoding and decoding required here, since the only
  requirement for an OSC string is that it end with a null byte (`"\\0"`) and
  that it be 32-bit aligned (like all OSC types).  As such, encoding just
  involves adding null bytes, and decoding just involves finding the last block
  and removing the trailing nulls.
  """

  @typedoc "An OSC string, represented by an Elixir binary string"
  @type t :: binary

  @doc """
  Returns `?s`, the type tag for the OSC integer type

      iex> <<OSC.Types.String.type_tag()>>
      "s"
  """
  def type_tag, do: ?s

  @doc """
  Encodes an Elixir string to an OSC string type.

  Returns the encoded string, which will be the original string with 1 to 4
  null bytes (`"\\0"`) added as needed (to 32-bit align it).

  The input string cannot itself contain any null bytes.

  ## Examples

      iex> "hello world" |> OSC.Types.String.encode()
      <<"hello world", 0>>

      iex> "PadMe" |> OSC.Types.String.encode()
      <<"PadMe", 0, 0, 0>>

      iex> "multiple of four" |> OSC.Types.String.encode()
      <<"multiple of four", 0, 0, 0, 0>>
  """
  def encode(str) when is_binary(str) do
    ensure_no_nulls(str)

    case byte_size(str) |> rem(4) do
      0 -> str <> <<0, 0, 0, 0>>
      1 -> str <> <<0, 0, 0>>
      2 -> str <> <<0, 0>>
      3 -> str <> <<0>>
    end
  end

  defp ensure_no_nulls(str) do
    case :binary.match(str, <<0>>) do
      :nomatch -> :ok
      {_, _} -> raise ArgumentError, "Cannot encode OSC string with nulls: #{inspect(str)}"
    end
  end

  @doc """
  Decodes an OSC string to an Elixir string.

  Will search through the input data for a 32-bit (4-byte) block that ends with
  a null character (`"\\0"`), raising if it reaches the end without finding one.

  Returns `{string, rest}`, where `string` is all data prior to the first null
  in the final block, and `rest` is a binary containing data after that block.

  ## Examples

      iex> "goodbye\0world" |> OSC.Types.String.decode()
      {"goodbye", "world"}

      iex> "unaligned\0\0\0rest" |> OSC.Types.String.decode()
      {"unaligned", "rest"}

      iex> "nulblock\0\0\0\0after" |> OSC.Types.String.decode()
      {"nulblock", "after"}
  """
  def decode(<<0, 0, 0, 0, rest::binary>>), do: {<<>>, rest}
  def decode(<<a, 0, 0, 0, rest::binary>>), do: {<<a>>, rest}
  def decode(<<a, b, 0, 0, rest::binary>>) when a != 0, do: {<<a, b>>, rest}
  def decode(<<a, b, c, 0, rest::binary>>) when a != 0 and b != 0, do: {<<a, b, c>>, rest}

  def decode(<<a, b, c, d, rest::binary>>) when a != 0 and b != 0 and c != 0 do
    {str, rest} = decode(rest)
    {<<a, b, c, d>> <> str, rest}
  end
end

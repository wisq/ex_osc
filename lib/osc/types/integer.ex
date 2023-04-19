defmodule OSC.Types.Integer do
  # -2,147,483,648
  @min 0 - 2 ** 31
  # 2,147,483,647
  @max 2 ** 31 - 1

  @moduledoc """
  Encoding and decoding of the OSC integer type.

  OSC integers are encoded in 32-bit, signed, big-endian binary format.  As
  such, the lowest possible integer is -2³¹ (`min/0` = -2,147,483,648) and
  the highest is one less than 2³¹ (`max/0` = 2,147,483,647).
  """

  @typedoc "An OSC integer, represented by a signed 32-bit Elixir integer"
  @type t :: -2_147_483_648..2_147_483_647

  @doc """
  Returns `?i`, the type tag for the OSC integer type

      iex> <<OSC.Types.Integer.type_tag()>>
      "i"
  """
  def type_tag, do: ?i

  @doc """
  Returns the smallest possible OSC integer (`0 - 2**31`).

      iex> OSC.Types.Integer.min()
      -2_147_483_648
  """
  def min, do: @min

  @doc """
  Returns the largest possible OSC integer (`2**31 - 1`).

      iex> OSC.Types.Integer.max()
      2_147_483_647
  """
  def max, do: @max

  @doc """
  Encodes an Elixir integer to an OSC integer type.

  Returns a 32-bit big-endian-encoded integer.

  Will raise an error if the integer is lower than `min/0` or higher than `max/0`.

  ## Examples

      iex> OSC.Types.Integer.encode(123)
      <<0, 0, 0, 123>>

      iex> OSC.Types.Integer.encode(-987)
      <<255, 255, 252, 37>>
  """
  def encode(int) when is_integer(int) and int >= @min and int <= @max do
    <<int::signed-big-size(32)>>
  end

  @doc """
  Decodes an OSC integer to an Elixir integer.

  Returns `{int, rest}` where `int` is an integer decoded from the first four
  bytes of the input, and `rest` is a binary containing the remaining data.

  ## Examples

      iex> <<0, 0, 0, 3>> |> OSC.Types.Integer.decode()
      {3, ""}

      iex> <<0, 1, 2, 3, 4, 5>> |> OSC.Types.Integer.decode()
      {66051, <<4, 5>>}
  """
  def decode(<<int::signed-big-size(32), rest::binary>>) do
    {int, rest}
  end
end

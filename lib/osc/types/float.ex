defmodule OSC.Types.Float do
  @moduledoc """
  Encoding and decoding of the OSC float type.

  OSC floats are encoded in 32-bit IEEE 754 binary format (a.k.a `single`, or
  more recently, `binary32`).  This makes converting them very easy in Elixir,
  since we can just use `<<x::float-size(32)>>` binary notation for both
  encoding and decoding.

  ## Precision and rounding

  As is always the case when working with floating point numbers, you should
  expect precision errors to appear rather quickly when using this datatype —
  especially since 32-bit floats are not especially precise, only reliable to
  about 7 digits worth.  For example, you will *almost always* get different
  results if you encode and then immediately decode a float:

      iex> 0.333 |> OSC.Types.Float.encode() |> OSC.Types.Float.decode()
      {0.3330000042915344, ""}

  This is also before you get into any precision errors introduced by the
  OSC-controlled hardware itself.  For example, your mixing hardware might
  store a fader volume as an integer, performing float-to-int conversions on
  "set" operations and int-to-float conversions on "get" operations.

  As such, you should always expect **a lot** of rounding when using the OSC
  float type, as well as a lot of extraneous digits (that you might want to
  consider discarding before displaying to the end user).
  """

  @typedoc "An OSC float represented by an Elixir float"
  @type t :: float

  @doc """
  Returns `?f`, the type tag for the OSC float type

      iex> <<OSC.Types.Float.type_tag()>>
      "f"
  """
  def type_tag, do: ?f

  @doc """
  Encodes an Elixir float to an OSC float type.

  Returns a 32-bit binary-encoded float.

  ## Examples

      iex> OSC.Types.Float.encode(0.3333)
      <<62, 170, 166, 76>>
  """
  def encode(float) when is_float(float) do
    <<float::float-size(32)>>
  end

  @doc """
  Decodes an OSC float to an Elixir float.

  Returns `{float, rest}` where `float` is a float decoded from the first four
  bytes of the input, and `rest` is a binary containing the remaining data.

  ## Examples

      iex> <<63, 128, 0, 0>> |> OSC.Types.Float.decode()
      {1.0, ""}

      iex> <<68, 249, 184, 0, 234>> |> OSC.Types.Float.decode()
      {1997.75, <<234>>}
  """
  def decode(<<float::float-size(32), rest::binary>>) do
    {float, rest}
  end
end

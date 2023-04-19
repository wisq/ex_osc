defmodule OSC.Types do
  @moduledoc """
  Encoding and decoding of the possible `args` types in an `OSC.Message`.

  Encoded messages contain a "type tag string" (encoded as an OSC "string"
  type), starting with a comma, where each subsequent letter indicates the type
  of the respective argument.  For example, `",sif"` indicates a message whose
  three arguments are an OSC string, integer, and float, respectively.

  Thus, to decode arguments, we need to know the type tag string; and when
  encoding arguments, we must also produce a type tag string.
  """
  alias __MODULE__

  @typedoc "Values that can be encoded into OSC types"
  @type t :: Types.String.t() | Types.Integer.t() | Types.Float.t() | Types.Blob.t()

  @typedoc "List of OSC message arguments"
  @type args :: [t]

  @type_modules [
    Types.String,
    Types.Integer,
    Types.Float,
    Types.Blob
  ]

  @type_tags Map.new(@type_modules, fn mod -> {mod.type_tag(), mod} end)

  defp module_for_tag(tag), do: Map.fetch!(@type_tags, tag)

  defp module_for_value(x) when is_binary(x), do: Types.String
  defp module_for_value(x) when is_integer(x), do: Types.Integer
  defp module_for_value(x) when is_float(x), do: Types.Float
  defp module_for_value(x) when is_list(x), do: Types.Blob
  defp module_for_value(x), do: raise(ArgumentError, "Unknown OSC type: #{inspect(x)}")

  @doc """
  Ensure that all arguments can be mapped to OSC types.

  Raises `ArgumentError` if an argument is of a type that cannot be encoded.

  Note that this only serves as a basic sanity check on argument types, and
  does not actually ensure that arguments can be encoded.  For example, it does
  not check the range of numeric types, nor does it check the contents of
  blobs.

  ## Examples

      iex> OSC.Types.validate_args([1, 2.0, [3, 4, 5], "str"])
      :ok

      iex> OSC.Types.validate_args([1, :atom, 12])
      ** (ArgumentError) Unknown OSC type: :atom
  """
  @spec validate_args(args) :: :ok
  def validate_args(args) when is_list(args) do
    Enum.each(args, &module_for_value/1)
  end

  @doc """
  Encode arguments into an OSC type tag string and encoded binaries.

  Returns `{tags, encoded}` where `tags` is the tag string, and `encoded` is a
  list of each encoded argument.

  Note that the tag string will itself need to be encoded before sending, using
  `OSC.Types.String.encode/1`.  The encoded tag string can then be concatenated
  with the remaining binaries to form the argument portion of an `OSC.Message`.

  ## Example

      iex> OSC.Types.encode_args([1.0, 2, [3], "4"])
      {",fibs", [
        <<63, 128, 0, 0>>,             # float:   1.0
        <<0, 0, 0, 2>>,                # int:     2
        <<0, 0, 0, 1, 3, 0, 0, 0>>,    # blob:   [3]
        <<52, 0, 0, 0>>                # string: "4"
      ]}
  """
  @spec encode_args(args) :: {binary, [binary]}
  def encode_args(args) when is_list(args) do
    {tags, encodes} =
      args
      |> Enum.reverse()
      |> Enum.reduce({[], []}, &encode_args_reduce/2)

    {
      [',' | tags] |> :erlang.list_to_binary(),
      encodes
    }
  end

  defp encode_args_reduce(arg, {tags, encodes}) do
    module = module_for_value(arg)
    tag = module.type_tag()
    encode = module.encode(arg)

    {[tag | tags], [encode | encodes]}
  end

  @doc """
  Decodes OSC arguments, given a decoded OSC type tag string.

  The type tag string will need to be decoded first using
  `OSC.Types.String.decode/1`.  This function will then determine which type
  decoder to use for each argument, based on the respective characters in the tag
  string.

  Returns `{args, rest}` where `args` is the decoded args and `rest` is any
  data that was not consumed by the argument decoders.

  ## Example

      iex> OSC.Types.decode_args(",iiis", <<
      ...>   0, 0, 0, 3,
      ...>   0, 0, 0, 2,
      ...>   0, 0, 0, 1,
      ...>   "go", 0, 0,
      ...>   "stop"
      ...> >>)
      {[3, 2, 1, "go"], "stop"}
  """
  @spec decode_args(binary, binary) :: {args, binary}
  def decode_args(<<?,, tags::binary>>, encoded_args) when is_binary(encoded_args) do
    {args, rest} =
      tags
      |> :erlang.binary_to_list()
      |> Enum.map(&module_for_tag/1)
      |> Enum.reduce({[], encoded_args}, &decode_args_reduce/2)

    {Enum.reverse(args), rest}
  end

  defp decode_args_reduce(module, {args, encoded}) do
    {arg, rest} = module.decode(encoded)
    {[arg | args], rest}
  end
end

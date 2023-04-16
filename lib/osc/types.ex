defmodule OSC.Types do
  alias __MODULE__

  @type_modules [
    Types.String,
    Types.Integer,
    Types.Float,
    Types.Blob
  ]

  @type_tags Map.new(@type_modules, fn mod ->
               <<tag>> = mod.type_tag()
               {tag, mod}
             end)

  defp module_for_tag(tag), do: Map.fetch!(@type_tags, tag)

  defp module_for_value(x) when is_binary(x), do: Types.String
  defp module_for_value(x) when is_integer(x), do: Types.Integer
  defp module_for_value(x) when is_float(x), do: Types.Float
  defp module_for_value(x) when is_list(x), do: Types.Blob

  def encode_args(args) do
    {tags, encodes} =
      args
      |> Enum.reverse()
      |> Enum.reduce({[], []}, &encode_args_reduce/2)

    {
      ["," | tags] |> Enum.join(""),
      encodes
    }
  end

  defp encode_args_reduce(arg, {tags, encodes}) do
    module = module_for_value(arg)
    tag = module.type_tag()
    encode = module.encode(arg)

    {[tag | tags], [encode | encodes]}
  end

  def decode_args(<<?,, tags::binary>>, encoded_args) do
    {args, rest} =
      tags
      |> :binary.bin_to_list()
      |> Enum.map(&module_for_tag/1)
      |> Enum.reduce({[], encoded_args}, &decode_args_reduce/2)

    {Enum.reverse(args), rest}
  end

  defp decode_args_reduce(module, {args, encoded}) do
    {arg, rest} = module.decode(encoded)
    {[arg | args], rest}
  end
end

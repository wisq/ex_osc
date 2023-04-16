defmodule OSC.Types do
  alias __MODULE__

  defp type_module(str) when is_binary(str), do: Types.String

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
    module = type_module(arg)
    tag = <<_>> = module.type_tag()
    encode = module.encode(arg)

    {[tag | tags], [encode | encodes]}
  end
end

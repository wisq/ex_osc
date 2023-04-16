defmodule OSC.Types.String do
  def type_tag, do: "s"

  def encode(str) when is_binary(str) do
    case byte_size(str) |> rem(4) do
      0 -> str <> <<0, 0, 0, 0>>
      1 -> str <> <<0, 0, 0>>
      2 -> str <> <<0, 0>>
      3 -> str <> <<0>>
    end
  end

  def decode(<<0, 0, 0, 0, rest::binary>>), do: {<<>>, rest}
  def decode(<<a, 0, 0, 0, rest::binary>>), do: {<<a>>, rest}
  def decode(<<a, b, 0, 0, rest::binary>>), do: {<<a, b>>, rest}
  def decode(<<a, b, c, 0, rest::binary>>), do: {<<a, b, c>>, rest}

  def decode(<<a, b, c, d, rest::binary>>) do
    {str, rest} = decode(rest)
    {<<a, b, c, d>> <> str, rest}
  end
end

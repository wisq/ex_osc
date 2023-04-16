defmodule OSC.Types.Float do
  def type_tag, do: "f"

  def encode(float) when is_float(float) do
    <<float::float-size(32)>>
  end

  def decode(<<float::float-size(32), rest::binary>>) do
    {float, rest}
  end
end

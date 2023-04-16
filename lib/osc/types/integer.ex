defmodule OSC.Types.Integer do
  # -2,147,483,648
  @min 0 - 2 ** 31
  # 2,147,483,647
  @max 2 ** 31 - 1

  def type_tag, do: "i"

  def encode(int) when is_integer(int) and int >= @min and int <= @max do
    <<int::signed-big-size(32)>>
  end

  def decode(<<int::signed-big-size(32), rest::binary>>) do
    {int, rest}
  end
end

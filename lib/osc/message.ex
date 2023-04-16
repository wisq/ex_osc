defmodule OSC.Message do
  @enforce_keys [:path]
  defstruct(
    path: nil,
    args: []
  )

  alias OSC.Types
  alias __MODULE__

  def to_packet(%Message{} = msg) do
    {tag_string, encoded_args} = Types.encode_args(msg.args)

    [
      msg.path |> Types.String.encode(),
      tag_string |> Types.String.encode(),
      encoded_args
    ]
    |> :erlang.iolist_to_binary()
  end

  def parse(str) do
    {path, rest} = Types.String.decode(str)
    {tag_string, encoded_args} = Types.String.decode(rest)
    {args, ""} = Types.decode_args(tag_string, encoded_args)

    %Message{path: path, args: args}
  end
end

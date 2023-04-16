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
end

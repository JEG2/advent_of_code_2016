defmodule Room do
  defstruct ~w[name id checksum]a

  @a 'a' |> hd

  def parse(details) do
    [name, id, checksum] =
      Regex.run(~r{(\S+)-(\d+)\[(\S+)\]}, details, capture: :all_but_first)
    %__MODULE__{name: name, id: String.to_integer(id), checksum: checksum}
  end

  def decode(room) do
    room.name
    |> String.graphemes
    |> Enum.map(fn
      "-" ->
        " "
      <<char::utf8>> ->
        shifted = rem(char - @a + room.id, 26) + @a
        <<shifted::utf8>>
    end)
    |> Enum.join
  end
end

defmodule RoomDecoder do
  def decode(input) do
    input
    |> parse
    |> decode_all
  end

  defp parse(input) do
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&Room.parse/1)
  end

  defp decode_all(rooms) do
    rooms
    |> Enum.map(fn room -> {Room.decode(room), room.id} end)
  end
end

 System.argv
|> hd
|> File.read!
|> RoomDecoder.decode
|> Enum.find(fn {name, _id} -> String.starts_with?(name, "northpole") end)
|> IO.inspect

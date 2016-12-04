defmodule Room do
  defstruct ~w[name id checksum]a

  def parse(details) do
    [name, id, checksum] =
      Regex.run(~r{(\S+)-(\d+)\[(\S+)\]}, details, capture: :all_but_first)
    %__MODULE__{name: name, id: String.to_integer(id), checksum: checksum}
  end

  def most_common_letters(room) do
    room.name
    |> String.graphemes
    |> Enum.filter(fn char -> char != "-" end)
    |> Enum.group_by(fn char -> char end)
    |> Enum.map(fn {char, chars} -> {char, length(chars)} end)
    |> Enum.sort(fn {a_char, a_count}, {b_char, b_count} ->
      if a_count == b_count do
        a_char <= b_char
      else
        b_count <= a_count
      end
    end)
    |> Enum.take(5)
    |> Enum.map(fn {char, _count} -> char end)
    |> Enum.join("")
  end
end

defmodule RoomChecker do
  def check(input) do
    input
    |> parse
    |> find_valid
    |> sum_ids
  end

  defp parse(input) do
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&Room.parse/1)
  end

  defp find_valid(rooms) do
    rooms
    |> Enum.filter(fn room ->
      Room.most_common_letters(room) == room.checksum
    end)
  end

  defp sum_ids(rooms) do
    rooms
    |> Enum.map(fn room -> room.id end)
    |> Enum.sum
  end
end

System.argv
|> hd
|> File.read!
|> RoomChecker.check
|> IO.inspect

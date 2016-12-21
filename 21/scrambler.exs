defmodule Scrambler do
  def scramble(input) do
    input
    |> parse
    |> execute("abcdefgh")
  end

  def parse(input) do
    parsers =
      [
        {
          ~r{\Aswap position (\d+) with position (\d+)\Z},
          fn [x, y] ->
            {:swap_positions, String.to_integer(x), String.to_integer(y)}
          end
        },
        {
          ~r{\Aswap letter (\w+) with letter (\w+)\Z},
          fn [x, y] ->
            {:swap_letters, x, y}
          end
        },
        {
          ~r{\Arotate (left|right) (\d+) steps?\Z},
          fn [direction, x] ->
            {:rotate, String.to_atom(direction), String.to_integer(x)}
          end
        },
        {
          ~r{\Arotate based on position of letter (\w+)\Z},
          fn [x] ->
            {:rotate_position, x}
          end
        },
        {
          ~r{\Areverse positions (\w+) through (\w+)\Z},
          fn [x, y] ->
            {:reverse, String.to_integer(x), String.to_integer(y)}
          end
        },
        {
          ~r{\Amove position (\d+) to position (\d+)\Z},
          fn [x, y] ->
            {:move, String.to_integer(x), String.to_integer(y)}
          end
        }
      ]

    Enum.map(input, fn line ->
      Enum.find_value(parsers, fn {regex, converter} ->
        match = Regex.run(regex, line, capture: :all_but_first)
        match && converter.(match)
      end)
    end)
  end

  def execute([ ], data), do: data
  def execute([instruction | instructions], data) do
    execute(instructions, modify(data, instruction))
  end

  def modify(data, {:swap_positions, x, y}) do
    [low, high] = Enum.sort([x, y])
    String.slice(data, 0, low) <>
      String.at(data, high) <>
      String.slice(data, low + 1, high - (low + 1)) <>
      String.at(data, low) <>
      String.slice(data, high + 1, String.length(data) - (high + 1))
  end
  def modify(data, {:swap_letters, x, y}) do
    modify(
      data,
      {
        :swap_positions,
        :binary.match(data, x) |> elem(0),
        :binary.match(data, y) |> elem(0)
      }
    )
  end
  def modify(data, {:rotate, :left, x}) do
    String.slice(data, x, String.length(data) - x) <>
      String.slice(data, 0, x)
  end
  def modify(data, {:rotate, :right, x}) do
    modify(data, {:rotate, :left, String.length(data) - x})
  end
  def modify(data, {:rotate_position, x}) do
    i = :binary.match(data, x) |> elem(0)
    offset = if i >= 4, do: 2, else: 1
    modify(data, {:rotate, :right, rem(i + offset, String.length(data))})
  end
  def modify(data, {:reverse, x, y}) do
    [low, high] = Enum.sort([x, y])
    String.slice(data, 0, low) <>
      String.reverse(String.slice(data, low..high)) <>
      String.slice(data, high + 1, String.length(data) - (high + 1))
  end
  def modify(data, {:move, x, y}) do
    if x < y do
      String.slice(data, 0, x) <>
        String.slice(data, x + 1, y - x) <>
        String.at(data, x) <>
        String.slice(data, y + 1, String.length(data) - (y + 1))
    else
      String.slice(data, 0, y) <>
        String.at(data, x) <>
        String.slice(data, y, x - y) <>
        String.slice(data, x + 1, String.length(data) - (x + 1))
    end
  end
end

System.argv
|> hd
|> File.stream!
|> Scrambler.scramble
|> IO.puts

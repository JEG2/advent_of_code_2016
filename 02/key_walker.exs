defmodule KeyWalker do
  def solve(input) do
    input
    |> parse
    |> generate_keys(5, [ ])
  end

  defp parse(input) do
    input
    |> String.trim
    |> String.split("\n")
  end

  defp generate_keys([ ], _key, result),
    do: result |> Enum.reverse |> Enum.join
  defp generate_keys([moves | keys], key, result) do
    new_key = walk(moves, key)
    generate_keys(keys, new_key, [new_key | result])
  end

  # @table [
  #   [1, 2, 3],
  #   [4, 5, 6],
  #   [7, 8, 9]
  # ]
  @table [
    [nil, nil,   1, nil, nil],
    [nil,   2,   3,   4, nil],
    [5,     6,   7,   8,   9],
    [nil, "A", "B", "C", nil],
    [nil, nil, "D", nil, nil]
  ]
  @table
  |> Enum.with_index
  |> Enum.flat_map(fn {row, y} ->
    row
    |> Enum.with_index
    |> Enum.flat_map(fn
      {nil, _x} ->
        [ ]
      {key, x} ->
        mapping = [ ]
        mapping =
          if y > 0 do
            [{"U", key, Enum.at(@table, y - 1) |> Enum.at(x)} | mapping]
          else
            mapping
          end
        mapping =
          if x < @table |> hd |> length |> Kernel.-(1) do
            [{"R", key, Enum.at(@table, y) |> Enum.at(x + 1)} | mapping]
          else
            mapping
          end
        mapping =
          if y < @table |> length |> Kernel.-(1) do
            [{"D", key, Enum.at(@table, y + 1) |> Enum.at(x)} | mapping]
          else
            mapping
          end
        mapping =
          if x > 0 do
            [{"L", key, Enum.at(@table, y) |> Enum.at(x - 1)} | mapping]
          else
            mapping
          end
        mapping
        |> Enum.filter(fn {_d, _k, nk} -> not is_nil(nk) end)
        |> Enum.map(fn {dir, k, nk} ->
          def walk(unquote(dir) <> moves, unquote(k)) do
            walk(moves, unquote(nk))
          end
        end)
    end)
  end)
  # |> IO.inspect
  # defp walk("R" <> moves, 1), do: walk(moves, 2)
  # defp walk("D" <> moves, 1), do: walk(moves, 4)
  # defp walk("R" <> moves, 2), do: walk(moves, 3)
  # defp walk("D" <> moves, 2), do: walk(moves, 5)
  # defp walk("L" <> moves, 2), do: walk(moves, 1)
  # defp walk("D" <> moves, 3), do: walk(moves, 6)
  # defp walk("L" <> moves, 3), do: walk(moves, 2)
  # defp walk("U" <> moves, 4), do: walk(moves, 1)
  # defp walk("R" <> moves, 4), do: walk(moves, 5)
  # defp walk("D" <> moves, 4), do: walk(moves, 7)
  # defp walk("U" <> moves, 5), do: walk(moves, 2)
  # defp walk("R" <> moves, 5), do: walk(moves, 6)
  # defp walk("D" <> moves, 5), do: walk(moves, 8)
  # defp walk("L" <> moves, 5), do: walk(moves, 4)
  # defp walk("U" <> moves, 6), do: walk(moves, 3)
  # defp walk("D" <> moves, 6), do: walk(moves, 9)
  # defp walk("L" <> moves, 6), do: walk(moves, 5)
  # defp walk("U" <> moves, 7), do: walk(moves, 4)
  # defp walk("R" <> moves, 7), do: walk(moves, 8)
  # defp walk("U" <> moves, 8), do: walk(moves, 5)
  # defp walk("R" <> moves, 8), do: walk(moves, 9)
  # defp walk("L" <> moves, 8), do: walk(moves, 7)
  # defp walk("U" <> moves, 9), do: walk(moves, 6)
  # defp walk("L" <> moves, 9), do: walk(moves, 8)
  def walk(<<_move::utf8, moves::binary>>, key), do: walk(moves, key)
  def walk("", key), do: key
end

System.argv
|> hd
|> File.read!
|> KeyWalker.solve
|> IO.inspect

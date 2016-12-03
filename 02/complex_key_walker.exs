defmodule ComplexKeyWalker do
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

  defp walk("D" <> moves, 1), do: walk(moves, 3)
  defp walk("R" <> moves, 2), do: walk(moves, 3)
  defp walk("D" <> moves, 2), do: walk(moves, 6)
  defp walk("U" <> moves, 3), do: walk(moves, 1)
  defp walk("R" <> moves, 3), do: walk(moves, 4)
  defp walk("D" <> moves, 3), do: walk(moves, 7)
  defp walk("L" <> moves, 3), do: walk(moves, 2)
  defp walk("D" <> moves, 4), do: walk(moves, 8)
  defp walk("L" <> moves, 4), do: walk(moves, 3)
  defp walk("R" <> moves, 5), do: walk(moves, 6)
  defp walk("U" <> moves, 6), do: walk(moves, 2)
  defp walk("R" <> moves, 6), do: walk(moves, 7)
  defp walk("D" <> moves, 6), do: walk(moves, "A")
  defp walk("L" <> moves, 6), do: walk(moves, 5)
  defp walk("U" <> moves, 7), do: walk(moves, 3)
  defp walk("R" <> moves, 7), do: walk(moves, 8)
  defp walk("D" <> moves, 7), do: walk(moves, "B")
  defp walk("L" <> moves, 7), do: walk(moves, 6)
  defp walk("U" <> moves, 8), do: walk(moves, 4)
  defp walk("R" <> moves, 8), do: walk(moves, 9)
  defp walk("D" <> moves, 8), do: walk(moves, "C")
  defp walk("L" <> moves, 8), do: walk(moves, 7)
  defp walk("L" <> moves, 9), do: walk(moves, 8)
  defp walk("U" <> moves, "A"), do: walk(moves, 6)
  defp walk("R" <> moves, "A"), do: walk(moves, "B")
  defp walk("U" <> moves, "B"), do: walk(moves, 7)
  defp walk("R" <> moves, "B"), do: walk(moves, "C")
  defp walk("D" <> moves, "B"), do: walk(moves, "D")
  defp walk("L" <> moves, "B"), do: walk(moves, "A")
  defp walk("U" <> moves, "C"), do: walk(moves, 8)
  defp walk("L" <> moves, "C"), do: walk(moves, "B")
  defp walk("U" <> moves, "D"), do: walk(moves, "B")
  defp walk(<<_move::utf8, moves::binary>>, key), do: walk(moves, key)
  defp walk("", key), do: key
end

System.argv
|> hd
|> File.read!
|> ComplexKeyWalker.solve
|> IO.inspect

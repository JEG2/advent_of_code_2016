defmodule LeastCommon do
  def decode(input) do
    input
    |> parse
    |> count(%{ })
    |> rebuild
  end

  defp parse(input) do
    input
    |> String.trim
    |> String.split("\n")
  end

  defp count([line | lines], counts) do
    new_counts =
      line
      |> String.graphemes
      |> Enum.with_index
      |> Enum.reduce(counts, fn {char, i}, updated_counts ->
        Map.update(updated_counts, i, %{char => 1}, fn chars ->
          Map.update(chars, char, 1, fn c -> c + 1 end)
        end)
      end)
    count(lines, new_counts)
  end
  defp count([ ], counts), do: counts

  defp rebuild(counts) do
    counts
    |> Map.keys
    |> Enum.sort
    |> Enum.map(fn i ->
      counts
      |> Map.fetch!(i)
      |> Enum.sort_by(fn {_char, count} -> count end)
      |> hd
      |> elem(0)
    end)
    |> Enum.join
  end
end

System.argv
|> hd
|> File.read!
|> LeastCommon.decode
|> IO.inspect

defmodule WalkRadius do
  require Integer

  @input 1350

  def pace(limit) do
    search([[{1, 1}]], String.to_integer(limit), MapSet.new([{1, 1}]))
  end

  defp search([path | paths], limit, seen) do
    if length(path) - 1 == limit do
      search(paths, limit, seen)
    else
      {new_paths, new_seen} = moves(path, seen)
      search(paths ++ new_paths, limit, new_seen)
    end
  end
  defp search([ ], _limit, seen), do: MapSet.size(seen)

  defp moves(path = [{x, y} | spaces], seen) do
    [
              {0, -1},
      {-1, 0},          {1, 0},
              {0, 1}
    ]
    |> Enum.map(fn {x_offset, y_offset} ->
      {x + x_offset, y + y_offset}
    end)
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 end)
    |> Enum.filter(&is_open/1)
    |> Enum.filter(fn xy -> not xy in spaces end)
    |> Enum.map(fn xy -> [xy | path] end)
    |> filter_if_seen([ ], seen)
  end

  defp is_open({x, y}) do
    x * x + 3 * x + 2 * x * y + y + y * y + @input
    |> Integer.to_string(2)
    |> String.graphemes
    |> Enum.count(fn bit -> bit == "1" end)
    |> Integer.is_even
  end

  defp filter_if_seen([path = [xy | _spaces] | paths], filtered, seen) do
    if MapSet.member?(seen, xy) do
      filter_if_seen(paths, filtered, seen)
    else
      filter_if_seen(paths, [path | filtered], MapSet.put(seen, xy))
    end
  end
  defp filter_if_seen([ ], filtered, seen), do: {filtered, seen}
end

System.argv
|> hd
|> WalkRadius.pace
|> IO.inspect

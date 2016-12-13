defmodule Walk do
  require Integer

  @input 1350

  def to([x, y]) do
    search([[{1, 1}]], {String.to_integer(x), String.to_integer(y)})
  end

  defp search([path | paths], goal) do
    new_paths = moves(path)
    final_path = Enum.find(new_paths, fn [xy | _spaces] -> xy == goal end)
    if final_path do
      length(final_path) - 1
    else
      search(paths ++ new_paths, goal)
    end
  end

  defp moves(path = [{x, y} | spaces]) do
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
  end

  def is_open({x, y}) do
    x * x + 3 * x + 2 * x * y + y + y * y + @input
    |> Integer.to_string(2)
    |> String.graphemes
    |> Enum.count(fn bit -> bit == "1" end)
    |> Integer.is_even
  end
end

System.argv
|> Walk.to
|> IO.inspect

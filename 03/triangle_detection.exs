defmodule TriangleDetection do
  def count(input) do
    input
    |> parse
    |> detect
  end

  defp parse(input) do
    Regex.scan(~r{\d+}, input, capture: :first)
    |> List.flatten
    |> Enum.map(fn n -> String.to_integer(n) end)
    |> Enum.chunk(3)
  end

  defp detect(triangles) do
    triangles
    |> Enum.filter(fn [a, b, c] -> a + b > c and a + c > b and b + c > a end)
    |> Enum.count
  end
end

System.argv
|> hd
|> File.read!
|> TriangleDetection.count
|> IO.inspect

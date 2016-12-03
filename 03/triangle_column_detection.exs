defmodule TriangleColumnDetection do
  def count(input) do
    input
    |> parse
    |> detect
  end

  defp parse(input) do
    numbers =
      Regex.scan(~r{\d+}, input, capture: :first)
      |> List.flatten
      |> Enum.map(fn n -> String.to_integer(n) end)
    Enum.concat( [
      Enum.take_every(numbers, 3),
      numbers |> Enum.drop(1) |> Enum.take_every(3),
      numbers |> Enum.drop(2) |> Enum.take_every(3),
    ] )
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
|> TriangleColumnDetection.count
|> IO.inspect

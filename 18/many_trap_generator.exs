defmodule ManyTrapGenerator do
  def generate(input) do
    input
    |> parse
    |> wrap
    |> build
    |> count
  end

  defp parse(line) do
    String.trim(line)
  end

  defp wrap(first_line) do
    Stream.iterate(first_line, fn previous_line ->
      ["."] ++ String.graphemes(previous_line) ++ ["."]
      |> Enum.chunk(3, 1)
      |> Enum.map(&generate_tile/1)
      |> Enum.join
    end)
  end

  defp generate_tile(["^", ".", "."]), do: "^"
  defp generate_tile(["^", "^", "."]), do: "^"
  defp generate_tile([".", "^", "^"]), do: "^"
  defp generate_tile([".", ".", "^"]), do: "^"
  defp generate_tile(_pattern), do: "."

  defp build(generator) do
    Enum.take(generator, 400_000)
  end

  defp count(rows) do
    Enum.reduce(rows, 0, fn row, sum ->
      new_count =
        row
        |> String.graphemes
        |> Enum.count(fn tile -> tile == "." end)
      sum + new_count
    end)
  end
end

System.argv
|> hd
|> File.read!
|> ManyTrapGenerator.generate
|> IO.puts

defmodule CountIPS do
  def scan(input) do
    input
    |> parse
    |> prepare
    |> count(0, 0)
  end

  defp parse(input) do
    Stream.map(input, fn range ->
      [low, high] =
        Regex.run(~r{\A(\d+)-(\d+)\Z}, range, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      {low, high}
    end)
  end

  defp prepare(data) do
    Enum.sort_by(data, fn {low, _high} -> low end)
  end

  defp count(_exclusions, 4_294_967_296, total), do: total
  defp count(exclusions, ip, total) do
    blocked =
      Enum.find(exclusions, fn {low, high} -> low <= ip and ip <= high end)
    case blocked do
      {_low, high} ->
        count(
          Enum.drop_while(exclusions, fn {_low, future_high} ->
            future_high <= high
          end),
          high + 1,
          total
        )
      _ ->
        count(exclusions, ip + 1, total + 1)
    end
  end
end

System.argv
|> hd
|> File.stream!
|> CountIPS.scan
|> IO.inspect

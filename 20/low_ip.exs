defmodule LowIP do
  def scan(input) do
    input
    |> parse
    |> prepare
    |> count(0)
  end

  def parse(input) do
    Stream.map(input, fn range ->
      [low, high] =
        Regex.run(~r{\A(\d+)-(\d+)\Z}, range, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      {low, high}
    end)
  end

  def prepare(data) do
    Enum.sort_by(data, fn {low, _high} -> low end)
  end

  def count(exclusions, ip) do
    blocked =
      Enum.find(exclusions, fn {low, high} -> low <= ip and ip <= high end)
    case blocked do
      {_low, high} ->
        count(
          Enum.drop_while(exclusions, fn {_low, future_high} ->
            future_high <= high
          end),
          high + 1
        )
      _ ->
        ip
    end
  end
end

System.argv
|> hd
|> File.stream!
|> LowIP.scan
|> IO.inspect

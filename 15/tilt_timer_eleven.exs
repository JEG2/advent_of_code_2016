defmodule TiltTimerEleven do
  def turn(input) do
    input
    |> parse
    |> add_disc
    |> search(0)
  end

  defp parse(lines) do
    Enum.map(lines, fn line ->
      [disc, positions, start] =
        Regex.run(
          ~r{\ADisc\s\#(\d+)\shas\s(\d+)\spositions;\s
            at\stime=0,\sit\sis\sat\sposition\s(\d+)\.\Z}x,
          line,
          capture: :all_but_first
        )
        |> Enum.map(&String.to_integer/1)
      {disc, positions, start}
    end)
  end

  def add_disc(discs) do
    last_disc = List.last(discs) |> elem(0)
    discs ++ [{last_disc + 1, 11, 0}]
  end

  defp search(discs, time) do
    if falls?(discs, time) do
      time
    else
      search(discs, time + 1)
    end
  end

  defp falls?([{disc, positions, start} | discs], time) do
    if rem(disc + start + time, positions) == 0 do
      falls?(discs, time)
    else
      false
    end
  end
  defp falls?([ ], _time), do: true
end

System.argv
|> hd
|> File.stream!
|> TiltTimerEleven.turn
|> IO.inspect

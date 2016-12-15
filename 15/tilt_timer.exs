defmodule TiltTimer do
  def turn(input) do
    input
    |> parse
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
|> TiltTimer.turn
|> IO.inspect

defmodule StealCircleAcross do
  def steal(input) do
    input
    |> parse
    |> play(1, 1, 0, 1, 1)
  end

  defp parse(input) do
    String.to_integer(input)
  end

  defp play(goal, goal, current, _exponent, _power, _half), do: current
  defp play(goal, i, current, exponent, power, half) do
    j = i + 1
    if i == power do
      new_exponent = exponent + 1
      new_power = :math.pow(3, new_exponent) |> round
      new_half = div(new_power - (power + 1), 2) + power + 1
      play(goal, j, 1, new_exponent, new_power, new_half)
    else
      if i < half do
        play(goal, j, current + 1, exponent, power, half)
      else
        play(goal, j, current + 2, exponent, power, half)
      end
    end
  end
end

System.argv
|> hd
|> StealCircleAcross.steal
|> IO.inspect

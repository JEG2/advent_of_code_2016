defmodule Circle do
  require Integer

  defstruct min: 1, max: nil, step: 1

  def new(max), do: %__MODULE__{max: max}

  def one?(%__MODULE__{min: n, max: n}), do: true
  def one?(_circle), do: false

  def shrink(circle) do
    size =
      Float.ceil((circle.max - circle.min + 1) / circle.step)
      |> round
    {new_min, new_max} =
      if Integer.is_even(size) do
        {circle.min, circle.max - circle.step}
      else
        {circle.min + circle.step * 2, circle.max}
      end
    %__MODULE__{circle | min: new_min, max: new_max, step: circle.step * 2}
  end
end

defmodule StealCircle do
  def steal(input) do
    input
    |> parse
    |> build
    |> play
  end

  defp parse(input) do
    String.to_integer(input)
  end

  defp build(count) do
    Circle.new(count)
  end

  defp play(circle) do
    if Circle.one?(circle) do
      circle.min
    else
      circle
      |> Circle.shrink
      |> play
    end
  end
end

System.argv
|> hd
|> StealCircle.steal
|> IO.inspect

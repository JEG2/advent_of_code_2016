defmodule Screen do
  defstruct ~w[width height pixels]a

  def new(width, height) do
    pixels = build_pixels(width, height, false)
    %__MODULE__{width: width, height: height, pixels: pixels}
  end

  def rect(screen, width, height) do
    turned_on = build_pixels(width, height, true)
    %__MODULE__{screen | pixels: Map.merge(screen.pixels, turned_on)}
  end

  def rotate_row(screen, y, steps) do
    rotate(screen, steps, screen.width, &{&1 - 1, y})
  end

  def rotate_column(screen, x, steps) do
    rotate(screen, steps, screen.height, &{x, &1 - 1})
  end

  def voltage(screen) do
    screen.pixels
    |> Map.values
    |> Enum.count(&(&1))
  end

  def to_string(screen) do
    Enum.map((1..screen.height), fn y ->
      Enum.map((1..screen.width), fn x ->
        if Map.fetch!(screen.pixels, {x - 1, y - 1}), do: "#", else: "."
      end)
      |> Enum.join
    end)
    |> Enum.join("\n")
  end

  defp build_pixels(width, height, on_or_off) do
    for x <- 1..width, y <- 1..height, into: %{ } do
      {{x - 1, y - 1}, on_or_off}
    end
  end

  defp rotate(screen, steps, limit, to_xy) do
    xys = for i <- 1..limit do to_xy.(i) end
    new_pixels =
      screen.pixels
      |> read_pixels(xys)
      |> rotate_line(rem(steps, limit))
      |> write_line(xys, screen.pixels)
    %__MODULE__{screen | pixels: new_pixels}
  end

  defp read_pixels(pixels, xys) do
    Enum.map(xys, fn xy -> Map.fetch!(pixels, xy) end)
  end

  defp rotate_line(line, steps) do
    count = length(line) - steps
    Enum.drop(line, count) ++ Enum.take(line, count)
  end

  defp write_line(line, xys, pixels) do
    new_line =
      xys
      |> Enum.zip(line)
      |> Enum.into(%{ })
    Map.merge(pixels, new_line)
  end
end

defmodule Controller do
  @command_parsers %{
    rect: ~r{\Arect (\d+)x(\d+)\Z},
    rotate_row: ~r{\Arotate row y=(\d+) by (\d+)\Z},
    rotate_column: ~r{\Arotate column x=(\d+) by (\d+)\Z}
  }

  def execute(input) do
    input
    |> parse
    |> draw(Screen.new(50, 6))
    |> display
  end

  defp parse(input) do
    Stream.map(input, fn instruction ->
      Enum.find_value(@command_parsers, fn {name, parser} ->
        match = Regex.run(parser, instruction, capture: :all_but_first)
        match && [name | Enum.map(match, &String.to_integer/1)]
      end)
    end)
  end

  defp draw(commands, screen) do
    Enum.reduce(commands, screen, fn [command | args], new_screen ->
      apply(Screen, command, [new_screen | args])
    end)
  end

  defp display(screen) do
    ["Voltage:  #{Screen.voltage(screen)}\n", Screen.to_string(screen)]
  end
end

System.argv
|> hd
|> File.stream!
|> Controller.execute
|> IO.puts

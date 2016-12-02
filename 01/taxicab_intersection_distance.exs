defmodule TaxicabIntersectionDistance do
  def calculate(input) do
    input
    |> parse
    |> move({0, 0}, :N, MapSet.new |> MapSet.put({0, 0}))
    |> measure
  end

  def parse(directions) do
    Regex.scan(~r{([LR]|\d+)}, directions, capture: :first)
    |> List.flatten
  end

  def move(["L" | steps], location, heading, seen) do
    new_heading = turn(heading, "L")
    move(steps, location, new_heading, seen)
  end
  def move(["R" | steps], location, heading, seen) do
    new_heading = turn(heading, "R")
    move(steps, location, new_heading, seen)
  end
  def move([digits | steps], location, heading, seen) do
    number = String.to_integer(digits)
    case take_steps(number, location, heading, seen) do
      {:done, new_location} ->
        new_location
      {:continuing, new_location, new_seen} ->
        move(steps, new_location, heading, new_seen)
    end
  end
  def move([ ], _location, _heading, _seen),
    do: raise "No double visit found"

  def take_steps(0, location, _heading, seen),
    do: {:continuing, location, seen}
  def take_steps(count, location, heading, seen) do
    new_location = walk(location, heading)
    if MapSet.member?(seen, new_location) do
      {:done, new_location}
    else
      new_seen = MapSet.put(seen, new_location)
      take_steps(count - 1, new_location, heading, new_seen)
    end
  end

  def turn(:N, "L"), do: :W
  def turn(:N, "R"), do: :E
  def turn(:E, "L"), do: :N
  def turn(:E, "R"), do: :S
  def turn(:S, "L"), do: :E
  def turn(:S, "R"), do: :W
  def turn(:W, "L"), do: :S
  def turn(:W, "R"), do: :N

  def walk({x, y}, :N), do: {x, y + 1}
  def walk({x, y}, :E), do: {x + 1, y}
  def walk({x, y}, :S), do: {x, y - 1}
  def walk({x, y}, :W), do: {x - 1, y}

  def measure({new_x, new_y}), do: abs(new_x) + abs(new_y)
end

System.argv
|> hd
|> File.read!
|> TaxicabIntersectionDistance.calculate
|> IO.inspect

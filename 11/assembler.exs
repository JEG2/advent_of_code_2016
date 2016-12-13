defmodule Arrangement do
  defstruct e: 1, f1: [], f2: [], f3: [], f4: []

  def to_floor(number) do
    String.to_atom("f#{number}")
  end

  def new(floors) do
    struct(__MODULE__, floors)
  end

  def moves(arrangement) do
    lowest_floor =
      Enum.find(1..4, fn floor ->
        length(Map.fetch!(arrangement, to_floor(floor))) > 0
      end)
    floors =
      case arrangement.e do
        1 -> [2]
        4 -> [3]
        n -> [n - 1, n + 1]
      end
      |> Enum.filter(fn floor -> floor >= lowest_floor end)
    contents = floor_contents(arrangement, arrangement.e)
    possible_moves =
      contents ++ content_pairs(contents, [ ])
      |> Enum.map(&List.wrap/1)
    Enum.flat_map(floors, fn floor ->
      Enum.map(possible_moves, fn move ->
        old_contents =
          Enum.reduce(move, contents, fn item, updated_contents ->
            List.delete(updated_contents, item)
          end)
        new_contents =
          floor_contents(arrangement, floor) ++ move
          |> Enum.sort
        Map.merge(
          arrangement,
          %{
            :e => floor,
            to_floor(arrangement.e) => old_contents,
            to_floor(floor) => new_contents
          }
        )
      end)
    end)
    |> Enum.filter(&safe?/1)
  end

  def safe?(arrangement) do
    Enum.all?(1..4, fn floor ->
      contents = floor_contents(arrangement, floor)
      contents
      |> Enum.filter(fn item -> String.last(item) == "M" end)
      |> Enum.all?(fn microchip ->
        "#{String.first(microchip)}G" in contents or
          not Enum.any?(contents, fn item ->
            String.last(item) == "G"
          end)
      end)
    end)
  end

  def score(arrangement) do
    length(arrangement.f4) * 40 +
    length(arrangement.f3) * 30 +
    length(arrangement.f2) * 20 +
    length(arrangement.f1) * 10
  end

  def done?(%__MODULE__{e: 4, f3: [ ], f2: [ ], f1: [ ]}), do: true
  def done?(_arrangement), do: false

  def signature(arrangement) do
    floors =
      ~w[f1 f2 f3 f4]a
      |> Enum.map(fn floor ->
        arrangement
        |> Map.fetch!(floor)
        |> Enum.join(" ")
        |> String.replace(~r{(\w)G \1M}, "P")
        |> String.split(" ")
        |> Enum.sort
        |> Enum.join(" ")
      end)
      |> Enum.join(" | ")
    "#{arrangement.e} #{floors}"
  end

  def to_string(arrangement) do
    4..1
    |> Enum.map(fn number ->
      elevator = if arrangement.e == number, do: "E", else: " "
      contents = Enum.join(floor_contents(arrangement, number), " ")
      "F#{number}: #{elevator} #{contents}"
    end)
    |> Enum.join("\n")
  end

  # Helpers

  defp floor_contents(arrangement, number) do
    Map.fetch!(arrangement, to_floor(number))
  end

  defp content_pairs([item | contents], pairs) do
    new_pairs = Enum.map(contents, fn other_item -> [item, other_item] end)
    content_pairs(contents, pairs ++ new_pairs)
  end
  defp content_pairs([ ], pairs), do: pairs
end

defmodule Assembler do
  def assemble(input) do
    input
    |> parse
    |> find_fastest
    |> count
  end

  defp parse(input) do
    setup =
      input
      |> Enum.with_index
      |> Enum.reduce([ ], fn {line, i}, floors ->
        contents =
          Regex.scan(
            ~r{(?:(\w)\w+ (g)enerator|(\w)\w+-compatible (m)icrochip)},
            line,
            capture: :all_but_first
          )
          |> Enum.map(fn letter ->
            Enum.slice(letter, -2..-1)
            |> Enum.join("")
            |> String.upcase
          end)
          |> Enum.sort
        [{Arrangement.to_floor(i + 1), contents} | floors]
      end)
    Arrangement.new(setup)
  end

  defp find_fastest(arrangement) do
    search(
      [[arrangement]],
      MapSet.new |> MapSet.put(Arrangement.signature(arrangement))
    )
  end

  defp search([path | paths], seen) do
    {next_paths, new_seen} =
      path
      |> hd
      |> Arrangement.moves
      |> Enum.map(fn move -> [move | path] end)
      |> filter_if_seen([ ], seen)
    finish =
      next_paths
      |> Enum.find(fn [arrangement | _path] ->
        Arrangement.done?(arrangement)
      end)
    if finish do
      finish
    else
      search(paths ++ next_paths, new_seen)
    end
  end
  defp search([ ], _seen), do: raise "Solution not found"

  defp filter_if_seen([path | paths], kept, seen) do
    latest =
      path
      |> hd
      |> Arrangement.signature
    if MapSet.member?(seen, latest) do
      filter_if_seen(paths, kept, seen)
    else
      filter_if_seen(paths, [path | kept], MapSet.put(seen, latest))
    end
  end
  defp filter_if_seen([ ], kept, seen), do: {kept, seen}

  defp count(path) do
    length(path) - 1
  end
end

System.argv
|> hd
|> File.stream!
|> Assembler.assemble
|> IO.puts

defmodule HashItOut do
  @input "yjdafjpo"
  @goal 64

  def search do
    find_hashes(0, [ ], [ ])
  end

  defp find_hashes(i, candidates, validated) do
    new_hash = :crypto.hash(:md5, "#{@input}#{i}") |> Base.encode16
    {added_validated, reduced_candidates} =
      candidates
      |> expire(i)
      |> validate(new_hash)
    new_validated = validated ++ added_validated
    last_i = finish(i, new_validated)
    if last_i do
      last_i
    else
      new_candidates = add_new(reduced_candidates, i, new_hash)
      find_hashes(i + 1, new_candidates, new_validated)
    end
  end

  defp expire(candidates, i) do
    Enum.filter(candidates, fn {j, _hash, _test} -> i <= j + 1_000 end)
  end

  defp validate(candidates, new_hash) do
    groups =
      Enum.group_by(candidates, fn {_i, _hash, test} ->
        String.contains?(new_hash, test)
      end)
    {groups[true] || [ ], groups[false] || [ ]}
  end

  defp add_new(candidates, i, new_hash) do
    case Regex.run(~r{(\w)\1\1}, new_hash, capture: :all_but_first) do
      [char] -> candidates ++ [{i, new_hash, String.duplicate(char, 5)}]
      nil -> candidates
    end
  end

  defp finish(i, validated) do
    if length(validated) >= @goal do
      highest =
        validated
        |> Enum.map(fn {i, _hash, _test} -> i end)
        |> Enum.sort
        |> Enum.take(@goal)
        |> List.last
      if i > highest + 1_000 do
        highest
      else
        nil
      end
    else
      nil
    end
  end
end

HashItOut.search
|> IO.inspect

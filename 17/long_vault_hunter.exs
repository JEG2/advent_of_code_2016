defmodule VaultPath do
  defstruct location: {0, 0}, steps: ""

  @open_tests ["b", "c", "d", "e", "f"]

  def new do
    %__MODULE__{ }
  end

  def moves(%__MODULE__{location: {3, 3}}, _passcode), do: [ ]
  def moves(path = %__MODULE__{location: {x, y}, steps: steps}, passcode) do
    possible_locations =
      [
                      {"U", 0, -1},
        {"L", -1, 0},               {"R", 1, 0},
                      {"D", 0, 1}
      ]
      |> Enum.map(fn {direction, x_offset, y_offset} ->
        {direction, x + x_offset, y + y_offset}
      end)
      |> Enum.filter(fn {_direction, new_x, new_y} ->
        new_x >= 0 and new_x <= 3 and new_y >= 0 and new_y <= 3
      end)
    legal_locations =
      if length(possible_locations) > 0 do
        hash =
          :crypto.hash(:md5, "#{passcode}#{steps}")
          |> Base.encode16
          |> String.downcase
        [u_check, d_check, l_check, r_check] =
          Regex.run(~r{\A(\w)(\w)(\w)(\w)}, hash, capture: :all_but_first)
        Enum.filter(possible_locations, fn {direction, _new_x, _new_y} ->
          (direction == "U" and u_check in @open_tests) or
          (direction == "D" and d_check in @open_tests) or
          (direction == "L" and l_check in @open_tests) or
          (direction == "R" and r_check in @open_tests)
        end)
      else
        possible_locations
      end
    Enum.map(legal_locations, fn {direction, new_x, new_y} ->
      %__MODULE__{path | location: {new_x, new_y}, steps: steps <> direction}
    end)
  end

  def vault?(%__MODULE__{location: {3, 3}}), do: true
  def vault?(_path), do: false
end

defmodule LongVaultHunter do
  def hunt(passcode) do
    walk([VaultPath.new], passcode, nil)
  end

  defp walk([path | paths], passcode, longest) do
    new_paths = VaultPath.moves(path, passcode)
    vault_path = Enum.find(new_paths, &VaultPath.vault?/1)
    new_longest = compare(longest, vault_path)
    walk(paths ++ new_paths, passcode, new_longest)
  end
  defp walk([ ], _passcode, nil), do: "No path found."
  defp walk([ ], _passcode, longest), do: byte_size(longest.steps)

  defp compare(%VaultPath{steps: previous_steps}, new = %VaultPath{steps: new_steps})
  when byte_size(previous_steps) < byte_size(new_steps),
    do: new
  defp compare(nil, new), do: new
  defp compare(previous, _new), do: previous
end

System.argv
|> hd
|> LongVaultHunter.hunt
|> IO.puts

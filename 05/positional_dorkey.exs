defmodule PositionalDorkey do
  def find(id) do
    id
    |> search(0, {nil, nil, nil, nil, nil, nil, nil, nil})
  end

  defp search(id, i, code)
  when is_nil(elem(code, 0)) or is_nil(elem(code, 1))
  or is_nil(elem(code, 2)) or is_nil(elem(code, 3))
  or is_nil(elem(code, 4)) or is_nil(elem(code, 5))
  or is_nil(elem(code, 6)) or is_nil(elem(code, 7)) do
    if rem(i, 100_000) == 0 do
      IO.puts i
    end
    hash = :crypto.hash(:md5, "#{id}#{i}") |> Base.encode16
    new_code = if String.match?(hash, ~r"\A0{5}[0-7]") do
      position = String.at(hash, 5) |> String.to_integer
      if !elem(code, position) do
        put_elem(code, position, String.at(hash, 6))
        |> IO.inspect
      else
        code
      end
    else
      code
    end
    search(id, i + 1, new_code)
  end
  defp search(_id, _i, code), do: code |> Tuple.to_list |> Enum.join
end

[id] = System.argv
PositionalDorkey.find(id)
|> IO.puts

defmodule Dorkey do
  def find(id) do
    id
    |> search(0, "")
  end

  defp search(id, i, code) when byte_size(code) < 8 do
    if rem(i, 100_000) == 0 do
      IO.puts i
    end
    hash = :crypto.hash(:md5, "#{id}#{i}") |> Base.encode16
    new_code = if String.starts_with?(hash, "00000") do
      code <> String.at(hash, 5)
      |> IO.inspect
    else
      code
    end
    search(id, i + 1, new_code)
  end
  defp search(_id, _i, code), do: code
end

[id] = System.argv
Dorkey.find(id)
|> IO.puts

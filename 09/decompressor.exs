defmodule Decompressor do
  def decompress(input) do
    input
    |> sanitize
    |> expand("")
    |> count
  end

  defp sanitize(data) do
    String.replace(data, ~r{\s+}, "")
  end

  defp expand(data, expanded) do
    expansion = Regex.run(
      ~r{\A(.*?)\((\d+)x(\d+)\)(.*)\z},
      data,
      capture: :all_but_first
    )
    if expansion do
      [prefix, chars, repeat, suffix] = expansion
      {chars, repeat} = {String.to_integer(chars), String.to_integer(repeat)}
      uncompressed =
        suffix
        |> String.slice(0, chars)
        |> String.duplicate(repeat)
      expand(
        String.slice(suffix, chars..-1),
        expanded <> prefix <> uncompressed
      )
    else
      expanded <> data
    end
  end

  defp count(data) do
    String.length(data)
  end
end

System.argv
|> hd
|> File.read!
|> Decompressor.decompress
|> IO.inspect

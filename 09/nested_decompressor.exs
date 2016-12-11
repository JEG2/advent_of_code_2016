defmodule NestedDecompressor do
  def decompress(input) do
    input
    |> sanitize
    |> expand(0)
  end

  defp sanitize(data) do
    String.replace(data, ~r{\s+}, "")
  end

  defp expand(data, count) do
    expansion = Regex.run(
      ~r{\A(.*?)\((\d+)x(\d+)\)(.*)\z},
      data,
      capture: :all_but_first
    )
    if expansion do
      [prefix, chars, repeat, suffix] = expansion
      {chars, repeat} = {String.to_integer(chars), String.to_integer(repeat)}
      uncompressed = expand(String.slice(suffix, 0, chars), 0) * repeat
      expand(
        String.slice(suffix, chars..-1),
        count + String.length(prefix) + uncompressed
      )
    else
      count + String.length(data)
    end
  end
end

System.argv
|> hd
|> File.read!
|> NestedDecompressor.decompress
|> IO.inspect

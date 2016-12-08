defmodule CountTLS do
  def count(input) do
    input
    |> parse
    |> count_tls
  end

  defp parse(input) do
    Stream.map(input, fn ip ->
      sequences = ip |> String.trim |> String.split(~r{[\[\]]})
      {
        Enum.take_every(sequences, 2),
        sequences |> Enum.drop(1) |> Enum.take_every(2)
      }
    end)
  end

  defp count_tls(parsed) do
    Enum.reduce(parsed, 0, fn parsed_ip, total ->
      total + if tls?(parsed_ip), do: 1, else: 0
    end)
  end

  defp tls?({supernet, hypernet}) do
    not Enum.any?(hypernet, &abba?/1) and Enum.any?(supernet, &abba?/1)
  end

  defp abba?(sequence) when byte_size(sequence) < 4,
    do: false
  defp abba?(<<a::utf8, b::utf8, b::utf8, a::utf8, _sequence::binary>>)
  when a != b,
    do: true
  defp abba?(<<_char::utf8, sequence::binary>>),
    do: abba?(sequence)
end

System.argv
|> hd
|> File.stream!
|> CountTLS.count
|> IO.inspect

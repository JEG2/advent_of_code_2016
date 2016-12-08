defmodule CountSSL do
  def count(input) do
    input
    |> parse
    |> count_ssl
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

  defp count_ssl(parsed) do
    Enum.reduce(parsed, 0, fn parsed_ip, total ->
      total + if ssl?(parsed_ip), do: 1, else: 0
    end)
  end

  defp ssl?({supernet, hypernet}) do
    abas = to_abas(supernet)
    Enum.any?(hypernet, fn sequence ->
      Enum.any?(abas, fn <<a::utf8, b::utf8, a::utf8>> ->
        String.contains?(sequence, <<b, a, b>>)
      end)
    end)
  end

  defp to_abas(sequences) when is_list(sequences) do
    sequences
    |> Stream.flat_map(&to_abas/1)
    |> Enum.uniq
  end
  defp to_abas(sequence) when is_binary(sequence) do
    to_abas(sequence, [ ])
  end

  defp to_abas(sequence, abas) when byte_size(sequence) < 3,
    do: abas
  defp to_abas(<<a::utf8, b::utf8, a::utf8, sequence::binary>>, abas)
  when a != b,
    do: to_abas(<<b, a>> <> sequence, [<<a, b, a>> | abas])
  defp to_abas(<<_char::utf8, sequence::binary>>, abas),
    do: to_abas(sequence, abas)
end

System.argv
|> hd
|> File.stream!
|> CountSSL.count
|> IO.inspect

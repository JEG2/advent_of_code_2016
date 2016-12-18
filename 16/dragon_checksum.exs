defmodule DragonChecksum do
  def dragon_curve(a) do
    b =
      a
      |> String.reverse
      |> flip("")
    "#{a}0#{b}"
  end

  defp flip("0" <> bits, flipped), do: flip(bits, flipped <> "1")
  defp flip("1" <> bits, flipped), do: flip(bits, flipped <> "0")
  defp flip("", flipped), do: flipped

  def checksum(bits) when rem(byte_size(bits), 2) != 0, do: bits
  def checksum(bits) do
    bits
    |> sum("")
    |> checksum
  end

  defp sum(<<bit::utf8, bit::utf8, bits::binary>>, summed),
    do: sum(bits, summed <> "1")
  defp sum(<<_bit::utf8, _other::utf8, bits::binary>>, summed),
    do: sum(bits, summed <> "0")
  defp sum("", summed), do: summed

  def compute(initial_bits, limit) when byte_size(initial_bits) >= limit,
    do: initial_bits
  def compute(initial_bits, limit) do
    Stream.iterate(initial_bits, &dragon_curve/1)
    |> Stream.drop_while(fn bits -> byte_size(bits) < limit end)
    |> Enum.take(1)
    |> hd
    |> String.slice(0, limit)
    |> checksum
  end
end

unless length(System.argv) == 0 do
  [bits, limit] = System.argv
  DragonChecksum.compute(bits, String.to_integer(limit))
  |> IO.puts
end

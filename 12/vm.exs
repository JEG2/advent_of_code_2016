defmodule VM do
  def run(input) do
    input
    |> parse
    |> execute(0, %{a: 0, b: 0, c: 0, d: 0})
  end

  defp parse(program) do
    Enum.map(program, fn line ->
      [command | args] =
        Regex.run(
          ~r{\A(\w+) (-?\w+)(?: (-?\w+))?\Z},
          line,
          capture: :all_but_first
        )
      {String.to_atom(command), Enum.map(args, &to_value_or_register/1)}
    end)
  end

  defp execute(instructions, index, registers) do
    instruction = Enum.at(instructions, index)
    if instruction do
      {new_index, new_registers} =
        perform_command(instruction, index, registers)
      execute(instructions, new_index, new_registers)
    else
      registers.a
    end
  end

  defp perform_command({:cpy, [x, y]}, index, registers) do
    {index + 1, Map.put(registers, y, to_value(x, registers))}
  end
  defp perform_command({:inc, [x]}, index, registers) do
    {index + 1, Map.update!(registers, x, &(&1 + 1))}
  end
  defp perform_command({:dec, [x]}, index, registers) do
    {index + 1, Map.update!(registers, x, &(&1 - 1))}
  end
  defp perform_command({:jnz, [x, y]}, index, registers) do
    if to_value(x, registers) == 0 do
      {index + 1, registers}
    else
      {index + y, registers}
    end
  end

  # Helpers

  defp to_value_or_register(value_or_register) do
    if String.match?(value_or_register, ~r{\A-?\d+\z}) do
      String.to_integer(value_or_register)
    else
      String.to_atom(value_or_register)
    end
  end

  def to_value(value_or_register, _registers)
  when is_integer(value_or_register),
    do: value_or_register
  def to_value(value_or_register, registers)
  when is_atom(value_or_register),
    do: Map.fetch!(registers, value_or_register)
end

System.argv
|> hd
|> File.stream!
|> VM.run
|> IO.inspect

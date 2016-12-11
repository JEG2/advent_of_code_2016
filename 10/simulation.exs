defmodule Bot do
  use GenServer

  defstruct ~w[number value low high]a

  # Server

  def start_link(number, low, high) do
    GenServer.start_link(
      __MODULE__,
      {number, low, high},
      name: number_to_name(number)
    )
  end

  def load_value(number, value) do
    GenServer.call(number_to_name(number), {:load, value})
  end

  # Client

  def init({number, low, high}) do
    {:ok, %__MODULE__{number: number, low: low, high: high}}
  end

  def handle_call({:load, value}, _from, bot) do
    value =
      if bot.value do
        pass_on_values(bot, value)
        nil
      else
        value
      end
    {:reply, :ok, %__MODULE__{bot | value: value}}
  end

  # Helpers

  def number_to_name(number) do
    String.to_atom("bot_#{number}")
  end

  def pass_on_values(bot, value) do
    [low, high] = Enum.sort([bot.value, value])
    IO.puts("Bot #{bot.number} compared #{low} and #{high}.")
    pass_on_value(low, bot.low)
    pass_on_value(high, bot.high)
  end

  def pass_on_value(value, {:output, bin}) do
    IO.puts("Output #{value} to bin #{bin}.")
  end
  def pass_on_value(value, number) do
    load_value(number, value)
  end
end

defmodule Simulation do
  def simulate(input) do
    input
    |> parse
    |> start_bots([ ])
    |> load_values
  end

  defp parse(input) do
    Enum.map(input, fn line ->
      load = Regex.run(
        ~r{\Avalue (\d+) goes to bot (\d+)\Z},
        line,
        capture: :all_but_first
      )
      if load do
        [value, bot] = Enum.map(load, &String.to_integer/1)
        {:load, bot, value}
      else
        instruction = Regex.run(
          ~r{ \A bot \s (\d+) \s gives \s
              low \s to \s (bot|output) \s (\d+) \s and \s
              high \s to \s (bot|output) \s (\d+) \s \Z }x,
          line,
          capture: :all_but_first
        )
        if instruction do
          [bot, low_name, low_number, high_name, high_number] = instruction
          [bot, low_number, high_number] =
            Enum.map([bot, low_number, high_number], &String.to_integer/1)
          [low_name, high_name] =
            Enum.map([low_name, high_name], &String.to_atom/1)
          {
            :build,
            bot,
            target(low_name, low_number),
            target(high_name, high_number)
          }
        else
          raise "Unrecognized command"
        end
      end
    end)
  end

  defp start_bots([{:build, bot, low, high} | commands], later_commands) do
    Bot.start_link(bot, low, high)
    start_bots(commands, later_commands)
  end
  defp start_bots([later_command | commands], later_commands) do
    start_bots(commands, [later_command | later_commands])
  end
  defp start_bots([ ], later_commands) do
    Enum.reverse(later_commands)
  end

  defp load_values([{:load, bot, value} | commands]) do
    Bot.load_value(bot, value)
    load_values(commands)
  end
  defp load_values([ ]), do: :done

  # Helpers

  defp target(:bot, number) do
    number
  end
  defp target(:output, number) do
    {:output, number}
  end
end

System.argv
|> hd
|> File.stream!
|> Simulation.simulate
|> IO.inspect

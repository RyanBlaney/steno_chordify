defmodule StenoChordify do
  @output "chord_chart.dtsi"

  def main(args) do
    case args do
      [file] ->
        process_file(file)

      _ ->
        IO.puts("Usage: steno_chordify <filename>")
        System.halt(1)
    end
  end

  defp process_file(file) do
    structure_output(@output)

    if File.exists?(file) do
      file
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(&1 == ""))
      |> Enum.each(&process_line/1)
    else
      IO.puts("File not found: #{file}")
      System.halt(1)
    end
  end

  defp process_line(line) do
    Macros.create_macro(line)
    Combos.create_combo(line)
  end

  defp structure_output(file_path) do
    file_path
    |> Path.dirname()
    |> File.mkdir_p!()

    content = """
    #include "keypos.h"

    / {
        steno_macros {

        };

        steno_combos {
          compatible = "zmk,combos";
      
        };
    };
    """

    case File.open(file_path, [:write]) do
      {:ok, file} ->
        IO.write(file, content)
        File.close(file)
        :ok

      {:error, reason} ->
        IO.puts("Failed to open file: #{reason}")
        System.halt(1)
    end
  end
end

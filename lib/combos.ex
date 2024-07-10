defmodule Combos do
  @output "chord_chart.dtsi"

  @char_map %{
    "q" => "P_Q",
    "w" => "P_W",
    "e" => "P_E",
    "r" => "P_R",
    "t" => "P_T",
    "y" => "P_Y",
    "u" => "P_U",
    "i" => "P_I",
    "o" => "P_O",
    "p" => "P_P",
    "a" => "P_A",
    "s" => "P_S",
    "d" => "P_D",
    "f" => "P_F",
    "g" => "P_G",
    "h" => "P_H",
    "j" => "P_J",
    "k" => "P_K",
    "l" => "P_L",
    "z" => "P_Z",
    "x" => "P_X",
    "c" => "P_C",
    "v" => "P_V",
    "b" => "P_B",
    "n" => "P_N",
    "m" => "P_M",
    "'" => "P_SEMI",
    "," => "P_COMMA",
    "." => "P_DOT",
    "/" => "P_SLASH",
    "(" => "P_LH1",
    "[" => "P_LH2",
    "]" => "P_RH1",
    ")" => "P_RH2"
  }

  def create_combo(line) do
    [word, chord] = String.split(line)

    key_positions = generate_key_positions(chord)

    new_combo = """
          c_#{word} {
            timeout-ms = <50>;
            key-positions = <#{key_positions}>;
            bindings = <&m_#{word}>;
            layers = <0>;
          };
    """

    case File.read(@output) do
      {:ok, content} ->
        new_content = append_to_combos(content, new_combo)
        File.write!(@output, new_content)

      {:error, reason} ->
        IO.puts("Failed to read file: #{reason}")
        System.halt(1)
    end
  end

  defp generate_key_positions(chord) do
    chord
    |> String.graphemes()
    |> Enum.map(&fetch_value_pair(&1))
    |> Enum.join(" ")
  end

  defp fetch_value_pair(key) do
    case Map.fetch(@char_map, key) do
      {:ok, value} ->
        value

      :error ->
        IO.puts("Unable to find value for key pair: #{key}\nReplacing with a 'P_DOT'")
        "P_DOT"
    end
  end

  defp append_to_combos(existing_content, new_combo) do
    target = "      compatible = \"zmk,combos\";"

    lines = String.split(existing_content, "\n")

    updated_lines =
      Enum.flat_map(lines, fn line ->
        if String.contains?(line, target) do
          [line, new_combo]
        else
          [line]
        end
      end)

    Enum.join(updated_lines, "\n")
  end
end

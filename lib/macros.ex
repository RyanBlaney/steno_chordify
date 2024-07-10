defmodule Macros do
  @output "chord_chart.dtsi"

  def create_macro(line) do
    [word, _chord] = String.split(line)

    bindings = generate_bindings(word)

    new_macro = """
          m_#{word}: m_#{word} {
            compatible = "zmk,behavior-macro";
            #binding-cells = <0>;
            wait-ms = <0>;
            tap-ms = <10>;
            bindings = #{bindings};
          };
    """

    case File.read(@output) do
      {:ok, content} ->
        new_content = append_to_macros(content, new_macro)
        File.write!(@output, new_content)

      {:error, :enoent} ->
        initial_content = """
        #include "keypos.h"

        / {
            steno_macros {

            };

            steno_combos {

            };
        };
        """

        new_content = append_to_macros(initial_content, new_macro)
        File.write!(@output, new_content)

      {:error, reason} ->
        IO.puts("Failed to read file: #{reason}")
        System.halt(1)
    end
  end

  defp generate_bindings(word) do
    if String.upcase(word) == word do
      # Entire word is uppercase
      bindings =
        word
        |> String.graphemes()
        |> Enum.map(&"&kp #{&1}")
        |> Enum.join(" ")

      "<&macro_press &kp LSHFT>, <&macro_tap #{bindings}>, <&macro_release &kp LSHFT>"
    else
      # Mixed case
      bindings =
        word
        |> String.graphemes()
        |> Enum.map(fn char ->
          if char == String.upcase(char) do
            "&kp LSHFT &kp #{char} &kp LSHFT"
          else
            "&kp #{String.upcase(char)}"
          end
        end)
        |> Enum.join(" ")

      "<&macro_tap #{bindings}>"
    end
  end

  defp append_to_macros(existing_content, new_macro) do
    target = "steno_macros {"
    lines = String.split(existing_content, "\n")

    updated_lines =
      Enum.flat_map(lines, fn line ->
        if String.contains?(line, target) do
          [line, new_macro]
        else
          [line]
        end
      end)

    Enum.join(updated_lines, "\n")
  end
end

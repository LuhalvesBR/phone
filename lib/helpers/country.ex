defmodule Helper.Country do
  defmacro __using__(_) do
    quote do
      import Helper.Country
    end
  end

  defmacro field(name, value) do
    quote do
      def unquote(name)(), do: unquote(value)
    end
  end

  defp regex_matcher do
    quote do
      def match?(number) do
        Regex.match?(@regex, number)
      end

      def builder(number) do
        [[_, code, area, number]] = Regex.scan(regex,number)

        %{
          country: country,
          a2: a2,
          a3: a3,
          international_code: code,
          area_code: area,
          number: number
        }
      end

      def build(number) do
        if match?(number) do
          builder(number)
        else
          {:error, "Not a valid phone number."}
        end
      end
    end
  end

  defp modules_matcher do
    quote do
      def match?(number) do
        modules = Enum.filter(modules, fn(m)-> m.match?(number) end)
        length(modules) > 0
      end

      def build(number) do
        if match?(number) do
          [module] = Enum.filter(modules, fn(m)-> m.match?(number) end)
          module.build(number)
        else
          {:error, "Not a valid phone number."}
        end
      end
    end
  end

  defmacro match(matcher) do
    case matcher do
      :regex -> regex_matcher
      :modules -> modules_matcher
      other ->
        raise ArgumentError, "You can only match against :regex or :modules, passed #{inspect matcher}"
    end
  end
end
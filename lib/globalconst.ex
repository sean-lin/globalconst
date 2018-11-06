defmodule GlobalConst do
  @moduledoc """
  Documentation for GlobalConst.
  """

  @doc """
  ## Examples

      iex> GlobalConst.new(GlobalMap, %{a: 1, b: 2})
      GlobalMap
  """
  def new(module_name, values) do
    compile(module_name, values)
    true = Code.ensure_loaded?(module_name)
    module_name
  end

  def delete(module_name) do
    :code.purge(module_name)
    :code.delete(module_name)
  end

  defp compile(module, values) do
    empty_fun = [
      quote do
        def get(_), do: {:error, :global_const_not_found}
      end,
      quote do
        def get(k, default) do
          case get(k) do
            {:error, :global_const_not_found} -> default
            o -> o
          end
        end
      end
    ]

    functions =
      Enum.reduce(values, empty_fun, fn {k, v}, acc ->
        key =
          case k do
            k when is_atom(k) -> k
            k when is_binary(k) -> String.to_atom(k)
          end

        f =
          quote do
            def get(unquote(key)), do: unquote(Macro.escape(v))
          end

        [f | acc]
      end)

    mod = {:__block__, [], functions}
    Code.compiler_options(ignore_module_conflict: true)

    {:module, ^module, _, _} =
      Module.create(module, mod, file: Atom.to_string(module) <> ".ex", line: 1)
  end
end

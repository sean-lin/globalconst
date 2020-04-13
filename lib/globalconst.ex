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
    new(module_name, values, [key_type: :atom])
  end

  @doc """
  ## Examples
  ## key_type: :any, :atom
      iex> GlobalConst.new(GlobalMap, %{a: 1, b: 2}, [key_type: :any])
      GlobalMap
  """
  def new(module_name, values, opt) do
    if :code.is_loaded(module_name) == false or module_name.cmp(values) == false do
      compile(module_name, values, opt)
    end

    true = Code.ensure_loaded?(module_name)
    module_name
  end

  def delete(module_name) do
    :code.purge(module_name)
    :code.delete(module_name)
  end

  def cmp(module_name, other) do
    this =
      module_name.keys()
      |> Enum.map(fn k -> {k, module_name.get(k)} end)
      |> :maps.from_list()

    other =
      other
      |> Enum.map(fn {k, v} -> {to_atom(k), v} end)
      |> :maps.from_list()

    this == other
  end

  defp compile(module, values, opt) do
    key_type = Keyword.get(opt, :key_type, :atom)
    keys = case key_type do
      :atom -> Enum.map(values, fn {k, _v} -> to_atom(k) end)
      :any -> Enum.map(values, fn {k, _v} -> k end)
    end

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
      end,
      quote do
        def keys(), do: unquote(Macro.escape(keys))
      end,
      quote do
        def cmp(other) do
          GlobalConst.cmp(unquote(module), other)
        end
      end
    ]

    functions =
      Enum.reduce(values, empty_fun, fn {k, v}, acc ->
        key = case key_type do
          :atom -> to_atom(k)
          :any -> k
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

  defp to_atom(k) when is_atom(k) do
    k
  end

  defp to_atom(k) when is_binary(k) do
    String.to_atom(k)
  end
end

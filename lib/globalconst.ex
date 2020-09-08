defmodule GlobalConst do
  @moduledoc """
  Documentation for GlobalConst.
  """
  
  @default_opt [key_type: :atom]

  @doc """
  ## Examples

      iex> GlobalConst.new(GlobalMap, %{a: 1, b: 2})
      GlobalMap
  """
  def new(module_name, values) do
    if :code.is_loaded(module_name) == false or module_name.cmp(values) == false do
      compile(module_name, values, @default_opt)
    end

    true = Code.ensure_loaded?(module_name)
    module_name
  end

  @doc """
  ## Examples
  ## key_type: :any, :atom
      iex> GlobalConst.new(GlobalMap, %{a: 1, b: 2}, [key_type: :any])
      GlobalMap
  """
  def new(module_name, values, opt) do
    if :code.is_loaded(module_name) == false or module_name.cmp(values, opt) == false do
      compile(module_name, values, opt)
    end

    true = Code.ensure_loaded?(module_name)
    module_name
  end

  def delete(module_name) do
    :code.purge(module_name)
    :code.delete(module_name)
  end

  def cmp(module_name, other, opt) do
    this =
      module_name.keys()
      |> Enum.map(fn k -> {k, module_name.get(k)} end)
      |> :maps.from_list()

    key_type = Keyword.get(opt, :key_type, :atom)
    other =
      other
      |> Enum.map(fn {k, v} -> {get_key(k, key_type), v} end)
      |> :maps.from_list()

    this == other
  end

  defp compile(module, values, opt) do
    key_type = Keyword.get(opt, :key_type, :atom)
    keys = Enum.map(values, fn {k, _v} -> get_key(k, key_type) end)

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
          cmp(other,  @default_opt)
        end
      end,
      quote do
        def cmp(other, opt) do
          GlobalConst.cmp(unquote(module), other, opt)
        end
      end,
      quote do
        defp opt(), do: unquote(Macro.escape(opt))
      end,
    ]

    functions =
      Enum.reduce(values, empty_fun, fn {k, v}, acc ->
        key = get_key(k, key_type)

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

  defp get_key(key, :any) do
    key
  end
  defp get_key(k, :atom) do
    to_atom(k)
  end

  defp to_atom(k) when is_atom(k) do
    k
  end

  defp to_atom(k) when is_binary(k) do
    String.to_atom(k)
  end
end

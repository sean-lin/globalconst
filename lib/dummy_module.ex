defmodule GlobalConst.DummyModule do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      def get(_), do: {:error, :global_const_not_found}
      def get(_, what), do: what

      def cmp(_), do: false
      def cmp(_, _), do: false
      def keys(), do: []

      defoverridable get: 1, get: 2, cmp: 1, cmp: 2, keys: 0
    end
  end
end

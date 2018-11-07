defmodule GlobalConstTest do
  use ExUnit.Case
  doctest GlobalConst

  test "get module" do
    GlobalConst.new(TestDict, %{a: 1})
    assert 1 == TestDict.get(:a)
    assert {:error, :global_const_not_found} == TestDict.get(:b)
    assert 2 = TestDict.get(:b, 2)
  end

  test "thousands keys" do
    entities =
      0..1000
      |> Enum.map(fn i -> {String.to_atom("key" <> to_string(i)), i} end)
      |> :maps.from_list()

    GlobalConst.new(TD, entities)

    Enum.each(entities, fn {k, v} ->
      assert TD.get(k) == v
    end)
  end

  test "reload" do
    GlobalConst.new(UpdatedDict, %{a: 1})
    assert 1 == UpdatedDict.get(:a)
    GlobalConst.new(UpdatedDict, %{a: 2})
    assert 2 == UpdatedDict.get(:a)
  end

  test "delete" do
    GlobalConst.new(DelDict, %{a: 1})
    assert {:file, _} = :code.is_loaded(DelDict)
    assert 1 == DelDict.get(:a)
    GlobalConst.delete(DelDict)
    assert false == :code.is_loaded(DelDict)
  end

  test "keys and cmp" do
    data = %{a: 1, b: 1, c: 2}
    mod = GlobalConst.new(DataMap, data)
    assert Enum.sort(Map.keys(data)) == Enum.sort(mod.keys())
    assert mod.cmp(data) == true
    assert mod.cmp(%{a: 1, c: 2, b: 1, d: 4}) == false
  end
end

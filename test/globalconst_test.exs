defmodule DummyModule do
  use GlobalConst.DummyModule
end

defmodule GlobalConstTest do
  use ExUnit.Case
  doctest GlobalConst

  test "get module atom" do
    GlobalConst.new(TestDict, %{:a => 1, "b" => 2})
    assert 1 == TestDict.get(:a)
    assert 2 == TestDict.get(:b)
    assert {:error, :global_const_not_found} == TestDict.get(:c)
    assert 3 = TestDict.get(:c, 3)
  end

  test "get module any" do
    GlobalConst.new(TestDict, %{:a => 1, "b" => 2, 3 => 3, [:c] => 4}, [key_type: :any])
    assert 1 == TestDict.get(:a)
    assert 2 == TestDict.get("b")
    assert 3 == TestDict.get(3)
    assert 4 == TestDict.get([:c])
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

    data = %{:a =>  1, "b"=> 1}
    mod = GlobalConst.new(DataMap, data)
    assert Enum.sort(Map.keys(data)) != Enum.sort(mod.keys())
    assert mod.cmp(data) == true
    assert mod.cmp(data, [key_type: :any]) == false
  end

  test "keys and cmp with opt" do
    data = %{:a =>  1, "b"=> 1}
    mod = GlobalConst.new(DataMap, data, [key_type: :any])
    assert Enum.sort(Map.keys(data)) == Enum.sort(mod.keys())
    assert mod.cmp(data) == false
    assert mod.cmp(data, [key_type: :any]) == true
    assert mod.cmp(%{a: 1, c: 2, b: 1, d: 4}) == false
  end

  test "is recompile" do
    data = %{:a =>  1, "b"=> 1}
    GlobalConst.new(DataMap, data, [key_type: :any])
    m1 = DataMap.module_info() |> Keyword.get(:md5)

    GlobalConst.new(DataMap, data, [key_type: :any])
    assert m1 == DataMap.module_info() |> Keyword.get(:md5)

    GlobalConst.new(DataMap, data)
    assert m1 != DataMap.module_info() |> Keyword.get(:md5)
  end

  test "dummy module" do
    data = %{a: 1, b: 1, c: 2}

    assert {:error, :global_const_not_found} = DummyModule.get(:a)
    assert :test = DummyModule.get(:a, :test)
    assert [] = DummyModule.keys()
    assert false == DummyModule.cmp(data)
    assert false == DummyModule.cmp(data, [key_type: :any])

    GlobalConst.new(DummyModule, data)
    assert 1 == DummyModule.get(:a)
  end
end

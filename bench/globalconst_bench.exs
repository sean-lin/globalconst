defmodule GlobalConstBench do
  use Benchfella

  bench "globalconst get atom", module: gen_globalconst(TestConst, :atom) do
    module.get(:data)
    :ok
  end

  bench "globalconst get string", module: gen_globalconst(TestConst, :any) do
    module.get("data")
    :ok
  end

  bench "globalconst get(10000keys) atom", module: gen_globalconst(TestConst, 10000, :atom) do
    module.get(:key9999)
    :ok
  end

  bench "globalconst get(10000keys) string", module: gen_globalconst(TestConst, 10000, :any) do
    module.get("key9999")
    :ok
  end

  bench "fastglobal get", fastglobal: gen_fastglobal() do
    FastGlobal.get(fastglobal)
    :ok
  end

  bench "agent get", agent: gen_agent() do
    Agent.get(agent, & &1)
    :ok
  end

  bench "ets get atom", ets: gen_ets(:atom) do
    :ets.lookup(ets, :data)
    :ok
  end

  bench "ets get string", ets: gen_ets(:any) do
    :ets.lookup(ets, "data")
    :ok
  end

  ## Private

  defp gen_fastglobal() do
    FastGlobal.put(:fg_data, gen_services(50))
    :fg_data
  end

  defp gen_agent() do
    {:ok, agent} = Agent.start_link(fn -> gen_services(50) end)
    agent
  end

  defp gen_ets(type) do
    if :ets.whereis(:ets_data) != :undefined do
      :ets.delete(:ets_data)
    end
    tab = :ets.new(:ets_data, [:public, {:read_concurrency, true}])
    key = gen_key("data", type)
    :ets.insert(tab, {key, gen_services(50)})
    tab
  end

  defp gen_globalconst(module, type) do
    key = gen_key("data", type)
    GlobalConst.new(module, %{key => gen_services(50)})
  end

  defp gen_globalconst(module, count, type) do
    entities =
      0..count
      |> Enum.map(fn i ->
        key = gen_key("key" <> to_string(i), type)
        {key, i}
      end)
      |> :maps.from_list()

    GlobalConst.new(module, entities)
  end

  defp gen_key(key, :atom) do
    String.to_atom(key)
  end
  defp gen_key(key, :any) do
    key
  end

  defp gen_services(n) do
    for i <- 0..n, into: Map.new() do
      service = new_service(i)
      {service.id, service}
    end
  end

  defp new_service(i) do
    port = 3000 + i

    %{
      __struct__: FastGlobal.Service,
      address: "fast-global-prd-1-#{i}",
      id: "fast-global-prd-1-#{i}:#{port}",
      metadata: %{
        "otp" => "fastglobal@fastglobal-prd-1-#{i}",
        "capacity" => "low"
      },
      name: "fastglobal",
      port: port
    }
  end
end

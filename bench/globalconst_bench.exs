defmodule GlobalConstBench do
  use Benchfella

  bench "globalconst get", module: gen_globalconst(TestConst) do
    module.get(:data)
    :ok
  end

  bench "globalconst get(10000keys)", module: gen_globalconst(TestConst, 10000) do
    module.get(:key9999)
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

  bench "ets get", ets: gen_ets() do
    :ets.lookup(ets, :data)
    :ok
  end

  ## Private

  defp gen_fastglobal() do
    FastGlobal.put(:data, gen_services(50))
    :data
  end

  defp gen_agent() do
    {:ok, agent} = Agent.start_link(fn -> gen_services(50) end)
    agent
  end

  defp gen_ets() do
    tab = :ets.new(:data, [:public, {:read_concurrency, true}])
    :ets.insert(tab, {:data, gen_services(50)})
    tab
  end

  defp gen_globalconst(module) do
    GlobalConst.new(module, %{data: gen_services(50)})
  end

  defp gen_globalconst(module, count) do
    entities =
      0..count
      |> Enum.map(fn i -> {String.to_atom("key" <> to_string(i)), i} end)
      |> :maps.from_list()

    GlobalConst.new(module, entities)
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

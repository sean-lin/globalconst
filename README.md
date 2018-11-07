# GlobalConst

[![Hex.pm Version](https://img.shields.io/hexpm/v/globalconst.svg?style=flat)](https://hex.pm/packages/globalconst)

GlobalConst converts large Key-Value entities to a module to make fast accessing by thousands of processes.

## Thanks

This library inspired by [FastGlobal](https://github.com/discordapp/fastglobal) and [mochiglobal](https://github.com/mochi/mochiweb/blob/master/src/mochiglobal.erl). 
In our case, we has thousands of entities to save, and don't want to make so many modules. 
So converting entities to a named module is a good approach. 

## Performance

```
benchmark name              iterations   average time
globalconst get              100000000   0.03 µs/op
globalconst get(10000keys)   100000000   0.06 µs/op
fastglobal get                10000000   0.29 µs/op
ets get                         500000   7.93 µs/op
agent get                       100000   14.95 µs/op
```

## Installation

Add it to `mix.exs`

```elixir
def deps do
  [
    {:globalconst, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/globalconst/](https://hexdocs.pm/globalconst/).

## Usage

Create a new global const map and get the value

```elixir
GlobalConst.new(GlobalMap, %{a: 1, b: 2})
1 == GlobalMap.get(:a)
2 == GlobalMap.get(:b)
[:a, :b] == GlobalMap.keys()
{:error, :global_const_not_found} = GlobalMap.get(:c)
:default_value = GlobalMap.get(:c, :default_value)
```

## License

GlobalConst is released under [the MIT License](LICENSE).
Check [LICENSE](LICENSE) file for more information.

# GlobalConst

GlobalConst converts large Key-Value entities to a module to make fast accessing by thousands of processes.

## Thanks

This library inspired by [FastGlobal](https://github.com/discordapp/fastglobal) and [mochiglobal](https://github.com/mochi/mochiweb/blob/master/src/mochiglobal.erl). 
In our case, we has thousands of entities to save, and don't want to make so many modules. 
So Converting entities to a named module is a good approach. 

## Performance


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `globalconst` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:globalconst, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/globalconst](https://hexdocs.pm/globalconst).

## Usage

Create a new global const map and get the value
```
GlobalConst.new(GlobalMap, %{a: 1, b: 2})
1 == GlobalMap.get(:a)
2 == GlobalMap.get(:b)
{:error, :global_const_not_found} = GlobalMap.get(:c)
:default_value = GlobalMap.get(:c, :default_value)
```

## License

GlobalConst is released under [the MIT License](LICENSE).
Check [LICENSE](LICENSE) file for more information.
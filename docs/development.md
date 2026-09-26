# Development

How lua-objects is put together and tested, and what could change.

## Where the Code Lives

Only `dmc_lua/lua_objects.lua` is written in this repository. The other two files in `dmc_lua/` are copies, kept so the tests and the Quick Start work from a plain clone. Fix them in their own repository, then copy them here by hand:

| file | owner |
|---|---|
| `lua_class.lua` (`newClass()`, `superCall()`, getters and setters) | [lua-class](https://github.com/dmccuskey/lua-class) |
| `lua_events_mix.lua` (events) | [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin) |

[DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies `lua_objects.lua`, and the two modules it requires from their own repositories, into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module and its requirements). Every DMC Solar2D library copies them from there into `dmc_corona/lib/dmc_lua/`.

## Testing

The tests are in `spec/lua_objects_spec.lua` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
++++++++++++++++++++++++++
26 successes / 0 failures / 0 errors / 0 pending : 0.00689 seconds
```

The file is lua-class's spec, run through `lua_objects`: it tests the class model, not `ObjectBase`, its hooks or its events.

## Possible Future Changes

Each needs discussion and a concrete use case before it is worked on.

- Tests for `ObjectBase`: the order of the hooks, events, and `removeSelf()`.
- Export lua-objects' own version (`VERSION` in `lua_objects.lua` is `1.3.0`).

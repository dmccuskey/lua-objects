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

The tests are in `spec/` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
++++++++++++++++++++++++++++++++++++++++
40 successes / 0 failures / 0 errors / 0 pending : 0.008573 seconds
```

`object_base_spec.lua` tests `ObjectBase`: the module's exports, the order of the hooks, errors from an `__init__()` that skips `superCall()`, and events. `lua_objects_spec.lua` is lua-class's spec, run through `lua_objects`: it tests the class model. `no_global_spec.lua` loads the module with lua-class's global `newClass` turned off.

## Possible Future Changes

None planned.

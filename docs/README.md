# lua-objects Documentation

New here? The [Quick Start](../README.md#quick-start) writes a class that sends events and removes an instance of it in about 5 minutes.

## Start

- [Quick Start](../README.md#quick-start): get the code, write a class that sends events, remove an instance

## Use

- [API reference](api.md): the module, `ObjectBase`, setup and teardown, events, known issues
- [lua-class API](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md): the class model: `newClass()`, class members, getters and setters, `superCall()`, multiple inheritance
- [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin): the events on their own, for objects that aren't lua-class classes
- [dmc-objects](https://github.com/dmccuskey/dmc-objects): classes for Solar2D display objects, built on this one

## Contribute

- [Development](development.md): which files are copies, tests, possible future changes
- [Issues](https://github.com/dmccuskey/lua-objects/issues)

## Project Structure

```text
README.md                   landing page and Quick Start
LICENSE
docs/                       this documentation
dmc_lua/
├── lua_objects.lua         the module: ObjectBase
├── lua_class.lua           from lua-class (copy)
└── lua_events_mix.lua      from lua-events-mixin (copy)
Snakefile                   build rules, for DMC-Lua-Library
spec/
└── lua_objects_spec.lua    tests (busted)
```

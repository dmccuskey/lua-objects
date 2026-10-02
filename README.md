# lua-objects

A base class for Lua 5.1 objects: events, and a set order for setting an object up and tearing it down.

`ObjectBase` is built with [lua-class](https://github.com/dmccuskey/lua-class) and the events mixin from [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin). [dmc-objects](https://github.com/dmccuskey/dmc-objects) builds its Solar2D (formerly Corona SDK) display classes on it, and it works the same in plain Lua:

```lua
local Objects = require 'lua_objects'

local Account = Objects.newClass( Objects.ObjectBase, { name="Account" } )

function Account:deposit( amount )
	self:dispatchEvent( 'deposit', { amount=amount } )
end

local account = Account:new()
account:addEventListener( account.EVENT, function( event )
	print( event.type, event.data.amount )  --> deposit  25
end )
account:deposit( 25 )
```

## Features

- Everything in [lua-class](https://github.com/dmccuskey/lua-class): `newClass()`, multiple inheritance and mixins, getters and setters, `superCall()`, `isa()`
- `addEventListener()`, `removeEventListener()` and `dispatchEvent()`, with a function or an object as the listener
- Setup hooks, `__init__()` and `__initComplete__()`, and teardown hooks that undo them in reverse
- `removeSelf()` and `destroy()` run the teardown, as on a Solar2D display object
- `createCallback()` turns a method into a function for timers and other callbacks
- Pure Lua, no dependencies beyond the two modules it's built on (copies included); MIT licensed

## Quick Start

The following code will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. It writes a class that sends events, creates an instance and removes it.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-objects.git
```

`lua-objects/dmc_lua/` holds the module, `lua_objects.lua`, and copies of the two it needs, `lua_class.lua` and `lua_events_mix.lua`.

### 2. Write a Class That Sends Events

Create `main.lua` in the same folder:

```lua
package.path = './lua-objects/dmc_lua/?.lua;' .. package.path
local Objects = require 'lua_objects'

local Account = Objects.newClass( Objects.ObjectBase, { name="Account" } )

Account.EVENT = 'account_event'
Account.BALANCE_CHANGED = 'balance_changed'

function Account:__init__( params )
	params = params or {}
	self:superCall( '__init__', params )
	--==--
	self._balance = params.balance or 0
end

function Account:__undoInit__()
	self._balance = nil
	--==--
	self:superCall( '__undoInit__' )
end

function Account:deposit( amount )
	self._balance = self._balance + amount
	self:dispatchEvent( self.BALANCE_CHANGED, { balance=self._balance } )
end

local account = Account:new{ balance=100 }

account:addEventListener( account.EVENT, function( event )
	print( event.type, event.data.balance, event.target:isa( Account ) )
end )

account:deposit( 25 )
```

Run it:

```sh
lua main.lua
```

```text
balance_changed	125	true
```

If it shows `module 'lua_objects' not found`, run it from the folder that holds `lua-objects/`.

`__init__()` sets the object up and `__undoInit__()` undoes it. Each calls `ObjectBase`'s version with `superCall()`, first when setting up and last when undoing: `ObjectBase:__init__()` is what makes the events work.

**Going further:** event names and types, and listener objects ([Events](docs/api.md#events)).

### 3. Remove It

Add this to the end of `main.lua`:

```lua
function Account:__initComplete__()
	self:superCall( '__initComplete__' )
	--==--
	print( 'ready', self._balance )
end

function Account:__undoInitComplete__()
	print( 'closing', self._balance )
	--==--
	self:superCall( '__undoInitComplete__' )
end

local savings = Account:new{ balance=200 }
savings:removeSelf()
```

`lua main.lua` now also shows:

```text
ready	200
closing	200
```

`__initComplete__()` runs after `__init__()`, when the object is fully set up. `removeSelf()` runs the undo hooks in the reverse order: `__undoInitComplete__()`, then `__undoInit__()`.

**Going further:** what each hook is for ([Setup and Teardown](docs/api.md#setup-and-teardown)), and the rest of the class model ([lua-class API](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md)).

To update, pull the repository again (`git -C lua-objects pull`), or replace the three files in `dmc_lua/` with the newer ones.

## Documentation

- [API reference](docs/api.md): the module, `ObjectBase`, setup and teardown, events, known issues
- [lua-class API](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md): `newClass()`, class members, getters and setters, `superCall()`, multiple inheritance
- [dmc-objects](https://github.com/dmccuskey/dmc-objects): classes for Solar2D display objects, built on this one

Everything else is listed on the [documentation home](docs/README.md).

## License

lua-objects is released under the [MIT License](LICENSE).

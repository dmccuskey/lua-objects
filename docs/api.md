# API Reference

Everything lua-objects adds to [lua-class](https://github.com/dmccuskey/lua-class), as of version 1.4.0. For `newClass()`, the class members (`new()`, `superCall()`, `isa()`, ...), getters and setters, and multiple inheritance, see the [lua-class API reference](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md).

| name | what it is |
|---|---|
| [The module](#the-module) | what `require 'lua_objects'` returns |
| [`ObjectBase`](#objectbase) | the base class |
| [Setup and teardown](#setup-and-teardown) | the hooks and the order they run in |
| [Events](#events) | listeners and dispatching |
| [Known issues](#known-issues) | what doesn't work as you'd expect |

## The Module

```lua
local Objects = require 'lua_objects'
```

`lua_objects.lua` loads `lua_class` and `lua_events_mix` by those names, so the folder that holds all three has to be on `package.path` (the [Quick Start](../README.md#2-write-a-class-that-sends-events) shows how). In [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) and the Solar2D libraries they are in `lib/dmc_lua/`.

It returns a table holding lua-class's module fields, with two of its own:

| field | |
|---|---|
| `Objects.ObjectBase` | [`ObjectBase`](#objectbase) |
| `Objects.__version` | lua-objects' version, `1.4.0` |
| `Objects.newClass`, `Objects.Class`, `Objects.registerCtorName`, ... | from lua-class ([The Module](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md#the-module)) |

Loading it also:

- sets the global `newClass`, as lua-class does;
- adds `removeSelf()` as another name for `destroy()` on the root class, so every class has it, whether or not it inherits from `ObjectBase`.

## ObjectBase

```lua
local Account = Objects.newClass( Objects.ObjectBase, { name="Account" } )
```

`ObjectBase` inherits from lua-class's root class and from the events mixin, in that order. Its `NAME` is `Object Base`. It adds:

- the [setup and teardown hooks](#setup-and-teardown), which replace `__new__()` and `__destroy__()` in your classes;
- the [events methods](#events).

## Setup and Teardown

`ObjectBase` has its own `__new__()` and `__destroy__()`, which call the hooks below in a set order. Override the hooks, not `__new__()` or `__destroy__()`.

| `Account:new( params )` runs | `account:removeSelf()` or `account:destroy()` runs |
|---|---|
| 1. `__init__( params )` | 1. `__undoInitComplete__()` |
| 2. `__initComplete__()` | 2. `__undoInit__()` |

| hook | use it to |
|---|---|
| `__init__( ... )` | set the object's properties from the arguments given to `new()` |
| `__initComplete__()` | start what needs the object fully set up: listeners, timers |
| `__undoInitComplete__()` | stop what `__initComplete__()` started |
| `__undoInit__()` | clear what `__init__()` set |

In each hook, call the parent's version with `superCall()`: first thing in the two setup hooks, last thing in the two undo hooks, so parents are set up before their subclasses and torn down after them.

```lua
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
```

`ObjectBase:__init__()` gives the object its own list of listeners, and `ObjectBase:__undoInit__()` removes it. If a class's `__init__()` doesn't call it, `new()` raises an error: `ObjectBase: Account's __init__() must call self:superCall( '__init__', ... )`.

Creating a class runs `__init__()` too, on the class, without arguments (lua-class runs each parent's constructor on a new class, see [newClass](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md#newclass)). So `__init__()` has to accept no arguments (`params = params or {}`). On a class, `ObjectBase:__init__()` does nothing: a class has no list of listeners, so it can't send or receive events. The `__initComplete__()` hooks run only for instances.

`removeSelf()` doesn't empty the object. After it, fields that `__undoInit__()` cleared read the class's values, if the class has them. Its events are gone: adding a listener or sending an event raises an error.

## Events

```lua
account:addEventListener( account.EVENT, function( event )
	print( event.name, event.type, event.data.balance )
end )

account:dispatchEvent( 'balance_changed', { balance=125 } )
--> account_event  balance_changed  125
```

An object sends every event under one name, its class's `EVENT`, and tells them apart by `type`. Give your class its own `EVENT`, and a constant for each type:

```lua
Account.EVENT = 'account_event'
Account.BALANCE_CHANGED = 'balance_changed'
```

| member | |
|---|---|
| `obj:addEventListener( name, listener )` | `listener` is a function, called with the event, or a table with a method named `name`, called as `listener:name( event )`. Adding the same listener twice prints a warning and keeps one. |
| `obj:removeEventListener( name, listener )` | removes it; a listener that isn't there prints a warning |
| `obj:dispatchEvent( type, data, params )` | sends `{ name=obj.EVENT, type=type, data=data, target=obj }`. With `params.merge = true` and a table `data`, the fields of `data` go into the event itself instead (`event.balance`, not `event.data.balance`). |
| `obj:dispatchRawEvent( event )` | sends `event` unchanged, to the listeners of `event.name`; it needs a `name` |
| `obj:createEvent( type, data, params )` | returns the event `dispatchEvent()` would send, without sending it |
| `obj:createCallback( method )` | returns a function that calls `method( obj, ... )`, for timers and other callbacks: `self:createCallback( self._tick )` |
| `obj:setEventFunc( func )` | replaces the function that builds events for `dispatchEvent()`. It is called as `func( obj, ... )` with `dispatchEvent()`'s arguments and returns the event. |
| `obj.EVENT` | the event name used by `dispatchEvent()`; default `event_mix_event` |

Listeners are called in no particular order, and the dispatch is synchronous: `dispatchEvent()` returns after every listener has run. A listener added during a dispatch is called from the next one; one removed during a dispatch, before its turn, isn't called. `obj:setDebug( true )` prints each event dispatched.

The events mixin can also be used on its own, without lua-class; see [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin).

## Known Issues

None of its own. Version 1.4.0 fixed those of 1.3.0: each class had a list of listeners, which an instance without its own (its `__init__()` skipped `superCall()`, or it was removed) shared with other instances; `removeEventListener()` raised an error when nothing listened to the name (fixed in [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin) 0.3.0); `Objects.__version` was lua-class's.

The known issues of the class model are listed in [lua-class](https://github.com/dmccuskey/lua-class/blob/master/docs/api.md#known-issues).

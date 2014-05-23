# DMC Lua Library #

A collection of Lua modules.

These are modules from my DMC Corona Library. I wanted to start using these modules in a server environment, so I am pulling out the non-Corona stuff. I will later re-integrate into the Corona Library, using subclassing, etc.

Some of the modules also require [Corovel](https://github.com/dmccuskey/lua-corovel) installed as well. The modules are noted below.



## Current Modules ##

* [lua_objects](#lua_objects)

  Advanced OOP for Lua. [Read more...](#lua_objects)

* [lua_sockets](#lua_sockets)

  Buffered, non-blocking, callback- or event-based socket library for clients. *Requires Corovel* [Read more...](#lua_sockets)

* [lua_utils](#lua_utils)

  Miscellaneious utility functions. [Read more...](#lua_utils)



## Coming Soon ##

* [lua_states](#lua_states)

  Implement the State Machine design pattern with your objects. [Read more...](#lua_states)

* [lua_wamp](#lua_wamp)

  WAMP (http://wamp.ws) module for the Corona SDK. *Requires Corovel* [Read more...](#lua_wamp)

* [lua_websockets](#lua_websockets)

  WebSocket module for the Corona SDK. *Requires Corovel* [Read more...](#lua_websockets)



<a name="lua_objects"></a>
### Module: lua_objects ###

This file contains several methods and object classes which together form an object-oriented framework to use when programming in Lua.



<a name="lua_sockets"></a>
### Module: lua_sockets ###

`lua_sockets` is a buffered, callback- or event-based socket library for clients which has two-flavors of sockets - asyncronous with callbacks or syncronous with events (non-blocking). In reality it's just a thin layer over the built-in socket library *LuaSockets*, but gives several additional benefits for your networking pleasure.

Requires: Corovel



<a name="lua_utils"></a>
### Module: lua_utils ###

This module is an ever-changing list of helpful utility functions. Ever-changing because, over time, some functions have been removed and put into their own modules, eg `lua_performance`. Here are some of the groupings at the moment:

* Callback Functions - createObjectCallback(), getTransitionCompleteFunc()
* Date Functions - calcTimeBreakdown()
* Image Functions - imageScale()
* String Functions - split(), stringFormatting()
* Table Functions - destroy(), extend(), hasOwnProperty(), print(), propertyIn(), removeFromTable(), shuffle(), tableSize(), tableSlice(), tableLength()
copy one table into another ( similar to jQuery extend() )
* Web Functions - parse_query(), create_query()

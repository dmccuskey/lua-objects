# DMC Lua Library #

A collection of Lua modules.

These are pure Lua modules pulled out of my DMC Corona Library. I wanted to start using these in a server environment. They will later be re-integrate into the Corona Library, using subclassing, etc.



## Current Modules ##

* [lua_e4x](#lua_e4x)

  Pure Lua E4X XML parser. [Read more...](#lua_e4x)

* [lua_errors](#lua_errors)

  Better error handling for Lua. [Read more...](#lua_errors)

* [lua_files](#lua_files)

  File tasks, handling json, config files. [Read more...](#lua_files)

* [lua_objects](#lua_objects)

  Advanced OOP for Lua. [Read more...](#lua_objects)

* [lua_patch](#lua_patch)

  Patch Lua with Python-cool. [Read more...](#lua_patch)

* [lua_promise](#lua_promise)

  Deferreds and Promises for Lua. [Read more...](#lua_promise)

* [lua_states](#lua_states)

  A mixin module which adds State Machine functionality to your objects. [Read more...](#lua_states)

* [lua_utils](#lua_utils)

  Miscellaneous utility functions. [Read more...](#lua_utils)



<a name="lua_e4x"></a>
### Module: lua_e4x ###

An implementation of E4X for Lua.

Documentation and Examples

http://docs.davidmccuskey.com/display/docs/lua_e4x.lua

There are a lot of examples in the unit test for `lua_e4x.lua`. Look in `spec/lua_e4x_spec.lua`.



<a name="lua_objects"></a>
### Module: lua_objects ###

This file contains several methods and object classes which together form an object-oriented framework to use when programming in Lua.



<a name="lua_patch"></a>
### Module: lua_patch ###

`lua_patch` patches Lua with extra functionality, currently this is:

* Python-style string formatting
* Python-style table pop function



<a name="lua_states"></a>
### Module: lua_states ###

`lua_states` mixin adds functionality to Lua objects so they can implement the State Machine design pattern.



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

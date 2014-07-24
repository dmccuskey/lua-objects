# DMC Lua Library #

A collection of Lua modules.

These are pure Lua modules extracted from my [DMC Corona Library](https://github.com/dmccuskey/DMC-Corona-Library). I did this because I wanted to start using them in a server environment. They have been re-integrated back into the Corona Library, using subclassing, etc.

*Tests*

The available unit tests are written using [Busted](https://github.com/Olivine-Labs/busted). Install using luarocks:

`> luarocks install busted`

Run at the command line:

`> busted`


## Current Modules ##

* [json](#json)

  A shim to load Lua `json` modules. [Read more...](#json)

* [lua_bytearray](#lua_bytearray)

  A Lua byte array module. [Read more...](#lua_bytearray)

* [lua_e4x](#lua_e4x)

  Pure Lua E4X XML parser. [Read more...](#lua_e4x)

* [lua_error](#lua_error)

  Better error handling for Lua. [Read more...](#lua_error)

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



<a name="json"></a>
### Module: json ###

This file is used to load any of the various Lua `json` modules, but standardize the name to `json`. Currently it searches for one of `dkjson`, `cjson` or `json`.

Of course you will need to install one of the above for it to work. You can also edit the file to add your favorite json module.

```
> luarocks install dkjson
> luarocks install lua-cjson
```



<a name="lua_bytearray"></a>
### Module: lua_bytearray ###

Currently this library contains two byte array modules – `lua_bytearray` and `bytearray`. The former is from another dev and contains methods for un/packing bytes into shorts, longs, etc. The latter currently only supports string-base read/writes. I currently use both in my projects, though I plan on joining the two.

If you want to use `lua_bytearray` then you need to install `lpack`:

`> luarocks install lpack`


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_bytearray.lua


**Examples**

There are a lot of examples in the unit test file, `spec/lua_bytearray_spec.lua`.



<a name="lua_e4x"></a>
### Module: lua_e4x ###

`lua_e4x` is an implementation of E4X for sane XML navigation in Lua.


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_e4x.lua


**Examples**

There are a lot of examples in the unit test file, `spec/lua_e4x_spec.lua`.

There is also a micro example on the documentation website.



<a name="lua_error"></a>
### Module: lua_error ###

`lua_error` contains an Error base class and several *global* methods (`try()`, `catch()` and `finally()`) used to create a decent error-handling framework similar to that of Python.

As seen in the example below, you can check for regular string-based errors or a custom error class.

```lua
try{
	function()
		self:unregister( handler, params )
	end,

	catch{
		function(e)
			if type(e)=='string' then
				error( e )
			elseif e:isa( Error.ProtocolError ) then
				self:_bailout(){
					code=WebSocket.CLOSE_STATUS_CODE_PROTOCOL_ERROR,
					reason="WAMP Protocol Error"
				}
			else
				self:_bailout{
					code=WebSocket.CLOSE_STATUS_CODE_INTERNAL_ERROR,
					reason="WAMP Internal Error"
				}
			end
		end
	},

	finally{
		self:close()
	}
}
```


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_error.lua


**Examples**

None yet



<a name="lua_files"></a>
### Module: lua_files ###

`lua_files` contains methods for reading and writing raw data, json, and configuration files.


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_files.lua


**Examples**

There are a lot of examples in the unit test file, `spec/lua_files_spec.lua`.



<a name="lua_objects"></a>
### Module: lua_objects ###

`lua_objects` contains several methods and object classes which together form an object-oriented framework to use when programming in Lua.

Some advanced features:
* getters/setters
* event dispatch/listeners
* structured object setup/teardown


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_objects.lua


**Examples**

There are a lot of examples in this library's modules and the `dmc-corona-library`.



<a name="lua_patch"></a>
### Module: lua_patch ###

`lua_patch` patches Lua with extra functionality, currently this is:

* Python-style string formatting
* Python-style table pop function


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_patch.lua


**Examples**

None yet



<a name="lua_promise"></a>
### Module: lua_promise ###

`lua_promise` contains classes and methods to create and use Promises and Deferreds. This is somewhat of a port from Python Twisted.


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_promise.lua


**Examples**

None yet



<a name="lua_states"></a>
### Module: lua_states ###

`lua_states` mixin adds functionality to Lua objects so they can implement the State Machine design pattern.


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_states.lua


**Examples**

There are a lot of examples in the unit test file, `spec/lua_states_spec.lua`.



<a name="lua_utils"></a>
### Module: lua_utils ###

This module is an ever-changing list of helpful utility functions. Ever-changing because, over time, some functions have been removed and put into their own modules, eg `lua_performance`. Here are some of the groupings at the moment:

* Callback Functions - createObjectCallback(), getTransitionCompleteFunc()
* Date Functions - calcTimeBreakdown()
* Image Functions - imageScale()
* String Functions - split(), stringFormatting()
* Table Functions - destroy(), extend(), hasOwnProperty(), print(), propertyIn(), removeFromTable(), shuffle(), tableSize(), tableSlice(), tableLength()
* Web Functions - urlDecode(), urlEncode(), parseQuery(), createQuery()


**Documentation**

http://docs.davidmccuskey.com/display/docs/lua_utils.lua


**Examples**

None yet


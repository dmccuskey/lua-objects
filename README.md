## lua-objects ##

Advanced object oriented module for Lua (OOP)

This single-file module started its life as [dmc-objects](https://github.com/dmccuskey/dmc-objects) and was used to create mobile apps built with the Corona SDK. It was later refactored into two files `lua_objects.lua` & `dmc_objects.lua` so that pure-Lua environments could benefit, too (eg, [lua-corovel](https://github.com/dmccuskey/lua-corovel)).

This power-duo have been used to create relatively complex Lua mobile apps (~60k LOC), clients for websockets and the WAMP-protocol, and countless others.


### Features ###

* **_new!_** customizable methods and names for constructor/destructor
* **_new!_** multiple inheritance (all way to top level)
* **_new!_** handles of ambiguities of inherited attributes
* **_new!_** advanced support for mixins
* getters and setters
* correctly handles missing methods on super classes
* optimization (copy methods from super classes)
* **_new!_** unit tested


#### Examples ####

The project [dmc-objects](https://github.com/dmccuskey/dmc-objects) contains two sub-classes made for mobile development with the Corona SDK (`ObjectBase` & `CoronaBase`). These sub-classes show how you can take advantage of the power of `lua_objects.lua`:

* custom initialization and teardown
* custom constructor/destructor names
* custom Event mixin (add/removeListener/dispatchEvent) [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin)


### Create Custom Class ###

Here's a quick example showing how to create a custom class.

```lua
--== Import module

local Objects = require 'dmc_lua.lua_objects'


--== Setup aliases, cleaner code

local newClass = Objects.newClass


--== Create a class

local AccountClass = newClass()
 

--== Class Properties

AccountClass.DEFAULT_PATH = '/path/dir/'
AccountClass.DEFAULT_AMOUNT = 100.45


--== Class constructor/destructor

-- called from obj:new()
function AccountClass:__new__( params )
	params = params or {}
	self._secure = params.secure or true 
	self._amount = params.amount or self.DEFAULT_AMOUNT 
end

-- called from obj:destroy()
function AccountClass:__destroy__()
	self._secure = nil 
	self._amount = nil 
end


--== Class getters/setters

function AccountClass.__setters:secure( value )
	if type( value ) ~= 'boolean' then return end 
	self._secure = value
end
function AccountClass.__getters:secure()
	return self._secure
end


--== Class methods

function AccountClass:deposit( amount )
	self._amount = self._amount + amount
	self:dispatchEvent( AccountClass.AMOUNT_CHANGED_EVENT, { amount=self._amount } )
end
function AccountClass:withdraw( amount )
	self._amount = self._amount - amount
end

```


### Create Class Instance ###

And here's how to work with that class.

```lua

-- Create instance

local account = AccountClass:new{ secure=true, amount=94.32 }

-- Call methods

account:deposit( 32.12 )
account:withdraw( 50.00 )


-- optimize method lookup

obj:optimize()
obj:deoptimize()


-- Check class/object types 

if AccountClass.is_class then print( "is class" ) end 
if obj:isa( AccountClass ) then print( "is AccountClass" ) end 
if obj.is_class then print( "is class" ) end 
if obj.is_instance then print( "is instance" ) end 


-- Destroy instance

account:destroy()
account = nil 

```


### Custom Constructor/Destructor ###

You can even customize the names used for construction and destruction.

```lua
-- use 'create' instead of 'new'
-- eg,  Class:create{ secure=true, amount=94.32 }
--
registerCtorName( 'create' )

-- use 'removeSelf' instead of 'destroy'
-- eg,  obj:removeSelf()
--
registerDtorName( 'removeSelf' )

```

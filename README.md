## lua-objects ##

Advanced object oriented library for Lua (OOP)

This library started out being used for mobile apps built with the Corona SDK. It was later separated into pure Lua and Corona modules (lua_objects, dmc_objects) so that pure Lua environments could benefit from the library, too (eg, Corovel).

It has been used to create relatively large Lua module apps (60k LOC).

Features include:

* constructor/initialization/destructor
* getters and setters
* multiple inheritance (all way to top level)
* advanced support for mixins
* event dispatch mixin (add/removeListener, dispatchEvent)
* handles of ambiguities of inherited attributes
* correctly handles missing methods on super classes
* optimization (copy methods from super classes)
* subclass built for Corona SDK (display objects) (dmc_objects)
* unit tested


Create Custom Class

```lua
--== Import module

local Objects = require 'lua_objects'


--== Setup aliases, cleaner code

local newClass = Objects.newClass
local Object = Objects.Object


--== Create a class, single inheritance

local AccountClass = newClass( Object )
 

--== Class Properties

AccountClass.DEFAULT_PATH = '/path/dir/'
AccountClass.DEFAULT_AMOUNT = 100.45

AccountClass.AMOUNT_CHANGED_EVENT = 'account_amount_changed_event'


--== Class setup and teardown

-- setup controlled by new()
function AccountClass:__init__( params )

	self._secure = params.secure or true 
	self._amount = params.amount or self.DEFAULT_AMOUNT 

end

-- teardown controlled by destroy()
function AccountClass:__undoInit__()
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


*Create Class Instance*

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

if Object.is_class then print( "is class" ) end 
if obj:isa( Object ) then print( "is Object" ) end 
if obj.is_class then print( "is class" ) end 
if obj.is_instance then print( "is instance" ) end 


-- Destroy instance

account:destroy()
account = nil 

```


Custom Constructor/Destructor

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



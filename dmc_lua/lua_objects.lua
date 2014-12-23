--====================================================================--
-- lua_objects.lua
--
-- Documentation: http://docs.davidmccuskey.com/display/docs/lua_objects.lua
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014-2015 David McCuskey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]



--====================================================================--
-- DMC Lua Library : Lua Objects
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "1.0.0"



--====================================================================--
--== Imports

local Utils = require 'lua_utils'



--====================================================================--
--== Setup, Constants


-- cache globals
local assert, type, rawget, rawset = assert, type, rawget, rawset
local getmetatable, setmetatable = getmetatable, setmetatable

local tinsert = table.insert
local tremove = table.remove

-- forward declare
local ClassBase, ObjectBase



--====================================================================--
--== Class Support Functions


-- registerCtorName
-- add names for the constructor
--
local function registerCtorName( name, class )
	-- print( "registerCtorName", name, class )
	class = class or ClassBase
	--==--
	assert( type( name ) == 'string', "ctor name should be string" )
	assert( class.is_class, "Class is not is_class" )

	class[ name ] = class.__create__
	return class[ name ]
end

-- registerDtorName
-- add names for the constructor
--
local function registerDtorName( name, class )
	-- print( "registerDtorName", name, class )
	class = class or ClassBase
	--==--
	assert( type( name ) == 'string', "dtor name should be string" )
	assert( class.is_class, "Class is not is_class" )

	class[ name ] = class.__destroy__
	return class[ name ]
end



--[[
obj:superCall( 'string', ... )
obj:superCall( Class, 'string', ... )
--]]

-- superCall()
-- method to intelligently find methods in object hierarchy
--
local function superCall( self, ... )
	local args = {...}
	local arg1 = args[1]
	assert( type(arg1)=='table' or type(arg1)=='string' )
	--==--
	-- pick off arguments	
	local parent_lock, method, params

	if type(arg1) == 'table' then 
		parent_lock = tremove( args, 1 )
		method = tremove( args, 1 )
	else  
		method = tremove( args, 1 )
	end
	params = args

	local self_dmc_super = self.__dmc_super
	local super_flag = ( self_dmc_super ~= nil )
	local result = nil

	-- finds method name in class hierarchy
	-- returns found class or nil
	-- @params classes list of Classes on which to look, table/list
	-- @params name name of method to look for, string
	-- @params lock Class object with which to constrain searching
	--
	function findMethod( classes, name, lock )
		-- print( "findMethod", name, classes, lock )
		local cls = nil
		for _, class in ipairs( classes ) do
			if not lock or class == lock then 
				if rawget( class, name ) then
					cls = class 
					break
				else
					-- check parents for method
					cls = findMethod( class.__parents, name )
					if cls then break end 
				end
			end
		end
		return cls
	end

	local c, s  -- class, super

	-- structure in which to save our place
	-- in case superCall() is invoked again
	--
	if self_dmc_super == nil then
		self.__dmc_super = {} -- a stack
		self_dmc_super = self.__dmc_super
		-- find out where we are in hierarchy
		s = findMethod( { self.__class }, method )
		tinsert( self_dmc_super, s )
	end

	-- pull Class from stack and search for method on Supers
	-- look for method on supers
	-- call method if found
	--
	c = self_dmc_super[ # self_dmc_super ]
	s = findMethod( c.__parents, method, parent_lock )
	if s then
		tinsert( self_dmc_super, s )
		result = s[method]( self, unpack( args ) )
		tremove( self_dmc_super, # self_dmc_super )
	end

	-- this is the first iteration and last 
	-- so clean up callstack, etc
	--
	if super_flag == false then
		parent_lock = nil
		tremove( self_dmc_super, # self_dmc_super )
		self.__dmc_super = nil
	end

	return result
end



-- initializeObject
-- this is the beginning of object initialization
-- either Class or Instance
-- this is what calls the parent constructors, eg new()
-- called from newClass(), __create__(), __call()
--
-- @params obj the object context
-- @params params table with :
-- set_isClass = true/false
-- data contains {...}
--
local function initializeObject( obj, params )
	-- print( "initializeObject", obj )
	params = params or {}
	--==--
	assert( params.set_isClass ~= nil, "initializeObject requires paramter 'set_isClass'" )

	local is_class = params.set_isClass
	local args = params.data or {}

	-- set Class/Instance flag
	obj.__is_class = params.set_isClass

	-- call Parent constructors, if any
	-- do in reverse
	--
	local parents = obj.__parents
	for i = #parents, 1, -1 do
		local parent = parents[i]

		rawset( obj, '__parent_lock', parent )
		if parent.__new__ then
			parent.__new__( obj, unpack( args ) )
		end

	end
	rawset( obj, '__parent_lock', nil )

	return obj 
end



-- newindexFunc()
-- override the normal Lua lookup functionality to allow
-- property setter functions
--
-- @param t object table
-- @param k key
-- @param v value
--
local function newindexFunc( t, k, v )
	-- print( "newindexFunc", t, k, v )

	local o, f

	-- check for key in setters table
	o = rawget( t, '__setters' ) or {}
	f = o[k]
	if f then
		-- found setter, so call it
		f(t,v)
	else
		-- place key/value directly on object
		rawset( t, k, v )
	end

end



-- multiindexFunc()
-- override the normal Lua lookup functionality to allow
-- property getter functions
--
-- @param t object table
-- @param k key
--
local function multiindexFunc( t, k )
	-- print( "multiindexFunc", t, k )

	local o, val

	--== do key lookup in different places on object

	-- check for key in getters table
	o = rawget( t, '__getters' ) or {}
	if o[k] then return o[k](t) end

	-- check for key directly on object
	val = rawget( t, k )
	if val ~= nil then return val end

	-- check OO hierarchy
	-- check Parent Lock else all of Parents
	--
	o = rawget( t, '__parent_lock' )
	if o then
		if o then val = o[k] end
		if val ~= nil then return val end
	else
		local par = rawget( t, '__parents' )
		for _, o in ipairs( par ) do
			if o[k] ~= nil then
				val = o[k]
				break
			end
		end
		if val ~= nil then return val end
	end

	return nil
end



-- newBless()
-- create new object, setup with Lua OO aspects, dmc-style aspects
-- @params inheritance table of supers/parents (dmc-style objects)
-- @params params
-- params.object
-- params.set_isClass
--
local function newBless( inheritance, params )
	params = params or {}
	params.object = params.object or {}
	params.set_isClass = params.set_isClass == true and true or false
	--==--
	local o = params.object
	local mt = {
		__index = multiindexFunc,
		__newindex = newindexFunc,
		__call = function()
			return initializeObject( o, params )
		end
	}
	setmetatable( o, mt )

	-- add Class property, access via getters:super()
	o.__parents = inheritance

	-- create lookup tables - setters, getters
	o.__setters = {}
	o.__getters = {}

	-- copy down all getters/setters of parents
	for _, cls in ipairs( inheritance ) do
		if cls.__getters then
			o.__getters = Utils.extend( cls.__getters, o.__getters )
		end
		if cls.__setters then
			o.__setters = Utils.extend( cls.__setters, o.__setters )
		end
	end

	return o
end



local function newClass( inheritance, params )
	-- print( "newClass", inheritance, params )
	inheritance = inheritance or {}
	params = params or {}
	params.set_isClass = true
	params.name = params.name or "<unnamed class>"
	--==--
	assert( type( inheritance ) == 'table', "first parameter should be nil, a Class, or a list of Classes" )

	-- wrap single-class into table list
	-- testing for DMC-Style objects
	-- TODO: see if we can test for other Class libs
	-- 
	if inheritance.is_class == true then
		inheritance = { inheritance }
	elseif ClassBase and #inheritance == 0 then 
		-- add default base Class
		tinsert( inheritance, ClassBase )
	end

	local o = newBless( inheritance, {} )

	initializeObject( o, params )

	-- add Class property, access via getters:class()
	o.__class = o 

	-- add Class property, access via getters:NAME()
	o.__name = params.name

	return o

end



local function inheritsFrom( baseClass, options, constructor )
	baseClass = baseClass == nil and baseClass or { baseClass }
	return newClass( baseClass, options )
end



--====================================================================--
--== Base Class
--====================================================================--


ClassBase = newClass( nil, { name="Base Class" } )

ClassBase._PRINT_INCLUDE = {}
ClassBase._PRINT_EXCLUDE = { '__dmc_super' }


function ClassBase:__create__( ... )
	-- print( "ClassBase:__create__", self, self.NAME )
	local params = {
		data = {...},
		set_isClass = false
	}
	--==--
	local o = newBless( { self.__class }, params )
	initializeObject( o, params )

	return o
end


function ClassBase:__new__( ... )
	-- print( "ClassBase:__new__", self )
	--==--
	return self
end


function ClassBase:__destroy__()
	-- print( "ClassBase:__destroy__", self )
	--==--
end


function ClassBase.__getters:NAME()
	-- print( "ClassBase.__getters:NAME", self.__name )
	return self.__name
end


function ClassBase.__getters:class()
	-- print( "ClassBase.__getters:class", self.__class )
	return self.__class
end

function ClassBase.__getters:super()
	-- print( "ClassBase.__getters:super", self.__parents )
	return self.__parents
end


function ClassBase.__getters:is_class()
	-- print( "ClassBase.__getters:is_class", self.__is_class )
	return self.__is_class
end

-- deprecated
function ClassBase.__getters:is_intermediate()
	-- print( "ClassBase.__getters:is_intermediate", self.__is_class )
	return self.__is_class
end

function ClassBase.__getters:is_instance()
	-- print( "ClassBase.__getters:is_instance", self.__is_class )
	return not self.__is_class
end



function ClassBase:isa( theClass )
	-- print( "ClassBase:isa", theClass )
	--==--
	local isa = false
	local cur_class = self.class 

	-- test self
	if cur_class == theClass then 
		isa = true 

	-- test parents
	else 
		local parents = self.__parents
		for i=1, #parents do
			isa = parents[i]:isa( theClass )
			if isa == true then break end
		end
	end

	return isa 
end



-- print
--
function ClassBase:print( include, exclude )
	local include = include or self._PRINT_INCLUDE
	local exclude = exclude or self._PRINT_EXCLUDE

	Utils.printObject( self, include, exclude )
end



function ClassBase:optimize()

	function _optimize( obj, class )

		-- climb up the hierarchy
		if not class then return end
		_optimize( obj, class:superClass() )

		-- make local references to all functions
		for k,v in pairs( class ) do
			if type( v ) == 'function' then
				obj[ k ] = v
			end
		end

	end

	_optimize( self, self:class() )
end

function ClassBase:deoptimize()
	for k,v in pairs( self ) do
		if type( v ) == 'function' then
			self[ k ] = nil
		end
	end
end



function ClassBase:createCallback( method )
	return Utils.createObjectCallback( self, method )	
end


-- Setup Class Properties (function references)

registerCtorName( 'new', ClassBase )
ClassBase.superCall = superCall



--====================================================================--
--== Object Base Class
--====================================================================--


ObjectBase = inheritsFrom( ClassBase, { name="Object Class" } )



--====================================================================--
--== Class Support Functions


-- callback is either function or object (table)
-- creates listener lookup key given event name and handler
--
local function createEventListenerKey( e_name, handler )
	return e_name .. "::" .. tostring( handler )
end




--====================================================================--
--== Constructor


function ObjectBase:__new__( ... )
	-- print( "ObjectBase:__new__" )
	--==--

	--== Do setup sequence ==--

	self:__init__( ... )

	-- skip these if a Class object (ie, NOT an instance)
	if rawget( self, '__is_class' ) == false then
		self:__initComplete__()
	end

	return self
end


--======================================================--
-- Start: Setup Lua Objects

-- _init()
-- initialize the object - setting the view
--
function ObjectBase:__init__( options )
	-- print( "ObjectBase:__init__" )
	-- OVERRIDE THIS
	--== Create Properties ==--
	self.__event_listeners = {} -- holds event listeners
	--[[
	event listeners key'd by:
	* <event name>::<function>
	* <event name>::<object>
	{
		<event name> = {
			'event::function' = func,
			'event::object' = object (table)
		}
	}
	--]]
	--== Object References ==--
end

ObjectBase._init = ObjectBase.__init__

-- _undoInit()
-- remove items added during _init()
--
function ObjectBase:__undoInit__( options )
	-- OVERRIDE THIS
	self.__event_listeners = nil
end
ObjectBase._undoInit = ObjectBase.__undoInit__


-- _initComplete()
-- any setup after object is done being created
--
function ObjectBase:__initComplete__()
	-- OVERRIDE THIS
end
ObjectBase._initComplete = ObjectBase.__initComplete__

-- _undoInitComplete()
-- remove any items added during _initComplete()
--
function ObjectBase:__undoInitComplete__()
	-- OVERRIDE THIS
end
ObjectBase._undoInitComplete = ObjectBase.__undoInitComplete__

-- END: Setup Lua Objects
--======================================================--



--====================================================================--
--== Public Methods


-- dispatchEvent( event, data, params )
--
function ObjectBase:dispatchEvent( e_type, data, params )
	-- print( "ObjectBase:dispatchEvent", e_type );
	self:_dispatchEvent( self:_buildDmcEvent( e_type, data, params ) )
end


-- addEventListener()
--
function ObjectBase:addEventListener( e_name, listener )
	-- print( "ObjectBase:addEventListener", e_name, listener );

	-- Sanity Check

	if not e_name or type(e_name)~='string' then
		error( "ERROR addEventListener: event name must be string", 2 )
	end
	if not listener and not Utils.propertyIn( {'function','table'}, type(listener) ) then
		error( "ERROR addEventListener: listener must be a function or object", 2 )
	end

	-- Processing

	local events, listeners, key

	events = self.__event_listeners
	if not events[ e_name ] then events[ e_name ] = {} end
	listeners = events[ e_name ]

	key = createEventListenerKey( e_name, listener )
	if listeners[ key ] then
		print("WARNING:: ObjectBase:addEventListener, already have listener")
	else
		listeners[ key ] = listener
	end

end

-- removeEventListener()
--
function ObjectBase:removeEventListener( e_name, listener )
	-- print( "ObjectBase:removeEventListener" );

	local listeners, key

	listeners = self.__event_listeners[ e_name ]
	if not listeners or type(listeners)~= 'table' then
		print("WARNING:: ObjectBase:removeEventListener, no listeners found")
	end

	key = createEventListenerKey( e_name, listener )

	if not listeners[ key ] then
		print("WARNING:: ObjectBase:removeEventListener, listener not found")
	else
		listeners[ key ] = nil
	end

end


-- removeSelf()
--
-- this method drives the destruction flow for DMC-style objects
-- typically, you won't override this
--
function ObjectBase:removeSelf()
	-- print( "ObjectBase:removeSelf" );

	-- skip these if a Class object (ie, NOT an instance)
	if rawget( self, '__is_class' ) == false then
		self:_undoInitComplete()
	end

	self:_undoInit()
end


--====================================================================--
--== Private Methods

function ObjectBase:_buildDmcEvent( e_type, data, params )
	params = params or {}
	if params.merge == nil then params.merge = true end
	--==--
	local e

	if params.merge and type( data ) == 'table' then
		e = data
		e.name = self.EVENT
		e.type = e_type
		e.target = self

	else
		e = {
			name=self.EVENT,
			type=e_type,
			target=self,
			data=data
		}

	end
	return e
end


function ObjectBase:_dispatchEvent( event )
	-- print( "ObjectBase:_dispatchEvent", event.name );
	local e_name, listeners

	e_name = event.name
	if not e_name or not self.__event_listeners[ e_name ] then return end

	listeners = self.__event_listeners[ e_name ]
	if type(listeners)~='table' then return end

	for k, callback in pairs( listeners ) do

		if type( callback ) == 'function' then
			-- have function
		 	callback( event )

		elseif type( callback )=='table' and callback[e_name] then
			-- have object/table
			local method = callback[e_name]
			method( callback, event )

		else
			print( "WARNING: ObjectBase dispatchEvent", e_name )

		end
	end
end


-- Setup Class Properties (function references)
registerCtorName( 'new', ObjectBase )



--====================================================================--
--== Event Handlers

-- none




--====================================================================--
--= Lua Objects Exports
--====================================================================--

return {
	__superCall = superCall, -- for testing

	registerCtorName = registerCtorName,
	registerDtorName = registerDtorName,
	inheritsFrom = inheritsFrom,
	newClass = newClass,
	ClassBase = ClassBase,
	ObjectBase = ObjectBase
}

--====================================================================--
-- spec/lua_objects_spec.lua
--
-- Testing for lua-objects using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


--====================================================================--
--== Test: Lua Objects
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.1"



--====================================================================--
--== Imports


local Objects = require 'lua_objects'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local Class = Objects.Class
local Object = Objects.Object



--====================================================================--
--== Testing Setup
--====================================================================--


--[[
Test methods and such on items inside of Lua Objects
--]]
describe( "Module Test: test Lua Object availability", function()

	it( "has Class name", function()
		assert( Class.NAME == "Class Class" )
	end)

	it( "has constructor function", function()
		assert( Class.new ~= nil )
		assert( type( Class.new ) == 'function' )
	end)

	it( "has method isa", function()
		assert( rawget( Class, 'isa' ) ~= nil )
	end)

	it( "has newClass access", function()
		assert( Objects.newClass == _G.newClass, "mismatch of newClass() functions" )
	end)

end)




--[[
Test the simplest class ever
--]]
describe( "Module Test: simplest class", function()

	local Class

	before_each( function()
		Class = newClass()
	end)

	after_each( function()
		Class = nil
	end)

	describe( "Test: simplest class elements", function()

		it( "returns a Class object", function()
			assert( type(Class) == 'table' )
			assert( Class.is_class == true )
		end)

		it( "is a subclass", function()
			assert.are.equal( Class:isa( Class ), true )
			assert.are.equal( Class:isa( Class ), true )

			assert.are.equal( Class:isa( nil ), false )
			assert.are.equal( Class:isa( {} ), false )
		end)

		it( "has a parent", function()
			assert.are.equal( #Class.supers, 1 )
		end)

		it( "has property class", function()
			assert( Class.class == Class )
		end)

		it( "has ctor/dtor methods", function()
			assert( Class.new ~= nil )
			assert( type(Class.new) == 'function' )

			assert( Class.destroy ~= nil )
			assert( type(Class.destroy) == 'function' )
		end)


		--== Private Testing ==--

		it( "has dmc-style properties", function()
			assert( rawget( Class, '__setters' ) ~= nil )
			assert( rawget( Class, '__getters' ) ~= nil )
			assert( rawget( Class, '__parents' ) ~= nil )
		end)

	end)

end)




--[[
Test the simplest inheritance
--]]
describe( "Module Test: single ineritance class", function()

	local ParentClass, Class

	before_each( function()
		ParentClass = newClass( {}, {name='Parent'} )

		Class = newClass( ParentClass, {name='Class'} )
	end)

	after_each( function()
		Class = nil
	end)

	describe( "Test: simplest class elements", function()

		it( "returns an object", function()
			assert( type(ParentClass) == 'table' )
			assert( ParentClass.is_class == true )

			assert( type(Class) == 'table' )
			assert( Class.is_class == true )
		end)

		it( "is not a table", function()
			assert( Class:isa( Class ) == true )
			assert( Class:isa( ParentClass ) == true )
			assert( Class:isa( Class ) == true )

			assert( Class:isa( nil ) == false )
			assert( Class:isa( {} ) == false )
		end)

		it( "has property class", function()
			assert( Class.class == Class )
		end)

		it( "has ctor/dtor methods", function()
			assert( type(ParentClass.new) == 'function' )
			assert( type(ParentClass.destroy) == 'function' )

			assert( type(Class.new) == 'function' )
			assert( type(Class.destroy) == 'function' )
		end)


		--== Private Testing ==--

		it( "has dmc-style properties", function()
			assert( rawget( Class, '__setters' ) ~= nil )
			assert( rawget( Class, '__getters' ) ~= nil )
			assert( rawget( Class, '__parents' ) ~= nil )
		end)

	end)

end)




--[[
Test simple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA
	local obj, obj2
	local p

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()
		ClassA = newClass()

		function ClassA:__new__( params )
			params = params or {}
			self:superCall( '__new__', params )
			self._params = params
		end

		function ClassA:one( num )
			return num
		end

		function ClassA:two( num )
			return num * 2
		end

		p = {one=1}

		obj = ClassA:new( p )
		obj2 = ClassA( p )

	end)

	after_each( function()
		ClassA = nil
		obj = nil
		p = nil
	end)


	describe("Test: simplest class elements", function()

		it( "created object", function()
			assert( type( obj ) == 'table' )
			assert( obj.is_class == false )
			assert( obj.is_instance == true )

			assert( type( obj2 ) == 'table' )
			assert( obj2.is_class == false )
			assert( obj2.is_instance == true )
		end)

		it( "class has methods", function()
			assert( type( ClassA.one ) == 'function' )
			assert( type( ClassA.two ) == 'function' )
		end)

		it( "can access parent methods", function()
			assert.are.equal( obj:one( 4 ), 4 )
			assert.are.equal( obj:two( 4 ), 8 )

			assert.are.equal( obj2:one( 4 ), 4 )
			assert.are.equal( obj2:two( 4 ), 8 )
		end)

		it( "has properties", function()
			assert.are.equal( obj._params, p )
			assert.are.equal( obj2._params, p )
		end)

	end)

end)




--[[
Test multiple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA, ClassB, obj, obj2

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()


		ClassA = newClass()

		function ClassA:one( num )
			return num * 2
		end

		function ClassA:two( num )
			return num * 4
		end

		function ClassA:three( num )
			return num * 6
		end

		-- function ClassA:four( num ) end


		ClassB = newClass( ClassA )

		function ClassB:one( num )
			return num * 1
		end

		function ClassB:two( num )
			return num * 2
		end

		-- function ClassB:three( num ) end

		function ClassB:four( num )
			return num * 4
		end


		obj = ClassB:new()
		obj2 = ClassB:new()


	end)

	after_each( function()
		ClassA, ClassB = nil, nil
		obj, obj2 = nil, nil
	end)


	describe("Test: inherited class elements", function()

		it( "ClassA has methods", function()
			assert( rawget( ClassA, 'one' ) ~= nil  )
			assert( type( ClassA.one ) == 'function' )

			assert( rawget( ClassA, 'two' ) ~= nil  )
			assert( type( ClassA.two ) == 'function' )

			assert( rawget( ClassA, 'three' ) ~= nil  )
			assert( type( ClassA.three ) == 'function' )

			assert( rawget( ClassA, 'four' ) == nil  )
			assert( type( ClassA.four ) == 'nil' )
		end)

		it( "ClassB has methods", function()
			assert( rawget( ClassB, 'one' ) ~= nil )
			assert( type( ClassB.one ) == 'function' )

			assert( rawget( ClassB, 'two' ) ~= nil  )
			assert( type( ClassB.two ) == 'function' )

			assert( rawget( ClassB, 'three' ) == nil  )
			assert( type( ClassB.three ) == 'function' )

			assert( rawget( ClassB, 'four' ) ~= nil  )
			-- inherited
			assert( type( ClassB.four ) == 'function' )
		end)

		it( "created object", function()
			assert( type(obj) == 'table' )
		end)

		it( "Obj1 several parent classes", function()
			assert( obj:isa( ClassA ) == true )
			assert( obj:isa( ClassB ) == true )
			assert( obj:isa( Class ) == true )

			assert( obj:isa( nil ) == false )
			assert( obj:isa( {} ) == false )
		end)

		it( "Obj2 several parent classes", function()
			assert( obj2:isa( ClassA ) == true )
			assert( obj2:isa( ClassB ) == true )
			assert( obj2:isa( Class ) == true )

			assert( obj2:isa( nil ) == false )
			assert( obj2:isa( {} ) == false )
		end)

		it( "can access parent methods", function()
			assert.are.equal( obj:one( 4 ), 4 )
			assert.are.equal( obj:two( 4 ), 8 )
			assert.are.equal( obj:three( 4 ), 24 )
			assert.are.equal( obj:four( 4 ), 16 )
		end)

	end)

end)




--[[
Test complex multiple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA, ClassB, ClassC, ClassD
	local obj, obj2

	before_each( function()

		ClassA = newClass()
		ClassA.NAME = "Class A"

		function ClassA:one( num )
			return num * 4
		end

		function ClassA:two( num )
			return num * 4
		end

		-- function ClassA:three( num ) end

		function ClassA:four( num )
			return num * 4
		end


		ClassB = newClass( ClassA )
		ClassB.NAME = "Class B"

		function ClassB:one( num )
			local val = self:superCall( 'one', num )
			return val * 3
		end

		-- function ClassB:two( num ) end

		function ClassB:three( num )
			-- local val = self:superCall( 'three', num )
			local val = num
			return val * 3
		end

		-- function ClassB:four( num ) end


		ClassC = newClass( ClassB )
		ClassC.NAME = "Class C"

		function ClassC:one( num )
			local val = self:superCall( 'one', num )
			return val * 2
		end

		function ClassC:two( num )
			local val = self:superCall( 'two', num )
			return val * 2
		end

		-- function ClassC:three( num ) end

		-- function ClassC:four( num ) end


		ClassD = newClass( ClassC )
		ClassD.NAME = "Class D"

		function ClassD:one( num )
			local val = self:superCall( 'one', num )
			return val * 1
		end

		-- function ClassD:two( num ) end

		function ClassD:three( num )
			local val = self:superCall( 'three', num )
			return val * 1
		end

		function ClassD:four( num )
			local val = self:superCall( 'four', num )
			return val * 1
		end


		obj = ClassD:new()

	end)

	after_each( function()
		ClassA, ClassB, ClassC, ClassD = nil, nil, nil, nil
		obj, obj2 = nil, nil
	end)


	describe("Test: complex multiple-inheritance method calls", function()

		it( "has good answers", function()
			assert.are.equal( obj:one( 4 ), 96 )
			assert.are.equal( obj:two( 4 ), 32 )
			assert.are.equal( obj:three( 4 ), 12 )
			assert.are.equal( obj:four( 4 ), 16 )
		end)

	end)

end)

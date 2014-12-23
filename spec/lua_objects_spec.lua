--[[
Unit Testing for lua_objects using Busted
--]]

package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
--== Test: Lua Objects
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Objects = require 'lua_objects'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local newClass = Objects.newClass

local ClassBase = Objects.ClassBase
local ObjectBase = Objects.ObjectBase



--====================================================================--
--== Testing Setup
--====================================================================--


--[[
Test methods and such on items inside of Lua Objects
--]]
describe( "Module Test: test Lua Object availability", function()

	it( "has Class name", function()
		assert( ClassBase.NAME == "Base Class" )
		assert( ObjectBase.NAME == "Object Class" )
	end)

	it( "has constructor function", function()
		assert( ClassBase.new ~= nil )
		assert( type( ClassBase.new ) == 'function' )

		assert( ObjectBase.new ~= nil )
		assert( type( ObjectBase.new ) == 'function' )
	end)

	it( "has method isa", function()
		assert( rawget( ClassBase, 'isa' ) ~= nil )

		assert( ObjectBase.isa ~= nil )
		assert( type( ObjectBase.isa ) == 'function' )
	end)

	it( "has ctor/dtor name functions", function()
		assert( Objects.registerCtorName ~= nil )
		assert( type( Objects.registerCtorName ) == 'function' )

		assert( Objects.registerDtorName ~= nil )
		assert( type( Objects.registerDtorName ) == 'function' )
	end)

	it( "has a string constructor name", function()
		assert.are.equal( type( Objects.registerCtorName( 'create' ) ), 'function' )

		assert.has.errors( function() Objects.registerCtorName() end )
		assert.has.errors( function() Objects.registerCtorName( 4 ) end )
		assert.has.errors( function() Objects.registerCtorName( {} ) end )
	end)

	it( "has a string destructor name", function()
		assert.are.equal( type( Objects.registerDtorName( 'delete' ) ), 'function' )

		assert.has.errors( function() Objects.registerDtorName() end )
		assert.has.errors( function() Objects.registerDtorName( 4 ) end )
		assert.has.errors( function() Objects.registerDtorName( {} ) end )
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
			assert.are.equal( Class:isa( ClassBase ), true )

			assert.are.equal( Class:isa( nil ), false )
			assert.are.equal( Class:isa( {} ), false )
		end)

		it( "has a parent", function()
			assert.are.equal( #Class.super, 1 )
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
		ParentClass = newClass( {}, {} )

		Class = newClass( ParentClass )
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
			assert( Class:isa( ClassBase ) == true )

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

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()
		ClassA = newClass()

		function ClassA:one( num )
			return num
		end

		function ClassA:two( num )
			return num * 2
		end

		obj = ClassA:new()
		obj2 = ClassA()

	end)

	after_each( function()
		ClassA = nil 
		obj = nil 
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
			assert( obj:isa( ClassBase ) == true )

			assert( obj:isa( nil ) == false )
			assert( obj:isa( {} ) == false )
		end)

		it( "Obj2 several parent classes", function()
			assert( obj2:isa( ClassA ) == true )
			assert( obj2:isa( ClassB ) == true )
			assert( obj2:isa( ClassBase ) == true )

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




--[[
Test simple inheritance initialization methods
--]]
describe( "Module Test: class methods", function()

	local ClassA, ClassB
	local obj, obj2 

	before_each( function()


		ClassA = newClass( ObjectBase )
		ClassA.NAME = "Class A"

		function ClassA:__init__( params )
			-- print( "ClassA:__init__", params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--
			params.p_one = "override"
			self.one = params.p_one
			self.two = params.p_two
		end


		ClassB = newClass( ClassA )
		ClassB.NAME = "Class B"

		function ClassB:__init__( num )
			-- print( "ClassB:__init__", params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--

			self.one = params.p_one
			self.two = params.p_two
		end


		obj = ClassA:new{ p_one='one', p_two='two' }
		obj2 = ClassA{ p_one='one', p_two='two' }

	end)

	after_each( function()
		ClassA, ClassB = nil, nil 
		obj, obj2 = nil, nil 
	end)


	describe("Test: simplest class elements", function()

		it( "can access parent methods", function()
			assert( obj.one == 'override' )
			assert( obj.two == 'two' )

			assert( obj2.one == 'override' )
			assert( obj2.two == 'two' )
		end)

	end)

end)




--[[
Test simple inheritance initialization methods
--]]
describe( "Module Test: complex hierarchy", function()

	local ClassZ, ClassA, ClassB, ClassC, obj, obj2

	before_each( function()

		ClassZ = newClass( ObjectBase )
		ClassZ.NAME = "Class Z"

		function ClassZ:__init__( params )
			-- print( "ClassZ:__init__", params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--
			self._checkEnd = false
		end

		function ClassZ:checkEnd()
			-- print( "ClassZ:checkEnd" )
			--==--
			self._checkEnd = true
		end


		ClassA = newClass( ClassZ )
		ClassA.NAME = "Class A"

		function ClassA:__init__( params )
			-- print( "ClassA:__init__", params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--

			params.p_one = "Override A"
			self.one = params.p_one
		end


		ClassB = newClass( ObjectBase )
		ClassB.NAME = "Class B"

		function ClassB:__init__( params )
			-- print( "ClassB:__init__", params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--

			params.p_two = "Override B"
			self.two = params.p_two
		end


		ClassC = newClass( { ClassA, ClassB } )
		ClassC.NAME = "Class C"

		function ClassC:__init__( params )
			-- print( "ClassC:__init__", params )
			params = params or {}
			self:superCall( ClassB, '__init__', params )
			self:superCall( ClassA, '__init__', params )
			--==--

			self.one = params.p_one
			self.two = params.p_two
			self.three = params.p_three
		end

		function ClassC:checkEnd()
			-- print( "ClassC:checkEnd" )
			self:superCall( 'checkEnd', params )
			--==--
		end

		obj = ClassC:new{ p_one='one', p_two='two', p_three='three' }

		obj2 = ClassC:new{ p_one='apple', p_two='orange', p_three='pear' }

	end)

	after_each( function()
		ClassZ, ClassA, ClassB, ClassC = nil, nil, nil, nil 
		obj, obj2 = nil, nil
	end)


	describe("Test: simplest class elements", function()

		it( "can access parent methods", function()
			assert( ClassC.one == 'Override A' )
			assert( ClassC.two == 'Override B' )
		end)


		it( "can access parent methods", function()
			assert( obj.one == 'Override A' )
			assert( obj.two == 'Override B' )
			assert( obj.three == 'three' )
		end)

		it( "can access parent methods", function()
			assert( obj2.one == 'Override A' )
			assert( obj2.two == 'Override B' )
			assert( obj2.three == 'pear' )
		end)

		it( "creates separate objects", function()
			assert( obj ~= obj2 )
		end)

		it( "creates separate objects", function()
			assert( obj._checkEnd == false )
			obj:checkEnd()
			assert( obj._checkEnd == true )
		end)

	end)

end)
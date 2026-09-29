--====================================================================--
-- spec/object_base_spec.lua
--
-- Testing for ObjectBase in lua-objects using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


local Objects = require 'lua_objects'

local newClass = Objects.newClass
local ObjectBase = Objects.ObjectBase



--====================================================================--
--== Helpers


-- a class that records the hooks it runs in `log`
local function newLoggingClass( log )
	local Logged = newClass( ObjectBase, { name="Logged" } )

	function Logged:__init__( ... )
		self:superCall( '__init__', ... )
		--==--
		if not self.is_class then log[ #log+1 ] = '__init__' end
	end
	function Logged:__undoInit__()
		log[ #log+1 ] = '__undoInit__'
		--==--
		self:superCall( '__undoInit__' )
	end
	function Logged:__initComplete__()
		self:superCall( '__initComplete__' )
		--==--
		log[ #log+1 ] = '__initComplete__'
	end
	function Logged:__undoInitComplete__()
		log[ #log+1 ] = '__undoInitComplete__'
		--==--
		self:superCall( '__undoInitComplete__' )
	end

	return Logged
end

-- runs f with print() captured; returns the printed lines
local function capturePrint( f )
	local lines, print_ = {}, _G.print
	_G.print = function( ... )
		local parts = {}
		for i = 1, select( '#', ... ) do parts[ i ] = tostring( ( select( i, ... ) ) ) end
		lines[ #lines+1 ] = table.concat( parts, ' ' )
	end
	local ok, err = pcall( f )
	_G.print = print_
	assert( ok, err )
	return lines
end



--====================================================================--
--== Tests


describe( "The module", function()

	it( "exports its own version", function()
		assert.are.equal( '1.4.1', Objects.__version )
	end)

	it( "exports lua-class's functions and ObjectBase", function()
		assert.are.equal( 'function', type( Objects.newClass ) )
		assert.are.equal( 'function', type( Objects.registerCtorName ) )
		assert.is_not_nil( Objects.Class )
		assert.are.equal( 'Object Base', ObjectBase.NAME )
	end)

	it( "leaves lua-class's module table alone", function()
		local Class = require 'lua_class'
		assert.are_not.equal( Objects, Class )
		assert.is_nil( Class.ObjectBase )
		assert.are.equal( '0.2.0', Class.__version )
	end)

	it( "sets no globals besides newClass", function()
		package.loaded[ 'lua_objects' ] = nil
		local before = {}
		for k in pairs( _G ) do before[ k ] = true end
		require 'lua_objects'
		for k in pairs( _G ) do
			assert.is_true( before[ k ] or k=='newClass', "new global " .. tostring( k ) )
		end
	end)

end)


describe( "Setup and teardown", function()

	it( "runs the hooks in order", function()
		local log = {}
		local Logged = newLoggingClass( log )
		assert.are.same( {}, log )

		local obj = Logged:new()
		assert.are.same( { '__init__', '__initComplete__' }, log )

		obj:removeSelf()
		assert.are.same( { '__init__', '__initComplete__',
			'__undoInitComplete__', '__undoInit__' }, log )
	end)

	it( "passes new()'s arguments to __init__()", function()
		local Account = newClass( ObjectBase, { name="Account" } )
		function Account:__init__( params )
			params = params or {}
			self:superCall( '__init__', params )
			--==--
			self.balance = params.balance or 0
		end
		assert.are.equal( 25, Account:new( { balance=25 } ).balance )
	end)

	it( "runs the same teardown for destroy() and removeSelf()", function()
		local log = {}
		local Logged = newLoggingClass( log )
		Logged:new():destroy()
		assert.are.same( { '__init__', '__initComplete__',
			'__undoInitComplete__', '__undoInit__' }, log )
	end)

	it( "raises an error when an __init__() skips superCall()", function()
		local Broken = newClass( ObjectBase, { name="Broken" } )
		function Broken:__init__( params ) end
		assert.has_error( function() Broken:new() end,
			"ObjectBase: Broken's __init__() must call self:superCall( '__init__', ... )" )
	end)

end)


describe( "Events", function()

	it( "gives a class no list of listeners", function()
		local Account = newClass( ObjectBase, { name="Account" } )
		assert.is_nil( rawget( ObjectBase, '__event_listeners' ) )
		assert.is_nil( rawget( Account, '__event_listeners' ) )
	end)

	it( "gives each instance its own list of listeners", function()
		local Account = newClass( ObjectBase, { name="Account" } )
		local a, b = Account:new(), Account:new()
		local got = {}
		a:addEventListener( a.EVENT, function( e ) got[ #got+1 ] = e.type end )
		b:dispatchEvent( 'from_b' )
		a:dispatchEvent( 'from_a' )
		assert.are.same( { 'from_a' }, got )
	end)

	it( "sends events with the class's EVENT, type, data and target", function()
		local Account = newClass( ObjectBase, { name="Account" } )
		Account.EVENT = 'account_event'
		local obj, got = Account:new()
		obj:addEventListener( obj.EVENT, function( e ) got = e end )
		obj:dispatchEvent( 'balance_changed', { balance=125 } )
		assert.are.equal( 'account_event', got.name )
		assert.are.equal( 'balance_changed', got.type )
		assert.are.equal( 125, got.data.balance )
		assert.are.equal( obj, got.target )
	end)

	it( "only warns when removing a listener from a name with none", function()
		local obj = newClass( ObjectBase, { name="Account" } ):new()
		local lines = capturePrint( function()
			obj:removeEventListener( 'none', function() end )
		end )
		assert.are.same( { 'WARNING:: Events:removeEventListener, no listeners found' }, lines )
	end)

	it( "removes an instance's list on removeSelf()", function()
		local obj = newClass( ObjectBase, { name="Account" } ):new()
		assert.is_not_nil( rawget( obj, '__event_listeners' ) )
		obj:removeSelf()
		assert.is_nil( obj.__event_listeners )
	end)

end)

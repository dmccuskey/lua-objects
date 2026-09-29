--====================================================================--
-- spec/no_global_spec.lua
--
-- lua-objects loads with lua-class's global newClass turned off
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


describe( "Module Test: lua_objects.lua without the global newClass", function()

	it( "loads and makes objects", function()
		for _, name in ipairs{ 'lua_class', 'lua_events_mix', 'lua_objects' } do
			package.loaded[name] = nil
		end
		local Class = require 'lua_class'
		Class.setNewClassGlobal( false )

		local ok, Objects = pcall( require, 'lua_objects' )
		Class.setNewClassGlobal( true )

		assert.is_true( ok, tostring( Objects ) )
		local obj = Objects.ObjectBase:new()
		assert.is_true( obj:isa( Objects.ObjectBase ) )
		obj:removeSelf()
	end)

end)

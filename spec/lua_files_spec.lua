
package.path = './dmc_lua/?.lua;' .. package.path

local File = require 'lua_files'

describe( "Module Test: lua_files.lua", function()

	describe("Tests for read/write JSON File", function()

		it( "File.convertJsonToLua", function()
			local j 
			j = File.convertJsonToLua( '{ "hello":123 }' )
			assert.is.equal( j.hello, 123 )

			--== Invalid 

			assert.has.errors( function() File.convertJsonToLua( {} ) end )
			assert.has.errors( function() File.convertJsonToLua( "" ) end )

			-- double quotes
			assert.has.errors( function() File.convertJsonToLua( "{ 'hello':123 }" ) end )
			-- equals sign
			assert.has.errors( function() File.convertJsonToLua( '{ "hello"=123 }' ) end )

		end)

	end)

	describe("Tests for readingConfigFile", function()

		it( "File.getLineType", function()
			local is_section, is_key

			is_section, is_key = File.getLineType( '[SECTION]' )
			assert.is.equal( is_section, true )
			assert.is.equal( is_key, false )

			is_section, is_key = File.getLineType( 'KEY_WORD' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, true )

			--== Invalid

			is_section, is_key = File.getLineType( '[section]' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, false )

			is_section, is_key = File.getLineType( 'key_word' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, false )

			is_section, is_key = File.getLineType( '' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, false )

			is_section, is_key = File.getLineType( '-- commented line' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, false )

		end)

		it( "File.processSectionLine", function()
			assert.is.equal( File.processSectionLine( "[KEY_LINE]" ), 'key_line' )

			assert.has.errors( function() File.processSectionLine( "[frank]" ) end )
			assert.has.errors( function() File.processSectionLine( "[KEY_LINE" ) end )
			assert.has.errors( function() File.processSectionLine( "KEY_LINE]" ) end )
		end)

		it( "File.processKeyLine", function()
			local key_name, key_value

			key_name, key_value = File.processKeyLine( "KEY_LINE:BOOL = true " )
			assert.is.equal( key_name, 'key_line' )
			assert.is.equal( key_value, true )

			key_name, key_value = File.processKeyLine( "HELLOWORLD:INT  =  45  " )
			assert.is.equal( key_name, 'helloworld' )
			assert.is.equal( key_value, 45 )

			key_name, key_value = File.processKeyLine( "THEPATH:PATH  =  '/one/two/three'  " )
			assert.is.equal( key_name, 'thepath' )
			assert.is.equal( key_value, '.one.two.three' )

			key_name, key_value = File.processKeyLine( 'THEPATH:PATH  =  "/one/two/three"  ' )
			assert.is.equal( key_value, '.one.two.three' )

			key_name, key_value = File.processKeyLine( 'THEPATH:PATH  =  /one/two/three  ' )
			assert.is.equal( key_value, '.one.two.three' )

			-- incorrect type, default to string
			key_name, key_value = File.processKeyLine( 'THE: PATH  =  "/one/two/three"  ' )
			assert.is.equal( key_value, '/one/two/three' )

			-- mismatched quotes
			assert.has.errors( function() File.processKeyLine( 'THE:PATH="/one/two\'' ) end )
		end)

		it( "File.processKeyName", function()
			assert.is.equal( File.processKeyName( 'HAROLD' ), 'harold' )
			assert.is.equal( File.processKeyName( 'LUA_PATH' ), 'lua_path' )

			assert.has.errors( function() File.processKeyName( 123 ) end )
			assert.has.errors( function() File.processKeyName( "" ) end )
			assert.has.errors( function() File.processKeyName( {} ) end )
		end)
		it( "File.processKeyType", function()
			assert.is.equal( File.processKeyType( 'BOOL' ), 'bool' )
			assert.is.equal( File.processKeyType( 'INT' ), 'int' )
			assert.is.equal( File.processKeyType( nil ), nil )
		end)

		it( "File.castTo_bool tests", function()
			assert.is.equal( File.castTo_bool( 'true' ), true )
			assert.is.equal( File.castTo_bool( 'false' ), false )
			assert.is.equal( File.castTo_bool( 'fdsfd' ), false )
		end)
		it( "File.castTo_int tests", function()
			assert.is.equal( File.castTo_int( '120' ), 120 )

			assert.has.errors( function() File.castTo_int( nil ) end )
			assert.has.errors( function() File.castTo_int( {} ) end )
			assert.has.errors( function() File.castTo_int( 'frank' ) end )
		end)
		it( "File.castTo_json tests", function()
			local j = File.castTo_json( '{ "hello":"123"}' )
			assert.is.equal( j.hello, '123' )
			assert.is.equal( type(j), 'table' )

			assert.has.errors( function() File.castTo_json( nil ) end )
			assert.has.errors( function() File.castTo_json( {} ) end )
			assert.has.errors( function() File.castTo_json( 'frank' ) end )
		end)
		it( "File.castTo_path tests", function()
			assert.is.equal( File.castTo_path( 'lib/one/two/three' ), 'lib.one.two.three' )

			assert.has.errors( function() File.castTo_path( nil ) end )
			assert.has.errors( function() File.castTo_path( {} ) end )
			assert.has.errors( function() File.castTo_path(  ) end )
		end)
		it( "File.castTo_string tests", function()
			assert.is.equal( File.castTo_string( 120 ), '120' )
			assert.is.equal( File.castTo_string( 'frank' ), 'frank' )

			assert.has.errors( function() File.castTo_string( nil ) end )
			assert.has.errors( function() File.castTo_string( {} ) end )
		end)


	end) -- reading config file

end)

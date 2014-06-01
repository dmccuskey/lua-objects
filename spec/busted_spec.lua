
package.path = './dmc_lua/?.lua;' .. package.path

local File = require 'lua_files'

describe( "lua files", function()

	describe("Tests for readingConfigFile", function()

		it( "File.getLineType", function()
			local is_section, is_key

			is_section, is_key = File.getLineType( '[SECTION]' )
			assert.is.equal( is_section, true )
			assert.is.equal( is_key, false )

			is_section, is_key = File.getLineType( 'KEY_WORD' )
			assert.is.equal( is_section, false )
			assert.is.equal( is_key, true )
		end)

		it( "File.processSectionLine", function()
			assert.is.equal( File.processSectionLine( "[KEY_LINE]" ), 'key_line' )
			assert.is.equal( File.processSectionLine( '[frank]' ), 'frank' )

			-- assert.has.errors( function() File.processSectionLine( "[KEY_1234LINE]" ) end )
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

			assert.has.errors( function() File.processKeyLine( 'THE:PATH="/one/two\'' ) end )

			-- assert.has.errors( function() File.processSectionLine( "KEY_LINE]" ) end )

			-- assert.is.equal( File.processSectionLine( '[frank]' ), 'frank' )

			-- assert.has.errors( function() File.processSectionLine( "[KEY_LINE" ) end )
			-- assert.has.errors( function() File.processSectionLine( "KEY_LINE]" ) end )
		end)

		it( "File.castTo_bool tests", function()
			assert.is.equal( File.castTo_bool( 'true' ), true )
			assert.is.equal( File.castTo_bool( 'false' ), false )
			assert.is.equal( File.castTo_bool( 'fdsfd' ), false )
		end)
		it( "File.castTo_string tests", function()
			assert.is.equal( File.castTo_string( 120 ), '120' )
			assert.is.equal( File.castTo_string( 'frank' ), 'frank' )

			assert.has.errors( function() File.castTo_string( nil ) end )
			assert.has.errors( function() File.castTo_string( {} ) end )
		end)
		it( "File.castTo_int tests", function()
			assert.is.equal( File.castTo_int( '120' ), 120 )

			assert.has.errors( function() File.castTo_int( nil ) end )
			assert.has.errors( function() File.castTo_int( {} ) end )
			assert.has.errors( function() File.castTo_int( 'frank' ) end )
		end)


	end)




end)

package.path = './dmc_lua/?.lua;' .. package.path

local XML = require 'lua_e4x'
local File = require 'lua_files'
local Utils = require 'lua_utils'


describe( "Module Test: lua_e4x.lua", function()

	describe("Traversing XML", function()

		local xml

		setup( function()
			local data_file = './spec/xml/test-01.xml'
			data = File.readFile( data_file, { lines=false })
			xml = XML.parse( data )
		end)

		teardown( function()
		end)

		before_each( function()
		end)

		after_each( function()
		end)

		it( "Test XMLDocNode", function()

			assert.is.equal( #(xml:children()), 2 )

		end)

		it( "Test XMLNode", function()

			assert.is.equal( xml.book[3], nil )

			assert.is.equal( xml.book[1]:name(), 'book' )
			assert.is.equal( xml:child('book')[1]:name(), 'book' )

			assert.is.equal( #(xml.book[1]:children()), 3 )

			assert.is.equal( xml.book[1].title[1]:toString(), 'Baking Extravagant Pastries with Kumquats' )

		end)


	end)
end)


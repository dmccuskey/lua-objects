package.path = './dmc_lua/?.lua;' .. package.path

local E4X = require 'lua_e4x'
local File = require 'lua_files'


describe( "Module Test: lua_e4x.lua", function()

	describe("Test: XMLList", function()

		local xml

		setup( function()
			local data_file = './spec/xml/test-01.xml'
			data = File.readFileContents( data_file )
			xml = E4X.parse( data )
		end)


		it( "method: dot traversal", function()
			assert.is.equal( xml.book:isa(E4X.XmlListClass), true )
			assert.is.equal( xml.book.title:isa( E4X.XmlListClass ), true )
		end)

		it( "method: length()", function()
			assert.is.equal( xml.book:length(), 2 )
			assert.is.equal( xml.book.title:length(), 2 )
		end)

		it( "method: attribute()", function()

			--== multiple book records

			assert.is.equal( xml.book:attribute('ISBN'):isa(E4X.XmlListClass), true )
			assert.is.equal( xml.book:attribute('ISBN'):length(), 2 )
			assert.is.equal( xml.book['@ISBN']:length(), 2 )

			local books = xml.book
			for i, attr in xml.book:attribute('ISBN'):nodes() do
				assert.are.same( books[i]:attribute('ISBN')[1], attr )
				assert.is.equal( books[i]:attribute('ISBN')[1]:toString(), attr:toString() )
			end

			assert.is.equal( xml.book:attribute('one'):length(), 0 )

		end)

		it( "method: hasOwnProperty", function()
			assert.is.equal( xml.book[1]:hasOwnProperty('title'), true )
			assert.is.equal( xml.book[1]:hasOwnProperty('@ISBN'), true )
			assert.is.equal( xml.book[1]:hasOwnProperty('@one'), false )
		end)

		it( "method: toString", function()
			assert.is.equal( xml.book[1]['@ISBN']:toString(), '0942407296' )
			assert.is.equal( xml.book[1]['@one']:toString(), nil )
		end)

	end) -- Test: XMLList



	describe("Test: XMLNode", function()

		local xml

		setup( function()
			local data_file = './spec/xml/test-01.xml'
			data = File.readFileContents( data_file )
			xml = E4X.parse( data )
		end)


		it( "Test XMLNode", function()

			assert.is.equal( xml.book[3], nil )

			assert.is.equal( xml.book[1]:isa( E4X.XmlNodeClass ), true )

			assert.is.equal( xml.book[1]:name(), 'book' )
			assert.is.equal( xml:child('book')[1]:name(), 'book' )

			assert.is.equal( xml.book[1]:length(), 1 )

			assert.is.equal( xml.book[1]:children():isa( E4X.XmlListClass ), true )
			assert.is.equal( xml.book[1]:children():length(), 3 )

			assert.is.equal( xml.book[1].title[1]:hasComplexContent(), false )
			assert.is.equal( xml.book[1].title[1]:hasSimpleContent(), true )

			assert.is.equal( xml.book[1], xml.book.title[1]:parent() )

		end)

		it( "method: toString()", function()

			--== Book 1

			assert.is.equal( xml.book[1]:toString(), '<title>Baking Extravagant Pastries with Kumquats</title><author><lastName>Contino</lastName><firstName>Chuck</firstName></author><pageCount>238</pageCount>' )
			assert.is.equal( xml.book[1]:toXmlString(), '<book ISBN="0942407296"><title>Baking Extravagant Pastries with Kumquats</title><author><lastName>Contino</lastName><firstName>Chuck</firstName></author><pageCount>238</pageCount></book>' )

			assert.is.equal( xml.book[1].title[1]:toString(), 'Baking Extravagant Pastries with Kumquats' )
			assert.is.equal( xml.book[1].title[1]:toXmlString(), '<title>Baking Extravagant Pastries with Kumquats</title>' )

			assert.is.equal( xml.book[1].author[1]:toString(), '<lastName>Contino</lastName><firstName>Chuck</firstName>' )
			assert.is.equal( xml.book[1].author[1]:toXmlString(), '<author><lastName>Contino</lastName><firstName>Chuck</firstName></author>' )

			assert.is.equal( xml.book[1]['@ISBN'][1]:toString(), '0942407296' )

			--== Book 2

			assert.is.equal( xml.book[2]:toString(), '<title>Emu Care and Breeding</title><editor><lastName>Case</lastName><firstName>Justin</firstName></editor><pageCount>115</pageCount>' )
			assert.is.equal( xml.book[2]:toXmlString(), '<book publisher="Prentice Hall" ISBN="0865436401"><title>Emu Care and Breeding</title><editor><lastName>Case</lastName><firstName>Justin</firstName></editor><pageCount>115</pageCount></book>' )

			assert.is.equal( xml.book[2].title[1]:toString(), 'Emu Care and Breeding' )
			assert.is.equal( xml.book[2].title[1]:toXmlString(), '<title>Emu Care and Breeding</title>' )

			assert.is.equal( xml.book[2].editor[1]:toString(), '<lastName>Case</lastName><firstName>Justin</firstName>' )
			assert.is.equal( xml.book[2].editor[1]:toXmlString(), '<editor><lastName>Case</lastName><firstName>Justin</firstName></editor>' )

		end)

		it( "Test: attribute()/attributes()", function()

			--== Book 1

			assert.is.equal( xml.book[1]:attribute('ISBN'):length(), 1 )
			assert.is.equal( xml.book[1]['@ISBN']:length(), 1 )

			assert.is.equal( xml.book[1]:attribute('missing'):length(), 0 )
			assert.is.equal( xml.book[1]['@missing']:length(), 0 )

			assert.is.equal( xml.book[1]:attribute('*'):length(), 1 )
			assert.is.equal( xml.book[1]:attributes():length(), 1 )

			--== Book 2

			assert.is.equal( xml.book[2]:attribute('ISBN'):length(), 1 )
			assert.is.equal( xml.book[2]['@ISBN']:length(), 1 )

			assert.is.equal( xml.book[2]:attribute('ISBN')[1]:toString(), '0865436401' )
			assert.is.equal( xml.book[2]['@ISBN'][1]:toString(), '0865436401' )

			assert.is.equal( xml.book[2]:attribute('publisher'):length(), 1 )
			assert.is.equal( xml.book[2]['@publisher']:length(), 1 )

			assert.is.equal( xml.book[2]:attribute('publisher'):toString(), 'Prentice Hall' )
			assert.is.equal( xml.book[2]['@publisher'][1]:toString(), 'Prentice Hall' )
			assert.is.equal( xml.book[2]:attribute('publisher')[1]:toXmlString(), 'publisher="Prentice Hall"' )
			assert.is.equal( xml.book[2]['@publisher'][1]:toXmlString(), 'publisher="Prentice Hall"' )

			assert.is.equal( xml.book[2]:attribute('missing'):length(), 0 )
			assert.is.equal( xml.book[2]['@missing']:length(), 0 )

			assert.is.equal( xml.book[2]:attribute('*'):length(), 2 )
			assert.is.equal( xml.book[2]:attributes():length(), 2 )

		end)

	end) -- Test: XML Node

end) -- lua_e4x.lua


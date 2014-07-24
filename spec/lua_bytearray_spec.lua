--[[
Tests for lua_bytearray.lua
--]]

package.path = './dmc_lua/?.lua;' .. package.path

local ByteArray = require 'lua_bytearray'
local File = require 'lua_files'
local Utils = require 'lua_utils'


describe( "Module Test: lua_bytearray.lua", function()

	describe("Reading bytes", function()

		local bin, byte

		setup( function()
			local data_file = './spec/bin/s-goog.bin'
			bin = File.readFile( data_file, { lines=false })

			byte = ByteArray:new()
			byte:setEndian( ByteArray.ENDIAN_BIG )
			byte:writeBuf( bin )
			byte:setPos( 1 )

		end)

		teardown( function()
		end)

		before_each( function()
		end)

		after_each( function()
		end)

		it( "Read Heartbeat", function()

			assert.is.equal( byte:readStringBytes(1), 'H' )
			assert.is.equal( byte:readStringBytes(1), 'T' )
			assert.is.equal( byte:readLong(), 1401726013968 )

		end)

		it( "Read Snapshop", function()

			local len, data

			assert.is.equal( byte:readStringBytes(1), 'N' )

			len = byte:readUShort()
			assert.is.equal( len, 3 )
			assert.is.equal( byte:readStringBytes(len), '100' )
			byte:setPos( byte:getPos()-5 )

			assert.is.equal( byte:readStringUShort(), '100' )

			len = byte:readInt()
			assert.is.equal( len, 15 )
			data = byte:readStringBytes(len)
			-- assert.is.equal( byte:readStringBytes(len), '' )

			-- data = byte:readStringBytes(1)
			-- Utils.hexDump(data)
			assert.is.equal( byte:readByte(), 0xFF )
			assert.is.equal( byte:readByte(), 0x0a )


		end)

		it( "ByteArray:setPos()", function()

			byte:setPos(1)
			byte:readStringBytes(1)
			byte:setPos(1)
			assert.is.equal( byte:readStringBytes(1), 'H' )

		end)

		it( "ByteArray:getAvailable()", function()

			local ba = ByteArray:new()
			ba:setEndian( ByteArray.ENDIAN_BIG )

			byte:setPos(1)
			byte:readBytes( ba, 1, 10 )
			ba:setPos(1)

			assert.is.equal( ba:readStringBytes(1), 'H' )
			assert.is.equal( ba:readStringBytes(1), 'T' )
			assert.is.equal( ba:readLong(), 1401726013968 )

			assert.is.equal( byte:getLen(), 364 )
			assert.is.equal( byte:getAvailable(), 354 )
			byte:setPos(1)
			assert.is.equal( byte:getAvailable(), 364 )

			assert.is.equal( ba:getLen(), 10 )
			assert.is.equal( ba:getAvailable(), 0 )
			ba:setPos(1)
			assert.is.equal( ba:getAvailable(), 10 )

		end)

	end)

end)




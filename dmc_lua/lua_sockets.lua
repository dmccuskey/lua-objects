--====================================================================--
-- lua_sockets.lua
--
--
-- by David McCuskey
-- Documentation: http://docs.davidmccuskey.com/display/docs/lua_sockets.lua
--====================================================================--

--[[

The MIT License (MIT)

Copyright (c) 2014 David McCuskey

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
-- DMC Lua Library : Sockets
--====================================================================--

-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--====================================================================--
-- Configuration

local DMC_SOCKETS_DEFAULTS = {
	check_reads=true,
	check_writes=false,
	throttle_level=math.floor( 1000/15 ), -- MEDIUM
}


--====================================================================--
-- Imports

local Objects = require 'lua_objects'
local socket = require 'socket'
local Utils = require 'lua_utils'

local tcp_socket = require 'lua_sockets.tcp'
local atcp_socket = require 'lua_sockets.async_tcp'



--====================================================================--
-- Setup, Constants

-- setup some aliases to make code cleaner
local inheritsFrom = Objects.inheritsFrom
local ObjectBase = Objects.ObjectBase

-- local control of development functionality
local LOCAL_DEBUG = false

local Singleton = nil



--====================================================================--
-- Sockets Class
--====================================================================--

local Sockets = inheritsFrom( ObjectBase )
Sockets.NAME = "Sockets Class"

Sockets.VERSION = VERSION

--== Class Constants

Sockets.NO_BLOCK = 0
Sockets.TCP = 'tcp'
Sockets.ATCP = 'atcp'

-- throttle socket checks, milliseconds delay
Sockets.OFF = 0
Sockets.LOW = math.floor( 1000/30 )  -- ie, 30 FPS
Sockets.MEDIUM = math.floor( 1000/15 )  -- ie, 15 FPS
Sockets.HIGH = math.floor( 1000/1 )  -- ie, 1 FPS

Sockets.DEFAULT = Sockets.MEDIUM



--====================================================================--
--== Start: Setup DMC Objects

function Sockets:_init( params )
	-- print( "Sockets:_init" )
	params = params or {}
	self:superCall( "_init", params )
	--==--

	--== Create Properties ==--

	self._sockets = {} -- socket objects, keyed by object
	self._raw_socks = {} -- socket objects, keyed by socket
	self._raw_socks_list = {} -- socket

	self._check_read = nil
	self._check_write = nil

	self._socket_check_is_active = false
	self._socket_check_handler = nil

	--== Object References ==--

	-- none

end
function Sockets:_undoInit()
	-- print( "Sockets:_undoInit" )

	self._sockets = nil
	self._raw_socks = nil
	self._raw_socks_list = nil

	--==--
	self:superCall( "_undoInit" )
end

function Sockets:_initComplete()
	-- print( "Sockets:_initComplete" )
	self:superCall( "_initComplete" )
	--==--

	-- initialize using setters
	self.check_reads = DMC_SOCKETS_DEFAULTS.check_reads
	self.check_writes = DMC_SOCKETS_DEFAULTS.check_writes

	if type( DMC_SOCKETS_DEFAULTS.throttle_level ) == 'number' then
		self.throttle = DMC_SOCKETS_DEFAULTS.throttle_level
	else
		self.throttle = Sockets.DEFAULT
	end

end
function Sockets:_undoInitComplete()
	-- print( "Sockets:_undoInitComplete" )

	self:_removeSockets()

	--==--
	self:superCall( "_undoInitComplete" )
end

--== END: Setup DMC Objects
--====================================================================--




--====================================================================--
--== Public Methods



function Sockets.__setters:throttle( value )
	-- print( 'Sockets.__setters:throttle', value )

	--== Sanity Check

	if type( value ) == 'string' then
		value = tonumber( value )
		if value == nil then value = Sockets.DEFAULT end
	elseif type( value ) ~= 'number' then
		value = Sockets.DEFAULT
	end

	local f

	if value == self.OFF then
		f = self:createCallback( self._checkConnections )
	else
		f = self:_createSocketCheckHandler( value )
	end

	-- using setter
	self._socketCheck_handler = f

end


-- whether to check socket read availability
--
function Sockets.__setters:check_reads( value )
	-- print( 'Sockets.__setters:check_reads', value )
	if value then
		self._check_read = self._raw_socks_list
	else
		self._check_read = nil
	end
end

-- whether to check socket write availability
--
function Sockets.__setters:check_writes( value )
	-- print( 'Sockets.__setters:check_writes', value )
	if value then
		self._check_write = self._raw_socks_list
	else
		self._check_write = nil
	end
end


function Sockets:create( s_type, params )
	-- print( 'Sockets:create', s_type, params )
	params = params or {}
	--==--

	if s_type == Sockets.TCP then
		return tcp_socket:new( { master=self } )

	elseif s_type == Sockets.ATCP then
		return atcp_socket:new( { master=self } )

	elseif s_type == Sockets.UDP then
		error( "UDP is not yet available" )

	else
		error( "Uknown socket type: %s" .. tostring( s_type ) )
	end

end




--====================================================================--
--== Private Methods



-- getter/setter: activate enterFrame for socket check
--
function Sockets.__getters:check_is_active()
	return self._socket_check_is_active
end

-- @param value boolean
function Sockets.__setters:check_is_active( value )
	-- print( 'Sockets.__setters:check_is_active', value )

	local f = self._socketCheck_handler

	if self._socket_check_is_active == value then return end

	if value == true and f then
		Runtime:addEventListener( 'enterFrame', f )
	elseif f then
		Runtime:removeEventListener( 'enterFrame', f )
	end

	self._socket_check_is_active = value

end


-- getter/setter: socket check handler function
function Sockets.__getters:_socketCheck_handler()
	return self._socket_check_handler
end

-- @param value function
function Sockets.__setters:_socketCheck_handler( func )

	if self.check_is_active then
		Runtime:removeEventListener( 'enterFrame', self._socket_check_handler )
		Runtime:addEventListener( 'enterFrame', func )
	end

	self._socket_check_handler = func

end


-- @param socket DMC TCP Socket
function Sockets:_connect( sock )
	-- print( 'Sockets:_connect', sock )
	self:_addSocket( sock )
end

-- @param socket DMC TCP Socket
function Sockets:_disconnect( sock )
	-- print( 'Sockets:_disconnect', sock )
	self:_removeSocket( sock )
end


-- TODO: check this
function Sockets:_removeSockets()
	-- print( "Sockets:_removeSockets" )

	for i = #self._sockets, 1, -1 do
		-- local s = table.remove( self._sockets, 1 )
		local s = self._sockets[ i ]
		self:_removeSocket( s )
	end

end


function Sockets:_addSocket( sock )
	-- print( "Sockets:_addSocket", sock )

	local raw_sock = sock._socket
	local key

	-- save TCP lookup
	key = tostring( sock )
	self._sockets[ key ] = sock

	-- save socket lookup
	key = tostring( raw_sock )
	self._raw_socks[ key ] = sock

	-- save raw socket in list
	table.insert( self._raw_socks_list, raw_sock )

	if #self._raw_socks_list then
		self.check_is_active = true
	end

end


function Sockets:_removeSocket( sock )
	-- print( "Sockets:_removeSocket", sock )

	local raw_sock = sock._socket
	local key

	Utils.removeFromTable( self._raw_socks_list, raw_sock )

	key = tostring( raw_sock )
	self._raw_socks[ key ] = nil

	key = tostring( sock )
	self._sockets[ key ] = nil

	if #self._raw_socks_list == 0 then
		self.check_is_active = false
	end

end


function Sockets:_checkConnections()
	-- print( "Sockets:_checkConnections" )

	local s_read, s_write, err = socket.select( self._check_read, self._check_write, Sockets.NO_BLOCK )

	if err ~= nil then return end

	for i, rs in ipairs( s_read ) do
		-- print( i, rs )
		local sock = self._raw_socks[ tostring( rs ) ]
		if sock then sock:_readStatus( 'ok' )
		else
			print( "ERROR IN SOCKET ")
		end
	end

	for i, rs in ipairs( s_write ) do
		-- print( i, rs )
		local sock = self._raw_socks[ tostring( rs ) ]
		sock:_writeStatus( 'ok' )
	end

end






--====================================================================--
--== Event Handlers



function Sockets:_createSocketCheckHandler( value )
	-- print("Sockets:_createSocketCheckHandler", value )
	local timeout = value
	local last_check = system.getTimer()

	local f = function( event )
		-- local current_time = system.getTimer()
		-- print( current_time, last_check, timeout )
			self:_checkConnections()

	end

	return f

end




--====================================================================--
--== Create Socket Class Singleton

local Singleton = Sockets:new()

return Singleton

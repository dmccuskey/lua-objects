--====================================================================--
-- lua_e4x.lua
--
--
-- by David McCuskey
-- Documentation: http://docs.davidmccuskey.com/display/docs/lua_e4x.lua
--====================================================================--

--[[

Copyright (C) 2014 David McCuskey. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in the
Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

--]]



--====================================================================--
-- DMC Lua Library : Lua E4X
--====================================================================--

-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
-- XML Classes
--====================================================================--


--====================================================================--
-- Setup, Constants

-- forward declare
local XmlBase, XmlList
local XmlDocNode, XmlDecNode, XmlNode, XmlTextNode, XmlAttrNode


--====================================================================--
-- Support Functions

local function createXmlList()
	return XmlList()
end


local function decodeXmlString(value)
	value = string.gsub(value, "&#x([%x]+)%;",
		function(h)
			return string.char(tonumber(h, 16))
		end)
	value = string.gsub(value, "&#([0-9]+)%;",
		function(h)
				return string.char(tonumber(h, 10))
		end)
	value = string.gsub(value, "&quot;", "\"")
	value = string.gsub(value, "&apos;", "'")
	value = string.gsub(value, "&gt;", ">")
	value = string.gsub(value, "&lt;", "<")
	value = string.gsub(value, "&amp;", "&")
	return value
end

-- local function encodeXmlString(value)
-- 	value = string.gsub(value, "&#x([%x]+)%;",
-- 		function(h)
-- 			return string.char(tonumber(h, 16))
-- 		end)
-- 	value = string.gsub(value, "&#([0-9]+)%;",
-- 		function(h)
-- 				return string.char(tonumber(h, 10))
-- 		end)
-- 	value = string.gsub(value, "&quot;", "\"")
-- 	value = string.gsub(value, "&apos;", "'")
-- 	value = string.gsub(value, "&gt;", ">")
-- 	value = string.gsub(value, "&lt;", "<")
-- 	value = string.gsub(value, "&amp;", "&")
-- 	return value
-- end



--====================================================================--
-- XML Setup

-- indexFunc()
-- override the normal Lua lookup functionality to allow
-- special lookup functionality
--
-- @param t object table
-- @param k key
--
local function indexFunc( t, k )
	-- print( "indexFunc", t, k )

	local o, val, f

	-- check if search for attribute with '@'
	if string.sub(k,1,1) == '@' then
		local attrs = rawget( t, '__attrs' )
		local _,_, name = string.find(k,'^@(.*)$')
		if attrs then
			for key, value in pairs( attrs ) do
				-- print( '>>', name, key, value )
				if key == name then
					val = value
					break
				end
			end
		end
	end
	if val ~= nil then return val end

	-- check for key directly on object
	val = rawget( t, k )
	if val ~= nil then return val end

	-- check OO hierarchy
	o = rawget( t, '__super' )
	if o then val = o[k] end
	if val ~= nil then return val end

	-- check for key in children
	local children = rawget( t, '__children' )
	if children then
		for i,node in ipairs( children ) do
			-- print( '>>', i,node, node:name())
			if node:name() == k then
				if val == nil then
					val = createXmlList()
				end
				val:addNode( node )
			end
		end
	end
	if val ~= nil then return val end

	return nil
end


local function toStringFunc( t )
	return t:toString()
end


local function bless( base, obj )
	-- print( "bless", base )
	local o = obj or {}
	local mt = {
		__index = indexFunc,
		__newindex = newindexFunc,
		-- __tostring = toStringFunc
	}
	if base and base.new and type(base.new)=='function' then
		-- print("adding call")
		mt.__call = base.new
	end

	setmetatable( o, mt )

	o.__super = base

	return o
end


local function inheritsFrom( base_class, options, constructor )

	local o

	o = bless( base_class )

	-- Return the class object of the instance
	function o:class()
		return o
	end

	-- Return the superclass object of the instance
	function o:superClass()
		return base_class
	end

	-- Return true if the caller is an instance of theClass
	function o:isa( the_class )

		local b_isa = false
		local cur_class = o

		while ( cur_class ~= nil ) and ( b_isa == false ) do
			if cur_class == the_class then
				b_isa = true
			else
				cur_class = cur_class:superClass()
			end
		end
		return b_isa
	end

	return o
end


--====================================================================--
-- XML Base

local XmlBase = inheritsFrom( nil )

function XmlBase:new( params )
	-- print("XmlBase:new")
	local o = self:_bless()
	if o._init then o:_init( params ) end
	return o
end
function XmlBase:_bless( obj )
	-- print("XmlBase:_bless")
	return bless( self, obj )
end


--====================================================================--
-- XML List

XmlList = inheritsFrom( XmlBase )

function XmlList:_init( params )
	-- print("XmlList:_init")
end
function XmlList:addNode( node )
	table.insert( self, node )
end


--====================================================================--
-- XML Declaration Node

XmlDecNode = inheritsFrom( XmlBase )

function XmlDecNode:_init( params )
	-- print("XmlDecNode:_init")
	params = params or {}

	self.__attrs = {}

end

function XmlDecNode:addAttribute( name, value )
	self.__attrs[ name ] = value
end


--====================================================================--
-- XML Node

XmlNode = inheritsFrom( XmlBase )

function XmlNode:_init( params )
	-- print("XmlNode:_init")
	params = params or {}

	self.__parent = params.parent
	self.__name = params.name
	self.__children = {}
	self.__attrs = {}

end


function XmlNode:addAttribute( name, value )
	self.__attrs[ name ] = value
end
function XmlNode:attribute( name )
	return self.__attrs[ name ]
end
function XmlNode:attributes()
	return self.__attrs
end


function XmlNode:hasSimpleContent()
	local is_simple = true
	local children = rawget( self, '__children' )
	for k,node in pairs( children ) do
		-- print(k,node)
		if node:isa( XmlNode ) then is_simple = false end
		if not is_simple then break end
	end
	return is_simple
end
function XmlNode:hasComplexContent()
	return not self:hasSimpleContent()
end


function XmlNode:name()
	return self.__name
end
function XmlNode:setName( value )
	self.__name = value
end


function XmlNode:addChild( node )
	table.insert( self.__children, node )
end
function XmlNode:child( value )
	-- print("XmlNode:child", self, value )
	local list

	for i, node in ipairs( self.__children ) do
		-- print(i,node:name())
		if node:name() == value then
			if list == nil then
				list = createXmlList()
			end
			list:addNode( node )
		end
	end

	return list
end
function XmlNode:children()
	return rawget( self, '__children' )
end


function XmlNode:toString()
	return self:_childrenContent()
end

function XmlNode:toXmlString()
	local str_t = {
		"<"..self.__name..">",
		self:_childrenContent(),
		"</"..self.__name..">",
	}
	return table.concat( str_t, '' )
end

function XmlNode:_childrenContent()
	local str_t = {}
	local children = rawget( self, '__children' )
	for k,node in pairs( children ) do
		if node:isa( XmlTextNode ) then
			table.insert( str_t, node:toString() )
		else
			table.insert( str_t, node:toXmlString() )
		end
	end
	return table.concat( str_t, '' )
end


--====================================================================--
-- XML Doc Node

XmlDocNode = inheritsFrom( XmlNode )

function XmlDocNode:_init( params )
	-- print("XmlDocNode:_init")
	params = params or {}
	XmlNode._init( self, params )

	self.declaration = params.declaration

end


--====================================================================--
-- XML Attribute Node

XmlAttrNode = inheritsFrom( XmlBase )


--====================================================================--
-- XML Text Node

XmlTextNode = inheritsFrom( XmlBase )

function XmlTextNode:_init( params )
	-- print("XmlTextNode:_init")
	params = params or {}

	self.__text = params.text or ""

end

function XmlTextNode:toString()
	return self.__text
end
function XmlTextNode:toXmlString()
	return self.__text
end


--====================================================================--
-- XML Parser
--====================================================================--


-- https://github.com/PeterHickman/plxml/blob/master/plxml.lua
-- https://developer.coronalabs.com/code/simple-xml-parser
-- https://github.com/Cluain/Lua-Simple-XML-Parser/blob/master/xmlSimple.lua
-- http://lua-users.org/wiki/LuaXml

local XmlParser = {}

XmlParser.XML_DECLARATION_RE = '<?xml (.-)?>'
XmlParser.XML_TAG_RE = '<(%/?)([%w:-]+)(.-)(%/?)>'
XmlParser.XML_ATTR_RE = "([%-_%w]+)=([\"'])(.-)%2"


function XmlParser:decodeXmlString(value)
	return decodeXmlString(value)
end


function XmlParser:parseAttributes( node, attr_str )
	string.gsub(attr_str, XmlParser.XML_ATTR_RE, function (w, _, a)
		node:addAttribute( w, self:decodeXmlString( a ) )
	end)
end


-- creates top-level Document Node
function XmlParser:parseString( xml_str )
	-- print( "XmlParser:parseString" )

	local root = XmlDocNode()
	local node
	local si, ei, close, label, attrs, empty
	local text, lval
	local pos = 1

	--== declaration

	si, ei, attrs = string.find(xml_str, XmlParser.XML_DECLARATION_RE, pos)

	if not si then
		-- error("no declaration")
	else
		node = XmlDecNode()
		self:parseAttributes( node, attrs )
		root.declaration = node
		pos = ei + 1
	end

	--== doc type
	-- pos = ei + 1

	--== document root element

	si,ei,close,label,attrs,empty = string.find(xml_str, XmlParser.XML_TAG_RE, pos)
	text = string.sub(xml_str, pos, si-1)
	if not string.find(text, "^%s*$") then
		root:addChild( XmlTextNode( {text=decodeXmlString(text)} ) )
	end

	pos = ei + 1

	if close == "" and empty == "" then -- start tag
		root:setName( label )
		self:parseAttributes( root, attrs )

		pos = self:_parseString( xml_str, root, pos )

	elseif empty == '/' then -- empty element tag
		root:setName( label )

	else
		error("malformed xml")

	end

	return root
end


-- recursive method
--
function XmlParser:_parseString( xml_str, xml_node, pos )
	-- print( "XmlParser:_parseString", xml_node:name(), pos )

	local si, ei, close, label, attrs, empty
	local node

	while true do

		si,ei,close,label,attrs,empty = string.find(xml_str, XmlParser.XML_TAG_RE, pos)
		if not si then break end

		local text = string.sub(xml_str, pos, si-1)
		if not string.find(text, "^%s*$") then
			xml_node:addChild( XmlTextNode( {text=decodeXmlString(text)} ) )
		end

		pos = ei + 1

		if close == "" and empty == "" then   -- start tag of doc
			local node = XmlNode( {name=label} )
			self:parseAttributes( node, attrs )
			xml_node:addChild( node )

			pos = self:_parseString( xml_str, node, pos )

		elseif empty == "/" then  -- empty element tag
			local node = XmlNode( {name=label} )
			self:parseAttributes( node, attrs )
			xml_node:addChild( node )

		else  -- end tag
			assert( xml_node:name() == label, "incorrect closing label" )
			break

		end

	end

	return pos
end


--====================================================================--
-- Lua E4X API
--====================================================================--

local function parse( xml_str )
	-- print("LuaE4X.parse")
	return XmlParser:parseString( xml_str )
end

local function load( file )
	print("LuaE4X.load")
end

local function save( xml_node )
	print("LuaE4X.save")
end



--====================================================================--
-- Lua E4X Facade
--====================================================================--

return {
	Parser=XmlParser,
	load=load,
	parse=parse,
	save=save
}

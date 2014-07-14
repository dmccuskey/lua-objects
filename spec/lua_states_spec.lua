--[[
Testing for lua_states
--]]

package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
-- Test: Lua States
--====================================================================--

-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"


--====================================================================--
-- Imports

local StatesMix = require 'lua_states'



--====================================================================--
-- Testing Setup
--====================================================================--


describe( "Module Test: lua_states.lua", function()

	local object

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()

		--== States Setup ==--

		object = {}
		StatesMix.mixin( object )

		--== State Constants

		object.STATE_INIT = 'state_init'
		object.STATE_ONE = 'state_one'
		object.STATE_TWO = 'state_two'
		object.STATE_THREE = 'state_three'
		object.STATE_MISSING = 'missing_method'

		--== State Machine

		function object:state_init( next_state, params )
			if next_state == self.STATE_ONE then
				self:do_state_one( params )
			elseif next_state == self.STATE_TWO then
				self:do_state_two( params )
			else
				error("incorrect transition")
			end
		end

		function object:do_state_one( params )
			self:setState( self.STATE_ONE )
		end
		function object:state_one( next_state, params )
			if next_state == self.STATE_TWO then
				self:do_state_two( params )
			elseif next_state == self.STATE_THREE then
				self:do_state_three( params )
			else
				error("incorrect transition")
			end
		end

		function object:do_state_two( params )
			self:setState( self.STATE_TWO )
		end
		function object:state_two( next_state, params )
			if next_state == self.STATE_ONE then
				self:do_state_one( params )
			elseif next_state == self.STATE_THREE then
				self:do_state_three( params )
			else
				error("incorrect transition")
			end
		end

		function object:do_state_three( params )
			self:setState( self.STATE_THREE )
		end
		function object:state_three( next_state, params )
			if next_state == self.STATE_ONE then
				self:do_state_one( params )
			elseif next_state == self.STATE_TWO then
				self:do_state_two( params )
			else
				error("incorrect transition")
			end
		end

	end)

	after_each( function()
		object = nil
	end)


	describe("Method: setState()/getState()", function()

		it( "set first state", function()
			object:setState( object.STATE_INIT )
			assert.are.equal( object:getState(), object.STATE_INIT )

			object:setState( object.STATE_ONE )
			assert.are.equal( object:getState(), object.STATE_ONE )

			object:setState( object.STATE_ONE )
			assert.are.equal( object:getState(), object.STATE_ONE )
			assert.are.equal( object:_stateStackSize(), 0 ) -- private method
		end)

		it( "initial state is ''", function()
			assert.are.equal( object:getState(), '' )
		end)

		it( "must have a state name", function()
			assert.has.errors( function() object:setState( nil ) end )
		end)
		it( "must have method for state name", function()
			assert.has.errors( function() object:setState( object.STATE_MISSING ) end )
		end)

	end)


	describe("Method: gotoState()", function()

		it( "transitions from one state to next", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )

			assert.are.equal( object:getState(), object.STATE_TWO )
			assert.are.equal( object:_stateStackSize(), 2 ) -- private method
		end)

		it( "transitions from one state to next", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_TWO )
			object:gotoState( object.STATE_ONE )

			assert.are.equal( object:getState(), object.STATE_ONE )
			assert.are.equal( object:_stateStackSize(), 2 ) -- private method
		end)

		it( "incorrect transition", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )

			--[[
			note: we wouldn't get this error if the above
			state diagram was changed
			--]]
			assert.has.errors( function() object:gotoState( object.STATE_INIT ) end )
		end)

		it( "has no initial state set", function()
			assert.has.errors( function() object:gotoState( object.STATE_ONE ) end )
		end)
		it( "must have a state name", function()
			object:setState( object.STATE_INIT )
			assert.has.errors( function() object:gotoState( nil ) end )
		end)
		it( "must have method for state name", function()
			object:setState( object.STATE_INIT )
			assert.has.errors( function() object:gotoState( object.STATE_MISSING ) end )
		end)

	end)


	describe("Method: getPreviousState()/gotoPreviousState()", function()

		it( "transitions from one state to next", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )

			assert.are.equal( object:getState(), object.STATE_TWO )
			assert.are.equal( object:_stateStackSize(), 2 ) -- private method
		end)

		it( "transitions from one state to next", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )

			assert.are.equal( object:getPreviousState(), object.STATE_ONE )
			assert.are.equal( object:_stateStackSize(), 2 ) -- private method

			object:gotoPreviousState()

			assert.are.equal( object:getState(), object.STATE_ONE )
			assert.are.equal( object:_stateStackSize(), 1 ) -- private method
		end)

		it( "incorrect transition", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )

			assert.are.equal( object:getState(), object.STATE_ONE )
			assert.are.equal( object:getPreviousState(), object.STATE_INIT )

			--[[
			note: we wouldn't get this error if the above
			state diagram was changed
			--]]
			assert.has.errors( function() object:gotoPreviousState() end )

			assert.are.equal( object:getState(), object.STATE_ONE )
		end)

		it( "has no previous state", function()
			object:setState( object.STATE_INIT )
			assert.has.errors( function() object:getPreviousState() end )
			assert.has.errors( function() object:gotoPreviousState() end )
		end)

	end)


	describe("Method: pushState()/popState()", function()

		it( "transitions from one state to next", function()
			object:setState( object.STATE_INIT )

			object:gotoState( object.STATE_ONE )
			object:pushStateStack( object.STATE_TWO )
			object:pushStateStack( object.STATE_THREE )

			assert.are.equal( object:getState(), object.STATE_ONE )
			assert.are.equal( object:getPreviousState(), object.STATE_THREE )
			assert.are.equal( object:_stateStackSize(), 3 ) -- private method

			object:gotoPreviousState()

			assert.are.equal( object:getState(), object.STATE_THREE )
			assert.are.equal( object:getPreviousState(), object.STATE_TWO )
			assert.are.equal( object:_stateStackSize(), 2 ) -- private method
		end)

	end)


	describe("Method: resetStates()", function()

		it( "resets all state information", function()
			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )

			object:resetStates()

			assert.are.equal( object:getState(), '' )
			assert.are.equal( object:_stateStackSize(), 0 ) -- private method
		end)

	end)


	describe("Method: setDebug()", function()

		it( "shows state output", function()
			object:setDebug( true )

			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )
			object:gotoPreviousState()

			object:resetStates()

			object:setDebug( false )

			object:setState( object.STATE_INIT )
			object:gotoState( object.STATE_ONE )
			object:gotoState( object.STATE_TWO )
			object:gotoPreviousState()

			object:resetStates()
		end)

	end)


end)

-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- Configuration file to globally control how Lua behaves
--[[
local function locals()
		local variables = {}
		local idx = 1
		while true do
			local ln, lv = debug.getlocal(2, idx)
			if ln ~= nil then
				variables[ln] = lv
			else
				break
			end
			idx = 1 + idx
		end
		return variables
	end 

local function upvalues()
		local variables = {}
		local idx = 1
		local func = debug.getinfo(2, "f").func
		while true do 
			local ln, lv = debug.getupvalue(func, idx)
			if ln ~= nil then
				variables[ln] = lv
			else
				break
			end
			idx = 1 + idx
		end
		return variables
	end 	
--]]	
--LOG("*AI DEBUG Local variables are "..locals() )	
--LOG("*AI DEBUG Upvalues are "..upvalues())

local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable

--====================================================================================
-- Disable the LuaPlus bit where you can add attributes to nil, numbers, and strings.
--------------------------------------------------------------------------------------
local function metacleanup(obj)
    local name = type(obj)
    mmt = {
        __newindex = function(table,key,value)
            error(string.format("Attempt to set attribute '%s' on %s", tostring(key), name), 2)
        end,
        #__index = function(table,key)
        #    error(string.format("Attempt to get attribute '%s' on %s", tostring(key), name), 2)
        #end
    }
    setmetatable(getmetatable(obj), mmt)
end

metacleanup(nil)
metacleanup(0)
metacleanup('')


--====================================================================================
-- Set up a metatable for coroutines (a.k.a. threads)
--------------------------------------------------------------------------------------
local thread_mt = {Destroy = KillThread}

thread_mt.__index = thread_mt

function thread_mt.__newindex(table,key,value)
    error('Attempt to set an attribute on a thread',2)
end

local function dummy() end

setmetatable(getmetatable(coroutine.create(dummy)),thread_mt)


--====================================================================================
-- Replace math.random with our custom random.  On the sim side, this is
-- a rng with consistent state across all clients.
--------------------------------------------------------------------------------------
if Random then
    math.random = Random
end


--====================================================================================
-- Give globals an __index() with an error function. This causes an error message
-- when a nonexistent global is accessed, instead of just quietly returning nil.
--------------------------------------------------------------------------------------
local globalsmeta = {
    __index = function(table, key)
        error("access to nonexistent global variable "..repr(key),2)
    end
}
setmetatable(_G, globalsmeta)


--====================================================================================
-- Check if an item is callable, ie not a variable. Returns the callable item,
-- otherwise returns nil
--------------------------------------------------------------------------------------
function iscallable(f)

	local type = type
	local getmetatable = getmetatable
	
    if type(f) == 'function' then
        return f
    end
	if type(f) == 'table' and getmetatable(f).__call then
		return f
	end	
	if type(f) == 'cfunction' then
		return f
	end

end

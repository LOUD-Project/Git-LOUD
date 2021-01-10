-- RAT:
-- This previously was (and still is) a collection of Lua implementations
-- of C# LINQ helper methods. Why they were in an OOP style and so
-- reliant on globals is unknown to me, but it was hard to read, pointless,
-- and wasted overhead on extra function calls, so now it's all pure functions.

local passthroughCondition = function(k,v) return true end

function Select(tab, callback)
	local result = {}
	for k,v in tab do
		if callback(k,v) then
			result[k] = callback(k,v)
		end
	end
	return result
end

function Where(tab, callback)
	local result = {}
	for k, v in tab do
		if callback(k, v) then
			table.insert(result, v)
		end
	end
	return result
end

function Contains(tab, value)
	for _, v in tab do
		if v == value then return true end
	end
	return false
end

function Distinct(tab)
	local result = {}
	for _, v in tab do
		if not Contains(result, v) then
			table.insert(result, v)
		end
	end
	return result
end

function All(tab, callback)
	for k, v in tab do
		if not callback(k,v) then
			return false
		end
	end
	return true
end

function First(tab, condition)
	for k, v in tab do
		if not condition or condition(k,v) then return v end
	end
	return nil
end

function Last(tab, condition)
	local l = nil
	for k, v in tab do
		if not condition or condition(k, v) then l = v end
	end
	return l
end

function Any(tab, condition)
	for k, v in tab do
		if not condition or condition(k, v) then return true end
	end
	return false
end

function Count(tab, condition)
	if not condition then condition = passthroughCondition end
	tab = Where(tab, condition)
	return table.getn(ToArray(tab))
end

function Average(tab, selector)
	local query = tab
	if selector then query = Select(query, selector) end
	local result = 0
	for _, v in query do
		result = result + v
	end
	return result / Count(query)
end

function Concat(tab1, tab2)
	local result = tab1.copy()
	for _, tv in tab2 do
		table.insert(result, tv)
	end
	return result
end

function RemoveByValue(tab, value)
	for k, v in ipairs(tab) do
		if v == value then
			table.remove(tab, k)
		end
	end
	LOG("Value not found: "..repr(tab))
end

function ToArray(tab)
	local result = {}
	for _, v in tab do
		table.insert(result, v)
	end
	return result
end
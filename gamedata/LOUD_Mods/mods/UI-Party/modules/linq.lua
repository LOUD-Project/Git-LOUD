local passthroughCondition = function(k,v) return true end
local passthroughSelector = function(k,v) return v end


_G.from = function(t)
	local self = {}
	
	self.t = t
	
	self.select = function(p) 
		local result = {}
		for k,v in self.t do
			if p(k,v) then
				result[k] = p(k,v)
			end
		end
		return from(result)
	end
	
	self.where = function(p)
		local result = from({})
		for k,v in self.t do
			if p(k,v) then
				result.addValue(v)
			end
		end
		return result
	end	
	
	self.distinct = function()
		local result = from({})
		for k,v in self.t do
			if not result.contains(v) then
				result.addValue(v)
			end
		end
		return result
	end
	
	
	self.all = function(p)
		for k,v in self.t do
			if not p(k,v) then
				return false
			end
		end
		return true
	end
	
	self.values = function()
		local result = {}
		for k,v in self.t do
			table.insert(result, v)
		end
		return from(result)
	end
	
	self.keys = function()
		local result = {}
		for k,v in self.t do
			table.insert(result, k)
		end
		return from(result)
	end
	
	self.first = function(condition)
		for k,v in self.t do
			if not condition or condition(k,v) then return v end
		end
		return nil
	end	
	
	self.last = function(condition)
		local l = nil
		for k,v in self.t do
			if not condition or condition(k,v) then l=v end
		end
		return l
	end	
	
	self.contains = function(value)
		for k,v in self.t do
			if v == value then return true end
		end
		return false
	end
	
	self.max = function(selector)
		local best = nil
		for k,v in self.t do
			if selector then v = selector(k, v) end
			if v > best then best = v end
		end
		return best
	end
	
	self.any = function(condition)
		for k,v in self.t do
			if not condition or condition(k,v) then return true end
		end
		return false
	end
	
	self.count = function(condition)
		if not condition then condition = passthroughCondition end
		return table.getn(self.where(condition).toArray())
	end
	
	self.foreach = function (action)
		for k,v in self.t do
			action(k,v)
		end
		return self --?
	end
		
	self.dump = function()
		LOG("-----")
		for k,v in self.t do
			LOG(k,v)
		end		
		LOG("-----")
		return self --?
	end
	
	self.sum = function(selector)
		local query = self		
		if selector then query = query.select(selector) end
		local result = 0
		query.foreach(function(k, v) result = result + v end)
		return result
	end
	
	self.avg = function(selector)
		local query = self		
		if selector then query = query.select(selector) end
		local result = 0
		query.foreach(function(k, v) result = result + v end)
		return result / query.count()
	end
	
	self.copy = function()
		local result = {}
		self.foreach(function(k,v) result[k] = v end)
		return from(result)
	end
	
	self.get = function(k)
		return t[k]
	end

	self.concat = function(t2)
		local result = self.copy()
		t2.foreach(function(tk, tv) 
			result.addValue(tv)
		end)
		return result
	end

	self.toArray = function()
		local result = {}
		for k,v in self.t do
			table.insert(result, v)
		end
		return result
	end
	
	self.addValue = function(v)
		table.insert(t, v)
	end

	self.addKeyValue = function(k, v)
		t[k] = v
	end

	self.removeKey = function(k)
		t[k] = nil
	end

	self.removeByKey = function(k)
		table.remove(t, k)
		return self
	end
	
	self.removeByValue = function(vToRemove)
		for k, v in ipairs(t) do
			if v == vToRemove then
				table.remove(t, k)
				return self
			end
		end
		LOG("value not found " .. tostring(vToRemove))
		return self
	end
	
	self.toDictionary = function() 
		return t
	end

	return self
end 


_G.range = function(startValue, endValue)
	local result = from({})
	local i = startValue
	local finished = false
	while not finished do
		result.addValue(i)
		i = i + 1
		finished = i >= endValue + 1
	end
	return result
end
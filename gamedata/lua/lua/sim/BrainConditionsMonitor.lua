--  File     :  /lua/sim/BrainConditionsMonitor.lua
--  Summary  : Monitors conditions for a brain and stores them in a keyed table

local LOUDINSERT = table.insert
local LOUDEQUAL = table.equal


local import = import
local type = type


function CreateConditionsMonitor(brain)

    local cMonitor = BrainConditionsMonitor()
    cMonitor:Create(brain)
    return cMonitor
end
    
BrainConditionsMonitor = Class {

    PreCreate = function(self)
       
        self.ConditionData = {}
		self.ResultTable = {}
		self.ResultTableCounter = 0
		
		self.Trash = TrashBag()
        
        self.ThreadWaitDuration = 15	-- default value
		
    end,

    Create = function(self, brain)
	
        self:PreCreate()

		-- start the Condition Monitor Thread
		self.Trash:Add(ForkThread( self.ConditionMonitorThread, self, brain))
		
    end,
	
	Destroy = function(self)
	
		self.Trash:Destroy()
		
    end,

    -- Find the key for a condition, add it to the table and check the condition
    GetConditionKey = function(self, cFilename, cFunctionName, cData)
        
        -- Add the record for the condition if not already there
        if not self.ConditionData[cFilename][cFunctionName] then
		
			-- Add the record for the Condition filename
			if not self.ConditionData[cFilename] then
				self.ConditionData[cFilename] = {}
			end
			
            self.ConditionData[cFilename][cFunctionName] = {}
        end
        
        -- Check if the cData matches up
        for _,data in self.ConditionData[cFilename][cFunctionName] do
		
			if LOUDEQUAL( self.ResultTable[data.Key].FunctionData, cData) then
				self.ResultTable[data.Key].Active = true
                return data.Key
			end
        end
        
        -- No match, so add the data to the table and return the key
        local newCondition
        
        if cFilename == '/lua/editor/UnitCountBuildConditions.lua' or cFilename == '/lua/editor/EconomyBuildConditions.lua' then
            newCondition = InstantImportCondition()
        else
            newCondition = ImportCondition()
        end

		newCondition:Create( self.Brain, self.ResultTableCounter + 1, cFilename, cFunctionName, cData)

		-- add it to the Result Table
		self.ResultTableCounter = self.ResultTableCounter + 1
        self.ResultTable[self.ResultTableCounter] = newCondition

		LOUDINSERT( self.ConditionData[cFilename][cFunctionName], { Key = newCondition.Key } )
		
        return newCondition.Key
		
    end,
	
    -- Thread that will monitor conditions the brain asks every ThreadWaitDuration period
	-- designed it to be dynamic in duration so that we keep checks at 2 per tick max
	-- and we add in some additional duration based upon number of players
    ConditionMonitorThread = function(self, aiBrain)
	
		-- record current game time
		aiBrain.CycleTime = GetGameTimeSeconds()
	
		WaitTicks(10)	-- wait a second before starting up --
		
		-- if time-limited game record victory time on the brain
		if ScenarioInfo.VictoryTime then
		
			aiBrain.VictoryTime = ScenarioInfo.VictoryTime
			
		else
		
			aiBrain.VictoryTime = false
			
		end
		
		LOG("*AI DEBUG "..aiBrain.Nickname.." VictoryTime is "..repr(aiBrain.VictoryTime))
		
		-- LocationType entries MUST ALWAYS be the first element so if it isnt we just
		-- return true since it must be a global condition		
		local function TestLocation( v )

			if type(v.FunctionData[1]) == 'string' then 
				
				if aiBrain.BuilderManagers[v.FunctionData[1]] then
					v.Status = true
					return true
				else
					v.Status = false
					return false
				end
			end

			return true
		end

        local WaitTicks = coroutine.yield
		local LOUDCEIL = math.ceil		

		local numChecks = self.ResultTableCounter
		local numResults = 0
		
		local checkrate = .1	 -- this makes the first pass very fast so CDR gets started
        
        local ResultTable = self.ResultTable

        local playerfactor = (self.Brain.Players or 1) * 4
		
		
        while true do
			
			-- record current game time
			aiBrain.CycleTime = GetGameTimeSeconds()

			-- the thread duration is always the number of conditions (minimum of 60 seconds)
			self.ThreadWaitDuration = math.max( LOUDCEIL((numChecks) / 10) + playerfactor, 60 )
			
			--LOG("*AI DEBUG "..aiBrain.Nickname.." Manager Thread Duration is "..self.ThreadWaitDuration)
			
			numChecks = 0
			numResults = 0
			
            for k,v in ResultTable do
			
				numChecks = numChecks + 1
				
				if ResultTable[k].Active then

					if TestLocation(v) then
						
						if not v.Instant then
						
							numResults = numResults + 1

							aiBrain.ConditionsMonitor.ResultTable[k].Status = v:CheckCondition(aiBrain)
							
							WaitTicks(checkrate)
						end
						
					else
						ResultTable[k].Active = false
						
						for a,b in self.ConditionData[v.Filename][v.FunctionName] do
						
							if k == b.Key then

								self.ConditionData[v.Filename][v.FunctionName][a] = nil
								aiBrain.ConditionsMonitor.ResultTable[k] = nil
								
								break
							end
						end
					end
				end
            end

			if ((self.ThreadWaitDuration * 10) - numChecks) > 0 then
			
				WaitTicks((self.ThreadWaitDuration * 10) - numResults)
				
			end
			
			checkrate = 1
			
        end
		
    end,
	
}



-- Here's where we create the Condition Class
-- which come in 3 sub-classes;
--   - Import Conditions
--   - Instant Import Conditions
--   - Function Conditions (disabled for now)
Condition = Class {

    Create = function( self, brain, key, filename, funcName, funcData)
	
        self.Status = false
        self.Key = key
		
		self.Active = true
        self.Filename = filename
        self.FunctionName = funcName
        self.FunctionData = funcData
		self.FunctionDataElements = table.getn(funcData)
		
    end,

	SetStatus = function(self,brain)
	
		
		if self.FunctionDataElements == 1 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1])
		elseif self.FunctionDataElements == 2 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2])
		elseif self.FunctionDataElements == 3 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3])
		elseif self.FunctionDataElements == 4 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3],self.FunctionData[4])
		elseif self.FunctionDataElements == 5 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3],self.FunctionData[4],self.FunctionData[5])
		elseif self.FunctionDataElements == 6 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3],self.FunctionData[4],self.FunctionData[5],self.FunctionData[6])
		elseif self.FunctionDataElements == 7 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3],self.FunctionData[4],self.FunctionData[5],self.FunctionData[6],self.FunctionData[7])
		elseif self.FunctionDataElements == 9 then
			self.Status = import(self.Filename)[self.FunctionName](brain, self.FunctionData[1],self.FunctionData[2],self.FunctionData[3],self.FunctionData[4],self.FunctionData[5],self.FunctionData[6],self.FunctionData[7],self.FunctionData[8],self.FunctionData[9])			
		else
			self.Status = import(self.Filename)[self.FunctionName](brain, unpack(self.FunctionData))
		end
	end,
}


--  Import Conditions are conditions which are semi-static in nature
--  they don't change often and only need to be evaluated once per cycle of the ConditionsMonitor
--  this makes them VERY efficient BUT not nearly as responsive as instant checks
ImportCondition = Class(Condition) {

    Create = function( self, brain, key, filename, funcName, funcData )
        Condition.Create( self, brain, key, filename, funcName, funcData )
    end,

    CheckCondition = function(self,aiBrain)
		Condition.SetStatus(self,aiBrain)
        return self.Status
    end,
	
    GetStatus = function(self)
        return self.Status
    end,
}

--  Instant Import Conditions are evaluated on the fly by the BuilderManagers (EM,FBM or PFM)
--  making them up to the minute responses BUT the cost of them adds up quickly
InstantImportCondition = Class(Condition) {
    
    Create = function( self, brain, key, filename, funcName, funcData )
        Condition.Create( self, brain, key, filename, funcName, funcData )
		self.Instant = true
    end,
    
    -- This class never checks the condition but if it does, it just returns the current status
    CheckCondition = function( self, aiBrain)
        return self.Status
    end,

    -- This class always performs the check when getting status (basically for stat checks)
    GetStatus = function( self, aiBrain)
		Condition.SetStatus( self, aiBrain)
		return self.Status
    end,
}

--[[
-- I have not seen a Function Condtion 
FunctionCondition = Class(Condition) {

    Create = function(self,brain,key,funcHandle,funcParams)
        Condition.Create(self,brain,key)
		self.Active = true
        self.FunctionHandle = funcHandle
        self.FunctionParameters = funcParams or {}
		
		self.Instant = true
    end,
    
    CheckCondition = function(self, aiBrain)
        self.Status = self.FunctionHandle( aiBrain, unpack(self.FunctionParameters) )
        return self.Status
    end,
	
	LocationExists = function(self)
	
		local found = false
		
		for k,v in self.FunctionParameters do
			if type(v) == 'string' and not ( v == 'Naval Area' or v == 'Expansion Area' or v == 'Large Expansion Area') then 
				if string.find(v, 'ARMY_') or string.find(v, 'MAIN') or string.find(v, 'Area') or string.find(v, 'Defensive Point') then
					found = true
					if self.Brain.BuilderManagers[v] then
						return true
					end
				end
			end
		end
		
		if not found then
			return true
		end
		
		self.Status = false
		return false
	end,
}
--]]
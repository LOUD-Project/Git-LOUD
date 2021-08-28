--  File     :  /lua/sim/BrainConditionsMonitor.lua
--  Summary  : Monitors conditions for a brain and stores them in a keyed table

local LOUDINSERT = table.insert
local LOUDEQUAL = table.equal
local LOUDGETN = table.getn


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
        
        self.ThreadWaitDuration = 40	-- starting value for first pass
		
    end,

    Create = function(self, brain)
	
        self:PreCreate()
		
		self.Brain = brain

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
        
        -- Check if the cData matches up to an existing function --
        for _,index in self.ConditionData[cFilename][cFunctionName] do
		
			if LOUDEQUAL( self.ResultTable[index].FunctionData, cData) then
            
				self.ResultTable[index].Active = true
                
                return index
			end
        end
        
        -- No match, so add the data to the table and return the new key
        local newCondition = ImportCondition()
        
        if cFilename == '/lua/editor/UnitCountBuildConditions.lua' or cFilename == '/lua/editor/EconomyBuildConditions.lua' then
            newCondition = InstantImportCondition()
        end

		self.ResultTableCounter = self.ResultTableCounter + 1

		newCondition:Create( self.Brain, self.ResultTableCounter, cFilename, cFunctionName, cData)

		-- add it to the Result Table
        self.ResultTable[self.ResultTableCounter] = newCondition

		LOUDINSERT( self.ConditionData[cFilename][cFunctionName], self.ResultTableCounter )
		
        return self.ResultTableCounter
		
    end,
	
    -- Thread that will monitor conditions the brain asks every ThreadWaitDuration period
	-- designed it to be dynamic in duration so that we keep checks at 2 per tick max
	-- and we add in some additional duration based upon number of players
    ConditionMonitorThread = function(self, aiBrain)

        local WaitTicks = coroutine.yield
		local LOUDCEIL = math.ceil
        local LOUDFLOOR = math.floor
        local LOUDMAX = math.max
        local type = type
	
		-- record current game time
		aiBrain.CycleTime = GetGameTimeSeconds()
	
		WaitTicks(11)	-- wait one second before starting up --
		
		-- if time-limited game record victory time on the brain
		if ScenarioInfo.VictoryTime then
		
			aiBrain.VictoryTime = ScenarioInfo.VictoryTime

		end
        
        local BM = aiBrain.BuilderManagers
	
		-- LocationType entries MUST ALWAYS be the first element so if it isnt we just
		-- return true since it must be a global condition		
		local function TestLocation( v )
		
			-- all location based conditions will always have more than 1 data element
			if v.FunctionDataElements > 1 then

				if type(v.FunctionData[1]) == 'string' then 
				
					if BM[v.FunctionData[1]].EngineerManager.Active then
						return true
					else
						return false
					end
				end
			end

			return true
		end

		local numChecks = self.ResultTableCounter
		local numResults = 0
		
		local checkrate = .1	 -- this makes the first pass very fast so CDR gets started
        
        local ResultTable = self.ResultTable

        -- adjustment for high player count comes into play when we can no longer maintain the minimum cycle time
        local playerfactor = LOUDGETN(ArmyBrains) * 5
        
        local minimumcycletime = 150     -- in ticks

        while true do
        
			-- record current game time
			aiBrain.CycleTime = GetGameTimeSeconds()
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." BCM cycles at "..aiBrain.CycleTime.." seconds")
            
            --local start = GetSystemTimeSecondsOnlyForProfileUse()

			-- the thread duration, in ticks, is always the number of checked conditions times 2
            -- plus a little extra slack based upon the number of brains + number of bases
			self.ThreadWaitDuration = LOUDMAX( LOUDCEIL( (numResults * 2)) + playerfactor + (aiBrain.NumBases * 5), minimumcycletime )
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." BCM Thread Duration for "..aiBrain.NumBases.." bases is "..self.ThreadWaitDuration.." ticks -- checkrate is every "..(checkrate).." ticks")

			numChecks = 0
			numResults = 0
			
            for k,v in ResultTable do
			
				numChecks = numChecks + 1
				
				if ResultTable[k].Active then

					if TestLocation(v) then
						
						if not v.Instant then
						
							numResults = numResults + 1

							aiBrain.ConditionsMonitor.ResultTable[k].Status = v:CheckCondition(aiBrain)
							
							WaitTicks(checkrate)    -- the real time is always 1 tick less
						end
						
					else
                    
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." Result Table "..k.." no longer active for "..repr(v.FunctionData[1]) )
                        
						ResultTable[k].Active = false
--[[
						for a,b in self.ConditionData[v.Filename][v.FunctionName] do
                        
                            --LOG("*AI DEBUG Reviewing Condition k is "..repr(k).." Key is "..repr(b))
						
							if k == b then
                            
 								self.ConditionData[v.Filename][v.FunctionName][a] = nil
								aiBrain.ConditionsMonitor.ResultTable[k] = nil
								
								break
							end
                            
						end
--]]                        
					end
                    
				end
                
            end
            
            --local final = GetSystemTimeSecondsOnlyForProfileUse()
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." BCM cycle time is "..final - start)

			if ( self.ThreadWaitDuration - (numResults * 2) ) > 0 then
            
                --LOG("*AI DEBUG "..aiBrain.Nickname.." BCM had "..numResults.." checks at "..(checkrate).." -- delays for "..(1 + self.ThreadWaitDuration) - (numResults * 2).." ticks")
            
				WaitTicks( (1 + self.ThreadWaitDuration) - (numResults * 2)  )
                
			end

            checkrate = LOUDFLOOR( (self.ThreadWaitDuration) / numResults ) + 1     -- we add the 1 tick lost to checkrate
            
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
		self.FunctionDataElements = LOUDGETN(funcData)
	
    end,

	SetStatus = function(self,brain)
    
        local elements = self.FunctionDataElements
        local filename = self.Filename
        local funcname = self.FunctionName
        local funcdata = self.FunctionData

		if elements == 1 then
			self.Status = import(filename)[funcname](brain, funcdata[1])
		elseif elements == 2 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2])
		elseif elements == 3 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3])
		elseif elements == 4 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3],funcdata[4])
		elseif elements == 5 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3],funcdata[4],funcdata[5])
		elseif elements == 6 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3],funcdata[4],funcdata[5],funcdata[6])
		elseif elements == 7 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3],funcdata[4],funcdata[5],funcdata[6],funcdata[7])
		elseif elements == 9 then
			self.Status = import(filename)[funcname](brain, funcdata[1],funcdata[2],funcdata[3],funcdata[4],funcdata[5],funcdata[6],funcdata[7],funcdata[8],funcdata[9])			
		else
			self.Status = import(filename)[funcname](brain, unpack(funcdata))
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

    CheckCondition = function( self,aiBrain )
		Condition.SetStatus( self, aiBrain)
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
    GetStatus = function( self, aiBrain )
		Condition.SetStatus( self, aiBrain )
		return self.Status
    end,
}

--[[
-- I have not seen a Function Condtion but we'll keep the code for reference 
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
--   /lua/sim/Builder.lua
--	Defines the BUILDER class which is the basic data class
--  in particular, units built by factories, combat and engineer platoons

-- Root builder class - common to all types of builders
-- Builder Spec
-- {
--        Priority = integer,
--        BuilderName = string,
--        BuilderType = string,
--        BuilderData = table,
--        BuilderConditions = list of functions that return true/false, list of args,  { < function>, {<args>}}
-- }

function CreateBuilder(brain, data, locationType, builderType)

    local builder = Builder()
	
    if builder:Create(brain, data, locationType, builderType) then
	
        return builder
		
    end
	
    return false
end


Builder = Class {

    Create = function(self, brain, data, locationType, builderType)
        
        self.Priority = data.Priority
		self.OldPriority = data.OldPriorty or false

        self.BuilderName = data.BuilderName
		self.BuilderType = builderType

		self.Location = locationType
        
        self:SetupBuilderConditions( brain, data, locationType)
        
        return true
		
    end,
	
    SetupBuilderConditions = function(self, aiBrain, data, locationType)

		self.BuilderConditions = {}
		
        if data.BuilderConditions then
		
			local counter = 0
		
            -- Convert location type here
            for k,v in data.BuilderConditions do

                local bCond = table.deepcopy(v)
				
                if type(bCond[1]) == 'function' then
				
                    for pNum,param in bCond[2] do
					
                        if param == 'LocationType' then
						
                            bCond[2][pNum] = locationType
							
                        end
						
                    end
					
                else
					-- some functions may not have any parameters
					if bCond[3] then
					
						for pNum,param in bCond[3] do
					
							if param == 'LocationType' then
							
								bCond[3][pNum] = locationType
								
							end
							
						end
						
					end
					
                end
				
				self.BuilderConditions[counter+1] = aiBrain.ConditionsMonitor:GetConditionKey( unpack(bCond) )
				counter = counter + 1
				
            end
			
        end
		
    end,
	
    SetPriority = function( builder, val, temporary)
	
        if temporary then
			
			if builder.Priority != 0 then
			
				builder.OldPriority = builder.Priority
				
			end

			builder.Priority = val
			builder.PriorityAltered = true
			
		else
		
			builder.OldPriority = val
			builder.Priority = val
			builder.PriorityAltered = false
			
		end
		
    end,
    
    ResetPriority = function(self, manager)
		
		if self.PriorityAltered and self.Priority != self.OldPriority then

			manager:SetBuilderPriority( self.BuilderName, self.OldPriority, false)
			
			self.PriorityAltered = false
			
		end
		
    end,
    
    CalculatePriority = function(self, builderManager)
	
        self.PriorityAltered = false
        
		if Builders[self.BuilderName].PriorityFunction then
		
			local newPri = false
			local temporary = true

			local newPri, temporary = Builders[self.BuilderName]:PriorityFunction(self.Brain)

			if newPri and newPri != self.Priority then
			
				LOG("*AI DEBUG "..self.BuilderName.." calculated")

				builderManager:SetBuilderPriority(self.BuilderName, newPri, temporary)
				
			end
			
		end
		
        return self.PriorityAltered
		
    end,
  
    GetBuilderData = function(self, locationType, builderData )

        local returnData = {}
		
        builderData = builderData or Builders[self.BuilderName].BuilderData
		
        for k,v in builderData do

            if type(v) == 'table' then
			
                returnData[k] = self:GetBuilderData(locationType, v )
				
            else
			
                if type(v) == 'string' and v == 'LocationType' then
				
                    returnData[k] = locationType
					
                else
				
                    returnData[k] = v
					
                end
				
            end
			
        end

        return returnData
		
    end,

    GetPlatoonTemplate = function(self)
	
        return Builders[self.BuilderName].PlatoonTemplate or false
		
    end,

}
	
--[[
    
    AdjustPriority = function(self, val)
        self.Priority = self.Priority + val
    end,
   
    GetBuilderType = function(self)
        return Builders[self.BuilderName].BuilderType
    end,
   
    GetBuilderName = function(self)
        return self.BuilderName
    end,
   
    GetPlatoonAIFunction = function(self)
        return Builders[self.BuilderName].PlatoonAIFunction or false
    end,
    
    GetPlatoonAddBehaviors = function(self)
        return Builders[self.BuilderName].PlatoonAddBehaviors or false
    end,
    
    GetPlatoonAddFunctions = function(self)
        return Builders[self.BuilderName].PlatoonAddFunctions or false
    end,
  
    GetPlatoonAddPlans = function(self)
        return Builders[self.BuilderName].PlatoonAddPlans or false
    end,

    GetPlatoonAIPlan = function(self)
        return Builders[self.BuilderName].PlatoonAIPlan or false
    end,

    VerifyDataName = function(self, valueName, data)
        if not data[valueName] and not data.BuilderName then
            error('*BUILDER ERROR: Invalid builder data missing: ' .. valueName .. ' - BuilderName not given')
            return false
        elseif not data[valueName] then
            error('*BUILDER ERROR: Invalid builder data missing: ' .. valueName .. ' - BuilderName given: ' .. data.BuilderName)
            return false
        end
        return true
    end,
    
--]]


------------------------
--- FACTORY BUILDERS ---
------------------------
FactoryBuilder = Class(Builder) {

    Create = function( self, brain, data, locationType )
	
		if not data.FactionIndex or data.FactionIndex == brain.FactionIndex then
		
			Builder.Create( self, brain, data, locationType )
			return true
			
		end
		
		return false
		
    end,    
}

function CreateFactoryBuilder(brain, data, locationType)

    local builder = FactoryBuilder()
	
    if builder:Create(brain, data, locationType) then
	
        return builder
		
    end
	
    return false
	
end

------------------------
--- PLATOON BUILDERS ---
------------------------
PlatoonBuilder = Class(Builder) {

    Create = function( builder, manager, brain, data, locationType)
	
		-- here is where I implement the faction specific platoon loading
		-- if the platoon spec has a FactionIndex tag then it's compared here	
		if not data.FactionIndex or data.FactionIndex == brain.FactionIndex then
	
			Builder.Create( builder, brain, data, locationType)
			
			builder.ManagerType = manager.ManagerType
		
			builder.InstanceCount = {}
			builder.InstancesAvailable = 0
		
			local num = 1
		
			while num <= ( data.InstanceCount or 1 ) do
			
				table.insert( builder.InstanceCount, { Status = 'Available', PlatoonHandle = false } )
				num = num + 1
				builder.InstancesAvailable = builder.InstancesAvailable + 1
				
			end
			
			return true
			
		else
		
			return false
			
		end
		
    end,
    
	-- OK - this is where the instances get used up -- and there is a small potential for
	-- two engineers to actually try and get the same instance -- which results in one of
	-- them succeeding while the other one just passes right thru here without setting anything
	
	-- The destroyedCallback is very important to this function - since it releases the instances used by platoons when they are formed
	StoreHandle = function( builder, platoon, manager, BuilderType )
	
        for k,v in builder.InstanceCount do
		
            if v.Status == 'Available' then
				
                v.Status = 'ActivePlatoon'
                v.PlatoonHandle = true
				
				platoon.BuilderName = builder.BuilderName
				platoon.BuilderType = BuilderType
				platoon.BuilderLocation = builder.Location
				platoon.BuilderManager = builder.ManagerType
				platoon.BuilderInstance = k
				
                local destroyedCallback = function( brain, platoon )
					
					local aiBrain = brain or platoon:GetBrain()
					
					local manager = 'PlatoonFormManager'
					
					if platoon.BuilderManager == 'EM' then
						manager = 'EngineerManager'
					end
					
					if platoon.BuilderManager == 'FBM' then
						manager = 'FactoryManager'
					end
					
					local buildertable = aiBrain.BuilderManagers[platoon.BuilderLocation][manager]['BuilderData'][platoon.BuilderType] or false
					
					if buildertable then
					
						for a,b in buildertable['Builders'] do
						
							if b.BuilderName == platoon.BuilderName then
							
								b.InstancesAvailable = b.InstancesAvailable + 1
								b.InstanceCount[platoon.BuilderInstance].PlatoonHandle = false
								b.InstanceCount[platoon.BuilderInstance].Status = 'Available'
								
								--LOG("*AI DEBUG "..aiBrain.Nickname.." resetting "..platoon.BuilderName.." instances to "..b.InstancesAvailable)
								
								break
								
							end
							
						end
						
					end
					
                end
				
				table.insert(platoon.EventCallbacks.OnDestroyed, destroyedCallback)

				builder.InstancesAvailable = builder.InstancesAvailable - 1

				return true
				
			end
			
        end

		return false
		
    end,
	
}


function CreatePlatoonBuilder( manager, brain, data, locationType)

    local builder = PlatoonBuilder()
	
    if builder:Create( manager, brain, data, locationType ) then
	
        return builder
		
    end
	
    return false
end

-------------------------
--- ENGINEER BUILDERS ---
-------------------------
-- this is the spec to have engineers perform specific tasks
EngineerBuilder = Class(PlatoonBuilder) {

    Create = function( self, manager, brain, data, locationType )
	
		-- here is where I implement the faction specific platoon loading
		-- if the platoon spec has a FactionIndex tag then it's compared here
		if not data.FactionIndex or data.FactionIndex == brain.FactionIndex then
		
			PlatoonBuilder.Create( self, manager, brain, data, locationType)
			
			return true
			
		else
		
			return false
			
		end
		
    end,
}

function CreateEngineerBuilder( manager, brain, data, locationType)

    local builder = EngineerBuilder()
	
    if builder:Create( manager, brain, data, locationType) then
	
        return builder
		
    end
	
    return false
	
end


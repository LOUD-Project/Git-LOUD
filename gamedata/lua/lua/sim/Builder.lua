--   /lua/sim/Builder.lua
--	Defines the BUILDER class which is a basic data class
--  think of builders as 'jobs to be done' - in particular, units built by factories, platoons for combat and jobs for engineers

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
        
        self.PriorityFunction = data.PriorityFunction or nil

        self.BuilderName = data.BuilderName
		self.BuilderType = builderType

        self.RTBLocation = data.RTBLocation or nil
        
        self:SetupBuilderConditions( brain, data, locationType)
        
        return true
		
    end,
	
    SetupBuilderConditions = function(self, aiBrain, data, locationType)

		self.BuilderConditions = {}
        
        local GetConditionKey = aiBrain.ConditionsMonitor.GetConditionKey
		
        if data.BuilderConditions then
        
            local LOUDDEEPCOPY = table.deepcopy
            local type = type
		
			local counter = 1
		
            -- Convert location type here
            for k,v in data.BuilderConditions do

                local bCond = LOUDDEEPCOPY(v)
				
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
				
				self.BuilderConditions[counter] = GetConditionKey( aiBrain.ConditionsMonitor, unpack(bCond) )
				counter = counter + 1
            end
        end
    end,
	
    SetPriority = function( builder, val, temporary)
    
        --if ScenarioInfo.PriorityDialog then
          --  LOG("*AI DEBUG "..builder.BuilderName.." Set to "..val.."  from "..builder.Priority.." temporary is "..repr(temporary).." on tick "..GetGameTick() )
        --end
	
        -- Priority changes are either temporary or permanent --
        if temporary then
			
            -- if there is an OLD Priority - then this builder is currently altered
            -- otherwise - store the current priority as the OLD priority
			if not builder.OldPriority then
			
				builder.OldPriority = builder.Priority
               
			end

            -- and change the current priority
			builder.Priority = val

		else
            
            -- this is a permanent change - so remove any OLD priority
            -- and change the current priority to the new value
			builder.OldPriority = nil
			builder.Priority = val

        end

    end,
    
    ResetPriority = function(self, manager)
    
        -- this is simple - return the priority of this job to it's original value
        -- and remove any indication of OLD Priority
        -- if there is NO OLD Priority this function does nothing
		if self.OldPriority then
		
			if ScenarioInfo.PriorityDialog then
				LOG("*AI DEBUG "..manager.ManagerType.." "..manager.LocationType.." "..self.BuilderName.." Reset to "..self.OldPriority.." on tick "..GetGameTick() )
			end

			manager:SetBuilderPriority( self.BuilderName, self.OldPriority, false)

            self.OldPriority = nil
            
		end

    end,

    GetBuilderData = function(self, locationType, builderData )

        local returnData = false
        local type = type
		
        builderData = builderData or Builders[self.BuilderName].BuilderData
		
        for k,v in builderData do

            if type(v) == 'table' then
            
                if not returnData then
                    returnData = {}
                end
			
                returnData[k] = self:GetBuilderData(locationType, v )
            else

                if not returnData then
                    returnData = {}
                end
			
                if type(v) == 'string' and v == 'LocationType' then
                    returnData[k] = locationType
                else
                    returnData[k] = v
                end
            end
        end

        if returnData then
            return returnData
        else
            return nil
        end
    end,

}

local BuilderCreate     = Builder.Create


------------------------
--- FACTORY BUILDERS ---
------------------------
FactoryBuilder = Class(Builder) {

    Create = function( self, brain, data, locationType )
	
		if not data.FactionIndex or data.FactionIndex == brain.FactionIndex then
		
			BuilderCreate( self, brain, data, locationType )
			return true
		end
		
		return false
    end,    
}

function CreateFactoryBuilder(brain, data, locationType)

    local builder = FactoryBuilder()
	
	if not builder then
		return false
	end
	
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
	
			BuilderCreate( builder, brain, data, locationType)

			builder.InstanceCount = {}
			builder.InstanceAvailable = 0
		
			local num = 1
		
			while num <= ( data.InstanceCount or 1 ) do
			
				builder.InstanceCount[num] = false
				num = num + 1
                
				builder.InstanceAvailable = builder.InstanceAvailable + 1
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

        local LOUDINSERT = table.insert
        local InstanceCount = builder.InstanceCount
	
        for k,v in InstanceCount do
		
            if not v then
				
                builder.InstanceCount[k] = true
				
				platoon.BuilderName = builder.BuilderName
				platoon.BuilderType = BuilderType
				platoon.BuilderLocation = manager.LocationType
				platoon.BuilderManager = manager.ManagerType
				platoon.BuilderInstance = k
				
                local destroyedCallback = function( brain, platoon )
					
					local aiBrain = brain or platoon:GetBrain()

                    local BuilderInstance = platoon.BuilderInstance
					local BuilderManager = platoon.BuilderManager
                    local BuilderName = platoon.BuilderName

					local manager = 'PlatoonFormManager'
					
					if BuilderManager == 'EM' then
						manager = 'EngineerManager'
					end
					
					if BuilderManager == 'FBM' then
						manager = 'FactoryManager'
					end
					
					local buildertable = aiBrain.BuilderManagers[platoon.BuilderLocation][manager]['BuilderData'][platoon.BuilderType]['Builders'] or false
					
					if buildertable then
					
						for a,b in buildertable do
						
							if b.BuilderName == BuilderName then
							
								b.InstanceAvailable = b.InstanceAvailable + 1
								b.InstanceCount[BuilderInstance] = false
								
								if ScenarioInfo.InstanceDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." resetting "..BuilderName.." instances to "..b.InstanceAvailable)
								end
								
								break
							end
						end
					end
                end
                
                if not platoon.EventCallbacks.OnDestroyed then
                    platoon.EventCallbacks.OnDestroyed = {}
                end
				
				LOUDINSERT(platoon.EventCallbacks.OnDestroyed, destroyedCallback)

				builder.InstanceAvailable = builder.InstanceAvailable - 1

				return true
			end
        end

		return false
    end,
	
}

local PlatoonBuilderCreate      = PlatoonBuilder.Create


function CreatePlatoonBuilder( manager, brain, data, locationType)

    local builder = PlatoonBuilder()
	
    if builder:Create( manager, brain, data, locationType ) then
        return builder
    end
	
    return false
end

-------------------------
--- ENGINEER BUILDERS ---
-- this is the spec to have engineers perform specific tasks
EngineerBuilder = Class(PlatoonBuilder) {

    Create = function( self, manager, brain, data, locationType )

		-- here is where I implement the faction specific platoon loading
		-- if the platoon spec has a FactionIndex tag then it's compared here
		if not data.FactionIndex or data.FactionIndex == brain.FactionIndex then
		
			PlatoonBuilderCreate( self, manager, brain, data, locationType)
			
			return true
		else
			return false
		end
    end,
}

function CreateEngineerBuilder( manager, brain, data, locationType)

    local builder = EngineerBuilder()

	if not builder then
		return false
	end
	
	local GetTemplateReplacement = import('/lua/ai/altaiutilities.lua').GetTemplateReplacement
	local Game = import('/lua/game.lua')

    local BuildStructures = data.BuilderData.Construction.BuildStructures		

	if BuildStructures then
    
        local LOUDCOPY = table.copy
        local LOUDINSERT = table.insert

        local FactionIndex = brain.FactionIndex
        local FactionName = brain.FactionName
		
		local fulltemplate = {}
		local datatemplate = {}

        local buildingTmpl = import('/lua/buildingtemplates.lua').BuildingTemplates[FactionIndex]
        local CustomUnits = ScenarioInfo.CustomUnits

		for k,v in BuildStructures do
			
			local template = {}
            local count = 0

			for _, id in buildingTmpl do
			
				if id[1] == v then
				
					local fog = id[2]
					
					if fog != nil and not Game.UnitRestricted( false, fog) then
                    
                        count = count + 1
                        template[count] = fog
                        
					end
                    
				end
                
			end
			
			local replacement = false
			
			if CustomUnits[v][FactionName] then
			
				replacement = GetTemplateReplacement( v, FactionName, CustomUnits[v][FactionName] )
				
				if replacement then
				
					local fog = replacement[1][2]
					
					if not Game.UnitRestricted( false, fog) then
                    
                        count = count + 1
						template[count] = fog
					end
				end
			end

			if not template[1] then
            
				--LOG("*AI DEBUG "..brain.Nickname.." id for "..repr(v).." in "..data.BuilderName.." is empty ")
                
			else
            
				LOUDINSERT( fulltemplate, template )
				LOUDINSERT( datatemplate, v )
                
			end
		end
		
		if not fulltemplate[1] then

			return false
            
		--else
			--LOG("*AI DEBUG IDs for "..repr(data.BuilderName).." are "..repr(fulltemplate) )
			--LOG("*AI DEBUG Data template will be "..repr(datatemplate))
		end	

		data.BuilderData.Construction.BuildStructures = LOUDCOPY(datatemplate)
	end
	
    if builder:Create( manager, brain, data, locationType) then
        return builder
    end
	
    return false
end


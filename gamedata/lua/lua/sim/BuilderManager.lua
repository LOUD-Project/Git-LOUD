--  /lua/sim/BuilderManager.lua
--  Manage builders

local CreateBuilder = import('/lua/sim/Builder.lua').CreateBuilder

local LOUDCOPY = table.copy
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove

local LOUDSORT = table.sort

local ForkThread = ForkThread
local ForkTo = ForkThread

local Random = Random

BuilderManager = Class {

    Create = function(self, brain)
	
        self.Trash = TrashBag()
        self.BuilderData = {}
        self.BuilderCheckInterval = 20

        self.Active = false
        self.NumBuilders = 0
		
    end,
    
    Destroy = function(self)
	
        for _,bType in self.BuilderData do
		
			for k,v in bType do
                v = nil
            end
        end

        self.Trash:Destroy()
    end,
    
    ForkThread = function(self, fn, ...)
	
        local thread = ForkThread(fn, self, unpack(arg))
        
		self.Trash:Add(thread)
    end,

    SetEnabled = function(self, brain, enable)

        if enable then

			self.Active = true		
			self:ForkThread( self.ManagerThread, brain)

        elseif not enable then

			self.Active = false		
			self.Trash:Destroy()
        end
	end,

    SortBuilderList = function(self, bType)

		if self.BuilderData[bType] then

			local oldtable = LOUDCOPY(self.BuilderData[bType].Builders)

			LOUDSORT(oldtable, function(a,b) return a.Priority > b.Priority end )

			self.BuilderData[bType].Builders = LOUDCOPY(oldtable)

			self.BuilderData[bType].NeedSort = false
		end
    end,

    AddBuilder = function(self, brain, builderData, locationType, builderType)

        local newBuilder = CreateBuilder(brain, builderData, locationType, builderType)

        self:AddInstancedBuilder(newBuilder, builderType, brain)
    end,
    
    AddInstancedBuilder = function(self, newBuilder, builderType, aiBrain)

        local BuilderType = builderType	or 'Any'
        
        -- not all bases support all builder types -- ie. FBM at naval base only supports Sea
        -- and likewise land bases don't support Sea -- this is particular mostly to the 
        -- FactoryBuilderManager - so look there for more information
        if self.BuilderData[BuilderType] then

            if newBuilder then
    
                LOUDINSERT( self.BuilderData[BuilderType].Builders, newBuilder )

                self.BuilderData[BuilderType].NeedSort = true

                self.NumBuilders = self.NumBuilders + 1
            end

            if newBuilder.InstantCheck then
                self:ManagerLoopBody(newBuilder)
            end
        end
		
    end,
    
    GetBuilderPriority = function(self, builderName)

        for _,bType in self.BuilderData do

            for _,builder in bType.Builders do

                if builder.BuilderName == builderName then
                    return builder.Priority
                end
            end
        end

        return false
    end,
    
    SetBuilderPriority = function( manager, builderName, priority, temporary )
	
        for k1,bType in manager.BuilderData do
		
            for k2,builder in bType.Builders do
			
                if builder.BuilderName == builderName then

					if builder.Priority != priority then
					
						builder:SetPriority(priority, temporary)

						if priority == 0 and not temporary then
							LOUDREMOVE( manager.BuilderData[k1].Builders, k2 )
						end
					
						manager.BuilderData[k1].NeedSort = true
					end
					
					return builder
                end
            end
        end
		
		return false
    end,

    AssignTimeout = function( self, builderName, timeoutticks )

		WaitTicks(2)	-- this allows platoon to disband first (which would possibly reset the builder to normal priority)

        local builder = self:SetBuilderPriority( builderName, 10, true ) -- set the builder to priority 10 temporarily

		local priority = self:GetBuilderPriority(builderName) -- retrieve that priority to make sure that it actually took since it's possible the builder may no longer exist
		
		if builder and priority then

			if timeoutticks then
				WaitTicks(timeoutticks)
			end

			builder:ResetPriority(self)
		end
    end,
	
    AddBuilderType = function(self, buildertype)
        self.BuilderData[buildertype] = { Builders = {}, NeedSort = true }
    end,
	

	-- loop thru all possible tasks for this type of builder (Engineer, Platoon or Factory) in priority sequence (high to low) at this location (self)
	-- The tasks are sorted from highest priority to lowest (except those which are set to zero at some point)
	-- ignore any job with a priority of 0
	-- the priority trigger is set by the first job that passes all checks and only jobs of the same priority will be considered after that
	-- jobs that pass all checks are added to the temporary table of possible jobs 
	-- stop looping once you encounter a job with a lower priority than that trigger (but not zero - those are ignored)
	-- and randomly return one of the possible jobs
    GetHighestBuilder = function( self, unit, aiBrain )
		
		-- use the BuilderParamCheck function specific to the Manager that called this function (ie. Engineer or Factory)
        local BuilderParamCheck = self.BuilderParamCheck		
		
        local found = false
        local possibleBuilders = {}
		local counter = 0
        local conditionschecked = 0
		
		local TaskList = self.BuilderData[unit.BuilderType].Builders or {}
        local ResultTable = aiBrain.ConditionsMonitor.ResultTable

		local continuesearching = true

		-- function that checks all the conditions of a builder
		-- only returns true if all conditions pass 
		local GetBuilderStatus = function( BuilderConditions )

			for _,value in BuilderConditions do

				if not ResultTable[value].Instant then
				
					if not ResultTable[value].Status then
						return false
					end
				else
                
                    conditionschecked = conditionschecked + 1

					if not ResultTable[value]:GetStatus(aiBrain) then
						return false
					end
				end
			end
			
			return true
		end
        
        local BuilderType = unit.BuilderType
        local ManagerType = self.ManagerType
        local PriorityDialog = ScenarioInfo.PriorityDialog

		-- sort the builders list if needed
		if self.BuilderData[BuilderType].NeedSort then
        
            --if PriorityDialog then
              --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." sorting "..BuilderType.." tasks")
            --end

			LOUDSORT( self.BuilderData[BuilderType].Builders, function(a,b) return a.Priority > b.Priority end )
--[[
            if PriorityDialog then
            
                if not self.BuilderData[BuilderType].displayed then
                
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." "..self.LocationType.." SORTED "..BuilderType.." Builders are ")
                    
                    for k,v in self.BuilderData[BuilderType].Builders do
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." "..v.BaseName.." "..v.Priority.." "..v.BuilderName)
                    end
                    
                    self.BuilderData[BuilderType].displayed = true
                end
            end
--]]
			self.BuilderData[BuilderType].NeedSort = false
        end
        
        local Priority, newPri, temporary

        for k,task in TaskList do
        
            conditionschecked = 0
            
            Priority = task.Priority
		
			if Priority > 100 and (task.InstanceAvailable > 0 or ManagerType == 'FBM') and continuesearching then
			
				-- if no task found yet or priority is the same as one we have already added - examine the task
                if (not found) or Priority >= found then

                    if GetBuilderStatus( task.BuilderConditions ) then

                        if BuilderParamCheck(self, task, unit) then
						
                            found = Priority
							counter = counter + 1
                            possibleBuilders[counter] = k

                        end
                    end
                    
                elseif found and Priority < found then
					continuesearching = false
                end
                
            else

				if task.Priority == 0 and not task.OldPriority then

					if PriorityDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." "..self.LocationType.." Removing "..repr(self.BuilderData[BuilderType].Builders[k].BuilderName) )
					end
					
					LOUDREMOVE(self.BuilderData[BuilderType].Builders,k)

					self.BuilderData[BuilderType].NeedSort = true
				end
			end
			
			if Builders[TaskList[k].BuilderName].PriorityFunction then

				newPri = false
				temporary = true
                
                --if PriorityDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." "..self.LocationType.." PriorityFunction for "..repr(self.BuilderData[BuilderType].Builders[k].BuilderName) )    
                --end
				
				newPri,temporary = Builders[TaskList[k].BuilderName]:PriorityFunction( aiBrain, unit )

				-- if the priority function reports a different priority than current priority
				if newPri and newPri != Priority and (task.InstanceAvailable > 0 or ManagerType == 'FBM') then
				
					if PriorityDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..ManagerType.." "..self.LocationType.." PriorityFunction for "..repr(self.BuilderData[BuilderType].Builders[k].BuilderName).." changes to "..newPri.." from "..Priority )
					end

					self.BuilderData[BuilderType].Builders[k]:SetPriority( newPri, temporary )
					
					self.BuilderData[BuilderType].NeedSort = true
				end
			end
        end

        if counter > 0 then 
			return TaskList[ possibleBuilders[ Random(1, counter) ] ]
        end
		
		if ManagerType == 'FBM' then
			unit.failedbuilds = unit.failedbuilds + 1
		end
		
        return false
    end,
	
	RebuildTable = function(self,oldtable)
	
		local temptable = {}
		local LOUDINSERT = table.insert
		local type = type
		
		for k,v in oldtable do
		
			if v != nil then
			
				if type(k) == 'string' then
				
					temptable[k] = v
				else
					LOUDINSERT(temptable, v)
				end
			end
		end
		
		return temptable
	end,
    
    ManagerLoopBody = function(self,builder,bType)
	
        if builder:CalculatePriority(self) then
		
            self.BuilderData[bType].NeedSort = true
        end
    end,
  
	-- originally this thread ran for each manager - but now just the PFM
	-- checks if the PFM builderlist needs to be resorted due to a priority change
	
	-- This thread is the core of the PFM -- cycles thru all the platoons as long as the manager is Active

	-- essentially, as more conditions must be checked (more bases) we slow the rate of platoon checking
	-- run the MAIN and any kind of PRIMARY base at twice the speed of the BCM (for responsiveness and that's where the units are likely to be)
    -- any other kind of base runs at half the speed (once every 2 BCM cycles)
    -- anytime any base has NO POOL - nothing will be checked and we simply delay by the length of the BCM cycle
    
    -- One huge difference in the PFM is that unlike the EM and the FM - if two tasks have equal priority
    -- and they both pass their status checks, the PFM will form them in alphabetical order
    
    ManagerThread = function(self, brain)

        local LOUDEQUAL = table.equal
		local LOUDFLOOR = math.floor
        local LOUDGETN = table.getn
        local LOUDSORT = table.sort
        local WaitTicks = coroutine.yield
       
        local ManagerLoopBody = self.ManagerLoopBody

		local duration = (self.BuilderCheckInterval) * 10
        local ticksize = 1
        
        local conditionscheckedcount = 0
        local conditioncounttotal = 0

		local tasks = self.NumBuilders
		
		local numTicks, numTested, numPassed
		
		local PoolGreaterAtLocation = import ('/lua/editor/UnitCountBuildConditions.lua').PoolGreaterAtLocation


		local GetBuilderStatus = function( BuilderConditions, ResultTable )

			for _,v in BuilderConditions do
            
                conditioncounttotal = conditioncounttotal + LOUDGETN(BuilderConditions)
			
				if not ResultTable[v].Instant then
				
					if not ResultTable[v].Status then
						return false
					end
					
				else
                    conditionscheckedcount = conditionscheckedcount + 1
                    
                    WaitTicks(1)
                    numTicks = numTicks + 1
				
					if not ResultTable[v]:GetStatus(brain) then
						return false
					end
					
				end
			end
		
			return true
		end		

        local LocationType = self.LocationType
        local BuilderManager = brain.BuilderManagers[LocationType]
        
        local PriorityDialog = ScenarioInfo.PriorityDialog
        
        while self.Active do
     
            -- if this is not a naval base - see if mode should change from Amphibious to Land
            if brain.AttackPlan.Goal and ( not self.LastGoalCheck or not LOUDEQUAL(self.LastGoalCheck, brain.AttackPlan.Goal) ) and BuilderManager.BaseType != 'Sea' then
        
                local path, reason, landpathlength, pathcost = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD( brain, 'AttackPlanner', 'Land', BuilderManager.Position, brain.AttackPlan.Goal, 999999, 160 )
                
                -- IDEALLY - we should evaluate both Land and Amphib paths and choose which is best - 
                -- but for now - we'll settle for land production if any kind of land connection exists --
                if path and not BuilderManager.LandMode then
                
                    brain.BuilderManagers[LocationType].LandMode = true

                else
                    if not path and BuilderManager.LandMode then
                    
                        brain.BuilderManagers[LocationType].LandMode = false

                    end
                end
                
                -- record the position of the the goal --
                self.LastGoalCheck = LOUDCOPY(brain.AttackPlan.Goal)
            end


			-- The PFM is the only manager truly affected by this since factories and engineers seek their own jobs
			-- Simply, the PFM at a Primary Base (or MAIN) runs at twice the speed of the Conditions Monitor
            -- other bases run at one/half the speed
			if LocationType == 'MAIN' or BuilderManager.PrimaryLandAttackBase or BuilderManager.PrimarySeaAttackBase then
			
				self.BuilderCheckInterval = brain.ConditionsMonitor.ThreadWaitDuration * .5
                
			else
			
				self.BuilderCheckInterval = brain.ConditionsMonitor.ThreadWaitDuration * 2
                
			end

            -- as we move the AI Mult up, we check the Builders more frequently
            -- this can simulate a greater degree of responsiveness
            -- self.BuilderCheckInterval = math.floor( self.BuilderCheckInterval / brain.VeterancyMult )

            -- and we set the delay between task checks accordingly
			if tasks != self.NumBuilders or ( self.BuilderCheckInterval != duration ) then
            
				duration = self.BuilderCheckInterval
				tasks = self.NumBuilders
				ticksize = LOUDFLOOR( duration / tasks )
                
			end

            numTicks = 1
			numTested = 0
			numPassed = 0
            
            conditionscheckedcount = 0
            conditioncounttotal = 0
    
            --if PriorityDialog then
              --  LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." Begins cycle at "..GetGameTimeSeconds().." seconds. Cycle will be "..(duration/10).." - BCM cycle is "..(brain.ConditionsMonitor.ThreadWaitDuration/10) )
            --end
			
            -- there must be units in the Pool or there will be nothing to form
			if PoolGreaterAtLocation( brain, LocationType, 0, categories.ALLUNITS - categories.ENGINEER ) then
		
                if self.BuilderData['Any'].NeedSort then
    
                    --if PriorityDialog then
                      --  LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." Sorting "..LOUDGETN(self.BuilderData['Any'].Builders).." -- Any -- PFM tasks")
                    --end

                    LOUDSORT( self.BuilderData['Any'].Builders, function(a,b) return a.Priority > b.Priority end )
                
                    self.BuilderData['Any'].NeedSort = false
                end
			
                -- loop thru all the platoon builders
				for bType,bTypeData in self.BuilderData do
                
                    --if ScenarioInfo.PlatoonDialog or PriorityDialog then
                      --  LOG("*AI DEBUG "..brain.Nickname.." PFM "..(LocationType).." Begins Processing "..repr(bType).." at "..repr(GetGameTimeSeconds()).." seconds using ticksize of "..ticksize.." between checks" )
                    --end
			
					for _,bData in bTypeData.Builders do

						if bData.Priority >= 100 and bData.InstanceAvailable > 0 then

							numTested = numTested + 1
						
							if GetBuilderStatus( bData.BuilderConditions, brain.ConditionsMonitor.ResultTable ) then

								ForkTo ( ManagerLoopBody, self, bData, bType, brain )
							
								numPassed = numPassed + 1
						
								WaitTicks(ticksize+1)
								numTicks = numTicks + ticksize
                                
                            end
						end
					end
				end

                --if PriorityDialog then
                  --  LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." processed "..numTested.." Builders - used "..numTicks.." ticks of "..duration.." - Formed "..numPassed ) 
                  --  LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." checked "..conditionscheckedcount.." of "..conditioncounttotal.." conditions this pass")
                --end
                
			else
                
                -- delay the next cycle by the length of the BCM cycle - with NO cheat multipliers
                duration = brain.ConditionsMonitor.ThreadWaitDuration

                if PriorityDialog then
                    LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." NO POOL UNITS - delaying "..duration ) 
                end

            end

			if numTicks < duration then

                --if PriorityDialog then
                  --  LOG("*AI DEBUG "..brain.Nickname.." "..self.ManagerType.." "..LocationType.." - delaying "..repr(((duration) - numTicks)/10).." seconds" ) 
                --end
            
				WaitTicks( duration - numTicks )

			end

            local ResetPFMTasks = import('/lua/loudutilities.lua').ResetPFMTasks

            -- reset the tasks with Priority Functions at this PFM
            ResetPFMTasks( self, brain )

        end
    end,
	
}

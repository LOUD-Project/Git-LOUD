--  /lua/sim/BuilderManager.lua
--  Manage builders

local CreateBuilder = import('/lua/sim/Builder.lua').CreateBuilder

local LOUDCOPY      = table.copy
local LOUDGETN      = table.getn
local LOUDINSERT    = table.insert
local LOUDREMOVE    = table.remove
local LOUDSORT      = table.sort

local ForkThread    = ForkThread
local ForkTo        = ForkThread

local Random = Random

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local WaitTicks = coroutine.yield

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

        TrashDestroy( self.Trash )
    end,
    
    ForkThread = function(self, fn, ...)
	
        local thread = ForkThread(fn, self, unpack(arg))
        
		TrashAdd( self.Trash, thread )
    end,

    SetEnabled = function(self, brain, enable)

        if enable then

			self.Active = true		
			self:ForkThread( self.ManagerThread, brain)

        elseif not enable then

			self.Active = false	
            
			TrashDestroy( self.Trash )
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
        
        self:SortBuilderList(builderType)
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

        if self.BuilderData then
        
            for _,bType in self.BuilderData do

                for _,builder in bType.Builders do

                    if builder.BuilderName == builderName then
                        return builder.Priority
                    end
                end
            end
        end

        return false
    end,
    
    SetBuilderPriority = function( manager, builderName, priority, temporary )

        if manager.BuilderData then

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
	

	-- loop thru all possible tasks for this type of builder (Engineer, Factory or Platoon) in priority sequence (high to low) at this location (self)
	-- completely ignore any task with a priority of 0 (they'll be removed) - process any task with a priority > 100 
    -- any task with a priority between 0 and 100 is basically 'parked' or idle  

	-- the priority trigger is set by the first task that passes all its checks and only tasks of the same priority will be considered after that
	-- tasks that pass all checks are added to the temporary table of possible tasks

	-- the loops ends once you encounter a task with a lower priority than that trigger (but not zero - those are ignored)
	-- and then one of the tasks in the possible tasks is randomly selected

    GetHighestBuilder = function( self, unit, aiBrain )
		
		-- use the BuilderParamCheck function specific to the Manager that called this function (ie. Engineer or Factory)
        local BuilderParamCheck = self.BuilderParamCheck		
		
        local found = false
        local possibleBuilders = {}
		local counter = 0
        local conditionschecked = 0

        local ResultTable = aiBrain.ConditionsMonitor.ResultTable

		local continuesearching = true
        
        local BuilderType       = unit.BuilderType
        local ManagerType       = self.ManagerType

        local PriorityDialog    = ScenarioInfo.PriorityDialog
        
        local LOUDSORT = LOUDSORT

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

        local RebuildTable = function(oldtable)

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
        end
        
		-- sort the builders list if needed
		if self.BuilderData[BuilderType].NeedSort then
        
            self.BuilderData[BuilderType].Builders = RebuildTable( self.BuilderData[BuilderType].Builders )
        
            if PriorityDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." sorting "..LOUDGETN(self.BuilderData[BuilderType].Builders).." tasks on tick "..GetGameTick() )
            end
    
			LOUDSORT( self.BuilderData[BuilderType].Builders, function(a,b) return a.Priority > b.Priority end )

            if PriorityDialog then
            
                if not self.BuilderData[BuilderType].displayed then
                
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." SORTED "..BuilderType.." Builders are ")
                    
                    --for k,v in self.BuilderData[BuilderType].Builders do
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." "..repr(v.Priority).." "..v.BuilderName)
                    --end
                    
                    self.BuilderData[BuilderType].displayed = true
                end
            end

			self.BuilderData[BuilderType].NeedSort = false
        end

		local TaskList = self.BuilderData[unit.BuilderType].Builders or {}        

        local Priority, newPri, temporary

        for k,task in TaskList do
        
            conditionschecked = 0
            
            TaskName = task.BuilderName
            Priority = task.Priority
			
            -- first step, process any PriorityFunction for this task

            -- if there is a new priority and it's not 0 then act on this task with it's new priority
            -- if the new priority is 0 - process it normally but this task will be removed on the next cycle
			if Builders[TaskName].PriorityFunction and Priority > 0 then
            
                --if PriorityDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." PriorityFunction review for "..Priority.." "..TaskName )
                --end

				newPri = false
				temporary = true

				newPri,temporary = Builders[TaskName]:PriorityFunction( aiBrain, unit, self )

				-- if the priority function reports a different priority than current priority
				if newPri and newPri != Priority and (task.InstanceAvailable > 0 or ManagerType == 'FBM') then
				
					if PriorityDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." PriorityFunction change for "..Priority.." "..TaskName.." to "..newPri.." on tick "..GetGameTick() )
					end

					self.BuilderData[BuilderType].Builders[k]:SetPriority( newPri, temporary )
					
					self.BuilderData[BuilderType].NeedSort = true
                    self.BuilderData[BuilderType].displayed = false
                    
                    if newPri != 0 then
                        Priority = newPri
                    end

                end
			end

            -- the continuesearching flag allows jobs to have their status checked and added to the list of possibles
            -- if we are not searching, we'll just process the remaining tasks and any PriorityFunctions
            -- and removing any tasks that may have been set to 0
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
                -- this task has been marked for removal (Priority == 0)
				if Priority == 0 and not task.OldPriority then

					if PriorityDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..ManagerType.." "..BuilderType.." Removing "..repr(TaskName) )
					end
					
                    self.BuilderData[BuilderType].Builders[k] = nil

					self.BuilderData[BuilderType].NeedSort = true
                    self.BuilderData[BuilderType].displayed = false
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
	
	RebuildTable = function(oldtable)
	
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
  
	-- originally this thread ran for each manager - but now just the PFM runs it
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
        local LOUDGETN  = LOUDGETN
        local LOUDSORT  = LOUDSORT
        local WaitTicks = WaitTicks
       
        local ManagerLoopBody = self.ManagerLoopBody

		local duration = (self.BuilderCheckInterval) * 10
        local ticksize = 1
        
        local conditionscheckedcount = 0
        local conditioncounttotal = 0

		local tasks = self.NumBuilders
		
		local numTicks, numTested, numPassed
		
		local PoolGreaterAtLocation         = import('/lua/editor/UnitCountBuildConditions.lua').PoolGreaterAtLocation
        local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD
        local ResetPFMTasks                 = import('/lua/loudutilities.lua').ResetPFMTasks
        
        local FREEUNITS = categories.ALLUNITS - categories.ENGINEER

		local GetBuilderStatus = function( BuilderConditions, ResultTable )
        
            local conditioncount = LOUDGETN(BuilderConditions)
            local WaitTicks = WaitTicks

			for _,v in BuilderConditions do
            
                conditioncounttotal = conditioncounttotal + conditioncount
			
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


        local BuilderData       = self.BuilderData
        local BuilderManager    = brain.BuilderManagers[self.LocationType]
        local LocationType      = self.LocationType
        local PriorityDialog    = ScenarioInfo.PriorityDialog

        local AttackPlan, landpathlength, path, pathcost, reason, ThreadWaitDuration
        
        local header = "*AI DEBUG "..brain.Nickname.." "..LocationType.." "..self.ManagerType
        
        while self.Active do
        
            PriorityDialog = ScenarioInfo.PriorityDialog or false
        
            AttackPlan = brain.AttackPlan
     
            -- if this is not a naval base - see if mode should change from Amphibious to Land
            if AttackPlan.Goal and ( not self.LastGoalCheck or not LOUDEQUAL(self.LastGoalCheck, AttackPlan.Goal) ) and BuilderManager.BaseType != 'Sea' then
        
                path, reason, landpathlength, pathcost = PlatoonGenerateSafePathToLOUD( brain, 'ManagerThreadAttackPlanner', 'Land', BuilderManager.Position, AttackPlan.Goal, 999999, 160 + (ScenarioInfo.IMAPSize/4) )
                
                -- IDEALLY - we should evaluate both Land and Amphib paths and choose which is best - 
                -- but for now - we'll settle for land production if any kind of land connection exists --
                if path and not BuilderManager.LandMode then
                    
                    --LOG( header.." finds Land path to Attack Plan Goal "..repr(AttackPlan.Goal).." - Land mode set to true")
                
                    brain.BuilderManagers[LocationType].LandMode = true

                else
                    if not path and BuilderManager.LandMode then
                    
                        --LOG( header.." finds NO LAND PATH to Attack Plan Goal "..repr(AttackPlan.Goal).." - Land mode set to false")
                    
                        brain.BuilderManagers[LocationType].LandMode = false

                    end
                end
                
                -- record the position of the the goal --
                self.LastGoalCheck = LOUDCOPY(brain.AttackPlan.Goal)
            end
            
            ThreadWaitDuration = brain.ConditionsMonitor.ThreadWaitDuration

			-- The PFM is the only manager truly affected by this since factories and engineers seek their own jobs
			-- Simply, the PFM at a Primary Base (or MAIN) runs at 2x the speed of the Conditions Monitor
            -- Production bases (factories) run at 1x the speed with a cycle of upto 75 seconds
            -- other bases run at 2/3 the speed but with a maximum cycle of 90 seconds
			if LocationType == 'MAIN' or BuilderManager.PrimaryLandAttackBase or BuilderManager.PrimarySeaAttackBase then
				self.BuilderCheckInterval = ThreadWaitDuration * .5
			else
                -- production bases run at 1x while others run at 2/3
                if brain.BuilderManagers[LocationType].CountedBase then
                    self.BuilderCheckInterval = math.min( ThreadWaitDuration * 1, 750 )
                else
                    self.BuilderCheckInterval = math.min( ThreadWaitDuration * 1.5, 900 )
                end
			end

            -- and we set the delay between task checks accordingly
			if tasks != self.NumBuilders or ( self.BuilderCheckInterval != duration ) then
            
				duration    = self.BuilderCheckInterval
				tasks       = self.NumBuilders
				ticksize    = math.max( 1, LOUDFLOOR( duration / tasks ))   -- ticksize must always be at least 1
			end

            numTicks = 1
			numTested = 0
			numPassed = 0
            
            conditionscheckedcount = 0
            conditioncounttotal = 0
    
            if PriorityDialog then
                LOG( header.." with "..self.NumBuilders.." tasks. Begins cycle at tick "..GetGameTick().." Cycle will be "..string.format("%d",duration).." - BCM cycle is "..string.format("%d",brain.ConditionsMonitor.ThreadWaitDuration) )
            end
			
            -- there must be units in the Pool or there will be nothing to form
			if PoolGreaterAtLocation( brain, LocationType, 0, FREEUNITS ) and brain:GetNoRushTicks() < 75 then
		
                if BuilderData['Any'].NeedSort then

                    if PriorityDialog then
                        LOG( header.." sorts tasks on tick "..GetGameTick() )
                    end

                    LOUDSORT( BuilderData['Any'].Builders, function(a,b) return a.Priority > b.Priority end )

                    BuilderData['Any'].NeedSort = false
                end
			
                -- loop thru all the platoon builders
				for bType,bTypeData in BuilderData do
                
                    if BuilderData['Any'].NeedSort then
                        break
                    end
                    
                    local Builders          = bTypeData.Builders
                    local ConditionResults  = brain.ConditionsMonitor.ResultTable

					for key,bData in Builders do

						if bData.Priority >= 100 and bData.InstanceAvailable > 0 then
                    
                            if PriorityDialog then
                                LOG( header.." examines "..repr(key).." "..repr(bData.Priority).." "..repr(bData.BuilderName).." on tick "..GetGameTick() )
                            end

							numTested = numTested + 1
						
							if GetBuilderStatus( bData.BuilderConditions, ConditionResults ) then

								ForkTo ( ManagerLoopBody, self, bData, bType, brain )
							
								numPassed = numPassed + 1
						
                                if ticksize + 1 >= 1 then
                                    WaitTicks(ticksize + 1)
                                    numTicks = numTicks + ticksize
                                end
                            end
						end
					end
				end

                --if PriorityDialog then
                  --  LOG( header.." processed "..numTested.." Builders - used "..numTicks.." ticks of "..duration.." - Formed "..numPassed ) 
                  --  LOG( header.." checked "..conditionscheckedcount.." of "..conditioncounttotal.." conditions this pass")
                --end
			else
                
                -- delay the next cycle by the length of the BCM cycle - with NO cheat multipliers
                duration = ThreadWaitDuration

                if PriorityDialog then
                    LOG( header.." NO POOL or RUSH TIMER - delaying "..duration.." on tick "..GetGameTick() ) 
                end
            end

			if numTicks < duration then

                --if PriorityDialog then
                  --  LOG( header.." - delaying "..string.format("%d", duration - numTicks).." ticks" ) 
                --end
            
				WaitTicks( duration - numTicks )
			end

            -- reset the tasks with Priority Functions at this PFM
            ResetPFMTasks( self, brain )

        end
    end,
	
}

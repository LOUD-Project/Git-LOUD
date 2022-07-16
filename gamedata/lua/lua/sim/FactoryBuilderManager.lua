--   /lua/sim/FactoryBuilderManager.lua

-- The Factory Builder Manager (FBM) is responsible for managing which builders (tasks) are available
-- whenever a factory goes looking for something to build

local import = import

local FactorySelfEnhanceThread = import('/lua/ai/aibehaviors.lua').FactorySelfEnhanceThread

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager

local AIGetClosestMarkerLocation = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation
local RandomLocation = import('/lua/ai/aiutilities.lua').RandomLocation

local CreateFactoryBuilder = import('/lua/sim/Builder.lua').CreateFactoryBuilder

local BuildPlatoon = moho.aibrain_methods.BuildPlatoon
local GetAIBrain = moho.unit_methods.GetAIBrain

local LOUDGETN  = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove

local LOUDENTITY = EntityCategoryContains

local EntityCategoryCount = EntityCategoryCount
local EntityCategoryFilterDown = EntityCategoryFilterDown
	
local IsIdleState = moho.unit_methods.IsIdleState
local IsUnitState = moho.unit_methods.IsUnitState

local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
	
local WaitTicks = coroutine.yield

local PlatoonTemplates = PlatoonTemplates

local FACTORY = categories.FACTORY * categories.STRUCTURE
local ENGINEER = categories.ENGINEER
local LAND = categories.LAND
local AIR = categories.AIR
local NAVAL = categories.NAVAL
local TRAFFICUNITS = categories.MOBILE - categories.EXPERIMENTAL - categories.AIR - categories.ENGINEER
	
function CreateFactoryBuilderManager(brain, lType, location, basetype)

    local fbm = FactoryBuilderManager()

    fbm:Create(brain, lType, location, basetype)

    fbm.BuilderCheckInterval = 40	-- default starting value

    return fbm
end


FactoryBuilderManager = Class(BuilderManager) {

	Create = function(self, brain, lType, location, basetype)
	
		BuilderManager.Create(self,brain)
		
		self.Active = true
		self.ChecksPerTick = 1
 		self.FactoryList = {}       
		self.Location = location
		self.LocationType = lType
		self.ManagerType = 'FBM'
		
		-- default for Land bases
		local builderTypes = { 'AirT1','AirT2','AirT3','LandT1','LandT2','LandT3','Gate' }
		
		-- for Naval bases
		if basetype == 'Sea' then
		
			builderTypes = { 'SeaT1','SeaT2','SeaT3' }
		end
		
		for _,v in builderTypes do
		
			self:AddBuilderType(v)
		end
	end,

	-- modified this process so we can specify multiple factory types (vs. All) to add builders for
	-- necessitated changing all the BuilderType entries into tables in the unit builder specs
	-- now we can avoid adding unworkable builders to the factories and make Gates more useful while
	-- avoiding adding land units to an air or naval factory for example
	AddBuilder = function(self, brain, builderData, locationType, builderType)
	
		local newBuilder = CreateFactoryBuilder( brain, builderData, locationType )
		
		if newBuilder then
			
			-- loop thru all the specified factory types for this builder
			for _,FactoryType in Builders[newBuilder.BuilderName].BuilderType do
		
				if FactoryType == 'All' then
				
					for k,v in self.BuilderData do
					
						self:AddInstancedBuilder(newBuilder, k, brain)
						
					end
					
				else
				
					self:AddInstancedBuilder( newBuilder, FactoryType, brain)
					
				end
				
			end
			
		end
		
		return newBuilder
		
	end,

	AddFactory = function( self, factory )

        while (not factory.Dead) and factory:GetFractionComplete() < 1 do
        
            LOG("*AI DEBUG Adding Factory 2 "..factory.Sync.id.." at "..factory:GetFractionComplete().." Dead is "..repr(factory.Dead).." to "..self.ManagerType.." "..self.LocationType)
            
            WaitTicks(100)
        end

		local LOUDENTITY = LOUDENTITY

		if not factory.Dead and not factory.BuildLevel then
			
			factory.failedbuilds = 0
			
			if LOUDENTITY( LAND * categories.TECH1, factory ) then
			
				factory.BuilderType = 'LandT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( LAND * categories.TECH2, factory ) then
			
				factory.BuilderType = 'LandT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( LAND * categories.TECH3, factory ) then
			
				factory.BuilderType = 'LandT3'
				factory.BuildLevel = 3
				
			elseif LOUDENTITY( AIR * categories.TECH1, factory ) then
			
				factory.BuilderType = 'AirT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( AIR * categories.TECH2, factory ) then
			
				factory.BuilderType = 'AirT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( AIR * categories.TECH3, factory ) then
			
				factory.BuilderType = 'AirT3'
				factory.BuildLevel = 3
				
			elseif LOUDENTITY( NAVAL * categories.TECH1, factory ) then
			
				factory.BuilderType = 'SeaT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( NAVAL * categories.TECH2, factory ) then
			
				factory.BuilderType = 'SeaT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( NAVAL * categories.TECH3, factory ) then
			
				factory.BuilderType = 'SeaT3'
				factory.BuildLevel = 3

			elseif LOUDENTITY( categories.GATE, factory ) then
			
				factory.BuilderType = 'Gate'
				factory.BuildLevel = 3
			end
			
            
			-- fired off when the factory completes an item (single or multiple units)
			local factoryWorkFinish = function( factory, finishedUnit, aiBrain )
			
				self:FactoryFinishBuilding(factory, finishedUnit)
			end

			factory:AddOnUnitBuiltCallback( factoryWorkFinish, categories.ALLUNITS )
			
			-- this section applies only to static factories - mobile factories dont need any of this
			if not LOUDENTITY( categories.MOBILE, factory) then
			
				factory.DesiresAssist = true		-- default factory to desire assist
				factory.NumAssistees = 3			-- default factory to 4 assistees			
			
				-- handles removal of the factory from the factory manager on death
				local factoryDestroyed = function( factory )
				
					self:FactoryDestroyed( factory )
				end

				factory:AddUnitCallback( factoryDestroyed, 'OnReclaimed')
				factory:AddUnitCallback( factoryDestroyed, 'OnCaptured')
				factory:AddUnitCallback( factoryDestroyed,'OnKilled')				
				
				ForkThread( self.SetRallyPoint, self, factory )
			
				LOUDINSERT(self.FactoryList, factory)

				ForkThread( self.DelayBuildOrder, self, factory )

			end
		end
	end,
    
    FactoryDestroyed = function(self, factory)
        
		if self then
		
			for k,v in self.FactoryList do
			
				if (not v.Sync.id) or v.Dead then
				
					LOUDREMOVE(self.FactoryList, k)

				end
                
			end

		end
        
    end,
    
    -- this is the function which actually finds and builds something
    -- a factory can pass a plan/behavior to a unit when its finished or
    -- run a function when the factory finishes its build queue
	-- as a result only one plan or behavior gets executed
    AssignBuildOrder = function( self, factory, aiBrain )
	
		if factory.Sync.id and not factory.Upgrading then

			local builder = self:GetHighestBuilder( factory, aiBrain )
		
			if builder then
            
                if ScenarioInfo.DisplayFactoryBuilds then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..factory.Sync.id.." building "..repr(builder.BuilderName))
                end
			
				local buildplatoon = self:GetFactoryTemplate( Builders[builder.BuilderName].PlatoonTemplate, factory, aiBrain.FactionName )
			
				if aiBrain:CanBuildPlatoon( buildplatoon, {factory} ) then

					factory.addplan = nil
					factory.addbehavior = nil
				
					factory.failedbuilds = 0
                    
                    -- we now will carry forward BuilderData from the builder definition and into the factory
                    -- we use the existing feature for platoons and engineers even though this is not really a platoon
                    -- just to keep the visibility of the mechanic high and neutral
                    -- this will normally just pass an empty table
                    factory.PlatoonData = builder:GetBuilderData(self.LocationType)

					local buildplatoonsqty = 1
                    
                    -- factory plans and behaviors are stored on the factory here
                    -- note how only ONE of each is supported at the moment
                    -- and they are only executed upon COMPLETION of the build
					if Builders[builder.BuilderName].PlatoonAddPlans then
				
						for _, papv in Builders[builder.BuilderName].PlatoonAddPlans do
					
							factory.addplan = papv
						end
					end

					if Builders[builder.BuilderName].PlatoonAddBehaviors then
				
						for _, papv in Builders[builder.BuilderName].PlatoonAddBehaviors do
					
							factory.addbehavior = papv
						end
					end
				
					if ScenarioInfo.DisplayFactoryBuilds then
				
						factory:SetCustomName(repr(builder.BuilderName))
					
						FloatingEntityText( factory.Sync.id, "Building "..repr(builder.BuilderName) )
					end

					aiBrain:BuildPlatoon( buildplatoon, {factory}, buildplatoonsqty )

                    -- unlike the Plans & Behaviors, we can execute multiple functions against the factory
                    -- also unlike the above, functions begin executing immediately
					if Builders[builder.BuilderName].PlatoonAddFunctions then
				
						for _, pafv in Builders[builder.BuilderName].PlatoonAddFunctions do

							ForkThread( import( pafv[1])[ pafv[2] ], aiBrain, factory, builder )
						end
					end
					
				else
					-- was originally going to set the priority to zero and have the job totally disabled but
					-- as I found from watching the log the for other reasons I cannot fathom - normal jobs just
					-- sometimes fail the CanBuildPlatoon function - so we'll set the priority to 10 and the 
					-- priority will return to normal on the next priority sort
					if ScenarioInfo.PriorityDialog or ScenarioInfo.DisplayFactoryBuilds then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..repr(factory.Sync.id).." unable to build "..repr(builder.BuilderName))
					end

                    -- if there was a build platoon but we failed anyway - assign a timeout
                    -- otherwise set the job priority to zero so it doesn't come up again
                    if buildplatoon then
                    
                        self:ForkThread( self.AssignTimeout, builder.BuilderName, 450 )
                    else
                    
                        builder:SetPriority( 0, false)
                    end
			
                    if ScenarioInfo.DisplayFactoryBuilds then
                        ForkThread(FloatingEntityText, factory.Sync.id, "Failed Job for "..factory.BuilderType )
                    end

					self.BuilderData[factory.BuilderType].NeedSort = true

					ForkThread( self.DelayBuildOrder, self, factory )
				end
				
			else
			
				if ScenarioInfo.DisplayFactoryBuilds then
					ForkThread(FloatingEntityText, factory.Sync.id, "No Job for "..factory.BuilderType )
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..repr(factory.Sync.id).." finds no job ")
				end
				
				factory.failedbuilds = factory.failedbuilds + 1

                ForkThread( self.DelayBuildOrder, self, factory )
			end
		end
	end,
    
	-- this keeps the factory from trying to build if the basic resources are not available (200M 2500E - varies by factory level - requirements are lower for low tier - but higher tier check more frequently )
	-- also waits for factory to be NOT busy (some units cause factory to pause after building)
	-- delays are dynamic - higher tier factories wait less while those enhancing wait more
    DelayBuildOrder = function( self, factory )

		if factory.Dead then
			return
		end
	
		local WaitTicks = WaitTicks

		local GetEconomyStored = GetEconomyStored
		local IsIdleState = IsIdleState
		local IsUnitState = IsUnitState
		
		local aiBrain = GetAIBrain(factory)

        -- this is the dynamic delay controlled - minimum delay is ALWAYS 2 --
        -- basically higher tier factories have less delay periods
        
		WaitTicks( (8 - (factory.BuildLevel * 2)) + (factory.failedbuilds * 10) )

		if factory.EnhanceThread or factory.Upgrading then
        
            if ScenarioInfo.DisplayFactoryBuilds then
                ForkThread(FloatingEntityText, factory.Sync.id, "Enhance/Upgrade Thread ")
            end
		
			WaitTicks(10)
		end
        
        -- the cheatvalue directly impacts the triggers --
        -- cheats above 1 lower the threshold making building more aggressive
        local masstrig = 200 * (1/ math.max(1, aiBrain.CheatValue))
        local enertrig = 2500 * (1/ math.max(1, aiBrain.CheatValue))

		while (not factory.Dead) and (not factory.Upgrading) and (( GetEconomyStored( aiBrain, 'MASS') < (masstrig - ( (3 - factory.BuildLevel) * 25)) or GetEconomyStored( aiBrain, 'ENERGY') < (enertrig - ( (3 - factory.BuildLevel) * 250))) or (IsUnitState(factory,'Upgrading') or IsUnitState(factory,'Enhancing')))  do
        
            if ScenarioInfo.DisplayFactoryBuilds then
                ForkThread(FloatingEntityText, factory.Sync.id, "Insufficient Resource")
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..repr(factory.Sync.id).." Insufficient resources -- delaying "..(23 - (factory.BuildLevel * 3)).." ticks")
            end
	
            -- higher tier factories check more frequently
			WaitTicks(23 - (factory.BuildLevel * 3))
		end
		
		if (not factory.Dead) and not (IsUnitState(factory,'Upgrading') or IsUnitState(factory,'Enhancing')) then
		
			while (not factory.Dead) and (not IsIdleState(factory)) do
			
				if not IsUnitState(factory,'Upgrading') and not factory.Upgrading then
				
					WaitTicks(10)
					
				else
				
					break
				end
			end
		
			if not factory.Dead and (not IsUnitState(factory,'Upgrading')) and (not factory.Upgrading) then
			
				ForkThread( self.AssignBuildOrder, self, factory, aiBrain )
			end
		end
    end,
    
	-- I learned something interesting here - when a factory gets upgraded, it is NOT removed from 
	-- the factory list by default - it simply has its Sync.id removed
	-- this made the original function give incorrect results - I rebuild the factory list
	-- in this function - and I added it to the AddUnit function
	GetNumFactories = function(self)

		local counter = 0
		local changed = false
        
		for k,v in self.FactoryList do
		
			if v.Sync.id then
			
               counter = counter + 1
			else

				LOUDREMOVE(self.FactoryList, k)
				changed = true
			end
		end
		
        if changed then

            LOG("*AI DEBUG Removed a factory factory - list is now "..repr(self.FactoryList))

		end

		return counter
	end,
    
--[[    
	GetNumCategoryFactories = function(self, category)
	
		return EntityCategoryCount( category, self.FactoryList ) or 0
	end,
    
	GetNumCategoryBeingBuilt = function(self, category, facCategory )

		local counter = 0
	
		for _,v in EntityCategoryFilterDown( facCategory, self.FactoryList ) do
		
			if v.Dead then
			
				continue
			end
            
			if not v:IsUnitState('Upgrading') and not v:IsUnitState('Building') then
			
				continue
			end
            
			local beingBuiltUnit = v.UnitBeingBuilt	
			
			if not beingBuiltUnit or beingBuiltUnit.Dead then
			
				continue
			end
            
			if not LOUDENTITY( category, beingBuiltUnit ) then
			
				continue
			end
            
			counter = counter + 1
		end
		
		return counter
	end,
--]]   
 
	GetFactoriesBuildingCategory = function(self, category, facCategory )
	
		local units = {}
		local counter = 0
	
		for _,v in EntityCategoryFilterDown( facCategory, self.FactoryList ) do
		
			if v.Dead then
			
				continue
			end
            
			if not IsUnitState( v, 'Upgrading' ) and not IsUnitState( v, 'Building' ) then
			
				continue
			end
            
			local beingBuiltUnit = v.UnitBeingBuilt	
			
			if not beingBuiltUnit or beingBuiltUnit.Dead then
			
				continue
			end
            
			if not LOUDENTITY( category, beingBuiltUnit ) then
			
				continue
			end

			counter = counter + 1            
			units[counter] = v

		end

		return units
	end,
    
	GetFactoriesWantingAssistance = function(self, category, facCatgory )
		
		local units = {}
		local counter = 0
		
		for _,v in self.GetFactoriesBuildingCategory( self, category, facCatgory ) do
		
			if v.DesiresAssist == false then
			
               continue
			end
            
			if v.NumAssistees and LOUDGETN( v:GetGuards() ) >= v.NumAssistees then
			
				continue
			end 
            
			counter = counter + 1            
			units[counter] = v

		end
        
       return units
    end,
	
	-- this is fired when a factory completes a build order
	-- not necessarily a single unit - in the case that platoon template specified more than 1 unit
	-- some specfic tasks are performed here for engineers, factory upgrades or air transports
    FactoryFinishBuilding = function( self, factory, finishedUnit )

		local aiBrain = GetAIBrain(factory)
		
		local LOUDENTITY = EntityCategoryContains
		
		if ScenarioInfo.DisplayFactoryBuilds then
		
			factory:SetCustomName("")
		end

        if LOUDENTITY( ENGINEER, finishedUnit ) then
		
			local EM = aiBrain.BuilderManagers[self.LocationType].EngineerManager

            EM:ForkThread( EM.AddEngineerUnit, finishedUnit )
		end

		if factory.addplan then
			finishedUnit:ForkThread( import('/lua/ai/aibehaviors.lua')[factory.addplan], aiBrain )
		end
		
		if factory.addbehavior then
			finishedUnit:ForkThread( import('/lua/ai/aibehaviors.lua')[factory.addbehavior], aiBrain )
		end
		
        -- note how we check for BuildLevel to insure that factory has not already been added
        -- this event was somehow misfiring - sometimes causing the factory to go thru being
        -- added twice - and putting a 2nd OnUnitBuilt callback onto the factory - which would
        -- cause the factory to go looking for 2 jobs whenever something was built
        if LOUDENTITY( FACTORY, finishedUnit ) and not finishedUnit.BuildLevel then

			if finishedUnit:GetFractionComplete() == 1 then

				ForkThread( self.AddFactory, self, finishedUnit )
                
                finishedUnit:LaunchUpgradeThread( aiBrain )

				if not finishedUnit.EnhanceThread and __blueprints[finishedUnit.BlueprintID].Enhancements.Sequence then
				
					finishedUnit.EnhanceThread = finishedUnit:ForkThread( FactorySelfEnhanceThread, aiBrain.FactionIndex, aiBrain, self)
				end				

				factory.Dead = true

				factory.Trash:Destroy()
				
				return self:FactoryDestroyed(factory)
			end
		end
		
		if not factory.Dead then
		
			if LOUDGETN(factory:GetCommandQueue()) <= 1 then
		
				factory.addplan = nil
				factory.addbehavior = nil

				ForkThread( self.DelayBuildOrder, self, factory )
			
				if not factory.UpgradesComplete then
				
					if not factory.UpgradeThread then
					
                        factory:LaunchUpgradeThread( aiBrain )
					end
				end
				
				if not factory.EnhancementsComplete then
				
					if not factory.EnhanceThread and __blueprints[factory.BlueprintID].Enhancements.Sequence then
					
						factory.EnhanceThread = factory:ForkThread( FactorySelfEnhanceThread, aiBrain.FactionIndex, aiBrain, self)
					end
				end
			end
		end
    end,
    
	-- this function starts with a raw template - ie. T3Engineer and fills it in with the actual unit ID - ie. url0105
	-- and the other parameters (min qty, max qty, squad and formation) required to fill out the template
	-- this is also where custom units come into play
	GetFactoryTemplate = function( self, templateName, factory, faction)

		local customData = ScenarioInfo.CustomUnits[templateName][faction] or false

        local template = false
		
		local Random = Random
		
		local LOUDINSERT = table.insert
		
		-- Get Custom Replacement - allows the factory to select 3rd party units from mods
		-- the original stock unit is one of the possible items to 
		-- be selected but only if no replacement is set to 100%
		local function GetCustomReplacement( template )

			local possibles = {}
			local counter = 0
			
			-- if the random number is lower than the replacment units setting then insert it into the list of possibles
			for _,v in customData do
			
				if Random(1,100) <= v[2] then

					counter = counter + 1				
					possibles[counter] = v[1]

				end
				
			end
            
            if not template then
                template = { 'none', 1, 1, 'attack', 'none' }
            end

			if counter > 0 then
				return { possibles[Random(1,counter)], template[2], template[3], template[4], template[5] }
			end

			return false
			
		end
		
		if faction and PlatoonTemplates[templateName].FactionSquads[faction] then
		
			-- this is here to insure that IF there are replacments we only replace
			-- the FIRST unit in those cases where a template may have multiple units specified (ie.- a platoon of units)
			local replacementdone = false
            
            -- sometimes the stock unit template is empty
            --local tablesize = LOUDGETN(PlatoonTemplates[templateName].FactionSquads[faction])
            
            if PlatoonTemplates[templateName].FactionSquads[faction][1] then
		
                for _,v in PlatoonTemplates[templateName].FactionSquads[faction] do
			
                    if customData and (not replacementdone) then

                        local replacement = GetCustomReplacement( v )
					
                        -- if a replacement is selected (by %) then it will fill the template otherwise stock will be used
                        if replacement then
					
                            if not template then
                                template = { PlatoonTemplates[templateName].Name, '', }
                            end
                        
                            LOUDINSERT( template, replacement )
                            replacementdone = true -- keeps us from replacing anything but the first unit in a template
						
                        else
                    
                            if not template then
                                template = { PlatoonTemplates[templateName].Name, '', }
                            end 
                        
                            LOUDINSERT( template, v )
						
                        end
					
                    else
                
                        if not template then
                            template = { PlatoonTemplates[templateName].Name, '', }
                        end
				
                        LOUDINSERT( template, v )
                    end
                end
                
            else
            
                if customData and (not replacementdone) then
                
                    local replacement = GetCustomReplacement()
					
                    -- if a replacement is selected (by %) then it will fill the template otherwise stock will be used
                    if replacement then
					
                        if not template then
                            template = { PlatoonTemplates[templateName].Name, '', }
                        end
                        
                        LOUDINSERT( template, replacement )
                        replacementdone = true -- keeps us from replacing anything but the first unit in a template

                    end
                end
            end
           
			
		elseif faction and customData then

			local replacement = GetCustomReplacement( PlatoonTemplates[templateName].FactionSquads[1] )
			
			if replacement then
			
				LOUDINSERT( template, replacement )
			end
		end
		
        if not template then
        
            WARN("*AI DEBUG Template "..repr(templateName).." for "..repr(faction).." is empty "..repr(PlatoonTemplates[templateName].FactionSquads[faction]))
        end
        
		return template
	end,
	
	-- as with the BuilderParamCheck in the EM, we no longer need most of these checks
	-- since we control the jobs presented to the factories in advance 
    BuilderParamCheck = function( self, builder, factory )
		
		if factory.Upgrading or IsUnitState( factory, 'Upgrading' ) then
		
			return false
		end
		
		return true
    end,
    
	-- one of the LOUD features - AI no longer relies upon placement of Rally Point markers - makes his own when he starts a base
	-- function will find the closest rally point marker and make that it's rally point  -- and initiate a traffic control thread
    SetRallyPoint = function(self, factory)

		WaitTicks(20)	
		
		if not factory.Dead then

			local position = factory.CachePosition
			
			local rally = false
		
			local rallyType = 'Rally Point'
		
			if LOUDENTITY( NAVAL, factory ) then
			
				rallyType = 'Naval Rally Point'
			end
        
			rally = AIGetClosestMarkerLocation( self, rallyType, position[1], position[3] )

			if not rally or VDist3( rally, position ) > 100 then
			
				position = RandomLocation(position[1],position[3])
				rally = position
			end
        
			IssueClearFactoryCommands( {factory} )
			
			IssueFactoryRallyPoint({factory}, rally)
		
			factory:ForkThread(self.TrafficControlThread, position, rally)
		end
    end,

	-- thread runs as long as the factory is alive and monitors the units at that
	-- factory rally point - ordering them into formation if they are not in a platoon
	-- this helps alleviate traffic issues and 'stuck' unit problems
	TrafficControlThread = function(factory, factoryposition, rally)
        
        local IsIdleState = IsIdleState
        local LOUDINSERT = LOUDINSERT
        local LOUDGETN = LOUDGETN
        local WaitTicks = WaitTicks
        
		WaitTicks(30)
	
		local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
		
		local category = TRAFFICUNITS
		
		local rallypoint = { rally[1],rally[2],rally[3] }
		local factorypoint = { factoryposition[1], factoryposition[2], factoryposition[3] }
		
		local Direction = import('/lua/utilities.lua').GetDirectionInDegrees( rallypoint, factorypoint )

		if Direction < 45 then
		
			Direction = 0		-- South
			
		elseif Direction < 135 then
		
			Direction = 90		-- East
			
		elseif Direction < 225 then
		
			Direction = 180		-- North
			
		else
		
			Direction = 270		-- West
		end

		local aiBrain = GetAIBrain(factory)
        
        local unitlist, units
		
		while true do

			WaitTicks(900)
			
			units = GetOwnUnitsAroundPoint( aiBrain, category, rallypoint, 16)
			
			if LOUDGETN(units) > 10 then
			
				unitlist = {}
				
				for _,unit in units do
				
					if (unit.PlatoonHandle == aiBrain.ArmyPool) and IsIdleState(unit) then

						LOUDINSERT( unitlist, unit )
					end
				end
				
				if LOUDGETN(unitlist) > 10 then

					IssueClearCommands( unitlist )

					IssueFormMove( unitlist, rallypoint, 'BlockFormation', Direction )
				end
			end
		end
	end,
	
}
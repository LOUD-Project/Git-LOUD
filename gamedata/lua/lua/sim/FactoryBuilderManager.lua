--   /lua/sim/FactoryBuilderManager.lua

-- The Factory Builder Manager (FBM) is responsible for managing which builders (tasks) are available
-- whenever a factory goes looking for something to build

local import = import

local AIBehaviors                   = import('/lua/ai/aibehaviors.lua')
local FactorySelfEnhanceThread      = AIBehaviors.FactorySelfEnhanceThread

local AIGetClosestMarkerLocation    = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation
local GetOwnUnitsAroundPoint        = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
local RandomLocation                = import('/lua/ai/aiutilities.lua').RandomLocation

local CreateFactoryBuilder          = import('/lua/sim/Builder.lua').CreateFactoryBuilder

local BuilderManager                = import('/lua/sim/BuilderManager.lua').BuilderManager

local Direction                     = import('/lua/utilities.lua').GetDirectionInDegrees

local BuildPlatoon              = moho.aibrain_methods.BuildPlatoon
local GetEconomyStored          = moho.aibrain_methods.GetEconomyStored

local GetFractionComplete       = moho.entity_methods.GetFractionComplete

local GetAIBrain        = moho.unit_methods.GetAIBrain
local IsIdleState       = moho.unit_methods.IsIdleState
local IsUnitState       = moho.unit_methods.IsUnitState

local EntityCategoryCount       = EntityCategoryCount
local EntityCategoryFilterDown  = EntityCategoryFilterDown
local LOUDENTITY                = EntityCategoryContains
local LOUDFLOOR                 = math.floor
local LOUDGETN                  = table.getn
local LOUDINSERT                = table.insert
local LOUDMAX                   = math.max
local LOUDMIN                   = math.min
local LOUDREMOVE                = table.remove
local WaitTicks                 = coroutine.yield

local PlatoonTemplates = PlatoonTemplates

local FACTORY       = categories.FACTORY * categories.STRUCTURE
local ENGINEER      = categories.ENGINEER
local LAND          = categories.LAND
local AIR           = categories.AIR
local NAVAL         = categories.NAVAL
local TRAFFICUNITS  = categories.MOBILE - categories.EXPERIMENTAL - categories.AIR - categories.ENGINEER
	
function CreateFactoryBuilderManager(brain, lType, location, basetype)

    local fbm = FactoryBuilderManager()

    fbm:Create(brain, lType, location, basetype)

    fbm.BuilderCheckInterval = 40	-- default starting value

    return fbm
end

function MassTrigger(factory, scale, adjacencyReduction)
	if LOUDENTITY(LAND, factory) then
    	return 300 * scale * adjacencyReduction
	end
		
	if LOUDENTITY(AIR, factory) then
    	return 200 * scale * adjacencyReduction
	end
	
	if LOUDENTITY(NAVAL, factory) then
		return 500 * scale * adjacencyReduction
	end

	if LOUDENTITY(categories.GATE, factory) then
		return 2500
	end

	return 100
end

function EnergyTrigger(factory, scale, adjacencyReduction)
	if LOUDENTITY(LAND, factory) then
    	return 500 * scale * adjacencyReduction
	end
		
	if LOUDENTITY(AIR, factory) then
    	return 2800 * scale * adjacencyReduction
	end
	
	if LOUDENTITY(NAVAL, factory) then
		return 4500 * scale * adjacencyReduction
	end

	if LOUDENTITY(categories.GATE, factory) then
		return 30000
	end

	return 1000
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

	AddFactory = function( self, factory, aiBrain )

        while (not factory.Dead) and GetFractionComplete(factory) < 1 do
        
            LOG("*AI DEBUG "..aiBrain.Nickname.." Adding Factory 2 "..factory.EntityID.." at "..GetFractionComplete(factory).." Dead is "..repr(factory.Dead).." to "..self.ManagerType.." "..self.LocationType)
            
            WaitTicks(100)
        end

		local LOUDENTITY = LOUDENTITY

		if not factory.Dead and not factory.BuildLevel then
			
			factory.failedbuilds = 0
            factory.LocationType = self.LocationType
			
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

            if ScenarioInfo.DisplayFactoryBuilds then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..factory.BuilderType.." Factory "..factory.EntityID.." added.  Level "..factory.BuildLevel )
            end
            
			-- fired off when the factory completes an item (single or multiple units)
			local factoryWorkFinish = function( factory, finishedUnit, aiBrain )
			
				self:FactoryFinishBuilding(factory, finishedUnit)
			end

			factory:AddOnUnitBuiltCallback( factoryWorkFinish, categories.ALLUNITS )
			
			-- this section applies only to static factories - mobile factories dont need any of this
			if not LOUDENTITY( categories.MOBILE, factory) then
			
				factory.DesiresAssist = true		-- default factory to desire assist
				factory.NumAssistees = 3			-- default factory to 3 assistees			
			
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

            -- sort the factory tasks any time we add a new factory
			self.BuilderData[factory.BuilderType].NeedSort = true

		end
        
	end,
    
    FactoryDestroyed = function(self, factory)
        
		if self then
		
			for k,v in self.FactoryList do
			
				if (not v.EntityID) or v.Dead then
				
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
	
		if factory.EntityID and not factory.Upgrading then

			local builder = self:GetHighestBuilder( factory, aiBrain )
            local DisplayFactoryBuilds = ScenarioInfo.DisplayFactoryBuilds
            local PriorityDialog = ScenarioInfo.PriorityDialog
		
			if builder then
            
                local BuilderName = builder.BuilderName
                local BuildersData = Builders[BuilderName]
                
                local PlatoonAddPlans           = BuildersData.PlatoonAddPlans
                local PlatoonAddBehaviors       = BuildersData.PlatoonAddBehaviors
                local PlatoonAddFunctions       = BuildersData.PlatoonAddFunctions
            
                if DisplayFactoryBuilds then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..factory.EntityID.." building "..repr(builder.BuilderName).." on tick "..GetGameTick() )
                end
			
				local buildplatoon = self:GetFactoryTemplate( BuildersData.PlatoonTemplate, factory, aiBrain.FactionName )
			
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
					if PlatoonAddPlans then
				
						for _, papv in PlatoonAddPlans do
					
							factory.addplan = papv
						end
					end

					if PlatoonAddBehaviors then
				
						for _, papv in PlatoonAddBehaviors do
					
							factory.addbehavior = papv
						end
					end
				
					if DisplayFactoryBuilds then
						factory:SetCustomName(repr(BuilderName))
					end

					aiBrain:BuildPlatoon( buildplatoon, {factory}, buildplatoonsqty )

                    -- unlike the Plans & Behaviors, we can execute multiple functions against the factory
                    -- also unlike the above, functions begin executing immediately
					if PlatoonAddFunctions then
				
						for _, pafv in PlatoonAddFunctions do

							ForkThread( import( pafv[1])[ pafv[2] ], aiBrain, factory, builder )
						end
                        
					end
					
				else
					-- was originally going to set the priority to zero and have the job totally disabled but
					-- as I found from watching the log the for other reasons I cannot fathom - normal jobs just
					-- sometimes fail the CanBuildPlatoon function - so we'll set the priority to 10 and the 
					-- priority will return to normal on the next priority sort
					if PriorityDialog or DisplayFactoryBuilds then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Factory "..repr(factory.EntityID).." unable to build "..repr(BuilderName))
					end

                    -- if there was a build platoon but we failed anyway - assign a timeout
                    -- otherwise set the job priority to zero so it doesn't come up again
                    if buildplatoon then
                        self:ForkThread( self.AssignTimeout, BuilderName, 450 )
                    else
                        builder:SetPriority( 0, false)
                    end
			
                    if DisplayFactoryBuilds then
                        factory:SetCustomName("Fail Job "..repr(BuilderName) )
                    end

					self.BuilderData[factory.BuilderType].NeedSort = true

					ForkThread( self.DelayBuildOrder, self, factory )
				end
				
			else
				
				factory.failedbuilds = factory.failedbuilds + 1
			
				if DisplayFactoryBuilds then
					factory:SetCustomName("No Job "..factory.failedbuilds.." for "..factory.BuilderType)
				end

                ForkThread( self.DelayBuildOrder, self, factory )
			end
		end
	end,
    
	-- this keeps the factory from trying to build if the basic resources are not available (200M 2250E - varies by factory level - requirements are lower for low tier - but higher tier check more frequently )
	-- also waits for factory to be NOT busy (some units cause factory to pause after building)
	-- delays are dynamic - higher tier factories wait less while those enhancing wait more
    DelayBuildOrder = function( self, factory )

		if factory.Dead then
			return
		end
        
        local DisplayFactoryBuilds = ScenarioInfo.DisplayFactoryBuilds

		local GetEconomyStored  = GetEconomyStored
		local IsIdleState       = IsIdleState
		local IsUnitState       = IsUnitState
        local WaitTicks         = WaitTicks
		
		local aiBrain       = GetAIBrain(factory)
        local BuildLevel    = factory.BuildLevel
        local Upgrading     = factory.Upgrading

        -- this is the dynamic delay controlled - minimum delay is ALWAYS 2 --
        -- basically higher tier factories have less delay periods
        -- those with adjacency bonuses may have even less delay
        -- this initial delay is NOT impacted by adjacency bonuses - only the BuildLevel of the factory
		WaitTicks( (8 - (BuildLevel * 2)) + (factory.failedbuilds * 10) )

		if factory.EnhanceThread or Upgrading then
        
            if DisplayFactoryBuilds then
                ForkThread(FloatingEntityText, factory.EntityID, "Enhance Thread")
            end
		
			WaitTicks(10)
		end
        
        -- the cheatvalues directly impact the resource triggers --
        -- cheats above 1 lower the threshold making building more aggressive
        -- more advanced factories require higher trigger amounts
        local adjacencyreductionE = 1
        local adjacencyreductionM = 1
        local adjacencyaverage = 1

        adjacencyreductionE = LOUDMIN(1, factory.EnergyBuildAdjMod or 1)
        adjacencyreductionM = LOUDMIN(1, factory.MassBuildAdjMod or 1)
	
		local massScale = math.pow(1.8, factory.BuildLevel - 1) -- exponential increase between tech levels
		local energyScale = math.pow(3.6, factory.BuildLevel - 1)

		local massTrigger = MassTrigger(factory, massScale, adjacencyreductionM)
		local energyTrigger = EnergyTrigger(factory, energyScale, adjacencyreductionE)

		-- initial engineers have a lower cost
		if aiBrain.CycleTime < 45 then
			massTrigger = 100
			energyTrigger = 1000
		end

        local trig = false
        
        --- while the factory is not dead or upgrading/enhancing --- loop here until the eco allows building again ---
		while (not factory.Dead and not Upgrading) and ( GetEconomyStored( aiBrain, 'MASS') < massTrigger or GetEconomyStored( aiBrain, 'ENERGY') < energyTrigger ) and not (IsUnitState(factory,'Upgrading') or IsUnitState(factory,'Enhancing')) do
            -- adjacency reduction is the average of the two reductions
            adjacencyaverage = ((adjacencyreductionE + adjacencyreductionM) / 2)          

            -- the delay period is reduced by the tier of the factory and the adjacency average
            local delay = LOUDFLOOR((28 - (BuildLevel * 3)) * adjacencyaverage)

            if DisplayFactoryBuilds then

                local message = "Resource Delay "..string.format("%d", delay)            

                trig = not trig

                if trig then
                    factory:SetCustomName( message )
                end

                LOG("*AI DEBUG "..aiBrain.Nickname.." Factory "..factory.EntityID.." "..message.." Masstrig "..string.format("%.1f", massTrigger).." Enertrig "..string.format("%.1f", energyTrigger))
            end
            
			WaitTicks( delay )
            adjacencyreductionE = LOUDMIN(1, factory.EnergyBuildAdjMod or 1)
            adjacencyreductionM = LOUDMIN(1, factory.MassBuildAdjMod or 1)

			-- the actual M & E triggers are impacted by new adjacencies each cycle
			massTrigger = MassTrigger(factory, massScale, adjacencyreductionM)
			energyTrigger = EnergyTrigger(factory, energyScale, adjacencyreductionE)
		end
		
		if (not factory.Dead) and not (IsUnitState(factory,'Upgrading') or IsUnitState(factory,'Enhancing')) then
		
			while (not factory.Dead) and (not IsIdleState(factory)) do
			
                -- must be enhancing ?
				if not IsUnitState(factory,'Upgrading') and not Upgrading then
					WaitTicks(10)
				else
					break
				end
			end

            if DisplayFactoryBuilds then
                factory:SetCustomName("")
            end
		
			if not factory.Dead and (not IsUnitState(factory,'Upgrading')) and (not Upgrading) then

                --- go and get a build task --
				ForkThread( self.AssignBuildOrder, self, factory, aiBrain )
			end
		end
    end,
    
	-- I learned something interesting here - when a factory gets upgraded, it is NOT removed from 
	-- the factory list by default - it simply has its EntityID removed
	-- this made the original function give incorrect results - I rebuild the factory list
	-- in this function - and I added it to the AddUnit function
	GetNumFactories = function(self)

		local counter = 0
		local changed = false
        
		for k,v in self.FactoryList do
		
			if v.EntityID then
			
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
 
	GetFactoriesBuildingCategory = function(self, category, facCategory )
	
        local EntityCategoryFilterDown = EntityCategoryFilterDown
        local LOUDENTITY = LOUDENTITY
        
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

		return units, counter
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
        
       return units, counter
    end,
	
	-- this is fired when a factory completes a build order
	-- not necessarily a single unit - in the case that platoon template specified more than 1 unit
	-- some specfic tasks are performed here for engineers, factory upgrades or air transports
    FactoryFinishBuilding = function( self, factory, finishedUnit )

		local aiBrain = GetAIBrain(factory)
		
		local LOUDENTITY = LOUDENTITY

        if LOUDENTITY( ENGINEER, finishedUnit ) then
		
			local EM = aiBrain.BuilderManagers[self.LocationType].EngineerManager

            EM:ForkThread( EM.AddEngineerUnit, finishedUnit )
		end
        
        local addplan           = factory.addplan
        local addbehavior       = factory.addbehavior

		if addplan then
			finishedUnit:ForkThread( AIBehaviors[addplan], aiBrain )
		end
		
		if addbehavior then
			finishedUnit:ForkThread( AIBehaviors[addbehavior], aiBrain )
		end
        
        local Enhancements = __blueprints[finishedUnit.BlueprintID].Enhancements.Sequence or false
        local FactionIndex = aiBrain.FactionIndex
		
        -- note how we check for BuildLevel to insure that factory has not already been added
        -- this event was somehow misfiring - sometimes causing the factory to go thru being
        -- added twice - and putting a 2nd OnUnitBuilt callback onto the factory - which would
        -- cause the factory to go looking for 2 jobs whenever something was built
        if LOUDENTITY( FACTORY, finishedUnit ) and not finishedUnit.BuildLevel then

			if GetFractionComplete(finishedUnit) == 1 then

				ForkThread( self.AddFactory, self, finishedUnit, aiBrain )
                
                finishedUnit:LaunchUpgradeThread( aiBrain )

				if not finishedUnit.EnhanceThread and Enhancements then
				
					finishedUnit.EnhanceThread = finishedUnit:ForkThread( FactorySelfEnhanceThread, FactionIndex, aiBrain, self)
				end				

				factory.Dead = true

				factory.Trash:Destroy()
				
				return self:FactoryDestroyed(factory)
			end
		end
		
		if not factory.Dead then
		
			if LOUDGETN(factory:GetCommandQueue()) <= 1 then

                if ScenarioInfo.DisplayFactoryBuilds then
                    factory:SetCustomName("")
                end

				factory.addplan = nil
				factory.addbehavior = nil

				ForkThread( self.DelayBuildOrder, self, factory )
			
				if not factory.UpgradesComplete then
				
					if not factory.UpgradeThread and factory.LaunchUpgradeThread then
					
                        factory:LaunchUpgradeThread( aiBrain )
					end
				end
				
				if not factory.EnhancementsComplete then
				
					if not factory.EnhanceThread and Enhancements then
					
						factory.EnhanceThread = factory:ForkThread( FactorySelfEnhanceThread, FactionIndex, aiBrain, self)
					end
				end
			end
		end
    end,
    
	-- this function starts with a raw template - ie. T3Engineer and fills it in with the actual unit ID - ie. url0105
	-- and the other parameters (min qty, max qty, squad and formation) required to fill out the template
	-- this is also where custom units come into play
	GetFactoryTemplate = function( self, templateName, factory, faction)
		
		local LOUDINSERT = LOUDINSERT
		local Random = Random        

		local customData = ScenarioInfo.CustomUnits[templateName][faction] or false
        local template = false

        local PlatoonTemplate = PlatoonTemplates[templateName]
        local FactionSquads = PlatoonTemplate.FactionSquads
		
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
		
		if faction and FactionSquads[faction] then
		
			-- this is here to insure that IF there are replacments we only replace
			-- the FIRST unit in those cases where a template may have multiple units specified (ie.- a platoon of units)
			local replacementdone = false
            
            -- sometimes the stock unit template is empty
            --local tablesize = LOUDGETN(PlatoonTemplates[templateName].FactionSquads[faction])
            
            if FactionSquads[faction][1] then
		
                for _,v in FactionSquads[faction] do
			
                    if customData and (not replacementdone) then

                        local replacement = GetCustomReplacement( v )
					
                        -- if a replacement is selected (by %) then it will fill the template otherwise stock will be used
                        if replacement then
					
                            if not template then
                                template = { PlatoonTemplate.Name, '', }
                            end
                        
                            LOUDINSERT( template, replacement )
                            replacementdone = true -- keeps us from replacing anything but the first unit in a template
						
                        else
                    
                            if not template then
                                template = { PlatoonTemplate.Name, '', }
                            end 
                        
                            LOUDINSERT( template, v )
						
                        end
					
                    else
                
                        if not template then
                            template = { PlatoonTemplate.Name, '', }
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
                            template = { PlatoonTemplate.Name, '', }
                        end
                        
                        LOUDINSERT( template, replacement )
                        replacementdone = true -- keeps us from replacing anything but the first unit in a template

                    end
                end
            end
           
			
		elseif faction and customData then

			local replacement = GetCustomReplacement( FactionSquads[1] )
			
			if replacement[1] then
			
				LOUDINSERT( template, replacement )
			end
		end
		
        if not template then
            WARN("*AI DEBUG Template "..repr(templateName).." for "..repr(faction).." is empty "..repr(FactionSquads[faction]))
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
        local LOUDGETN = LOUDGETN
        local WaitTicks = WaitTicks
        
		WaitTicks(30)
		
		local category = TRAFFICUNITS
		
		local rallypoint = { rally[1],rally[2],rally[3] }

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
        local ArmyPool = aiBrain.ArmyPool

        local counter, unitlist, units
		
		while true do

			WaitTicks(480)

			units = GetOwnUnitsAroundPoint( aiBrain, category, rallypoint, 16)
			
			if LOUDGETN(units) > 8 then
			
				unitlist = {}
                counter = 0
				
				for _,unit in units do
				
					if (unit.PlatoonHandle == ArmyPool) and IsIdleState(unit) then
                    
                        counter = counter + 1

						unitlist[counter] = unit
					end
				end
				
				if counter > 7 then

					IssueClearCommands( unitlist )

					IssueFormMove( unitlist, rallypoint, 'BlockFormation', Direction )
				end
                
			end
		end
	end,
	
}
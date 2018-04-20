--   /lua/sim/FactoryBuilderManager.lua

-- The Factory Builder Manager (FBM) is responsible for managing which builders (tasks) are available
-- whenever a factory goes looking for something to build

local import = import

local AssignTransportToPool = import('/lua/ai/altaiutilities.lua').AssignTransportToPool

local FactorySelfEnhanceThread = import('/lua/ai/aibehaviors.lua').FactorySelfEnhanceThread

local SelfUpgradeThread = import('/lua/ai/aibehaviors.lua').SelfUpgradeThread

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager

local AIGetClosestMarkerLocation = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation
local RandomLocation = import('/lua/ai/aiutilities.lua').RandomLocation

local CreateFactoryBuilder = import('/lua/sim/Builder.lua').CreateFactoryBuilder

local BuildPlatoon = moho.aibrain_methods.BuildPlatoon

--local CanBuildPlatoon = moho.aibrain_methods.CanBuildPlatoon

local LOUDGETN  = table.getn
local LOUDINSERT = table.insert

local LOUDENTITY = EntityCategoryContains
local EntityCategoryCount = EntityCategoryCount
local EntityCategoryFilterDown = EntityCategoryFilterDown

local WaitTicks = coroutine.yield

local PlatoonTemplates = PlatoonTemplates

	
function CreateFactoryBuilderManager(brain, lType, location, basetype)

    local fbm = FactoryBuilderManager()
	
	--LOG("*AI DEBUG "..brain.Nickname.." creating FBM for "..lType)
	
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
	-- the necessitated changing all the BuilderType entries into tables in the unit builder specs
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

				self.FactoryList[k] = nil
				changed = true
				
			end
			
		end
		
        if changed then
		
			self.FactoryList = self:RebuildTable( self.FactoryList )
			
		end

		return counter
		
	end,
    
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
    
	GetFactoriesBuildingCategory = function(self, category, facCategory )
	
		local units = {}
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
            
			units[counter+1] = v
			counter = counter + 1
			
		end

		return units
		
	end,
    
	GetFactoriesWantingAssistance = function(self, category, facCatgory )
		
		local units = {}
		local counter = 0
		
		for _,v in self:GetFactoriesBuildingCategory(category, facCatgory ) do
		
			if v.DesiresAssist == false then
			
               continue
			   
			end
            
			if v.NumAssistees and LOUDGETN( v:GetGuards() ) >= v.NumAssistees then
			
				continue
				
			end 
            
			units[counter+1] = v
			counter = counter + 1
			
		end
        
       return units
	   
    end,

	AddFactory = function( self, factory )
	
        while (not factory.Dead) and factory:GetFractionComplete() < 1 do
		
            WaitTicks(100)
			
        end

		local LOUDENTITY = EntityCategoryContains

		if not factory.Dead and not factory.SetupComplete then
			
			factory.SetupComplete = true
			
			factory.failedbuilds = 0
			
			if LOUDENTITY( categories.LAND * categories.TECH1, factory ) then
			
				factory.BuilderType = 'LandT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( categories.LAND * categories.TECH2, factory ) then
			
				factory.BuilderType = 'LandT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( categories.LAND * categories.TECH3, factory ) then
			
				factory.BuilderType = 'LandT3'
				factory.BuildLevel = 3
				
			elseif LOUDENTITY( categories.AIR * categories.TECH1, factory ) then
			
				factory.BuilderType = 'AirT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( categories.AIR * categories.TECH2, factory ) then
			
				factory.BuilderType = 'AirT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( categories.AIR * categories.TECH3, factory ) then
			
				factory.BuilderType = 'AirT3'
				factory.BuildLevel = 3
				
			elseif LOUDENTITY( categories.NAVAL * categories.TECH1, factory ) then
			
				factory.BuilderType = 'SeaT1'
				factory.BuildLevel = 1
				
			elseif LOUDENTITY( categories.NAVAL * categories.TECH2, factory ) then
			
				factory.BuilderType = 'SeaT2'
				factory.BuildLevel = 2
				
			elseif LOUDENTITY( categories.NAVAL * categories.TECH3, factory ) then
			
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
				factory.NumAssistees = 4			-- default factory to 4 assistees			
			
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

				self.FactoryList = self:RebuildTable( self.FactoryList )
				
			end
			
		end
		
	end,
    
    FactoryDestroyed = function(self, factory)
        
		if self then
		
			for k,v in self.FactoryList do
			
				if (not v.Sync.id) or v.Dead then
				
					self.FactoryList[k] = nil
					break
					
				end
				
			end
		
			self.FactoryList = self:RebuildTable( self.FactoryList )
			
		end
		
    end,
	
	-- this is fired when a factory completes a build order
	-- not necessarily a single unit - in the case that platoon template specified more than 1 unit
	-- some specfic tasks are performed here for engineers, factory upgrades or air transports
    FactoryFinishBuilding = function( self, factory, finishedUnit )

		local aiBrain = factory:GetAIBrain()
		
		local LOUDENTITY = EntityCategoryContains
		
		if ScenarioInfo.DisplayFactoryBuilds then
		
			factory:SetCustomName("")
			
		end
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." Factory "..factory.Sync.id.." finishes building "..finishedUnit:GetBlueprint().Description)
		
        if LOUDENTITY( categories.ENGINEER, finishedUnit ) then
		
			local EM = aiBrain.BuilderManagers[self.LocationType].EngineerManager

            ForkThread( EM.AddEngineerUnit, EM, finishedUnit )
			
		end
		
        if LOUDENTITY((categories.AIR * categories.MOBILE), finishedUnit) then
		
			-- all AIR units (except true Transports) will get these callbacks to assist with Airpad functions
			if not LOUDENTITY((categories.TRANSPORTFOCUS - categories.uea0203), finishedUnit) then

				local ProcessDamagedAirUnit = function( finishedUnit, newHP, oldHP )
	
					-- added check for RTP callback (which is intended for transports but UEF gunships sometimes get it)
					-- to bypass this is the unit is in the transport pool --
					if (newHP < oldHP and newHP < 0.5) and not finishedUnit.ReturnToPoolCallbackSet then
					
						--LOG("*AI DEBUG Callback Damaged running on "..finishedUnit:GetBlueprint().Description.." with New "..repr(newHP).." and Old "..repr(oldHP))

						local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits

						ProcessAirUnits( finishedUnit, finishedUnit:GetAIBrain() )
						
					end
					
				end

				finishedUnit:AddUnitCallback( ProcessDamagedAirUnit, 'OnHealthChanged')

				
				local ProcessFuelOutAirUnit = function( finishedUnit )
				
					-- this flag only gets turned on after this executes
					-- and is turned back on only when the unit gets fuel - so we avoid multiple executions
					-- and we don't process this if it's a transport pool unit --
					if finishedUnit.HasFuel and not finishedUnit.ReturnToPoolCallbackSet then
				
						--LOG("*AI DEBUG Callback OutOfFuel running on "..finishedUnit:GetBlueprint().Description )
				
						local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits
					
						ProcessAirUnits( finishedUnit, finishedUnit:GetAIBrain() )
						
					end
					
				end
				
				finishedUnit:AddUnitCallback( ProcessFuelOutAirUnit, 'OnRunOutOfFuel')
				
			else
			
				-- transports get assigned to the Transport pool
				finishedUnit:ForkThread( AssignTransportToPool, aiBrain )
				
			end
			
		end
		
		if factory.addplan then
		
			finishedUnit:ForkThread( import('/lua/ai/aibehaviors.lua')[factory.addplan], aiBrain )
			
		end
		
		if factory.addbehavior then
		
			finishedUnit:ForkThread( import('/lua/ai/aibehaviors.lua')[factory.addbehavior], aiBrain )
			
		end
		
        if LOUDENTITY( categories.FACTORY * categories.STRUCTURE, finishedUnit ) then
		
			if finishedUnit:GetFractionComplete() == 1 then

				ForkThread( self.AddFactory, self, finishedUnit )

				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, aiBrain.FactionIndex, aiBrain, 1, 1.01, 9999, 9999, 16, 240, false )
				
				if not finishedUnit.EnhanceThread and finishedUnit:GetBlueprint().Enhancements.Sequence then
				
					finishedUnit.EnhanceThread = finishedUnit:ForkThread( FactorySelfEnhanceThread, aiBrain.FactionIndex, aiBrain, self)
					
				end				

				factory.Dead = true

				factory.Trash:Destroy()
				
				return self:FactoryDestroyed(factory)
				
			end
			
		end
		
		if not factory.Dead then
		
			if table.getn(factory:GetCommandQueue()) <= 1 then
		
				factory.addplan = false
				factory.addbehavior = false

				ForkThread( self.DelayBuildOrder, self, factory )
			
				if not factory.UpgradesComplete then
				
					if not factory.UpgradeThread then
					
						factory.UpgradeThread = factory:ForkThread( SelfUpgradeThread, aiBrain.FactionIndex, aiBrain, 1, 1.01, 9999, 9999, 16, 240, false )
						
					end
					
				end
				
				if not factory.EnhancementsComplete then
				
					if not factory.EnhanceThread and factory:GetBlueprint().Enhancements.Sequence then
					
						factory.EnhanceThread = factory:ForkThread( FactorySelfEnhanceThread, aiBrain.FactionIndex, aiBrain, self)
						
					end
					
				end
				
			end
			
		end
		
    end,
    
	-- this function starts with a raw template - ie. T3Engineer and fills it in with the actual unit ID - ie. url0105
	-- and the other parameters (min qty, max qty, role and formation) required to fill out the template
	-- this is also where custom units come into play
	GetFactoryTemplate = function( self, templateName, factory, faction)

		local customData = ScenarioInfo.CustomUnits[templateName][faction] or false

		local template = { PlatoonTemplates[templateName].Name, '', }
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
				
					possibles[counter+1] = v[1]

					counter = counter + 1
					
				end
				
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
		
			for _,v in PlatoonTemplates[templateName].FactionSquads[faction] do
			
				if customData and (not replacementdone) then

					local replacement = GetCustomReplacement( v )
					
					-- if a replacement is selected (by %) then it will fill the template otherwise stock will be used
					if replacement then
					
						LOUDINSERT( template, replacement )
						replacementdone = true -- keeps us from replacing anything but the first unit in a template
						
					else
					
						LOUDINSERT( template, v )
						
					end
					
				else
				
					LOUDINSERT( template, v )
					
				end
				
			end
			
			
		elseif faction and customData then

			local replacement = GetCustomReplacement( PlatoonTemplates[templateName].FactionSquads[1] )
			
			if replacement then
			
				LOUDINSERT( template, replacement )
				
			end
			
		end
		
		return template
		
	end,
    
	-- this keeps the factory from trying to build if the basic resources are not available (200M 2500E - varies by factory level - requirements are lower for low tier - but higher tier check more frequently )
	-- also waits for factory to be NOT busy (some units cause factory to pause after building)
	-- delays are dynamic - higher tier factories wait less while those enhancing wait more
    DelayBuildOrder = function( self, factory )

		if factory:BeenDestroyed() then
		
			return
			
		end
	
		local WaitTicks = coroutine.yield
		local IsIdleState = moho.unit_methods.IsIdleState
		local IsUnitState = moho.unit_methods.IsUnitState
		
		local aiBrain = factory:GetAIBrain()		
		local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
	
		WaitTicks( 6 - (factory.BuildLevel * 2) + (factory.failedbuilds * 10) + 1 )

		if self.EnhanceThread then
		
			WaitTicks(10)
			
		end

		while (not factory.Dead) and (( GetEconomyStored( aiBrain, 'MASS') < (200 - ( (3 - factory.BuildLevel) * 25)) or GetEconomyStored( aiBrain, 'ENERGY') < (2500 - ( (3 - factory.BuildLevel) * 250))) or (IsUnitState(factory,'Upgrading') or IsUnitState(factory,'Enhancing')))  do
		
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
    
    -- this is the function which actually finds and builds something
    -- a factory can pass a plan/behavior to a unit when its finished or
    -- run a function when the factory finishes its build queue
	-- as a result only one plan or behavior gets executed
    AssignBuildOrder = function( self, factory, aiBrain )
	
		if factory.Sync.id and not factory.Upgrading then
			
			local builder = self:GetHighestBuilder( factory, aiBrain )
		
			if builder then
		
				if ScenarioInfo.DisplayFactoryBuilds then
				
					factory:SetCustomName(repr(builder.BuilderName))
					
				end
				
                factory.addplan = false
				factory.addbehavior = false
				
				factory.failedbuilds = 0

				local buildplatoonsqty = 1

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

				--LOG("*AI DEBUG "..aiBrain.Nickname.." Building Platoon "..repr(builder.BuilderName))
				
                aiBrain:BuildPlatoon( self:GetFactoryTemplate( Builders[builder.BuilderName].PlatoonTemplate, factory, aiBrain.FactionName ), {factory}, buildplatoonsqty )

				if Builders[builder.BuilderName].PlatoonAddFunctions then
				
					for _, pafv in Builders[builder.BuilderName].PlatoonAddFunctions do
					
                        ForkThread( import( pafv[1])[ pafv[2] ], aiBrain )
						
					end
					
				end
				
			else
			
				if ScenarioInfo.DisplayFactoryBuilds then
					ForkThread(FloatingEntityText, factory.Sync.id, "No Job for "..factory.BuilderType )
				end
				
				factory.failedbuilds = factory.failedbuilds + 1

                ForkThread( self.DelayBuildOrder, self, factory )
				
			end
			
		end
		
	end,
	
	-- as with the BuilderParamCheck in the EM, we no longer need most of these checks
	-- since we control the jobs presented to the factories in advance 
    BuilderParamCheck = function( self, builder, factory )
		
		if factory.Upgrading or factory:IsUnitState('Upgrading') then
		
			return false
			
		end
		
		return true
		
    end,
    
	-- one of the LOUD features - AI no longer relies upon placement of Rally Point markers - makes his own when he starts a base
	-- function will find the closest rally point marker and make that it's rally point  -- and initiate a traffic control thread
    SetRallyPoint = function(self, factory)

		WaitTicks(20)	
		
		if not factory.Dead then

			local position = factory:GetPosition()
			
			local rally = false
		
			local rallyType = 'Rally Point'
		
			if LOUDENTITY( categories.NAVAL, factory ) then
			
				rallyType = 'Naval Rally Point'
				
			end
        
			rally = AIGetClosestMarkerLocation( self, rallyType, position[1], position[3] )

			if not rally or VDist3( rally, position ) > 100 then
			
				position = RandomLocation(position[1],position[3])
				rally = position
				
			end
        
			IssueClearFactoryCommands( {factory} )
			
			IssueFactoryRallyPoint({factory}, rally)
		
			TrafficControl = factory:ForkThread(self.TrafficControlThread, position, rally)
			
		end
		
    end,

	-- thread runs as long as the factory is alive and monitors the units at that
	-- factory rally point - ordering them into formation if they are not in a platoon
	-- this helps alleviate traffic issues and 'stuck' unit problems
	TrafficControlThread = function(factory, factoryposition, rally)
	
		WaitTicks(30)
	
		local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
		
		local category = categories.MOBILE - categories.EXPERIMENTAL - categories.AIR - categories.ENGINEER
		
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

		local aiBrain = factory:GetAIBrain()
		
		while true do
		
			local unitlist = nil
			local units = nil
			
			WaitTicks(900)
			
			units = GetOwnUnitsAroundPoint( aiBrain, category, rallypoint, 16)
			
			if table.getn(units) > 10 then
			
				local unitlist = {}
				
				for _,unit in units do
				
					if (not unit.PlatoonHandle) and unit:IsIdleState() then

						table.insert( unitlist, unit )
						
					end
					
				end
				
				if table.getn(unitlist) > 10 then

					IssueClearCommands( unitlist )

					IssueFormMove( unitlist, rallypoint, 'BlockFormation', Direction )
					
				end
				
			end
			
		end
		
	end,
}
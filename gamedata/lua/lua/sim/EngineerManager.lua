--   /lua/sim/EngineerManager.lua

-- The Engineer Manager (EM) is responsible for managing the various builders (tasks) that 
-- an engineer can select from when he goes looking for work

local import = import

local BuilderManager    = import('/lua/sim/BuilderManager.lua').BuilderManager
local BuildingTemplates = import('/lua/buildingtemplates.lua').BuildingTemplates

local CreateEngineerBuilder         = import('/lua/sim/Builder.lua').CreateEngineerBuilder

local AIBehaviors = import('/lua/ai/aibehaviors.lua')

local CzarCarrierThread             = AIBehaviors.CzarCarrierThread
local EyeBehavior                   = AIBehaviors.EyeBehavior
local FatBoyAI                      = AIBehaviors.FatBoyAI
local RiftGateBehavior              = AIBehaviors.RiftGateBehavior
local SCUSelfEnhanceThread          = AIBehaviors.SCUSelfEnhanceThread
local TMLThread                     = AIBehaviors.TMLThread

local RandomLocation                = import('/lua/ai/aiutilities.lua').RandomLocation

local AISendPing                    = import('/lua/ai/altaiutilities.lua').AISendPing

local DisperseUnitsToRallyPoints    = import('/lua/loudutilities.lua').DisperseUnitsToRallyPoints
local GetFreeUnitsAroundPoint       = import('/lua/loudutilities.lua').GetFreeUnitsAroundPoint
local RemoveBaseMarker              = import('/lua/loudutilities.lua').RemoveBaseMarker

local AIBrainMethods = moho.aibrain_methods

local AssignUnitsToPlatoon      = AIBrainMethods.AssignUnitsToPlatoon
local DecideWhatToBuild         = AIBrainMethods.DecideWhatToBuild
local GetThreatAtPosition       = AIBrainMethods.GetThreatAtPosition
local GetUnitsAroundPoint       = AIBrainMethods.GetUnitsAroundPoint
local MakePlatoon               = AIBrainMethods.MakePlatoon
local PlatoonExists             = AIBrainMethods.PlatoonExists	


local BeenDestroyed         = moho.entity_methods.BeenDestroyed
local GetFractionComplete   = moho.entity_methods.GetFractionComplete
local GetPosition           = moho.entity_methods.GetPosition

local GetAIBrain        = moho.unit_methods.GetAIBrain
local GetGuards         = moho.unit_methods.GetGuards
local IsUnitState       = moho.unit_methods.IsUnitState

local ForkThread    = ForkThread
local LOUDABS       = math.abs
local LOUDCOPY      = table.copy
local LOUDENTITY    = EntityCategoryContains
local LOUDFIND      = table.find
local LOUDFLOOR     = math.floor
local LOUDGETN      = table.getn
local LOUDINSERT    = table.insert
local LOUDMAX       = math.max
local LOUDMIN       = math.min
local LOUDREMOVE    = table.remove
local LOUDSORT      = table.sort
local VDist2Sq      = VDist2Sq
local WaitTicks     = coroutine.yield

-- add support for builderType (ie. Any, Commander)	-- so now we can specify as follows;
local builderTypes = { 'Any','T1','T2','T3','SubCommander','Commander' }

local COMMAND           = categories.COMMAND
local FACTORY           = categories.FACTORY * categories.STRUCTURE - categories.EXPERIMENTAL
local T4FACTORIES       = categories.FACTORY * categories.STRUCTURE * categories.EXPERIMENTAL
local GENERALSTRUCTURE  = categories.STRUCTURE - categories.NUKE - (categories.ARTILLERY * categories.STRATEGIC)
local RHIANNE           = categories.STRUCTURE * categories.AEON * categories.OPTICS
local SUBCOMMANDER      = categories.SUBCOMMANDER

local LANDUNITS     = categories.LAND * categories.MOBILE
local AIRUNITS      = categories.AIR * categories.MOBILE
local FIGHTERS      = categories.AIR * categories.ANTIAIR
local SEAUNITS      = categories.MOBILE - categories.AIR

local LANDRESPONSE  = (categories.LAND * categories.MOBILE) - categories.ANTIAIR - categories.COUNTERINTELLIGENCE - categories.ENGINEER - categories.COMMAND
local SEARESPONSE   = (categories.NAVAL * categories.MOBILE) - categories.STRUCTURE - categories.ENGINEER - categories.CARRIER
local GROUNDATTACK  = categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY
local NAVALATTACK   = categories.TORPEDOBOMBER + categories.GROUNDATTACK

local PlatoonTemplates = PlatoonTemplates


function CreateEngineerManager( brain, lType, location, radius )

    local em = EngineerManager()

    em:Create(brain, lType, location, radius)
	
    return em
end

EngineerManager = Class(BuilderManager) {

    Create = function( self, brain, lType, location, radius )
	
        BuilderManager.Create(self,brain)

		self.Active = true
        self.Location = location
        self.LocationType = lType
		self.ManagerType = 'EM'
        self.Radius = radius
		self.EngineerList = { Count = 0, }

		for _,v in builderTypes do
			self:AddBuilderType(v)
		end
    end,

    AddBuilder = function( self, brain, builderData, locationType, builderType )
	
		local newBuilder = false
		
		if not builderData.FactionIndex or builderData.FactionIndex == brain.FactionIndex then
			newBuilder = CreateEngineerBuilder( self, brain, builderData, locationType)
		end
		
		if newBuilder then
		
			for _,EngineerType in Builders[newBuilder.BuilderName].BuilderType do
			
				if EngineerType == 'All'  then
				
					for k,v in self.BuilderData do
					
						-- filter out any Commander tasks
						if not k == 'Commander' then
							self:AddInstancedBuilder( newBuilder, k, brain)
						end
					end
				else
					self:AddInstancedBuilder(newBuilder,EngineerType, brain)
				end
			end
		end
        
        return newBuilder
    end,
    
	-- this function adds an engineer to a base and sets up additional data
	-- It then sends the engineer off to find work
    AddEngineerUnit = function( self, unit, dontAssign )

        LOUDINSERT( self.EngineerList, unit )
        
        if ScenarioInfo.EngineerDialog then
            LOG("*AI DEBUG "..GetAIBrain(unit).Nickname.." Eng "..unit.EntityID.." "..__blueprints[unit.BlueprintID].Description.." added to "..self.ManagerType.." "..self.LocationType)
        end
		
        self.EngineerList.Count = self.EngineerList.Count + 1

		unit.failedbuilds = 0
        unit.LocationType = self.LocationType

		if LOUDENTITY( COMMAND, unit ) then
		
			unit.BuilderType = 'Commander'
			
		elseif LOUDENTITY( categories.TECH1, unit ) then
		
			unit.BuilderType = 'T1'
			
		elseif LOUDENTITY( categories.TECH2, unit ) then
		
			unit.BuilderType = 'T2'
			
		elseif LOUDENTITY( categories.TECH3 - SUBCOMMANDER, unit ) then
		
			unit.BuilderType = 'T3'
			
		elseif LOUDENTITY( SUBCOMMANDER, unit ) then
		
			unit.BuilderType = 'SubCommander'
		end

        local deathFunction = function( unit )
			self:RemoveEngineerUnit( unit )
		end

		-- setup engineer death callbacks --
		unit:AddUnitCallback( deathFunction, 'OnReclaimed')
		unit:AddUnitCallback( deathFunction, 'OnCaptured')
		unit:AddUnitCallback( deathFunction, 'OnKilled')

		-- setup other engineer callbacks --
		unit:SetupEngineerCallbacks( self )

		-- new engineers will execute this code 
		-- transferred engineers will not since the RTB that is called by a transfer
		-- will send them to an assignment when it completes
		if not dontAssign then
    
			while not unit.Dead and unit:GetFractionComplete() < 1 do
				WaitTicks(100)
			end
		
			if not LOUDENTITY( COMMAND, unit) then
				WaitTicks(35)
			end
		
			if not unit.Dead then

				if not unit.AssigningTask then
					self:ForkThread( self.DelayAssignEngineerTask, unit, GetAIBrain(unit) )
				end
			end	
		end

		-- SACU will have enhancement threads that may need rebuilding
		-- so we cancel any existing thread and restart it
		if LOUDENTITY( SUBCOMMANDER, unit) then
		
			if unit.EnhanceThread then
			
				KillThread(unit.EnhanceThread)
				unit.EnhanceThread = nil
			end
			
			local aiBrain = GetAIBrain(unit)
			
			if not unit.EnhancementsComplete then
				unit.EnhanceThread = unit:ForkThread( SCUSelfEnhanceThread, aiBrain.FactionIndex, aiBrain )
			end
		end

        return
    end,

	-- This is the primary function that assigns jobs to an engineer
    AssignEngineerTask = function( self, unit, aiBrain )
    
        local EngineerDialog = ScenarioInfo.EngineerDialog
        local PlatoonDialog = ScenarioInfo.PlatoonDialog

		if unit.Dead or unit.AssigningTask or BeenDestroyed(unit) then
			return
		end

		local builder = self:GetHighestBuilder( unit, aiBrain )

		if unit.Dead or unit.AssigningTask or BeenDestroyed(unit) then
			return
		end

        if EngineerDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..unit.EntityID.." starts AssignEngineerTask at "..self.LocationType.." on tick "..GetGameTick() )
        end

		unit.AssigningTask = true

        local BuilderName = builder.BuilderName
        local Builder = Builders[builder.BuilderName]
        
        local PlatoonAddBehaviors   = Builder.PlatoonAddBehaviors
        local PlatoonAddFunctions   = Builder.PlatoonAddFunctions
        local PlatoonAddPlans       = Builder.PlatoonAddPlans
        local PlatoonAIPlan         = Builder.PlatoonAIPlan

        if builder and (not unit.Dead) and (not unit.Fighting) then
            
            local LocationType  = self.LocationType
            local PlanName      = PlatoonTemplates[Builder.PlatoonTemplate].Plan

			if PlatoonDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." Platoon "..repr(BuilderName).." forms at EM on tick "..GetGameTick() )
			end

            if EngineerDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." Eng "..unit.EntityID.." "..repr(BuilderName).." forms on tick "..GetGameTick() )
            end
			
            local hndl = MakePlatoon( aiBrain, BuilderName, PlanName or 'none' )

			hndl.BuilderName = BuilderName
            hndl.LocationType = LocationType
			hndl.MovementLayer = 'Amphibious'
            
            hndl.PlanName = PlanName
            
            hndl.PlatoonData = builder:GetBuilderData(LocationType)
			hndl.RTBLocation = builder.RTBLocation or LocationType

			IssueStop( {unit} )
			
            AssignUnitsToPlatoon( aiBrain, hndl, {unit}, 'Support', 'none' )
			
			if not builder:StoreHandle( hndl, self, unit.BuilderType ) then
			
				WARN("*AI DEBUG "..aiBrain.Nickname.." no available instance for "..BuilderName.." Eng "..unit.EntityID.." Creation Time "..hndl.CreationTime.." told that "..builder.InstanceAvailable.." were available")
				
				builder.InstanceAvailable = 0
				aiBrain:DisbandPlatoon(hndl)
            
				if not unit.Dead then

					unit.AssigningTask = false
					
					unit.PlatoonHandle = false
					unit.failedbuilds = unit.failedbuilds + 1
					
					if unit.failedbuilds > 14 then
						unit.failedbuilds = 14
					end
					
					return self:DelayAssignEngineerTask( unit, aiBrain )
				end
				
				return
			end

			unit.PlatoonHandle = hndl
            unit.BuilderName = BuilderName

			unit.failedbuilds = 0
			unit.failedmoves = 0
			
			unit.DesiresAssist = hndl.PlatoonData.DesiresAssist or false	
			unit.NumAssistees = hndl.PlatoonData.NumAssistees or 1

			--Add functions are run immediately upon platoon creation
			-- since these functions are not forked off of the platoon they can persist beyond the death of the platoon (ie. - Commander Thread)
            if PlatoonAddFunctions then
			
                for pafk, pafv in PlatoonAddFunctions do
                
                    ForkThread( import(pafv[1])[pafv[2]], hndl, aiBrain)

					--if PlatoonDialog then
						--LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..BuilderName.." adds function "..repr(pafv[2]))
					--end
                end
            end
			
			-- PlatoonAIPlan is intended to replace whatever the Normal plan might be
			-- the SetAIPlan function will kill whatever AIThread is already running
            if PlatoonAIPlan then
			
                hndl.PlanName = PlatoonAIPlan
                hndl:SetAIPlan(PlatoonAIPlan, aiBrain)
            end

            if PlatoonAddPlans then
			
                for papk, papv in PlatoonAddPlans do

					--if PlatoonDialog then
						--LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..BuilderName.." adds plan "..repr(papv))
					--end

                    hndl:ForkThread( hndl[papv], aiBrain )
                end
            end
            
            if PlatoonAddBehaviors then
			
				-- fork off all the additional behaviors --
                for pafk, pafv in PlatoonAddBehaviors do

					--if PlatoonDialog then
						--LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..BuilderName.." adds behavior "..repr(pafv))
					--end

                    hndl:ForkThread( AIBehaviors[pafv], aiBrain )
                end
            end
            
		else
        
			if (unit.PlatoonHandle and unit.PlatoonHandle != aiBrain.ArmyPool) and (unit.PlatoonHandle and unit.PlatoonHandle != aiBrain.StructurePool) then
				
				if PlatoonExists( aiBrain, unit.PlatoonHandle ) then
					aiBrain:DisbandPlatoon(unit.PlatoonHandle)
				end
			
            else
            
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." Eng "..unit.EntityID.." finds NO TASK on tick "..GetGameTick() )
                end
                
            end

            unit.PlatoonHandle = aiBrain.ArmyPool
            unit.failedbuilds = ((unit.failedbuilds or 0) + 1) 
            
			if not unit.Dead then

				unit.AssigningTask = false
                return self:DelayAssignEngineerTask( unit, aiBrain )
			end
		end
    end,

    -- This routine runs when an engy cant find a job to do
	-- Delays him before seeking a new task to avoid thrashing the EM
    DelayAssignEngineerTask = function( self, unit, aiBrain )
    
        local delay = LOUDMIN( 101, 14 + (unit.failedbuilds * 5))

        if ScenarioInfo.EngineerDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..unit.EntityID.." waiting "..delay.." ticks")
        end    

		WaitTicks( delay )
        
        local IsUnitState = IsUnitState
        
        while unit and not unit.Dead and not unit.AssigningTask do

			if not ( unit.Fighting or unit.AssigningTask) and not unit.Dead then
				-- send the engineer off to find a job --
				return self.AssignEngineerTask( self, unit, aiBrain )
			else
				WaitTicks(31)
			end

			if (not unit.Dead) and ( (not unit:IsIdleState() ) or IsUnitState( unit, 'Attached' ) ) then
			
				if IsUnitState( unit, 'Attached' ) then

					WaitTicks(31)	
				end
			end
        end
    end,
	
    -- ok - this routine should find engineers which are building an item of a given category
	-- problem is - actively - it doesn't account for them having that item in
	-- their build queue but haven't started it yet - that's ok - but it's misleading
	-- as we use this function to find engineers wanting assistance with something so
	-- we wont be able to assist them until they are building it
	-- if we want to find engineers that want assistance building something in their
	-- queue, we have to interrogate the queue - which may not have the data we can
	-- compare to - since the queue stores references like 'T1LandFactory' and not
	-- actual unitID information
    GetEngineersBuildingCategory = function( self, engCategory, buildingcategory )
		
		local engs = EntityCategoryFilterDown( engCategory, self.EngineerList ) or {}
        
        local LOUDENTITY = LOUDENTITY

        local units = {}
		local counter = 1
        
        local beingBuiltUnit

        for _,v in engs do
		
            -- the inclusion of Upgrading allows this to pickup units which are enhancing
            if not v.Dead and IsUnitState( v, 'Building') or v.Upgrading then
            
				beingBuiltUnit = v.UnitBeingBuilt
			
				if beingBuiltUnit and not beingBuiltUnit.Dead then
            
					if LOUDENTITY( buildingcategory, beingBuiltUnit ) then
					
						units[counter] = v
						counter = counter + 1
					end
				end
			end
        end
        
        return units
    end,
	
    GetBuildingId = function( self, engineer, buildingType )
    
        local aiBrain = GetAIBrain(engineer)
	
        return DecideWhatToBuild( aiBrain, engineer, buildingType, BuildingTemplates[ aiBrain.FactionIndex ] )
    end,
    
    GetEngineersQueued = function( self, buildingType )
		
        local units = {}
        local count = 0
		
        for _,v in self.EngineerList do
		
            if not v.Dead then

				if v.EngineerBuildQueue[1] then
            
					local buildingId = self:GetBuildingId( v, buildingType )
			
					for num, data in v.EngineerBuildQueue do
			
						if data[1] == buildingId then

                            count = count + 1
							units[count] = v
                            
							break
						end
					end
				end
			end
        end
		
        return units
    end,

    GetEngineersWantingAssistanceWithBuilding = function( self, buildingcategory, engCategory )
	
		local GetGuards = GetGuards
		local LOUDGETN = LOUDGETN
		
		-- get all the engineers building this category from this base
        local testUnits = self:GetEngineersBuildingCategory( engCategory, buildingcategory )
		
        local retUnits = {}
		local counter = 0

		-- see if any need assistance
        for _,v in testUnits do
		
            if v.DesiresAssist and not v.Dead then

				if LOUDGETN( GetGuards(v) ) < v.NumAssistees then
				
					counter = counter + 1
					retUnits[counter] = v
				end
			end
        end

        return retUnits, counter
    end,

	-- this removes an engineer from this base manager - destroys all existing engy callbacks
	-- used when engineer dies or is transferred to another base
    RemoveEngineerUnit = function( self, unit )

        for num,sUnit in self.EngineerList do

            if sUnit == unit then
            
                if ScenarioInfo.EngineerDialog then
                
                    local brain = GetAIBrain(unit)
                    
                    LOG("*AI DEBUG "..brain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Removing Engineer "..unit.EntityID.." "..__blueprints[unit.BlueprintID].Description )
                    
                    LOG("*AI DEBUG "..brain.Nickname.." "..self.LocationType.." "..self.ManagerType.." Engineer Count is "..self.EngineerList.Count - 1)
                end

                LOUDREMOVE( self.EngineerList, num )
				
				self.EngineerList.Count = self.EngineerList.Count - 1
				break
            end
		end

		unit.EventCallbacks.OnReclaimed = nil
		unit.EventCallbacks.OnCaptured = nil
		unit.EventCallbacks.OnKilled = nil
		
		unit.EventCallbacks.OnUnitBuilt = nil

		unit.EventCallbacks.OnStopCapture = nil
		unit.EventCallbacks.OnFailedCapture = nil
		unit.EventCallbacks.OnFailedToBuild = nil
		unit.EventCallbacks.OnStartBeingCaptured = nil
    end,
    
    -- this gets fired by self when it begins to build the unit
    -- we use it to pass the Manager location to a factory as soon
    -- as it's started in order to sidestep it being set incorrectly
    -- if an engineer from another location comes along and finishes it
    UnitConstructionStarted = function( self, unit )
       
        if not unit.LocationType then
            unit.LocationType = self.LocationType
        end
    end,

	-- When an engineer finishes construction of something it will pass thru here making it a natural place to assign unit-specific routines
    UnitConstructionFinished = function( self, unit, finishedUnit )
	
		if finishedUnit:GetFractionComplete() < 1 or BeenDestroyed(finishedUnit) or finishedUnit.ConstructionComplete then
			return
		end
		
		finishedUnit.ConstructionComplete = true
	
		local LOUDENTITY = LOUDENTITY
		local ForkThread = ForkThread
		
        local aiBrain = GetAIBrain(unit)
        
        local faction = aiBrain.FactionIndex
		local StructurePool = aiBrain.StructurePool

		if LOUDENTITY( FACTORY, finishedUnit ) and finishedUnit.ArmyIndex == aiBrain.ArmyIndex then

			-- this was a tricky problem for engineers starting new bases since it was getting
			-- the LocationType from the platoon (which came from the original base not the new base)
			-- since the engineer is added to the new base (which changes his LocationType but not the platoons)
			-- it was necessary to change this call to use the units LocationType and NOT the platoons
            -- altered this so that we pass the locationtype to the factory when the build is started 
            ForkThread( aiBrain.BuilderManagers[finishedUnit.LocationType].FactoryManager.AddFactory, aiBrain.BuilderManagers[finishedUnit.LocationType].FactoryManager, finishedUnit, aiBrain )
		end

		-- if STRUCTURE see if Upgrade Thread should start - excluding NUKES & Strat Artillery (they get formed into their own platoons)
		if LOUDENTITY( GENERALSTRUCTURE, finishedUnit ) then
		
			finishedUnit.DesiresAssist = true

			AssignUnitsToPlatoon( aiBrain, StructurePool, {finishedUnit}, 'Support', 'none' )
            
            if finishedUnit.LaunchUpgradeThread then
                finishedUnit:LaunchUpgradeThread( aiBrain )
            --else
                --LOG("*AI DEBUG finishedUnit "..repr(finishedUnit.BlueprintID).." has no LaunchUpgradeThread")
            end

			-- TMLs --
			if LOUDENTITY( categories.TACTICALMISSILEPLATFORM, finishedUnit ) then
			
				if not finishedUnit.AIThread then
					finishedUnit.AIThread = finishedUnit:ForkThread( TMLThread, aiBrain)
				end
			end	
		
			-- Sera Rift Gate --
			if LOUDENTITY( T4FACTORIES, finishedUnit ) then
			
				local FBM = aiBrain.BuilderManagers[unit.LocationType].FactoryManager
				finishedUnit.AIThread = finishedUnit:ForkThread( RiftGateBehavior, aiBrain, FBM)
			end
	
			-- Aeon Eye of Rhianne --
			if LOUDENTITY( RHIANNE, finishedUnit ) then
			
				finishedUnit.AIThread = finishedUnit:ForkThread( EyeBehavior, aiBrain)
			end
		end
		
		-- Aeon CZAR (to make aircraft)
		if LOUDENTITY( categories.uaa0310, finishedUnit ) and not finishedUnit.CarrierThread then
			--finishedUnit.CarrierThread = finishedUnit:ForkThread( CzarCarrierThread, aiBrain )
		end
		
		-- UEF FatBoy (to make units)
		if LOUDENTITY( categories.uel0401, finishedUnit ) then
			--finishedUnit:ForkThread( FatBoyAI, aiBrain )
		end
		
		-- UEF Atlantis (to make aircraft)
		if LOUDENTITY( categories.ues0401, finishedUnit ) then
			--finishedUnit.CarrierThread = finishedUnit:ForkThread( AtlantisCarrierThread, aiBrain )
		end
		
        local guards = GetGuards(unit)
		
        for k,v in guards do
		
            if not v.Dead and v.AssistPlatoon then
			
                if PlatoonExists( aiBrain, v.AssistPlatoon ) then
				
                    v.AssistPlatoon = nil
                end
            end
        end
		
    end,

	ReassignEngineer = function( self, unit, aiBrain )
	
		local BM = aiBrain.BuilderManagers
		
		local bestManager = false
		local bestname 
		local distance = false
		
		local unitPos = GetPosition(unit)
        local checkDistance
        
        local VDist3 = VDist3

		for k,v in BM do
		
			if v.EngineerManager.Active and v.EngineerManager != self then
			
				checkDistance = VDist3( v.Position, unitPos)

				if not distance or checkDistance < distance then
			
					distance = checkDistance
					bestManager = v.EngineerManager
					bestname = k
				end
			end
		end

		if bestManager != self then
	
			LOG("*AI DEBUG "..aiBrain.Nickname.." Found a closer Manager "..repr(bestname))
		
			if self.Active then
				self:RemoveEngineerUnit(unit)
			end
		
			bestManager:AddEngineerUnit(unit)
		else
			return self:DelayAssignEngineerTask( unit, aiBrain )
		end
	end,
	
    ManagerLoopBody = function( self, builder, bType )
    end,

	-- thanks to splitting jobs out to the engineers that can do them - this check is redundant - always true
    BuilderParamCheck = function( self, builder, unit )
		
        if not unit.Dead and builder.InstanceAvailable > 0 then
			return true
		end
	
        return false
	end,

	-- this is the function which sets up and starts the Base Alert system for a base
	-- it determines if any threatening targets have entered the alert range of the base and issues an alert
	-- This base, and various platoons, use these alerts to send response teams
	BaseMonitorSetup = function( self, aiBrain)

		self.BaseMonitor = {
	
			BaseMonitorInterval = 6, 					-- how often the base monitor will do threat checks to raise alerts in seconds

			ActiveAlerts = 0,							-- number of active alerts at this base
			AlertLevel = 2,								-- threat must be this size to trigger an alert
			AlertTimeout = 12,							-- time it takes for a created alert to expire in seconds
		
			AlertRange = math.min( math.floor(self.Radius * 1.2), 150 ),		-- radius at which base will consider targets for an alert (between 108 and 150)
		
			AlertResponseTime = 11,						-- time it allows to pass before sending more responses to an active alert in seconds
		
			AlertsTable = {},							-- stores the data for each threat (position, amount of threat, type of threat)

			LastAlertTime = LOUDFLOOR(GetGameTimeSeconds()),	-- how long since last alert
		}
	
		--if ScenarioInfo.BaseMonitorDialog then
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." BASEMONITOR setting up - radius is "..self.BaseMonitor.AlertRange)
		--end
		
		self:ForkThread( self.BaseMonitorThreadLOUD, aiBrain)
    
		return
	end,

	-- This thread runs every BaseMonitorInterval & triggers the BaseMonitorThreatCheck() each
	-- iteration - when the location is ACTIVE -- the delay period increases upto an additional
	-- 20 seconds if there have not been any alerts
	-- at it's busiest - the thread will execute a threat check every 8 seconds
	-- for each minute that no threat is found - the interval will be increased by 1 second - to a max of 20 additional seconds
	BaseMonitorThreadLOUD = function( self, aiBrain )

		local DrawC = DrawCircle

        local LOUDCOPY  = LOUDCOPY
        local LOUDFIND  = LOUDFIND
        local LOUDFLOOR = LOUDFLOOR
        local LOUDLOG10 = math.log10
        local LOUDMAX   = LOUDMAX
		local LOUDMIN   = LOUDMIN
		local LOUDSORT  = LOUDSORT
		
		local GetUnitsAroundPoint = GetUnitsAroundPoint
        
        local BaseMonitorDialog = ScenarioInfo.BaseMonitorDialog or false
		
        local VDist2Sq = VDist2Sq
		local WaitTicks = WaitTicks
        
        local ArmyIndex = aiBrain.ArmyIndex
        local Location = self.Location
        local LocationType = self.LocationType
        
        local Position,Type,Threat

        local ThreatTypes = { 'Experimental', 'Land', 'Air', 'Naval', 'AntiSub' }

        local ThreatTypesUsed = {}
        local threatTable = {}

		-- this function will draw a visible radius around the base
		-- equal to the alert radius of the base each time the base
		-- looks for threats
		local function DrawBaseMonitorRadius( range )

			Position = aiBrain.BuilderManagers[self.LocationType].Position or false

			if Position then
  		
                local color = 'cc0055'      -- red --
		
                if aiBrain.BuilderManagers[LocationType].PrimaryLandAttackBase then
            
                    color = '00cc55'        -- green --
                end
            
                if aiBrain.BuilderManagers[LocationType].PrimarySeaAttackBase then
            
                    color = '0099dd'        -- bluish
                end
          
                if GetFocusArmy() == -1 or (ArmyIndex == GetFocusArmy()) or IsAlly(GetFocusArmy(), ArmyIndex) then

                    for j = 1, 3 do
			
                        for i = 0,9 do
				
                            DrawC( Position, range - i, color)
                            WaitTicks(1)
                        end
                    end
                end
            end
		end

		-- This function is used by the AI to put markers on a map so that Allied Humans can see them
		local function SetBaseMarker()
		
			if BaseMonitorDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." adding Marker")
			end
	
			if aiBrain.BuilderManagers[LocationType] then
				aiBrain.BuilderManagers[LocationType].MarkerID = AISendPing( Location, 'marker', ArmyIndex, aiBrain.Nickname.." "..LocationType )
			end
		end
		
		-- This function examines the HiPri intel list and decides if an ALERT needs to be triggered.

		-- A base can have one of each kind of threat (Air, Land and Naval)
		-- We loop thru the threat data for each of these 3 and for experimentals
		-- looking at any threat within the AlertRadius and greater than the AlertLevel
		-- If an experimental is found, it is examined to determine which kind of threat it is (Air, Land or Naval)
		-- If the base does not currently have an alert of that kind, an entry will be inserted into the AlertTable
		-- noting Position, Threat level and the kind of threat (Air, Land or Naval)
		-- This is then passed off to the BaseMonitorAlertTimeoutLOUD which will follow that threat,
		-- keeping it updated and active, or expiring it when it is no longer valid
		local function BaseMonitorThreatCheck()
 
            local GetUnitsAroundPoint   = GetUnitsAroundPoint
            local VDist2Sq              = VDist2Sq

            -- if there is a HiPri Intel List
			if aiBrain.IL.HiPri[1] then
                
                --if BaseMonitorDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR threat check building threatTable on tick "..GetGameTick() )
                --end
	
                local AlertLevel    = self.BaseMonitor.AlertLevel
				local AlertRadius   = self.BaseMonitor.AlertRange
		
                -- primary land base has a larger radius
				if aiBrain.BuilderManagers[LocationType].PrimaryLandAttackBase then
					AlertRadius = self.BaseMonitor.AlertRange + 25
				end

				if ScenarioInfo.DisplayBaseMonitors or aiBrain.DisplayBaseMonitors then
					ForkThread( DrawBaseMonitorRadius, AlertRadius )
				end

                -- rather than taking a full copy of HiPri - we could iterate over HiPri and just take what we need 
                -- with a smaller footprint since we don't care about things like lastscouted, lastupdate and Permanent
                -- or threat types we don't process or those beyond AlertRadius
                threatTable = {}        -- table of threat items to process
                ThreatTypesUsed = {}    -- table of threat types we processed
                
                local TType, TThreat, TPosition
                
                for _,v in aiBrain.IL.HiPri do
                
                    TType       = v.Type or false
                    TThreat     = v.Threat
                    TPosition   = v.Position

                    if TType and TThreat > 0 and VDist3( TPosition, Location ) <= (AlertRadius + 50) then

                        if LOUDFIND( ThreatTypes, TType ) then

                            LOUDINSERT( threatTable, { Position = TPosition, Threat = TThreat, Type = TType } )
                            
                            if not LOUDFIND( ThreatTypesUsed, TType ) then
                                LOUDINSERT( ThreatTypesUsed, TType )
                            end

                        end
                    end

                end

				-- if there is a threat table and we have a position
				if threatTable[1] and Location then

					-- sort the threat table by distance from this base --
					LOUDSORT(threatTable, function (a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], Location[1],Location[3]) < VDist2Sq(b.Position[1],b.Position[3], Location[1],Location[3]) end)
                
                    --if BaseMonitorDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR threat check using threatTable "..repr(threatTable) )
                    --end

					local highThreat, highThreatPos, highThreatType
                    local alertraised, alertrangemod
		
					for _,LoopType in ThreatTypesUsed do
                
                        if BaseMonitorDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR threat check reviews "..LoopType.." on tick "..GetGameTick() )
                        end
					
						alertraised = false
						alertrangemod = 0

                        -- highthreat can now be modified by a ratio or the AIMult --
						highThreat = AlertLevel	-- this sets the basic threat required to trigger an alert
                        
                        if LoopType == 'Land' then
                        
                            -- mult by current LandRatio
                            highThreat = highThreat * LOUDMAX( 0.8, aiBrain.LandRatio or 1)
                            
                            -- and again by the base AIMult (carried in VeterancyMult) --
                            highThreat = highThreat * ( 1 + LOUDLOG10( aiBrain.VeterancyMult))
                        end
                        
                        if LoopType == 'Air' then
                        
                            alertrangemod = 50                  -- AIR threats checked at greater range
                        
                            highThreat = highThreat * 3         -- AIR threats MUST be thrice the normal size to trigger --
                        
                            -- NOTE -- This is an interesting application point since if AirRatio is bad - he'll throw alerts all the time --
                            highThreat = highThreat * LOUDMAX( 0.8, aiBrain.AirRatio or 1)      -- The AirRatio will modify his alert trigger - even down if bad
                            
                            highThreat = highThreat * ( 1 + LOUDLOG10( aiBrain.VeterancyMult))     -- higher mult means AIR threats must be larger to trigger
                            
                        end
                        
                        if LoopType == 'Naval' or LoopType == 'AntiSub' then
                        
                            highThreat = highThreat * LOUDMAX( 0.8, aiBrain.NavalRatio or 1)
                            
                            highThreat = highThreat * ( 1 + LOUDLOG10( aiBrain.VeterancyMult))
                        
                        end
                        
						highThreatPos = false
						highThreatType = false
	
						if not self.BaseMonitor.AlertsTable[LoopType] then		-- this means we always check experimentals but bypass any already active alert types
					
                            if BaseMonitorDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR checks "..repr(LoopType).." with alert trigger "..highThreat.." at radius "..AlertRadius + alertrangemod.." on tick "..GetGameTick() )
                            end
					
							-- loop thru the threat list
							for _,threat in threatTable do
                            
                                Position    = threat.Position
                                Threat      = threat.Threat
                                Type        = threat.Type or false

								-- filter by distance from the base and break out if threats are farther away (we presorted by distance)
								if Type == LoopType and Threat >= highThreat then

                                    if BaseMonitorDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR examines "..repr(Position).." - "..repr(Threat).." distance is "..repr(VDist3(Position,Location)) )
                                    end

									-- signal that an alert has been raised 
									alertraised = true

                                    -- record the threat and it's position --
									highThreat = Threat
									highThreatPos = {Position[1], Position[2], Position[3]}
							
                                    -- determine the Type of threat it is
									if Type == 'Experimental' then
							
										experimentalsair = GetUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL * categories.AIR, highThreatPos, 120, 'Enemy')
										experimentalssea = GetUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL * categories.NAVAL, highThreatPos, 120, 'Enemy')
										
										if experimentalsair[1] then

											highThreatType = 'Air'

										elseif experimentalssea[1] then
    
											highThreatType = 'Naval'

										else

											highThreatType = 'Land'

										end

									else
										highThreatType = threat.Type
									end

									break	-- we raised an alert - we dont check any more of this looptype

								end

							end

						else
					
                            if BaseMonitorDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR has "..repr(self.BaseMonitor.AlertsTable[LoopType]).." ALERT underway on tick "..GetGameTick() )
                            end
                       
                        end

						-- if we raised a threat -- and don't already have one of this type --
						-- AlertsTables can now log multiple threats of the same type --

						if alertraised and not self.BaseMonitor.AlertsTable[highThreatType] then
			
							-- update the BaseMonitors total active alerts
							self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
						
							-- record the time of the alert
							self.BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())
					
							-- put an entry into the alert table for this threat type
							self.BaseMonitor.AlertsTable[highThreatType] = { Position = highThreatPos, Threat = highThreat }
						
							-- notify the brain there is an alert at a base
							aiBrain.BaseAlertSounded = true
							
							if BaseMonitorDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR raises "..highThreatType.." alert of "..math.floor(highThreat).." at position "..repr(highThreatPos))
							end
							
							-- accurately check the threat, launch the response thread, and monitor the threat until its gone
							self:ForkThread( self.BaseMonitorAlertTimeoutLOUD, aiBrain, highThreatPos, Location, highThreatType, ((AlertRadius + alertrangemod)*(AlertRadius + alertrangemod)) )
						end

                    end

				end

			end

		end

		if BaseMonitorDialog then
			LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR starts with radius "..self.BaseMonitor.AlertRange.." on tick "..GetGameTick() )
		end
	
        local Interval  = self.BaseMonitor.BaseMonitorInterval
		local delay     = Interval or 2
        
        -- using this flag to control appearance of delays so they only appear when they change
        local lastdelay = 0

		while self.Active do
        
            BaseMonitorDialog = ScenarioInfo.BaseMonitorDialog or false
			
			WaitTicks(( Interval + delay ) * 10 )        
		
			if self.Active then

                --if BaseMonitorDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR thread cycles on tick "..GetGameTick() )
                --end
		
				if ScenarioInfo.DisplayBaseNames or aiBrain.DisplayBaseNames then
                
					if not aiBrain.BuilderManagers[LocationType].MarkerID then
						ForkThread( SetBaseMarker )
					end
                    
				else
                
                    if aiBrain.BuilderManagers[LocationType].MarkerID then
   						ForkThread( RemoveBaseMarker, aiBrain, LocationType, aiBrain.BuilderManagers[LocationType].MarkerID)
                    end
                    
                end
		
				ForkThread( BaseMonitorThreatCheck )
			end
		
			delay = (GetGameTimeSeconds()) - self.BaseMonitor.LastAlertTime
		
			delay = LOUDFLOOR(delay/150)	-- delay is increased by 1 second for every 2.5 minutes since last alert
			delay = LOUDMIN(delay, 15)	-- delay is capped at 15 additional seconds

		end
	
	end,

	-- When an alert is created by the BaseMonitorThreatCheck - control gets handed to this thread.

	-- The intitial data is the position of the threat, the location of the base raising the threat
	-- and the kind of threat (Air, Land or Naval)
	-- Using the initial position - look around that point in a radius and pick up all the units
	-- related to that threat (Air, Land or Naval).  By adding up all the positions, and threat amounts
	-- and averaging them by the number of units we found, we have an average position and total threat
	-- we write that new information to the AlertsTable

	-- If the threat level is high enough, we pause for the AlertTimeout period
	-- before repeating the above process to get new values
	-- The cycle ends when the threat falls below the threshold or moves out of the distress range
	-- we then delete the entry from the AlertsTable and lower the number of ActiveAlerts by 1,

	-- Sure - this could be modded to have multiple threats of the same kind going on at once,
	-- but my fear here was having the responding units ping-ponging between two or more threats at once. 

	BaseMonitorAlertTimeoutLOUD = function( self, aiBrain, pos, baseposition, threattype, distressrange )
    
        local BaseMonitorDialog = ScenarioInfo.BaseMonitorDialog
        local header = "*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." BASEMONITOR ALERT "
        
        local BaseMonitor   = self.BaseMonitor
		local threshold     = BaseMonitor.AlertLevel
        
        local LocationType = self.LocationType
        
        local GetPosition   = GetPosition
        local LOUDCOPY      = LOUDCOPY
		local LOUDFLOOR     = LOUDFLOOR
		local VDist2Sq      = VDist2Sq
		local WaitTicks     = WaitTicks
	
		local GetUnitsAroundPoint = GetUnitsAroundPoint
		
		local threat = 0
		
		local myThreat
		local targetUnits
		local x1,x2,x3,count,newpos,unitpos,bp

        local LocationInWaterCheck = function(position)
            return GetTerrainHeight(position[1], position[3]) < GetSurfaceHeight(position[1], position[3])
        end    

		-- loop until the alert falls below the trigger or moves outside the alert radius
		repeat

            BaseMonitorDialog = ScenarioInfo.BaseMonitorDialog or false
            
			-- look for units of the threattype
			if threattype == 'Land' then
            
				targetUnits = GetUnitsAroundPoint( aiBrain, LANDUNITS, pos, 120, 'Enemy')
			
			elseif threattype == 'Air' then
            
				targetUnits = GetUnitsAroundPoint( aiBrain, AIRUNITS, pos, 120, 'Enemy')
			
			elseif threattype == 'Naval' or threattype == 'AntiSub' then
            
				targetUnits = GetUnitsAroundPoint( aiBrain, categories.MOBILE - categories.AIR, pos, 120, 'Enemy')

			end

			x1 = 0
			x2 = 0
			x3 = 0
			count = 0

			threat = 0

			-- loop thru units found and accumulate threat and positions
			for _, nearunit in targetUnits do
		
				if not nearunit.Dead then
		
					unitpos = GetPosition(nearunit)
                    
                    if threattype == 'Naval' or threattype == 'AntiSub' then

                        -- confirm target positions are on the water
                        if not LocationInWaterCheck(unitpos) then
                            continue
                        end

                    end

					if unitpos then
						x1 = x1 + unitpos[1]
						x2 = x2 + unitpos[2]
						x3 = x3 + unitpos[3]
					
						count = count + 1
					
						bp = __blueprints[nearunit.BlueprintID].Defense

						if threattype == 'Land' then
							threat = threat + bp.SurfaceThreatLevel
					
						elseif threattype == 'Air' then
							threat = threat + bp.SurfaceThreatLevel
							threat = threat + bp.AirThreatLevel
					
						elseif threattype == 'Naval' then
							threat = threat + bp.SurfaceThreatLevel
							threat = threat + bp.SubThreatLevel
                            
                        elseif threattype == 'AntiSub' then
                            threat = threat + bp.SubThreatLevel

						end

					end

				end

			end
		
			-- if there are units and the threat is above the threshold
			-- update the alerts table, time of last alert, ping interface
			-- and launch the response thread if not already underway --
			if count > 0 and threat >= threshold then

				if BaseMonitorDialog then
					LOG( header.." "..threattype.." - "..count.." units found with threat of "..threat.." - ALERT ! on tick "..GetGameTick() )
				end

				-- do the average position calculation -- 
				newpos = { x1/count, x2/count, x3/count }
			
				-- re-write the alert data with new values
				BaseMonitor.AlertsTable[threattype] = { Position = newpos, Threat = threat }

				-- mark the brain that a base is sounding an alert
				aiBrain.BaseAlertSounded = true

				pos = LOUDCOPY(newpos)
		
				BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())

				-- if we haven't launched a response thread
				if aiBrain.BuilderManagers[LocationType].EngineerManager and not aiBrain.BuilderManagers[LocationType].EngineerManager.BMDistressResponseThread then
				
					aiBrain.BuilderManagers[LocationType].EngineerManager.BMDistressResponseThread = true
				
					self:ForkThread( self.BaseMonitorDistressResponseThread, aiBrain)

					if ScenarioInfo.DisplayPingAlerts or aiBrain.DeliverStatus then
					
						LOG( header.." "..threattype )
					
						-- send the visible ping to the interface --
						AISendPing(newpos, 'attack', aiBrain.ArmyIndex)
					end
				end
			
				if BaseMonitorDialog then
					LOG( header.." "..threattype.." threat is "..math.floor(threat).." distance is "..math.floor(VDist2(pos[1],pos[3], baseposition[1],baseposition[3])) )
				end

				WaitTicks( BaseMonitor.AlertTimeout * 10 ) -- before checking this threat again --
			else
			
				--if BaseMonitorDialog then
					--LOG( header.." "..threattype.." - "..count.." units found with threat of "..threat.." - NO ALERT raised")
				--end
			end

		until (threat < threshold) or VDist2Sq(pos[1],pos[3], baseposition[1],baseposition[3]) > distressrange

		BaseMonitor.AlertsTable[threattype] = nil
		BaseMonitor.ActiveAlerts = BaseMonitor.ActiveAlerts - 1
		
		if BaseMonitorDialog then
			LOG( header.." deactivates "..threattype )
		end

		-- if no more alerts reset the alert table
		if BaseMonitor.ActiveAlerts == 0 then

			BaseMonitor.AlertsTable = {}

			aiBrain.BaseAlertSounded = false
			
			if BaseMonitorDialog then
				LOG( header.." has no activity")
			end
		else
            aiBrain.BaseAlertSounded = true
		end
	
	end,
	
	-- This function is designed to get a distress position and send all of the appropriate
	-- pool units it has, to respond to it

	--  The base has 4 groups of response units which are tailored to respond (or not) to each of the 3 distress kinds
	--	This allows it to send it's land units and gunships to a LAND
	-- 	alert, while fighters deal with an AIR alert and the naval units
	--	go after an enemy naval threat
	--  There is one overlap - when a LAND and NAVAL alert are both
	-- 	triggered, the gunship/bomber group will get ping ponged

	-- I added an additional function after observing this base alert response
	-- I decided that the longer an alert goes on, the greater the period should
	-- be between responses from the AI - I grow it by 10 seconds per cycle
	BaseMonitorDistressResponseThread = function( self, aiBrain )
	
        local GetPosition   = GetPosition
        local LOUDABS       = LOUDABS
        local LOUDFLOOR     = LOUDFLOOR
        local VDist2        = VDist2
        local VDist2Sq      = VDist2Sq
		local WaitTicks     = WaitTicks
        
        local GetThreatAtPosition = GetThreatAtPosition

        local Defense

		local GetThreatOfGroup = function( group, distressType )
	
			local totalThreat = 0

			if distressType == 'Land' then
		
				for _,u in group do

					if not u.Dead then
						totalThreat = totalThreat + (__blueprints[u.BlueprintID].Defense.SurfaceThreatLevel or 0)
					end
				end
			
				return totalThreat	
			end
		
			if distressType == 'Naval' then
		
				for _,u in group do
                
					if not u.Dead then
                    
                        Defense = __blueprints[u.BlueprintID].Defense
                        
						totalThreat = totalThreat + (Defense.SurfaceThreatLevel or 0) + (Defense.SubThreatLevel or 0)
					end
				end
			
				return totalThreat	
			end

			if distressType == 'AntiSub' then
		
				for _,u in group do
                
					if not u.Dead then

						totalThreat = totalThreat + (__blueprints[u.BlueprintID].Defense.SubThreatLevel or 0)
					end
				end
			
				return totalThreat	
			end
		
			if distressType == 'Air' then
		
				for _,u in group do
					if not u.Dead then
						totalThreat = totalThreat + (__blueprints[u.BlueprintID].Defense.AirThreatLevel or 0)
					end
				end
			
				return totalThreat	
			end		
		end
        
        local BaseMonitorDialog             = ScenarioInfo.BaseMonitorDialog or false
        local BaseDistressResponseDialog    = ScenarioInfo.BaseDistressResponseDialog or false

        local LocationType  = self.LocationType
		local baseposition  = aiBrain.BuilderManagers[LocationType].Position
		local radius        = aiBrain.BuilderManagers[LocationType].Radius
    
		local distressunderway = true
		local response = false
	
		local recovery = false
	
		local distress_air      = false
		local distress_ftr      = false
		local distress_land     = false
		local distress_naval    = false

        local DistressRepeats   = 0
		local DistressTypes     = { 'Air', 'Land', 'Naval' }
		
		local distressLocation, distressType, threatamount, lastdistressLocation
	
		local grouplnd, groupair, groupsea, groupftr
		local grouplndcount, groupaircount, groupseacount, groupfrtcount, nextposheight

        local BaseMonitorGetDistressLocation = self.BaseMonitorGetDistressLocation
        local RallyPoints = aiBrain.BuiderManagers[LocationType].RallyPoints
		
		-- the intent of this function is to make sure that we don't try and respond over mountains
		-- and rivers and other serious terrain blockages -- these are generally identified by
        -- a rapid elevation change over a very short distance
		local function CheckBlockingTerrain( pos, targetPos )

            local GetTerrainHeight = GetTerrainHeight	

			-- This gives us the approx number of 8 ogrid steps in the distance
			local steps = LOUDFLOOR( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 8 ) + 1
	
			local xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
			local ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step
			
			local lastpos = {pos[1], 0, pos[3]}
            local lastposHeight = GetTerrainHeight( lastpos[1], lastpos[3] )
            
            local nextpos = { 0, 0, 0 }
	
			-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
			for i = 1, steps do
		
                nextpos[1] = pos[1] - (xstep * i)
                nextpos[3] = pos[3] - (ystep * i)
			
				nextposHeight = GetTerrainHeight( nextpos[1], nextpos[3] )

				-- if more than 3.6 ogrids change in height over 8 ogrids distance
				if LOUDABS(lastposHeight - nextposHeight) > 3.6 then

                    if BaseMonitorDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." DISTRESS RESPONSE OBSTRUCTED to "..repr(targetPos))
                    end

                    return true
				end

                lastpos[1] = nextpos[1]
                lastpos[3] = nextpos[3]
                lastposHeight = nextposHeight

			end
	
			return false
		end
		
		if BaseMonitorDialog then
			LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE underway for "..self.BaseMonitor.ActiveAlerts.." alerts")
		end
        
        local BaseMonitor       = self.BaseMonitor
        local AlertResponseTime = BaseMonitor.AlertResponseTime
        local AlertRings        = math.floor( 120/ScenarioInfo.IMAPSize)

        local GetDistressDistance
        local counter, totalthreatsent, threatlimit

		-- this loop runs as long as there is distress underway and the base exists and has active alerts
		-- repeating every AlertResponseTime period
		while distressunderway and self.Active and BaseMonitor.ActiveAlerts > 0 do
		
            if BaseMonitorDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE cycles on tick "..GetGameTick() )
            end 
      
			distressunderway = false

            -- loop thru each threat type and try to respond
			for _,distresskind in DistressTypes do
			
				GetDistressDistance = BaseMonitor.AlertRange
				
				if distresskind == 'Air' then
					GetDistressDistance = GetDistressDistance + 65
				end

				distressLocation, distressType, threatamount = BaseMonitorGetDistressLocation( self, aiBrain, baseposition, GetDistressDistance, BaseMonitor.AlertLevel, distresskind )

				if distressLocation then
                
                    lastdistressLocation = table.copy(distressLocation)
				
					if BaseDistressResponseDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE begins for "..repr(distressType).." at "..repr(distressLocation) )
					end
		
					distressunderway = true
				
					-- respond with land units
					if distressType == 'Land' then

						grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, LANDRESPONSE, baseposition, radius )
					
						if grouplndcount > 4 then
						
							if BaseDistressResponseDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE to "..distressType.." value "..GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSurface' ).." my assets are "..GetThreatOfGroup(grouplnd,'Land'))
							end
							
							-- only send response if we can muster 70% of enemy threat
							if GetThreatOfGroup(grouplnd,'Land') >= ( GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSurface' ) * .70) then
							
								-- must have a clear unobstructed path to location --
								if not CheckBlockingTerrain( baseposition, distressLocation ) then
					
									-- Move the land group to the distress location and then back to the location of the base
									IssueClearCommands( grouplnd )
                                    
                                    -- so new thinking - get all the units but sort for closest first
                                    -- select enough units to at least double the enemy threat
                                    -- put those into new list and then sort for furthest
                                    
                                    -- sort all the response units so that the farthest will be first in the list
                                    LOUDSORT( grouplnd, function(a,b) local GetPosition = GetPosition local VDist2Sq = VDist2Sq return VDist2Sq(GetPosition(a)[1],GetPosition(a)[3], distressLocation[1],distressLocation[3]) > VDist2Sq(GetPosition(b)[1],GetPosition(b)[3], distressLocation[1],distressLocation[3]) end)

                                    counter = 0
                                    totalthreatsent = 0
                                    
                                    threatlimit = ( GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSurface' ) * 2)
                                    
                                    -- send 5 per second to the distressLocation --
                                    for _,u in grouplnd do
                                    
                                        if not u.Dead then
                                            IssueAggressiveMove( {u}, RandomLocation(distressLocation[1],distressLocation[3], 15))
                                            counter = counter + 1
                                            totalthreatsent = totalthreatsent + (__blueprints[u.BlueprintID].Defense.SurfaceThreatLevel or 0)
                                        end
                                        
                                       
                                        if totalthreatsent > threatlimit then
                                            break   -- dont send any more units --
                                        end
                                        
                                        -- wait one second for every 5 units sent
                                        if counter >= 4 then
                                            WaitTicks(11)
                                            counter = 0
                                        end
                                        
                                    end
					
                                    -- then send them back to rally points --
									DisperseUnitsToRallyPoints( aiBrain, grouplnd, baseposition, RallyPoints, distressLocation, 2 )

									response = true
									distress_land = true
								end
							else
								if BaseDistressResponseDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE unable to respond to "..distressType.." only have "..GetThreatOfGroup(grouplnd,'Land'))
								end	

                                IssueClearCommands( grouplnd )
							
                                -- move the units to the 3 rallypoints closest to the distressLocation
                                DisperseUnitsToRallyPoints( aiBrain, grouplnd, baseposition, RallyPoints, distressLocation, 3 )
							end

						end

					end
				
					-- respond with naval units
					if distressType == 'Naval' or distressType == 'AntiSub' then
				
						groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, SEARESPONSE, baseposition, radius )
					
						if groupseacount > 2 then
                        
                            local enemynavalthreat = GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSurface') + GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSub')
						
							if BaseDistressResponseDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE to "..enemynavalthreat.." at "..repr(distressLocation).." - my "..LOUDGETN(groupsea).." assets are valued at "..repr(GetThreatOfGroup(groupsea,'Naval') ).." threat" )
							end
				
                            -- only send response if we can muster 70% of enemy threat
							if GetThreatOfGroup(groupsea,'Naval') >= (enemynavalthreat * .70) then

								-- Move the naval group to the distress location and then back to the location of the base
								IssueClearCommands( groupsea )

                                -- sort all the response units so that the farthest will be first in the list
                                LOUDSORT( groupsea, function(a,b) local GetPosition = GetPosition local VDist2Sq = VDist2Sq return VDist2Sq(GetPosition(a)[1],GetPosition(a)[3], distressLocation[1],distressLocation[3]) > VDist2Sq(GetPosition(b)[1],GetPosition(b)[3], distressLocation[1],distressLocation[3]) end)

                                counter = 0
                                totalthreatsent = 0
                                
                                threatlimit = ( GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSurface' ) + GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiSub')) + 10

                                -- send upto 5 units every 11 ticks, to the distressLocation --
                                for _,u in groupsea do

                                    if not u.Dead then
                                        IssueAggressiveMove( {u}, RandomLocation(distressLocation[1],distressLocation[3], 10))
                                        counter = counter + 1

                                        Defense = __blueprints[u.BlueprintID].Defense
                                        totalthreatsent = totalthreatsent + (Defense.SurfaceThreatLevel or 0) + (Defense.SubThreatLevel or 0)
                                    end

                                    if totalthreatsent > threatlimit then
                                        break   -- dont send any more units --
                                    end

                                    if counter >= 4 then
                                        WaitTicks(11)
                                        counter = 0
                                    end
                                end

                                -- then send them back to 2 nearest rally points --
                                DisperseUnitsToRallyPoints( aiBrain, groupsea, baseposition, RallyPoints, distressLocation, 2 )

                                response = true
								distress_naval = true
							else
								if BaseDistressResponseDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE unable to respond to "..repr(distressType).." only have "..repr(GetThreatOfGroup( groupsea,'NavalAntiSurface') ) )
								end

                                IssueClearCommands( groupsea )                                

                                -- move the units to the 3 rallypoints closest to the distressLocation
                                DisperseUnitsToRallyPoints( aiBrain, groupsea, baseposition, RallyPoints, distressLocation, 3 )
							end
                            
						end
					end
	
                    -- respond with air units 
					if distressType then
		
						-- respond with gunships and bombers if NOT air distress
						if distressType != 'Air' then
                        
                            -- but only if there has been a response from another layer
                            if response then
                        
                                if distressType !='Naval' then
						
                                    -- get all bombers and gunships not already in platoons
                                    groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, GROUNDATTACK, baseposition, radius, true  )

                                    if groupaircount > 1 then

                                        if BaseDistressResponseDialog then
                                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE bomber/gunship to "..distressType.." value "..threatamount.." using Air assets of "..GetThreatOfGroup(groupair,'Land'))
                                        end
						
                                        -- Move the gunship/bomber group to the distress location and issue guard there 
                                        IssueClearCommands( groupair )
                                        IssueAggressiveMove( groupair, distressLocation )
                                
                                        DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, RallyPoints, distressLocation, 5 )                                
					
                                        response = true
                                        distress_air = true
                                    else
						
                                        if BaseDistressResponseDialog then
                                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE bomber/gunship unable to respond to "..distressType.." only have "..groupaircount)
                                        end
                                
                                        -- move the units to the 3 rallypoints closest to the distressLocation
                                        DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, RallyPoints, distressLocation, 3 )						
                                    end
                            
                                else
						
                                    -- get all torpedobombers and gunships not already in platoons
                                    groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, NAVALATTACK, baseposition, radius, true )

                                    if groupaircount > 2 then

                                        if BaseDistressResponseDialog then
                                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE torpedobomber/gunship to "..distressType.." value "..threatamount.." using Air assets of "..GetThreatOfGroup(groupair,'Land'))
                                        end
						
                                        -- Move the torpedo/gunship group to the distress location and issue guard there 
                                        IssueClearCommands( groupair )
                                        IssueAggressiveMove( groupair, distressLocation )
                                
                                        DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, RallyPoints, distressLocation, 5 )                                
					
                                        response = true
                                        distress_air = true
                                    else
						
                                        if BaseDistressResponseDialog then
                                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE torpedo/gunship unable to respond to "..distressType.." only have "..groupaircount)
                                        end

                                        IssueClearCommands( groupair )                                

                                        -- move the units to the 3 rallypoints closest to the distressLocation
                                        DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, RallyPoints, distressLocation, 3 )						
                                    end
                                
                                end
                            
                            end
                            
						else

							-- locate all anti-air air units not already in platoons
							groupftr, groupftrcount = GetFreeUnitsAroundPoint( aiBrain, FIGHTERS, baseposition, radius, true )

							-- if there are more than 4 anti-air units
							if groupftrcount > 4 then 
						
								if BaseDistressResponseDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE fighters to "..distressType.." value "..threatamount)
								end
						
								-- and we can match at least 66% of the enemy threat
								if GetThreatOfGroup(groupftr,'Air') >= ( GetThreatAtPosition( aiBrain, distressLocation, AlertRings, true, 'AntiAir' )/1.5) then
					
									-- Move the fighter group to the distress location 
									IssueClearCommands( groupftr )
									IssueAggressiveMove( groupftr, distressLocation )
				
									response = true
									distress_ftr = true
								else
							
									if BaseDistressResponseDialog then
										LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE fighters unable to respond to "..distressType.." my threat is only "..GetThreatOfGroup(groupftr,'Air'))
									end
                                    
                                    -- move the units to the 5 rallypoints closest to the distressLocation
                                    DisperseUnitsToRallyPoints( aiBrain, groupftr, baseposition, RallyPoints, distressLocation, 5 )
								end
                                
							else
							
								if BaseDistressResponseDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE fighters unable to respond to "..distressType.." only have "..groupftrcount)
								end
                                
                                IssueClearCommands( groupftr )

                                -- move the units to the 3 rallypoints closest to the distressLocation
                                DisperseUnitsToRallyPoints( aiBrain, groupftr, baseposition, RallyPoints, distressLocation, 3 )
							end

						end

					end
                    
				else
				
					if BaseDistressResponseDialog then
						LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE Got no distressLocation for "..distresskind.." at baseposition "..repr(baseposition) )
					end
                
                end

			end
			
			if not response then

				if BaseDistressResponseDialog or BaseMonitorDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE - no response to "..repr(distressType).." at "..repr(distressLocation).." repeats "..DistressRepeats)
				end

				-- as a base responds to a continued alert I want to gradually slow the response loop
				-- this allows a base more time to gather additional units before sending them out 
				-- this will reduce the effect of 'kiting' the AI out of his base by triggering an alert
				DistressRepeats = LOUDMIN(DistressRepeats + 1, 8)
                
			else
                DistressRepeats = 0
            end
            
            -- if we have not been able to respond to distress
            -- then close this distress repsonse
            if DistressRepeats > 8 then
                distressunderway = false
            end

			-- Delay between Distress check cycles
            if distressunderway then
            
                if BaseDistressResponseDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE waiting "..(AlertResponseTime + (DistressRepeats*4)).." seconds until next cycle - tick "..GetGameTick() )
                end
                
                -- each DistressRepeat adds 4 seconds to each response period --
                WaitTicks( (AlertResponseTime + (DistressRepeats*4)) * 10)
            end

		end

        if BaseDistressResponseDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE completed" )
        end        
	
		-- If there was a response by any group try and send those groups back to rally points
		-- note that recovery is done at the EM radius * 1.75 to pick up everyone
		if response then

            if BaseDistressResponseDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..LocationType.." BASEMONITOR DISTRESS RESPONSE - last distress position is "..repr(lastdistressLocation) )
            end        

            -- reset the Distress Repeats --
			DistressRepeats = 0
			
			if distress_land then 
		
				grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.ANTIAIR - categories.SCOUT - categories.COMMAND - categories.ENGINEER, baseposition, (self.Radius * 1.75) )

				if grouplndcount > 0 then
			
					-- Move the land group back to closest land base
					IssueClearCommands( grouplnd )
				
					-- we need to find the closest LAND manager name at this point
					-- put grouplnd into a platoon --
					-- use FindClosestBaseName( aiBrain, GetPlatoonPosition(), false, false ) for BaseName
					-- use BaseName instead of LocationType below
					-- OR JUST RTB the platoon
					DisperseUnitsToRallyPoints( aiBrain, grouplnd, baseposition, RallyPoints, lastdistressLocation, 3 )
				
					recovery = true
				end
			end

			if distress_naval then

				groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, (categories.NAVAL * categories.MOBILE) - categories.STRUCTURE - categories.ENGINEER, baseposition, self.Radius * 1.75 )		

				if groupseacount > 0 then
			
					-- Move the naval group back to the closest naval base
					IssueClearCommands( groupsea )
				
					-- we need to find the closest SEA manager at this point
					DisperseUnitsToRallyPoints( aiBrain, groupsea, baseposition, RallyPoints, lastdistressLocation, 3 )
				
					recovery = true
				end
			end

			if distress_air then
		
				groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY, baseposition, self.Radius * 2.5 )
			
				if groupaircount > 0 then
			
					-- Move the gunship/bomber group back to base 
					IssueClearCommands( groupair )
				
					DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, RallyPoints, lastdistressLocation, 3 )
				
					recovery = true
				end
			end
		
			if distress_ftr then
		
				groupftr, groupftrcount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.ANTIAIR), baseposition, self.Radius * 2.5 )
			
				if groupftrcount > 0 then
			
					-- Move the fighter group back to base 
					IssueClearCommands( groupftr )
				
					DisperseUnitsToRallyPoints( aiBrain, groupftr, baseposition, RallyPoints, lastdistressLocation, 3 )
				
					recovery = true
				end
			end	
		end

		self.BMDistressResponseThread = nil
	end,

	-- So, if your following the story then you know we now have detailed alert information 

	-- This is the primary function used by a base for interrogating if there are
	-- any distress calls in action.  Each request must indicate where you
	-- are, how far away a threat can be, the amount of threat it must have and
	-- the kind of distress you are looking for (Air, Land or Naval). I dont 
	-- presently use the threshold - as the threat levels are filtered by the
	-- process which creates them.  You can assume that the threat is always 
	-- viable and needs help

	-- Distress calls can be created by 3 different processes
	-- A Commander		CommanderThread
	-- A Base			BaseMonitorThreatCheck
	-- A Platoon		PlatoonCallForHelpAI

	-- And each of them is stored in a different place.

	-- Commanders store their distress calls directly in aiBrain in a single variable that will have a postion in it if the CDR is in distress
	-- Bases store their alerts in the Engineer Manager BaseMonitor Alerts table - a flag stored in aiBrain signifies if there are ANY bases with distress calls
	-- Platoons store their alerts in the PlatoonDistress table in aiBrain with a flag that notes if there are ANY platoons with an ongoing distress call

	-- brain flag indicating if there are ANY base alerts anywhere

	-- We check all 3 - Commanders, Bases then platoons
	-- function returns a position, a threattype and a threat amount -- false if no distress 
	BaseMonitorGetDistressLocation = function( self, aiBrain, baseposition, radius, threshold, threattype )
    
        local LOUDCOPY      = LOUDCOPY
        local PlatoonExists = PlatoonExists
        local VDist3        = VDist3
	
		-- Commander Distress is 1st priority --
		if aiBrain.CDRDistress then
			if (threattype == 'Land' or threattype == 'Air') and VDist3( aiBrain.CDRDistress, baseposition ) < (radius*2) then
				return aiBrain.CDRDistress, threattype, 25
			end
		end
	
        local AlertsTable = self.BaseMonitor.AlertsTable[threattype]

		-- Base Alerts are second --
		if AlertsTable then
			return AlertsTable.Position, threattype, AlertsTable.Threat
		end

		-- Platoon Distress calls -- 
		if aiBrain.PlatoonDistress.AlertSounded then

			local returnPos = { 0, 0, 0 }
			local returnThreat = 0
			local distressdist, distressposition
            
            local Platoons = aiBrain.PlatoonDistress.Platoons
		
			for _,v in Platoons do
		
				if threattype == v.DistressType then
			
					if PlatoonExists( aiBrain, v.Platoon ) then
				
                        distressposition = v.Position
						distressdist = VDist3(baseposition, distressposition)

						-- if closest one - store it
						if distressdist <= radius then

							returnPos[1] = distressposition[1]
                            returnPos[2] = distressposition[2]
                            returnPos[3] = distressposition[3]
							returnThreat = v.Threat
							distance = distressdist
						end
					end
				end
			end

            if returnThreat > 0 then
                return returnPos, threattype, returnThreat
            end
		end

		return false, false, 0
	end,
}

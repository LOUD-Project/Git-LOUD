--   /lua/sim/EngineerManager.lua

-- The Engineer Manager (EM) is responsible for managing the various builders (tasks) that 
-- an engineer can select from when he goes looking for work

local import = import

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager

local MassFabThread = import('/lua/ai/aibehaviors.lua').MassFabThread
local TMLThread = import('/lua/ai/aibehaviors.lua').TMLThread
local RiftGateBehavior = import('/lua/ai/aibehaviors.lua').RiftGateBehavior
local EyeBehavior = import('/lua/ai/aibehaviors.lua').EyeBehavior
local FatBoyAI = import('/lua/ai/aibehaviors.lua').FatBoyAI
local CzarCarrierThread = import('/lua/ai/aibehaviors.lua').CzarCarrierThread

local CreateEngineerBuilder = import('/lua/sim/Builder.lua').CreateEngineerBuilder

local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local BeenDestroyed = moho.entity_methods.BeenDestroyed
local MakePlatoon = moho.aibrain_methods.MakePlatoon

local LOUDFLOOR = math.floor
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove
local LOUDENTITY = EntityCategoryContains

local VDist2Sq = VDist2Sq

local ForkThread = ForkThread

local WaitTicks = coroutine.yield

-- add support for builderType (ie. Any, Commander)	-- so now we can specify as follows;
local builderTypes = { 'Any','T1','T2','T3','SubCommander','Commander' }

local PlatoonTemplates = PlatoonTemplates


function CreateEngineerManager( brain, lType, location, radius )

    local em = EngineerManager()
	
	--LOG("*AI DEBUG "..brain.Nickname.." creating EM for "..lType)
	
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
	
        local newBuilder = CreateEngineerBuilder( self, brain, builderData, locationType)
		
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

        table.insert( self.EngineerList, unit )
		
        self.EngineerList.Count = self.EngineerList.Count + 1

		unit.failedbuilds = 0
        unit.LocationType = self.LocationType

		if LOUDENTITY( categories.COMMAND, unit ) then
		
			unit.BuilderType = 'Commander'
			
		elseif LOUDENTITY( categories.TECH1, unit ) then
		
			unit.BuilderType = 'T1'
			
		elseif LOUDENTITY( categories.TECH2, unit ) then
		
			unit.BuilderType = 'T2'
			
		elseif LOUDENTITY( categories.TECH3 - categories.SUBCOMMANDER, unit ) then
		
			unit.BuilderType = 'T3'
			
		elseif LOUDENTITY( categories.TECH3 + categories.SUBCOMMANDER, unit ) then
		
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
		
			if not LOUDENTITY( categories.COMMAND, unit) then
			
				WaitTicks(35)

			end
		
			if not unit.Dead then

				if not unit.AssigningTask then
				
					self:ForkThread( self.DelayAssignEngineerTask, unit, unit:GetAIBrain() )
					
				end
				
			end	
			
		end

		-- SACU will have enhancement threads that may need rebuilding
		-- so we cancel any existing thread and restart it
		if LOUDENTITY( categories.SUBCOMMANDER, unit) then
		
			if unit.EnhanceThread then
			
				KillThread(unit.EnhanceThread)
				
				unit.EnhanceThread = nil
				
			end
			
			local aiBrain = unit:GetAIBrain()
			
			if not unit.EnhancementsComplete then
			
				unit.EnhanceThread = unit:ForkThread( import('/lua/ai/aibehaviors.lua').SCUSelfEnhanceThread, aiBrain.FactionIndex, aiBrain )
			
			end

		end

        return
		
    end,

	-- This is the primary function that assigns jobs to an engineer
    AssignEngineerTask = function( self, unit, aiBrain )

		if unit.Dead or unit.AssigningTask or BeenDestroyed(unit) then
		
			return
			
		end
    	
   		--LOG("*AI DEBUG "..aiBrain.Nickname.." eng "..unit.Sync.id.." Assigning task")

		local builder = self:GetHighestBuilder( unit, aiBrain )
		
		if unit.Dead or unit.AssigningTask or BeenDestroyed(unit) then
		
			return
			
		end
		
		unit.AssigningTask = true
		
        if builder and (not unit.Dead) and (not unit.Fighting) then

			--LOG("*AI DEBUG "..aiBrain.Nickname.." about to make a platoon with "..repr(PlatoonTemplates[Builders[builder.BuilderName].PlatoonTemplate]))
			
            local hndl = MakePlatoon( aiBrain, builder.BuilderName, PlatoonTemplates[Builders[builder.BuilderName].PlatoonTemplate].Plan or 'none' )

			hndl.BuilderName = builder.BuilderName
            hndl.LocationType = self.LocationType
			hndl.MovementLayer = 'Amphibious'
            hndl.PlanName = PlatoonTemplates[Builders[builder.BuilderName].PlatoonTemplate].Plan
            hndl.PlatoonData = builder:GetBuilderData(self.LocationType)
			hndl.RTBLocation = builder.RTBLocation or self.LocationType
			
			--LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..unit.Sync.id.." takes "..repr(builder.BuilderName))	--.." eng data is "..repr(unit))	--.." hndl is "..repr(hndl))

			IssueClearCommands( {unit} )
			IssueStop ( {unit} )
			
            AssignUnitsToPlatoon( aiBrain, hndl, {unit}, 'Support', 'none' )
			
			if not builder:StoreHandle( hndl, self, unit.BuilderType ) then
			
				WARN("*AI DEBUG "..aiBrain.Nickname.." no available instance for "..builder.BuilderName.." Eng "..unit.Sync.id.." Creation Time "..hndl.CreationTime.." told that "..builder.InstancesAvailable.." were available")
				
				builder.InstancesAvailable = 0
				aiBrain:DisbandPlatoon(hndl)
            
				if not unit.Dead then

					unit.AssigningTask = false
					
					unit.PlatoonHandle = false
					unit.failedbuilds = unit.failedbuilds + 1
					
					return self:DelayAssignEngineerTask( unit, aiBrain )
					
				end
				
				return
				
			end

			unit.PlatoonHandle = hndl
            unit.BuilderName = hndl.BuilderName

			unit.failedbuilds = 0
			unit.failedmoves = 0
			
			unit.DesiresAssist = hndl.PlatoonData.DesiresAssist or false	
			unit.NumAssistees = hndl.PlatoonData.NumAssistees or 1

			--Add functions are run immediately upon platoon creation
			-- since these functions are not forked off of the platoon they can persist beyond the death of the platoon (ie. - Commander Thread)
            if Builders[builder.BuilderName].PlatoonAddFunctions then
			
                for pafk, pafv in Builders[builder.BuilderName].PlatoonAddFunctions do
				
                    ForkThread( import(pafv[1])[pafv[2]], hndl, aiBrain)
					
                end
				
            end
			
			-- PlatoonAIPlan is intended to replace whatever the Normal plan might be
			-- the SetAIPlan function will kill whatever AIThread is already running
            if Builders[builder.BuilderName].PlatoonAIPlan then
			
                hndl.PlanName = Builders[builder.BuilderName].PlatoonAIPlan
                hndl:SetAIPlan(hndl.PlanName, aiBrain)
				
            end

            if Builders[builder.BuilderName].PlatoonAddPlans then
			
                for papk, papv in Builders[builder.BuilderName].PlatoonAddPlans do
				
                    hndl:ForkThread( hndl[papv], aiBrain )
					
                end
				
            end
            
            if Builders[builder.BuilderName].PlatoonAddBehaviors then
			
				-- fork off all the additional behaviors --
                for pafk, pafv in Builders[builder.BuilderName].PlatoonAddBehaviors do
				
                    hndl:ForkThread( import('/lua/ai/aibehaviors.lua')[pafv], aiBrain )
					
                end
				
            end
			
		else
			
			if unit.PlatoonHandle and unit.PlatoonHandle != aiBrain.ArmyPool then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." Has platoon "..repr(unit.PlatoonHandle) )
				LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." is attached "..repr(unit:IsUnitState('Attached') ) )
				
				if aiBrain:PlatoonExists(unit.PlatoonHandle) then
				
					aiBrain:DisbandPlatoon(unit.PlatoonHandle)
					
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

		WaitTicks(14 + (unit.failedbuilds * 6))
        
        while unit and not unit.Dead and not unit.AssigningTask do

			--LOG("*AI DEBUG Eng "..unit.Sync.id.." in delay assign task "..unit.failedbuilds)

			if not ( unit.Fighting or unit.AssigningTask) and not unit.Dead then
			
				-- send the engineer off to find a job --
				return self.AssignEngineerTask( self, unit, aiBrain )
				
			else

				WaitTicks(50)
				
			end

			if (not BeenDestroyed(unit)) and ( (not unit:IsIdleState() ) or unit:IsUnitState('Attached') ) then
			
				if unit:IsUnitState('Attached') then
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..unit.Sync.id.." is attached ")
					
					WaitTicks(30)	
					
				end
				
			end
			
        end

    end,
	
    GetNumCategoryUnits = function( self, category )
	
        return EntityCategoryCount( category, self.EngineerList ) or 0
		
    end,
    
    GetNumCategoryBeingBuilt = function( self, category, engCategory )
	
		local engs = EntityCategoryFilterDown( engCategory, self.EngineerList ) or {}
		
		local counter = 0

        for _,v in engs do
		
            if not v.Dead  and v:IsUnitState('Building') then
            
				local beingBuiltUnit = v.UnitBeingBuilt
			
				if beingBuiltUnit and not beingBuiltUnit.Dead then
            
					if LOUDENTITY( category, beingBuiltUnit ) then
					
						counter = counter + 1
						
					end
					
				end
				
			end
			
        end

        return counter
		
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
		
		--LOG("*AI DEBUG Found "..table.getn(engs).." that match category "..repr(engCategory))

        local units = {}
		local counter = 0

        for _,v in engs do
		
            if not v.Dead  and v:IsUnitState('Building') then
            
				local beingBuiltUnit = v.UnitBeingBuilt
			
				if beingBuiltUnit and not beingBuiltUnit.Dead then
            
					if LOUDENTITY( buildingcategory, beingBuiltUnit ) then
					
						units[counter+1] = v
						counter = counter + 1
						
					end
					
				end
				
			end
			
        end
        
        return units
		
    end,
	
    GetBuildingId = function( self, engineer, buildingType )
	
        return engineer:GetAIBrain():DecideWhatToBuild( engineer, buildingType, import('/lua/buildingtemplates.lua').BuildingTemplates[engineer:GetAIBrain().FactionIndex] )
		
    end,
    
    GetEngineersQueued = function( self, buildingType )
		
        local units = {}
		
        for _,v in self.EngineerList do
		
            if not v.Dead then

				if v.EngineerBuildQueue and LOUDGETN(v.EngineerBuildQueue) > 0 then
            
					local buildingId = self:GetBuildingId( v, buildingType )
					
					local found = false
			
					for num, data in v.EngineerBuildQueue do
			
						if data[1] == buildingId then
						
							found = true
							LOUDINSERT( units, v )
							break
							
						end
				
					end
					
				end
			
			end
 
        end
		
        return units
		
    end,

    GetEngineersWantingAssistanceWithBuilding = function( self, buildingcategory, engCategory )
	
		local GetGuards = moho.unit_methods.GetGuards
		local LOUDGETN = table.getn
		
		-- get all the engineers building this category from this base
        local testUnits = self:GetEngineersBuildingCategory( engCategory, buildingcategory )
		
        local retUnits = {}
		local counter = 0

		-- see if any need assistance
        for _,v in testUnits do
		
            if v.DesiresAssist and not v.Dead then

				if LOUDGETN( GetGuards(v) ) < v.NumAssistees then
				
					retUnits[counter+1] = v
					counter = counter + 1
					
				end
				
			end
			
        end

        return retUnits
		
    end,

	-- this removes an engineer from this base manager - destroys all existing engy callbacks
	-- used when engineer dies or is transferred to another base
    RemoveEngineerUnit = function( self, unit )

        for num,sUnit in self.EngineerList do

            if sUnit == unit then

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
    
	-- fired whenever a engineer platoon disbands on the same tick it was created
	-- often caused when one of the build conditions is not an instant condition
	-- and it is reported as true even though the real condition is false (until the next condition cycle)
	-- we set that job to be unavailable so that its not picked again
	-- we'll reset it back to normal later
    AssignTimeout = function( self, builderName, temporary )
    
		WaitTicks(2)	-- this allows platoon to disband first (which would possibly reset the builder to normal priority)

		local priority = self:GetBuilderPriority(builderName)
		
        local builder = self:SetBuilderPriority(builderName, 10, true)

		local priority = self:GetBuilderPriority(builderName)
		
		if builder and priority then
		
			-- this is (at most) half of the conditions monitor cycle
			-- ideally we would tie it to the brain condition monitor cycle --	self.BuilderCheckInterval = brain.ConditionsMonitor.ThreadWaitDuration
	
			--LOG("*AI DEBUG Current Thread Duration is "..repr(self.BuilderCheckInterval))	-- = brain.ConditionsMonitor.ThreadWaitDuration
			
			WaitTicks(300)	

			builder:ResetPriority(self)
		
			--LOG("*AI DEBUG EM timeout for "..repr(builderName).." ends - builder is "..repr(builder) )

		end

    end,

    UnitConstructionStarted = function( self, unit, unitBeingBuilt )
    end,

	-- When an engineer finishes construction of something it will pass thru here making it a natural place to assign unit-specific routines
    UnitConstructionFinished = function( self, unit, finishedUnit )
	
		if finishedUnit:GetFractionComplete() < 1 then
		
			return
			
		end
	
		local LOUDENTITY = EntityCategoryContains
		local ForkThread = ForkThread
		
        local aiBrain = unit:GetAIBrain()
        local faction = aiBrain.FactionIndex
		local StructurePool = aiBrain.StructurePool
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..unit.Sync.id.." finished building "..finishedUnit:GetBlueprint().Description)

		if LOUDENTITY( categories.FACTORY * categories.STRUCTURE - categories.EXPERIMENTAL, finishedUnit ) and finishedUnit:GetAIBrain().ArmyIndex == aiBrain.ArmyIndex then
		
			-- this was a tricky problem for engineers starting new bases since it was getting
			-- the LocationType from the platoon (which came from the original base not the new base)
			-- since the engineer is added to the new base (which changes his LocationType but not the platoons)
			-- it was necessary to change this call to use the units LocationType and NOT the platoons
			--local FBM = aiBrain.BuilderManagers[unit.LocationType].FactoryManager
			
            ForkThread( aiBrain.BuilderManagers[unit.LocationType].FactoryManager.AddFactory, aiBrain.BuilderManagers[unit.LocationType].FactoryManager, finishedUnit )
			
		end

		-- if STRUCTURE see if Upgrade Thread should start - excluding NUKES
		if LOUDENTITY( categories.STRUCTURE - categories.NUKE, finishedUnit ) then
		
			finishedUnit.DesiresAssist = true

			AssignUnitsToPlatoon( aiBrain, StructurePool, {finishedUnit}, 'Support', 'none' )

			finishedUnit:LaunchUpgradeThread( aiBrain )

			-- massfabricators --
			if LOUDENTITY( categories.MASSFABRICATION - categories.EXPERIMENTAL, finishedUnit ) then
			
				if not finishedUnit.AIThread then
				
					finishedUnit.AIThread = finishedUnit:ForkThread( MassFabThread, aiBrain)
					
				end
				
			end 
		
			-- TMLs --
			if LOUDENTITY( categories.TACTICALMISSILEPLATFORM, finishedUnit ) then
			
				if not finishedUnit.AIThread then
				
					finishedUnit.AIThread = finishedUnit:ForkThread( TMLThread, aiBrain)
					
				end
				
			end	
		
			-- Sera Rift Gate --
			if LOUDENTITY( categories.STRUCTURE * categories.EXPERIMENTAL * categories.FACTORY, finishedUnit ) then
			
				local FBM = aiBrain.BuilderManagers[unit.LocationType].FactoryManager
				
				finishedUnit.AIThread = finishedUnit:ForkThread( RiftGateBehavior, aiBrain, FBM)
				
			end
	
			-- Aeon Eye of Rhianne --
			if LOUDENTITY( categories.STRUCTURE * categories.AEON * categories.OPTICS, finishedUnit ) then
			
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
		
        local guards = unit:GetGuards()
		
        for k,v in guards do
		
            if not v.Dead and v.AssistPlatoon then
			
                if aiBrain:PlatoonExists(v.AssistPlatoon) then
				
                    v.AssistPlatoon = nil
					
                end
				
            end
			
        end
		
    end,

	ReassignEngineer = function( self, unit, aiBrain )
	
		local managers = aiBrain.BuilderManagers
		
		local bestManager = false
		local bestname 
		local distance = false
		
		local unitPos = unit:GetPosition()

		for k,v in managers do
		
			if v.EngineerManager.Active and v.EngineerManager != self then
			
				local checkDistance = VDist3( v.Position, unitPos)

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
		
        if not unit.Dead and builder.InstancesAvailable > 0 then

			return true
		end
	
        return false
		
	end,

	-- this is the function which sets up and starts the Base Alert system for a base
	-- it determines if any threatening targets have entered the alert range of the base and issues an alert
	-- This base, and various platoons, use these alerts to send response teams
	BaseMonitorSetup = function( self, aiBrain)

		--LOG("*AI DEBUG "..aiBrain.Nickname.." setting up Base Monitor")
	
		self.BaseMonitor = {
	
			BaseMonitorInterval = 8, 					-- how often the base monitor will do threat checks to raise alerts

			ActiveAlerts = 0,							-- number of active alerts at this base
			AlertLevel = 6,								-- threat must be this size to trigger an alert
			AlertTimeout = 16,							-- time it takes for a created alert to expire
		
			AlertRange = math.min( math.floor(self.Radius * 2), 175 ),		-- radius at which base will consider targets for an alert
		
			AlertResponseTime = 16,						-- time it allows to pass before sending more responses to an active alert
		
			AlertsTable = {},							-- stores the data for each threat (position, amount of threat, type of threat)
        
			LastAlertTime = LOUDFLOOR(GetGameTimeSeconds()),	-- how long since last alert
			
		}
	
		self:ForkThread( self.BaseMonitorThreadLOUD, aiBrain)
    
		return
	
	end,

	-- This thread runs every BaseMonitorInterval & triggers the BaseMonitorThreatCheck() each
	-- iteration - when the location is ACTIVE -- the delay period increases upto an additional
	-- 20 seconds if there have not been any alerts
	BaseMonitorThreadLOUD = function( self, aiBrain )

		local DrawC = DrawCircle

		local LOUDGETN = table.getn
		local LOUDMIN = math.min
		local LOUDSORT = table.sort
		
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		
		local WaitTicks = coroutine.yield

		-- this function will draw a visible radius around the base
		-- equal to the alert radius of the base each time the base
		-- looks for threats
		local function DrawBaseMonitorRadius()
	
			local range = self.BaseMonitor.AlertRange
			local position = table.copy(self.Location)
		
			local color = '00ff00'
		
			if aiBrain.BuilderManagers[self.LocationType].PrimaryLandAttackBase or aiBrain.BuilderManagers[self.LocationType].PrimarySeaAttackBase then
		
				color = 'ff0000'
			
			end

			if GetFocusArmy() == -1 or (aiBrain.ArmyIndex == GetFocusArmy()) then

				for j = 1, 3 do
			
					for i = 1,10 do
				
						DrawC( position, range - i, color)
					
						WaitTicks(1)
					
					end
				
				end
			
			end

		end

		-- This function is used by the AI to put markers on a map so that Allied Humans can see them
		local function SetBaseMarker()

			--LOG("*AI DEBUG "..aiBrain.Nickname.." adding Base Marker for "..self.LocationType)
	
			if aiBrain.BuilderManagers[self.LocationType] then
	
				aiBrain.BuilderManagers[self.LocationType].MarkerID = import('/lua/ai/altaiutilities.lua').AISendPing( self.Location, 'marker', aiBrain.ArmyIndex, aiBrain.Nickname.." "..self.LocationType )
		
			end
	
		end
		
		-- This function examines the HiPri intel list and decides if an ALERT needs to be triggered.

		-- A base can have one of each kind of threat (Air, Land and Naval)
		-- We loop thru the threat data for each of these 3 and for experimentals
		-- looking at any threat within the AlertRadius and greater than the AlertLevel
		-- If an experimental is found, it is examined to determine which kind of
		-- threat it is (again - Air, Land or Naval)
		-- If the base does not currently have an alert of that kind, an entry will be inserted into the AlertTable
		-- noting Position, Threat level and the kind of threat (Air, Land or Naval)
		-- This is then passed off to the BaseMonitorAlertTimeoutLOUD which will follow that threat,
		-- keeping it updated and active, or expiring it when it is no longer valid
		local function BaseMonitorThreatCheck()

			if aiBrain.IL.HiPri and LOUDGETN(aiBrain.IL.HiPri) > 0 then
	
				local AlertRadius = self.BaseMonitor.AlertRange
		
				if aiBrain.BuilderManagers[self.LocationType].PrimaryLandAttackBase then
			
					AlertRadius = self.BaseMonitor.AlertRange + 15
				
				end
		
				AlertRadius = AlertRadius * AlertRadius

				local threatTable = table.copy(aiBrain.IL.HiPri)

				-- if there is a threat table and we have a position
				if LOUDGETN(threatTable) > 0 and self.Location then
				
					--LOG("*AI DEBUG Processing HiPri table for distress calls")
					
					-- sort the threat table by distance from this base --
					LOUDSORT(threatTable, function (a,b) return VDist2Sq(a.Position[1],a.Position[3], self.Location[1],self.Location[3]) < VDist2Sq(b.Position[1],b.Position[3], self.Location[1],self.Location[3]) end)
		
					local LoopTypes = { 'Experimental', 'Land', 'Air', 'Naval' }
				
					local highThreat, highThreatPos, highThreatType
		
					for _,LoopType in LoopTypes do
					
						--LOG("*AI DEBUG Processing "..repr(LoopType))
			
						highThreat = false
						highThreatPos = false
						highThreatType = false
	
						if not self.BaseMonitor.AlertsTable[LoopType] then		-- this means we always check experimentals but bypass any already active alert types
					
							-- loop thru the threat list
							for _,threat in threatTable do
						
								-- filter by distance from the base and break out if threats are farther away (we presorted by distance)
								if VDist2Sq(threat.Position[1],threat.Position[3], self.Location[1],self.Location[3]) <= AlertRadius then
							
									-- match for threat type we are currently checking
									if threat.Type == LoopType then
									
										--LOG("*AI DEBUG Found "..repr(LoopType).." threat of "..threat.Threat)
								
										-- find highest threat and filter out tiny threats
										if (not highThreat or threat.Threat > highThreat) and threat.Threat >= self.BaseMonitor.AlertLevel then
									
											highThreat = threat.Threat
											highThreatPos = {threat.Position[1], threat.Position[2], threat.Position[3]}
							
											if threat.Type == 'Experimental' then
									
												experimentalsair = GetUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL * categories.AIR, highThreatPos, 90, 'Enemy')
												experimentalssea = GetUnitsAroundPoint( aiBrain, categories.EXPERIMENTAL * categories.NAVAL, highThreatPos, 90, 'Enemy')
										
												if LOUDGETN(experimentalsair) > 0 then
											
													highThreatType = 'Air'
												
												elseif LOUDGETN(experimentalssea) > 0 then
											
													highThreatType = 'Naval'
												
												else
											
													highThreatType = 'Land'
												
												end
											
											else
										
												highThreatType = threat.Type
											
											end
										
										end
									
									end
								
								else
							
									break
								
								end
							
							end
						
						end

						-- if we have a high threat condition -- and don't already have one of this type --
						if highThreat and not self.BaseMonitor.AlertsTable[highThreatType] then
			
							-- update the BaseMonitor data
							self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
						
							self.BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())
					
							-- put an entry into the alert table for this threat type
							self.BaseMonitor.AlertsTable[highThreatType] = { Position = highThreatPos, Threat = highThreat }
						
							-- notify the brain there is an alert at a base
							aiBrain.BaseAlertSounded = true
					
							--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." raises "..highThreatType.." alert of "..highThreat)
							
							-- accurately check the threat, launch the response thread, and monitor the threat until its gone
							self:ForkThread( self.BaseMonitorAlertTimeoutLOUD, aiBrain, highThreatPos, self.Location, highThreatType)
						
						end
					
						WaitTicks(1)
					
					end
				
				end
			
				--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." threat check complete")
			
			end
		
		end
	
		local delay = 0
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." starts")
	
		while self.Active do
	
			-- at present, this starts at about 7 seconds per cycle
			WaitTicks(( self.BaseMonitor.BaseMonitorInterval + delay ) * 10 )        
		
			if self.Active then
		
				if ScenarioInfo.DisplayBaseNames then
			
					if not aiBrain.BuilderManagers[self.LocationType].MarkerID then
				
						ForkThread( SetBaseMarker )
					
					end
				
				end

				if ScenarioInfo.DisplayBaseMonitors then
			
					ForkThread( DrawBaseMonitorRadius )
				
				end
			
				BaseMonitorThreatCheck()
			
			end
		
			delay = (GetGameTimeSeconds()) - self.BaseMonitor.LastAlertTime
		
			delay = LOUDFLOOR(delay/120)	-- delay is increased by 1 second for every 2 minutes since last alert
			delay = LOUDMIN(delay, 20)	-- delay is capped at 20 additional seconds
		
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
	BaseMonitorAlertTimeoutLOUD = function( self, aiBrain, pos, baseposition, threattype )
    
		local distressrange = self.BaseMonitor.AlertRange * self.BaseMonitor.AlertRange 	-- for VDist2Sq distances

		local threshold = self.BaseMonitor.AlertLevel
	
		local LOUDFLOOR = math.floor
		local LOUDINSERT = table.insert
		local LOUDREMOVE = table.remove
		
		local WaitTicks = coroutine.yield
	
		local GetBlueprint = moho.entity_methods.GetBlueprint
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		
		local threat = 0
		
		local myThreat
		local targetUnits
		local x1,x2,x3,count,newpos,unitpos,bp

		-- loop until the alert falls below the trigger or moves outside the alert radius
		repeat
	
			-- look for units of the threattype
			if threattype == 'Land' then
		
				targetUnits = GetUnitsAroundPoint( aiBrain, (categories.MOBILE * categories.LAND), pos, 90, 'Enemy')
			
			elseif threattype == 'Air' then
		
				targetUnits = GetUnitsAroundPoint( aiBrain, (categories.AIR * categories.MOBILE), pos, 90, 'Enemy')
			
			elseif threattype == 'Naval' then
		
				targetUnits = GetUnitsAroundPoint( aiBrain, categories.NAVAL * categories.MOBILE, pos, 90, 'Enemy')
			
			end

			x1 = 0
			x2 = 0
			x3 = 0
			count = 0

			threat = 0

			-- loop thru units found and accumulate threat and positions
			for _, nearunit in targetUnits do
		
				if not nearunit.Dead then
		
					unitpos = nearunit:GetPosition()

					if unitpos then
				
						x1 = x1 + unitpos[1]
						x2 = x2 + unitpos[2]
						x3 = x3 + unitpos[3]
					
						count = count + 1
					
						bp = GetBlueprint(nearunit).Defense

						if threattype == 'Land' then
						
							threat = threat + bp.SurfaceThreatLevel
					
						elseif threattype == 'Air' then
					
							threat = threat + bp.SurfaceThreatLevel
							threat = threat + bp.AirThreatLevel
					
						elseif threattype == 'Naval' then
					
							threat = threat + bp.SurfaceThreatLevel
							threat = threat + bp.SubThreatLevel
						
						end
						
					end
				
				end
			
			end
		
			-- if there are units and the threat is above the threshold
			-- update the alerts table, time of last alert, ping interface
			-- and launch the response thread if not already underway --
			if count > 0 and threat >= self.BaseMonitor.AlertLevel then
		
				-- do the average position calculation -- 
				newpos = { x1/count, x2/count, x3/count }
			
				-- re-write the alert data with new values
				self.BaseMonitor.AlertsTable[threattype] = { Position = newpos, Threat = threat }

				-- mark the brain that a base is sounding an alert
				aiBrain.BaseAlertSounded = true

				pos = table.copy(newpos)
			
				-- send the visible ping to the interface --
				ForkThread( import('/lua/ai/altaiutilities.lua').AISendPing, newpos, 'attack', aiBrain.ArmyIndex )
				
				self.BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())

				-- if we haven't launched a response thread
				if aiBrain.BuilderManagers[self.LocationType].EngineerManager and not aiBrain.BuilderManagers[self.LocationType].EngineerManager.BMDistressResponseThread then
				
					aiBrain.BuilderManagers[self.LocationType].EngineerManager.BMDistressResponseThread = true
				
					self:ForkThread( self.BaseMonitorDistressResponseThread, aiBrain)
				
				end
        
				WaitTicks( self.BaseMonitor.AlertTimeout * 10 ) -- before checking this threat again --

			end

		until (threat < self.BaseMonitor.AlertLevel) or VDist2Sq(pos[1],pos[3], baseposition[1],baseposition[3]) > distressrange

		self.BaseMonitor.AlertsTable[threattype] = nil

		self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts - 1
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." deactivates "..threattype.." alert")

		-- if no more alerts reset the alert table
		if self.BaseMonitor.ActiveAlerts == 0 then
	
			--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." has NO alerts")
	
			self.BaseMonitor.AlertsTable = {}

			aiBrain.BaseAlertSounded = false
		
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
	
		local GetThreatOfGroup = function( group, distressType )
	
			local GetBlueprint = moho.entity_methods.GetBlueprint
			local totalThreat = 0
	
			if distressType == 'Land' then
		
				for _,u in group do
			
					if not u.Dead then
				
						totalThreat = totalThreat + (GetBlueprint(u).Defense.SurfaceThreatLevel or 0)
					
					end
				
				end
			
				return totalThreat	
			
			end
		
			if distressType == 'Naval' then
		
				for _,u in group do
			
					if not u.Dead then
				
						totalThreat = totalThreat + (GetBlueprint(u).Defense.SurfaceThreatLevel or 0) + (GetBlueprint(u).Defense.SubThreatLevel or 0)
					
					end
				
				end
			
				return totalThreat	
			
			end
		
			if distressType == 'Air' then
		
				for _,u in group do
			
					if not u.Dead then
				
						totalThreat = totalThreat + (GetBlueprint(u).Defense.AirThreatLevel or 0)
					
					end
				
				end
			
				return totalThreat	
			
			end		
		
		end
	
		local LOUDGETN = table.getn
		local WaitTicks = coroutine.yield

		local baseposition = self.Location

		local radius = 200	-- range that base will draw in pool units to respond with
    
		local distressunderway = true
		local response = false
	
		local recovery = false
	
		local distress_air = false
		local distress_ftr = false
		local distress_land = false
		local distress_naval = false
	
		local distressrepeats = 0	-- each time we fail to respond to a distress, increase the wait time before we try again
		
		local DistressTypes = { 'Land', 'Air', 'Naval' }
		
		local distressLocation, distressType, threatamount
	
		local grouplnd, groupair, groupsea, groupftr
		local grouplndcount, groupaircount, groupseacount, groupfrtcount
		
		local DisperseUnitsToRallyPoints = import('/lua/loudutilities.lua').DisperseUnitsToRallyPoints
		local GetFreeUnitsAroundPoint = import('/lua/loudutilities.lua').GetFreeUnitsAroundPoint
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.LocationType.." Base Monitor Distress Response Thread Launched")
	
		-- this loop runs as long as there is distress underway and the base exists and has active alerts
		-- repeating every AlertResponseTime period
		while distressunderway and self.Active and self.BaseMonitor.ActiveAlerts > 0 do
	
			--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." distress response underway for "..self.BaseMonitor.ActiveAlerts.." alerts")
    
			-- Delay between Distress check cycles
			-- add extra delay based upon LastAlert at this base
			-- so that quiet bases will check less often
			-- local ThreatCheckDelay = BaseMonitorThreatCheckDelay(EM)
        
			distressunderway = false

			for _,distresskind in DistressTypes do
		
				distressLocation, distressType, threatamount = self:BaseMonitorGetDistressLocation( aiBrain, baseposition, self.BaseMonitor.AlertRange, self.BaseMonitor.AlertLevel, distresskind )

				if distressLocation then
		
					distressunderway = true
				
					if distressType == 'Land' then

						grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.ANTIAIR - categories.COUNTERINTELLIGENCE - categories.ENGINEER, baseposition, radius )
					
						if grouplndcount > 4 then

							--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." trying to respond to "..distressType.." value "..aiBrain:GetThreatAtPosition( distressLocation, 0, true, 'AntiSurface' ).." my assets are "..GetThreatOfGroup(grouplnd,'Land'))

							-- only send response if we can muster 33% of enemy threat
							if GetThreatOfGroup(grouplnd,'Land') >= (aiBrain:GetThreatAtPosition( distressLocation, 0, true, 'AntiSurface' )/3) then
					
								-- Move the land group to the distress location and then back to the location of the base
								IssueClearCommands( grouplnd )

								IssueFormAggressiveMove( grouplnd, distressLocation, 'AttackFormation', import('/lua/utilities.lua').GetDirectionInDegrees( baseposition, distressLocation ))
					
								DisperseUnitsToRallyPoints( aiBrain, grouplnd, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )

								response = true
								distress_land = true
							
							end
						
						end
					
					end
				
					if distressType == 'Naval' then
				
						groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, (categories.NAVAL * categories.MOBILE) - categories.STRUCTURE - categories.ENGINEER - categories.CARRIER, baseposition, radius )
					
						if groupseacount > 0 then
					
							--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." trying to respond to "..distressType.." value "..threatamount)
				
							if GetThreatOfGroup(groupsea,'Naval') >= (aiBrain:GetThreatAtPosition( distressLocation, 0, true, 'AntiSurface' )/2) then
					
								-- Move the naval group to the distress location and then back to the location of the base
								IssueClearCommands( groupsea )
						
								IssueAggressiveMove( groupsea, distressLocation )
					
								DisperseUnitsToRallyPoints( aiBrain, groupsea, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )

								response = true
								distress_naval = true
							
							end
						
						end
					
					end
				
					if distressType != 'Air' then
				
						groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY, baseposition, radius )
						groupftr, groupftrcount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.ANTIAIR), baseposition, radius )
					
						if groupaircount > 2 then

							--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." trying to respond to "..distressType.." value "..threatamount)
						
							-- Move the gunship/bomber group to the distress location and issue guard there 
							IssueClearCommands( groupair )
							IssueGuard( groupair, distressLocation )
					
							response = true
							distress_air = true
						
						end
				
						if groupftrcount > 2 then 
					
							--LOG("*AI DEBUG "..aiBrain.Nickname.." BASEMONITOR "..self.LocationType.." trying to respond to "..distressType.." value "..threatamount)
						
							if GetThreatOfGroup(groupftr,'Air') >= (aiBrain:GetThreatAtPosition( distressLocation, 0, true, 'AntiAir' )/2) then
					
								-- Move the fighter group to the distress location 
								IssueClearCommands( groupftr )
								IssueGuard( groupftr, distressLocation )
				
								response = true
								distress_ftr = true

							end
						
						end	
					
					end

				end

				WaitTicks(2) -- delay between distress type checks
			
			end

			WaitTicks( (self.BaseMonitor.AlertResponseTime + distressrepeats) * 10)
		
			-- as a base responds to a continued alert I want to gradually slow the response loop
			-- this allows a base more time to gather additional units before sending them out 
			-- this will reduce the effect of 'kiting' the AI out of his base by triggering an alert
			-- as his responses will get further and further apart
			-- the inital response period is 20 seconds -- then 40 -- then 60 -- then 80
			-- and can go as high as 120 seconds
			distressrepeats = distressrepeats + 20
		
			if distressrepeats > 100 then
		
				distressrepeats = 100
			
			end
		
		end
	
		-- If there was a response by any group try and send those groups back to rally points
		-- note that recovery is done at the EM radius * 2 to pick up everyone
		if response then

			distressrepeats = 0
			
			if distress_land then 
		
				grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.ANTIAIR - categories.SCOUT - categories.COMMAND - categories.ENGINEER, baseposition, (self.Radius * 2) )

				if grouplndcount > 0 then
			
					-- Move the land group back to closest land base
					IssueClearCommands( grouplnd )
				
					-- we need to find the closest LAND manager name at this point
					-- put grouplnd into a platoon --
					-- use AIFindClosestBuilderManagerName( aiBrain, GetPlatoonPosition(), false, false ) for BaseName
					-- use BaseName instead of self.LocationType below
					-- OR JUST RTB the platoon
					DisperseUnitsToRallyPoints( aiBrain, grouplnd, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )
				
					recovery = true
				
				end
			
			end

			if distress_naval then

				groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, (categories.NAVAL * categories.MOBILE) - categories.STRUCTURE - categories.ENGINEER, baseposition, self.Radius * 2 )		

				if groupseacount > 0 then
			
					-- Move the naval group back to the closest naval base
					IssueClearCommands( groupsea )
				
					-- we need to find the closest SEA manager at this point
					DisperseUnitsToRallyPoints( aiBrain, groupsea, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )
				
					recovery = true
				
				end
			
			end

			if distress_air then
		
				groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, categories.BOMBER + categories.GROUNDATTACK - categories.ANTINAVY, baseposition, self.Radius * 2 )
			
				if groupaircount > 0 then
			
					-- Move the gunship/bomber group back to base 
					IssueClearCommands( groupair )
				
					DisperseUnitsToRallyPoints( aiBrain, groupair, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )
				
					recovery = true
				
				end
			
			end
		
			if distress_ftr then
		
				groupftr, groupftrcount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.ANTIAIR), baseposition, self.Radius * 2 )
			
				if groupftrcount > 0 then
			
					-- Move the fighter group back to base 
					IssueClearCommands( groupftr )
				
					DisperseUnitsToRallyPoints( aiBrain, groupftr, baseposition, aiBrain.BuilderManagers[self.LocationType].RallyPoints )
				
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

		-- Commander Distress is 1st priority --
		if aiBrain.CDRDistress then
	
			if (threattype == 'Land' or threattype == 'Air') and VDist3( aiBrain.CDRDistress, baseposition ) < (radius*2) then
		
				return aiBrain.CDRDistress, threattype, 25
			
			end
		
		end
	
		-- Base Alerts are second --
		if self.BaseMonitor.AlertsTable[threattype] then
	
			return self.BaseMonitor.AlertsTable[threattype].Position, threattype, self.BaseMonitor.AlertsTable[threattype].Threat
		
		end

		-- Platoon Distress calls -- 
		if aiBrain.PlatoonDistress.AlertSounded then
	
			local PlatoonExists = moho.aibrain_methods.PlatoonExists
	
			local returnPos = false
			local returnThreat = 0
			local distance = (radius * radius)	-- maximum search radius
			local distressdist
		
			for _,v in aiBrain.PlatoonDistress.Platoons do
		
				if threattype == v.DistressType then
			
					if PlatoonExists( aiBrain, v.Platoon ) then
				
						distressdist = VDist2Sq(baseposition[1],baseposition[3], v.Position[1],v.Position[3])

						-- if closest one - store it
						if distressdist <= distance then

							returnPos = table.copy(v.Position)
							returnThreat = v.Threat
							distance = distressdist
						
						end

					end

				end
			
			end
		
			return returnPos,threattype,returnThreat
		
		end

		return false, false, 0
	
	end,


	
}

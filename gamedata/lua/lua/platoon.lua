-- Platoon Lua Module    #

local import = import

local AIUtilities = import('ai/aiutilities.lua')

local AIAddMustScoutArea                    = AIUtilities.AIAddMustScoutArea
local AIGetClosestMarkerLocation            = AIUtilities.AIGetClosestMarkerLocation
local AIGetMarkersAroundLocation            = AIUtilities.AIGetMarkersAroundLocation
local AIGetReclaimablesAroundLocation       = AIUtilities.AIGetReclaimablesAroundLocation
local CheckUnitPathingEx                    = AIUtilities.CheckUnitPathingEx
local GetNumberOfOwnUnitsAroundPoint        = AIUtilities.GetNumberOfOwnUnitsAroundPoint
local GetOwnUnitsAroundPoint                = AIUtilities.GetOwnUnitsAroundPoint
local GetOwnUnitsAroundPointWithThreatCheck = AIUtilities.GetOwnUnitsAroundPointWithThreatCheck
local RandomLocation                        = AIUtilities.RandomLocation

AIUtilities = nil

local AltAIUtilities = import('/lua/ai/altaiutilities.lua')

local AIFindDefensivePointNeedsStructure        = AltAIUtilities.AIFindDefensivePointNeedsStructure
local AIFindDefensivePointForDP                 = AltAIUtilities.AIFindDefensivePointForDP
local AIFindBaseAreaForDP                       = AltAIUtilities.AIFindBaseAreaForDP
local AIFindBaseAreaForExpansion                = AltAIUtilities.AIFindBaseAreaForExpansion
local AIFindBasePointNeedsStructure             = AltAIUtilities.AIFindBasePointNeedsStructure
local AIFindNavalAreaForExpansion               = AltAIUtilities.AIFindNavalAreaForExpansion
local AIFindNavalDefensivePointNeedsStructure   = AltAIUtilities.AIFindNavalDefensivePointNeedsStructure
local AIFindStartPointNeedsStructure            = AltAIUtilities.AIFindStartPointNeedsStructure
local AISendPing                                = AltAIUtilities.AISendPing
local AssistBody                                = AltAIUtilities.AssistBody
local GetTemplateReplacement                    = AltAIUtilities.GetTemplateReplacement
local UnfinishedBody                            = AltAIUtilities.UnfinishedBody

AltAIUtilities = nil

local SendPlatoonWithTransportsLOUD     = import('/lua/ai/transportutilities.lua').SendPlatoonWithTransportsLOUD

local AIBuildAdjacency                  = import('/lua/ai/aibuildstructures.lua').AIBuildAdjacency
local AIBuildBaseTemplateFromLocation   = import('/lua/ai/aibuildstructures.lua').AIBuildBaseTemplateFromLocation
local AIBuildBaseTemplateOrdered        = import('/lua/ai/aibuildstructures.lua').AIBuildBaseTemplateOrdered
local AIExecuteBuildStructure           = import('/lua/ai/aibuildstructures.lua').AIExecuteBuildStructure
local AINewExpansionBase                = import('/lua/ai/aibuildstructures.lua').AINewExpansionBase

local Behaviors = import('/lua/ai/aibehaviors.lua')

local CreatePlatoonToPositionDistanceTrigger = import('/lua/scenariotriggers.lua').CreatePlatoonToPositionDistanceTrigger

local GetDirection = import('/lua/utilities.lua').GetDirectionInDegrees

local AIFindTargetInRangeInCategoryWithThreatFromPosition   = import('/lua/ai/aiattackutilities.lua').AIFindTargetInRangeInCategoryWithThreatFromPosition
local FindPointMeetsConditions                              = import('/lua/ai/aiattackutilities.lua').FindPointMeetsConditions
local FindTargetInRange                                     = import('/lua/ai/aiattackutilities.lua').FindTargetInRange
local GetMostRestrictiveLayer                               = import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer
local InWaterCheck                                          = import('/lua/ai/aiattackutilities.lua').InWaterCheck

local AIFindUndefendedBrainTargetInRangeSorian  = import('/lua/ai/sorianutilities.lua').AIFindUndefendedBrainTargetInRangeSorian
local FindDamagedShield                         = import('/lua/ai/sorianutilities.lua').FindDamagedShield
local AISendChat                                = import('/lua/ai/sorianutilities.lua').AISendChat

local BaseInPlayableArea                        = import('loudutilities.lua').BaseInPlayableArea
local DisperseUnitsToRallyPoints                = import('loudutilities.lua').DisperseUnitsToRallyPoints
local FindClosestBaseName                       = import('loudutilities.lua').FindClosestBaseName
local GetBasePerimeterPoints                    = import('loudutilities.lua').GetBasePerimeterPoints
local GetBaseWithGreatestThreatAtDistance       = import('loudutilities.lua').GetBaseWithGreatestThreatAtDistance
local GetHiPriTargetList                        = import('loudutilities.lua').GetHiPriTargetList
local GetPrimaryLandAttackBase                  = import('loudutilities.lua').GetPrimaryLandAttackBase
local GetPrimarySeaAttackBase                   = import('loudutilities.lua').GetPrimarySeaAttackBase
local ProcessAirUnits                           = import('loudutilities.lua').ProcessAirUnits
local RecheckHiPriTarget                        = import('loudutilities.lua').RecheckHiPriTarget

local UnitCapCheckGreater   = import('/lua/editor/UnitCountBuildConditions.lua').UnitCapCheckGreater

local AIBrainMethods    = moho.aibrain_methods
local EntityMethods     = moho.entity_methods
local PlatoonMethods    = moho.platoon_methods

local AssignUnitsToPlatoon         = AIBrainMethods.AssignUnitsToPlatoon
local BuildStructure               = AIBrainMethods.BuildStructure
local CanBuildStructureAt          = AIBrainMethods.CanBuildStructureAt
local GetEconomyStored             = AIBrainMethods.GetEconomyStored
local GetEconomyStoredRatio        = AIBrainMethods.GetEconomyStoredRatio
local GetPlatoonsList              = AIBrainMethods.GetPlatoonsList
local GetThreatAtPosition          = AIBrainMethods.GetThreatAtPosition
local GetThreatBetweenPositions    = AIBrainMethods.GetThreatBetweenPositions
local GetUnitsAroundPoint          = AIBrainMethods.GetUnitsAroundPoint
local PlatoonExists                = AIBrainMethods.PlatoonExists

AIBrainMethods = nil

local BeenDestroyed             = EntityMethods.BeenDestroyed
local GetBlueprint              = EntityMethods.GetBlueprint
local GetFractionComplete       = EntityMethods.GetFractionComplete
local GetPosition               = EntityMethods.GetPosition

EntityMethods = nil

local CalculatePlatoonThreat                = PlatoonMethods.CalculatePlatoonThreat
local CanAttackTarget                       = PlatoonMethods.CanAttackTarget
local GetBrain                              = PlatoonMethods.GetBrain
local GetPlatoonPosition                    = PlatoonMethods.GetPlatoonPosition
local GetPlatoonUnits                       = PlatoonMethods.GetPlatoonUnits
local GetSquadUnits                         = PlatoonMethods.GetSquadUnits
local PlatoonCategoryCount                  = PlatoonMethods.PlatoonCategoryCount
local PlatoonCategoryCountAroundPosition    = PlatoonMethods.PlatoonCategoryCountAroundPosition

local GetAIBrain    = moho.unit_methods.GetAIBrain
local IsIdleState   = moho.unit_methods.IsIdleState
local IsUnitState   = moho.unit_methods.IsUnitState

local LOUDABS       = math.abs
local LOUDCAT       = table.cat
local LOUDCEIL      = math.ceil
local LOUDCOPY      = table.copy
local LOUDDEEPCOPY  = table.deepcopy
local LOUDENTITY    = EntityCategoryContains
local LOUDEQUAL     = table.equal
local LOUDFIND      = string.find
local LOUDFLOOR     = math.floor
local LOUDGETN      = table.getn
local LOUDINSERT    = table.insert
local LOUDLOG10     = math.log10
local LOUDMAX       = math.max
local LOUDMIN       = math.min
local LOUDMOD       = math.mod
local LOUDPARSE     = ParseEntityCategory
local LOUDREMOVE    = table.remove
local LOUDSORT      = table.sort
local LOUDSQRT      = math.sqrt
local LOUDTIME      = GetGameTimeSeconds
local VDist2Sq      = VDist2Sq
local VDist3        = VDist3

local ForkThread    = ForkThread
local ForkTo        = ForkThread
local KillThread    = KillThread
local TrashBag      = TrashBag
local TrashAdd      = TrashBag.Add
local TrashDestroy  = TrashBag.Destroy
local WaitTicks     = coroutine.yield

local ALLUNITS      = categories.ALLUNITS
local AIRUNITS      = categories.AIR * categories.MOBILE - categories.EXPERIMENTAL
local COMMANDER     = categories.COMMAND
local ENGINEERS     = categories.ENGINEER
local EXPERIMENTALS = categories.EXPERIMENTAL

-- types of threat to look at based on composition of platoon
local ThreatTable = { Land = 'AntiSurface', Water = 'AntiSurface', Amphibious = 'AntiSurface', Air = 'AntiAir', }

Platoon = Class(PlatoonMethods) {
    
    OnCreate = function( self, plan)
	
        self.CreationTime = LOUDTIME()	
        self.EventCallbacks = { }
        self.Trash = TrashBag()

        if plan and plan != 'none' then

			self:ForkAIThread( self[plan], GetBrain(self) )
        end

		if ScenarioInfo.PlatoonDialog then
        
			local aiBrain = GetBrain(self)
            
            self:ForkThread( function(self) WaitTicks(1) LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." created") end)
		end
        
    end,

    SetPlatoonData = function( self, dataTable)
	
        self.PlatoonData = dataTable
    end,

    ForkThread = function( self, fn, ...)

        local thread = ForkThread(fn, self, unpack(arg))
		
        TrashAdd( self.Trash, thread )
		
        return thread
    end,

    ForkAIThread = function( self, fn, option1)
	
        self.AIThread = self:ForkThread(fn, option1)
    end,

    SetAIPlan = function( self, plan, aiBrain)

        if self.AIThread then
			
            self.AIThread:Destroy()
			self.AIThread = nil
        end
		
		if self[plan] then

			if ScenarioInfo.PlatoonDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..self.BuilderName.." "..repr(self.BuilderInstance).." SetAIPlan to "..repr(plan))
			end

			self:ForkAIThread(self[plan], aiBrain)
		else
		
			WARN("Unable to locate AIPlan "..repr(plan).." for "..repr(self.BuilderName))
		end

    end,

    StopAI = function( self )
	
        if self.AIThread != nil then
		
            self.AIThread:Destroy()
			self.AIThread = nil
        end
    end,

    OnUnitsAddedToPlatoon = function( self )

		local units = GetPlatoonUnits(self)
        
        local DisplayPlatoonMembership = ScenarioInfo.DisplayPlatoonMembership
        
        local BuilderName = tostring(self.BuilderName)
        local BuilderInstance = self.BuilderInstance or false
        
        local PlanName = self.PlanName
		
        for _,v in units do
		
            if not v.Dead then
			
				if v.PlatoonHandle != self then

					v.PlatoonHandle = self
					v.PlatoonHandle.PlanName = PlanName
					v.PlatoonHandle.BuilderName = BuilderName
				
					if DisplayPlatoonMembership then

                        if BuilderInstance then
                            v:SetCustomName( BuilderName.." "..BuilderInstance )
                        else
                            v:SetCustomName( BuilderName )
                        end

					end
                    
				end
			end
        end
    end,

    AddDestroyCallback = function( self, callbackFunction)
	
        LOUDINSERT(self.EventCallbacks.OnDestroyed, callbackFunction)
		
    end,

    DoDestroyCallbacks = function( self)
	
        for k, cb in self.EventCallbacks.OnDestroyed do
		
	        if cb then
			
                cb( GetBrain(self), self )
            end
        end
    end,

    OnDestroy = function( self)

        local aiBrain = GetBrain(self)
        local Callbacks = self.EventCallbacks.OnDestroyed

		if ScenarioInfo.PlatoonDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..self.BuilderName.." "..repr(self.BuilderInstance).." destroyed on tick "..GetGameTick() )
		end

        if Callbacks then

            for k, cb in Callbacks do
	
                if cb then

                    cb( aiBrain, self )
                end
            end		
        end

        TrashDestroy(self.Trash)
    end,

    WatchPlatoonSize = function(self, startsize, triggervalue)

        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists
        local WaitTicks = WaitTicks
        
        local aiBrain = GetBrain(self)
        local triggerpoint = startsize * triggervalue
        local count = 0

        while PlatoonExists(aiBrain,self) and self.WatchPlatoon do
        
            count = 0
            
            for k,v in GetPlatoonUnits(self) do 
            
                if not v.Dead then
                    
                    count = count + 1
    
                    if count > triggerpoint then
                    
                        break
                    end
                end
            end
            
            if count < triggerpoint then
                self.WatchPlatoon = nil
            end
            
            WaitTicks(4)
        end

    end,

    -- this is the primary movement method for platoon movement in LOUD
    -- it handles processing the path provided to it by the platoon
    -- moving it one segment at a time
	MovePlatoon = function( self, path, PlatoonFormation, AggroMove, waypointslackdistance)
        
        local aiBrain = self:GetBrain()

		local prevpoint = GetPlatoonPosition(self) or false

		if prevpoint and path[1] then
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." MTWayPt "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." starts MovePlatoon with path "..repr(path))

            local GetDirection          = GetDirection            
            local GetSquadUnits         = GetSquadUnits
            local GetPlatoonUnits       = GetPlatoonUnits

            local LOUDCOPY      = LOUDCOPY
            local LOUDREMOVE    = LOUDREMOVE
            local WaitTicks     = WaitTicks

            SetupPlatoonAtWaypointCallbacks = self.SetupPlatoonAtWaypointCallbacks
            
            if PlatoonFormation != 'None' then
                self:SetPlatoonFormationOverride(PlatoonFormation)
            end

            -- make a copy of the original to use for the primary loop
            self.pathcopy = LOUDCOPY(path)
		
			-- this variable controls what I call the 'path slack' - the distance at which a platoon considers this step complete
			-- as a platoon moves from point to point when it's within this range of it's goal - it considers itself there
            -- and moves onto it's next waypoint

			-- this seems to be most helpful for very large platoons which often seem to get 'stuck' right at a waypoint, unable to close
			-- the distance due to the sheer size of the platoon
            -- problem is - you don't want the value too large or platoons will change
            -- to their next waypoint too early - also - speed of the platoon is important 
            -- faster platoons need a little more warning 

            -- TODO: Make pathslack an optional variable that can be passed in
            -- or calculate one based on the step distance and/or platoon size
			local pathslack = waypointslackdistance or 21
            
            local Direction, SCOUTS, ATTACKS, ARTILLERY, GUARDS, SUPPORTS

			for wpidx, waypointPath in self.pathcopy do
			
				if self.MoveThread then
                    
                    if type(waypointPath) != 'table' then

                        LOG("*AI DEBUG "..aiBrain.Nickname.." MTWayPt "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." using path "..repr(path))

                        continue
                    end

					self.WaypointCallback = SetupPlatoonAtWaypointCallbacks( self, waypointPath, pathslack )
                    
					Direction = GetDirection( prevpoint, waypointPath )
                    
                    self:Stop()

					if AggroMove then

                        --LOG("*AI DEBUG "..aiBrain.Nickname.." MTWayPt "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." issuing orders using aggro to "..repr(waypointPath) )

                        SCOUTS = GetSquadUnits( self, 'Scout' ) or false

						if SCOUTS[1] then
                        
							IssueFormMove( SCOUTS, waypointPath, 'BlockFormation', Direction)
						end
                        
                        ATTACKS = table.merged( GetSquadUnits( self,'Attack'), GetSquadUnits( self,'Unassigned') )
					
						if ATTACKS[1] then
                        
							IssueFormAggressiveMove( ATTACKS, waypointPath, 'AttackFormation', Direction)
                        end
                        
                        ARTILLERY = GetSquadUnits( self,'Artillery') or false
                        
						if ARTILLERY[1] then
                        
							IssueFormAggressiveMove( ARTILLERY, waypointPath, PlatoonFormation, Direction)
						end
                        
                        GUARDS = GetSquadUnits(self,'Guard') or false

                        SUPPORTS = GetSquadUnits(self,'Support') or false					

						if GUARDS[1] then
                     
                            if not ARTILLERY[1] and not ATTACKS[1] then
                            
                                IssueFormMove( GUARDS, waypointPath, 'BlockFormation', Direction)
                                
                            elseif ARTILLERY[1] then
                                
                                IssueGuard( GUARDS, ARTILLERY[1] )
                                
                            elseif ATTACKS[1] then
                                
                                IssueGuard( GUARDS, ATTACKS[1] )
                            
                            elseif SUPPORTS[1] then
                            
                                IssueGuard( GUARDS, SUPPORTS[1] )
                            
                            end
						end
					
						if SUPPORTS[1] then
                        
                            if not ATTACKS[1] and not ARTILLERY[1] and not GUARDS[1] then
                            
                                IssueFormAggressiveMove( SUPPORTS, waypointPath, 'BlockFormation', Direction)
                                
                            elseif ATTACKS[1] then
                            
                                IssueGuard( SUPPORTS, ATTACKS[1] )
                                
                            elseif ARTILLERY[1] then
                            
                                IssueGuard( SUPPORTS, ARTILLERY[1] )                            
                            
                            elseif GUARDS[1] then
                            
                                IssueGuard( SUPPORTS, GUARDS[1] )
                                
                            end
						end
					
					else
			
						self:MoveToLocation( waypointPath, false )
                        
					end

					while self.MovingToWaypoint do
                        WaitTicks(2)
                    end
                    
				end
			
				if self.WaypointCallback then

                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." killing WayPointCallback")
                    
					KillThread(self.WaypointCallback)
					self.WaypointCallback = nil
				end

                -- by doing this - the currently executing step is always the first entry in the remaining path which the source platoon can follow
                LOUDREMOVE( path, 1)    -- we remove the step, from the original path, as we complete it.
  			
				prevpoint[1] = waypointPath[1]
                prevpoint[2] = waypointPath[2]
                prevpoint[3] = waypointPath[3]
			end
		else
			WARN("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..repr(self.BuilderInstance).." has no path ! Position is "..repr(prevpoint))
		end
        
        self:KillMoveThread()        
	end,
	
    -- this just kills the thread created by MovePlatoon
	KillMoveThread = function( self )
		
		if self.WaypointCallback then
		
			KillThread( self.WaypointCallback )
			
			self.MovingToWaypoint = nil
			self.WaypointCallback = nil
		end

		KillThread( self.MoveThread )
		
		self.MoveThread = nil
        self.pathcopy = nil
	end,

    -- this function will hunt and engage a local target within a radius
    -- either from the scanposition (if provided) or the platoon position
    -- returns true if a target was found - false if not
    PlatoonFindTarget = function( self, aiBrain, squad, scanposition, range, attackcategories)
    
        local GetDirection          = GetDirection
        local GetPlatoonPosition    = GetPlatoonPosition
        local GetSquadUnits         = GetSquadUnits
        local PlatoonExists         = PlatoonExists
        
        local VDist3        = VDist3
        local WaitTicks     = WaitTicks
        
		-- seek a target around the point --
		local target, targetposition, position

		target,targetposition = FindTargetInRange( self, aiBrain, squad, range, attackcategories, false, scanposition )

		if target and PlatoonExists( aiBrain,self) then
        
            targetposition = LOUDCOPY(targetposition)
 
            local PlatoonFormation = self.PlatoonData.UseFormation or 'None'

			-- issue attack moves toward the target --
			if target.EntityID and not target.Dead then

				position = GetPlatoonPosition(self) or false
                
                self:Stop()

				if position then

					local direction = GetDirection( position, targetposition )

                    local ATTACKS = GetSquadUnits(self,'Attack')

                    if ATTACKS[1] then
				
                        IssueFormAggressiveMove( ATTACKS, targetposition, 'AttackFormation', direction)
                        
                    end
                    
                    local ARTILLERY = GetSquadUnits(self,'Artillery')
					
                    if ARTILLERY[1] then
                       
                        IssueFormAggressiveMove( ARTILLERY, targetposition, PlatoonFormation, direction)

                    end
                    
                    local GUARDS = GetSquadUnits(self,'Guard')

                    if GUARDS[1] then

                        if not ARTILLERY[1] and not ATTACKS[1] then

                            IssueFormMove( GUARDS, targetposition, 'BlockFormation', direction)

                        elseif ARTILLERY[1] then

                            IssueGuard( GUARDS, ARTILLERY[1] )

                        elseif ATTACKS[1] then

                            IssueGuard( GUARDS, ATTACKS[1] )

                        end

                    end
                    
                    local SUPPORTS = GetSquadUnits(self,'Support')
					
                    if SUPPORTS[1] then

                        if not ATTACKS[1] and not ARTILLERY[1] then
                            
                            IssueFormAggressiveMove( SUPPORTS, targetposition, 'BlockFormation', direction)

                        elseif ATTACKS[1] then
                            
                            IssueGuard( SUPPORTS, ATTACKS[1] )

                        elseif ARTILLERY[1] then
                            
                            IssueGuard( SUPPORTS, ARTILLERY[1] )

                        end
                    end
                end

			else

				target = false
			end

			-- Engage target until dead or target is outside guard radius
			while target and (not target.Dead) and PlatoonExists(aiBrain, self) do 

				WaitTicks(21)

				if PlatoonExists(aiBrain,self) then
                
                    position = GetPlatoonPosition(self) or false

                    -- if target dies or moves out of range --
                    if target.Dead or (not position) or VDist3( GetPosition(target), position) >= range then

						target = false
                        
                        self:Stop() 
					end
                end
            end

            -- acknowledges we had a target
            return true
		end
        
        -- acknowledges no target was found
        return false
    
    end,
    
	-- this function is just a 'tiny' bit different than DisbandPlatoon
	-- first off - it makes sure that all the units get their PlatoonHandle field cleared - which is quite useful
	-- secondly - it handles special processing for engineers and air units
    PlatoonDisband = function( self, aiBrain)
	
		if PlatoonExists(aiBrain,self) then
        
            local EngineerDialog    = ScenarioInfo.EngineerDialog
            local NameEngineers     = ScenarioInfo.NameEngineers
            local PlatoonDialog     = ScenarioInfo.PlatoonDialog
    
            local LOUDENTITY    = LOUDENTITY
            local LOUDFIND      = LOUDFIND

			if PlatoonDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..self.BuilderName.." "..repr(self.BuilderInstance).." beginning Disband")
			end

			if self.MoveThread then
				self:KillMoveThread()
			end

			local units = GetPlatoonUnits(self)
            local ArmyPool = aiBrain.ArmyPool

			for _,v in units do

				if not v.Dead then
				
					v.PlatoonHandle = false
					
					-- processing for engineers --
					if LOUDENTITY( ENGINEERS, v ) then

                        local BuilderName = self.BuilderName

						local EM = aiBrain.BuilderManagers[v.LocationType].EngineerManager

						local CurrentTime = LOUDTIME()
						
						if self.CreationTime == CurrentTime then
					
							if BuilderName and not LOUDFIND( BuilderName, 'Eng RTB') and self.BuilderLocation then
                                
								v.failedbuilds = (v.failedbuilds + 1) or 1
                        
                                if EngineerDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..v.EntityID.." "..BuilderName.." immediately disbands - assigning TIMEOUT to this task - failedbuilds is "..v.failedbuilds )
                                end
								
								ForkTo( EM.AssignTimeout, EM, BuilderName, 300 )
							end
						end
                        
                        if EngineerDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..v.EntityID.." "..repr(BuilderName).." disbands - failedbuilds is "..(v.failedbuilds or 0) )
                        end
                    
						if NameEngineers then
						
							if v.BuilderName and not LOUDENTITY( COMMANDER, v ) then
							
								v:SetCustomName("Eng "..v.EntityID.." Last: "..v.BuilderName)
							else
								v:SetCustomName( aiBrain.Nickname )
							end
						end

						v.BuilderName = nil
						v.NewExpansion = nil

						v.AssigningTask = false
						v.EngineerBuildQueue = {}

						-- this will fire up the engineer seeking a job to do
						-- or move him to another base if his current base is dead
						if EM.Active then
						
							EM:ForkThread( EM.DelayAssignEngineerTask, v, aiBrain)
						else
							EM:ForkThread( EM.ReassignEngineer, v, aiBrain)
						end
                    end
				
					-- processing for air units assigns them to the refuel pool 
					if LOUDENTITY( AIRUNITS, v ) then
					
						if ProcessAirUnits( v, aiBrain) then
							-- onto next unit --
							continue
						end
					end
					
					-- everyone else goes to Army Pool -- 
					if not v.PlatoonHandle then
						AssignUnitsToPlatoon( aiBrain, ArmyPool, {v}, 'Unassigned','none' )
					end
				end
			end
		end
    end,

	-- If there are pathing nodes available to this platoon's most restrictive movement type, then a path to the destination
	-- can be generated while avoiding other high threat areas along the way.
		-- platoonLayer 	- layer to use to generate safe path... e.g. 'Air', 'Land', etc.
		-- start 			- the start location
		-- destination 		- the destination location
		-- threatallowed	- maximum amount of threat allowed at any point
		-- MaxMarkerDist 	- maximum distance that a selectable point can be from the destination
	
	--   Returns -- a list of locations representing the path to the destination and a result code indicating reason for failure or success;
	--			Direct - very close - no path required
	--			BadLocations - no start or destination was specified
	--			NoStartNode - can't find a node near start position
	--			NoEndNode - can't find a node near destination
	--
    -- May 2020 - added the pathcost to the return value for Land and Amphib paths
	PlatoonGenerateSafePathToLOUD = function( aiBrain, platoon, platoonLayer, start, destination, threatallowed, MaxMarkerDist)

        local PathFindingDialog         = ScenarioInfo.PathFindingDialog

        local GetPlatoonUnits           = GetPlatoonUnits
		local GetUnitsAroundPoint       = GetUnitsAroundPoint
        local PlatoonExists             = PlatoonExists

        local LOUDFLOOR     = LOUDFLOOR
        local LOUDMAX       = LOUDMAX
        local LOUDMIN       = LOUDMIN
        local LOUDSORT      = LOUDSORT
		local VDist2Sq      = VDist2Sq
		local VDist2        = VDist2
        local VDist3Sq      = VDist3Sq
        local WaitTicks     = WaitTicks

		local threattype    = ThreatTable[platoonLayer]

		-- threatallowed controls how much threat is considered acceptable at any point
		local threatallowed = threatallowed or 5
        
        -- the number of blocks to use for threat lookups - based on IMAP size
        -- basically 2, 2, 1, 0 for 5k, 10k, 20k, 40k+
        local IMAPblocks    = ScenarioInfo.IMAPBlocks
        local IMAPRadius    = ScenarioInfo.IMAPSize * .5

		
		-- step size is used when making DestinationBetweenPoints checks
		local stepsize = 96

		-- air platoons can look much further off the line since they generally ignore terrain anyway
		-- this larger step makes looking for destination much less costly in processing
		if platoonLayer == 'Air' then
        
            -- modified to adapt to smaller IMAP sizes - will now range from 96 to 256
			stepsize = LOUDMIN( LOUDMAX( 96, ScenarioInfo.IMAPSize*1.5 ), 256 )
            
		end
		
		if start and destination then
	
			local distance = VDist2( start[1],start[3], destination[1],destination[3] )
		
			if distance <= stepsize then
			
				return {destination}, 'Direct', distance, 0
				
			elseif platoonLayer == 'Amphibious' then
			
				stepsize = 96
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance, 0
				end
				
			elseif platoonLayer == 'Water' then
			
				stepsize = 128
				
				if distance <= stepsize then
					return {destination}, 'Direct', distance, 0
				end

			end
			
		else
		
			if not destination then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." Generate Safe "..platoonLayer.." Path has a bad destination "..repr(destination))
                
				return false, 'Badlocations', 0, 0
                
			else
			
                if platoon != 'AttackPlanner' or (platoon and platoon.BuilderName != nil) then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." Generate Safe Path "..platoonLayer.." had a bad start "..repr(start))
                end
                
				return {destination}, 'Direct', 9999, 0
			end
		end

		-- MaxMarkerDist controls the range we look for markers AND the range we use when making threat checks
		local MaxMarkerDist = MaxMarkerDist or 160
		local radiuscheck = MaxMarkerDist * MaxMarkerDist

		local stepcheck = stepsize * stepsize
		
		-- get all the layer markers -- table format has 5 values (posX,posY,posZ, nodeName, graph)
		local markerlist = ScenarioInfo.PathGraphs['RawPaths'][platoonLayer] or false

		
		--** A Whole set of localized function **--
		-------------------------------------------

		local AIGetThreatLevelsAroundPoint = function( position )

			if threattype == 'AntiAir' then
				return aiBrain:GetThreatAtPosition( position, IMAPblocks, true, 'AntiAir')	--airthreat
			elseif threattype == 'AntiSurface' then
				return aiBrain:GetThreatAtPosition( position, IMAPblocks, true, 'AntiSurface')	--surthreat
			elseif threattype == 'AntiSub' then
				return aiBrain:GetThreatAtPosition( position, IMAPblocks, true, 'AntiSub')	--subthreat
			elseif threattype == 'Economy' then
				return aiBrain:GetThreatAtPosition( position, IMAPblocks, true, 'Economy')	--ecothreat
			else
				return aiBrain:GetThreatAtPosition( position, IMAPblocks, true, 'Overall')	--airthreat + ecothreat + surthreat + subthreat
			end
	
		end

		-- checks if destination is somewhere between two points
        -- if it is, return the point at which we located the destination
		local DestinationBetweenPoints = function( destination, start, finish )
        
            local VDist2Sq = VDist2Sq

			local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )

            if steps == 0 then
                return false
            end
            
			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
	
			-- check the steps from start to one less than then destination
			for i = 1, steps do
				
				-- if we're within the stepcheck ogrids of the destination then we found it
				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < stepcheck then
            
                    if PathFindingDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." finds destination within "..stepsize.." range of ".. repr({start[1] - (xstep * i), start[3] - (ystep * i)}) )
                    end

					return { start[1] - (xstep * i), destination[2], start[3] - (ystep * i) }
				end
			end	
			
			return false
		end

		-- the intent of this function is to make sure that we don't try and respond over mountains
		-- and rivers and other serious terrain blockages -- these are generally identified by
        -- a rapid elevation change over a very short distance
		local function CheckBlockingTerrain( pos, targetPos, blockingcheck )
        
            if platoonLayer == 'Air' then
                return false
            end
            
            if not blockingcheck then
                return false
            end
            
            local GetSurfaceHeight = GetSurfaceHeight
            local LOUDABS = LOUDABS
            local InWater, steps, xstep, ystep
  
            -- alter the function according to layer
            local terrainfunction = GetTerrainHeight
            local deviation = 2.5
            
            if platoonLayer == 'Water' then
                terrainfunction = GetSurfaceHeight
                deviation = 0.5
            end
            
			-- This gives us the number of approx. 6 ogrid steps in the distance
			steps = LOUDFLOOR( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 6 ) + 1
	
			xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
			ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step
			
			local lastpos = {pos[1], 0, pos[3]}
            local lastposHeight = terrainfunction( lastpos[1], lastpos[3] )
            
            local nextpos = { 0, 0, 0 }
            
            local nextposHeight

			-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
			for i = 1, steps do

                InWater = lastposHeight < (GetSurfaceHeight( lastpos[1], lastpos[3] ) -1 )

                nextpos[1] = pos[1] - (xstep * i)
                nextpos[3] = pos[3] - (ystep * i)
                nextposHeight = terrainfunction( nextpos[1], nextpos[3] )

                -- if more than deviation ogrids change in height over 6 ogrids distance
				if LOUDABS(lastposHeight - nextposHeight) > deviation or (InWater and platoonLayer != 'Amphibious') then

                    if PathFindingDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." "..platoonLayer.." obstructed between "..repr(pos).." and "..repr(targetPos) )
                    end                

					return true
				end

				lastpos[1] = nextpos[1]
                lastpos[3] = nextpos[3]
                lastposHeight = nextposHeight

			end	
	
			return false
		end
		
		-- this function will return a 3D position and a named marker
		local GetClosestSafePathNodeInRadiusByLayerLOUD = function( location, seeksafest, goalseek, threatmodifier, blockingcheck )

            -- the marker list is the master list of all movement markers of the Platoons current layer (Land, Amphib, Air, Water)
			if markerlist then

                local CheckBlockingTerrain = CheckBlockingTerrain
                local GetThreatBetweenPositions = GetThreatBetweenPositions
                local LOUDCOPY = LOUDCOPY
                local LOUDSORT = LOUDSORT
				local VDist2 = VDist2
                local VDist3 = VDist3

				local counter = 0
				local positions = {}			

                local maxthreat = (threatallowed * threatmodifier)
                local maxthreattest = maxthreat
                local nomarkers = true

                local Node, Position, goaldistance, testdistance, thisdistance, thisthreat
				
				-- sort the table by closest to the given location (start position of this test)
				LOUDSORT(markerlist, function(a,b) local VDist3Sq = VDist3Sq return VDist3Sq( a.position, location ) < VDist3Sq( b.position, location ) end)
                
                if goalseek then
                    -- only allow points that are closer (within 10%) of the goal
                    -- as sometimes the only connecting marker is actually a bit further away from the desired goal
                    goaldistance = VDist3(location,goalseek) * 1.1
                end
	
				-- traverse the list and make a new list of those with allowable threat and within the MaxMarkerDist range
				-- since the source table is already sorted by range, the output table will be created in a sorted order
                -- if we are seeking the safest, we should always immediately return when we get a 0 or less threat - as it will also be the closest
                -- if we are goalseeking then we must review them all - and then sort to get the one closest to the goal (that is still safe)
				for _,v in markerlist do
                
                    Node = v.node
                    Position = LOUDCOPY(v.position)
                    
                    testdistance = VDist2( Position[1],Position[3], location[1],location[3] )

					-- process only those entries within the radius
					if testdistance <= MaxMarkerDist then
                    
                        nomarkers = false
                        
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind checking marker "..repr(Node).." at "..repr(Position).." goalseek is "..repr(goalseek).." seeksafest is "..repr(seeksafest) )
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." IMAPRadius is "..IMAPRadius.." testdistance is "..testdistance.." factor would be "..testdistance/IMAPRadius )

                        thisthreat = GetThreatBetweenPositions( aiBrain, location, Position, nil, threattype ) / math.max( 1, testdistance/IMAPRadius )
                        
                        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." Gets "..thisthreat.." "..threattype.." threat between "..repr(location).." and "..repr(Position).." Max "..maxthreattest.." modifier is "..math.max( 1, testdistance/IMAPRadius )  )

                        if thisthreat <= maxthreattest then
                        
                            if goalseek then
                                thisdistance = VDist3(Position, goalseek)
                            else
                                -- record lowest threat
                                maxthreattest = thisthreat
                            end

                            if not CheckBlockingTerrain( location, Position, blockingcheck ) then

                                -- add only those with acceptable threat to the new list
                                -- if seeksafest or goalseek and there is any kind of threat, we'll build a table of points with allowable threats
                                -- otherwise we'll just take the closest one with zero threat

                                -- if threat is zero - and we're not goalseeking - we'll use it immediately
                                -- if we are goalseeking - the tested Position has to be closer to the goal than the location where we started this test from
                                -- we'll just add the location to the list of positions and sort it afterwards by which is closer to the goal
                                if thisthreat > 0 or ( goalseek and thisdistance < goaldistance ) then
                                
                                    if counter > 0 then
                                    
                                        if platoonLayer != 'Air' and testdistance > (MaxMarkerDist * .5) then
                                            break
                                        end

                                    end
                                    
                                    --LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind checking marker "..repr(Node).." at "..repr(Position).." ADDED" )

                                    counter = counter + 1						
                                    positions[counter] = { thisthreat, Node, Position, math.floor(testdistance), math.floor(thisdistance or 0) }

                                    -- within DIRECT range --
                                    if platoonLayer == 'Air' and thisdistance and thisdistance < stepsize then
                                        break
                                    end
                                    
                                    goaldistance = thisdistance
                                
                                else
                                    if not goalseek then
                                        return ScenarioInfo.PathGraphs[platoonLayer][Node], Node or GetPathGraphs()[platoonLayer][Node], Node
                                    end
                                end

                            end

                        end
                        
					else
                        break   -- markers are sorted by range from location so we've exhausted any that are close enough
                    end
                    
				end

                --LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind checking marker list is "..counter) 

				-- resort positions 

				if goalseek and not seeksafest then
                    -- sort by shortest total distance to goal (sum of both distances, from start and to goal)
					LOUDSORT(positions, function(a,b) return a[4]+a[5] < b[4]+b[5] end)
				else
                    if seeksafest and not goalseek then
                        -- sort by threat -- plus a small distance modifier - so if threat is the same (or very close), we prefer the result closer to the start
                        LOUDSORT(positions, function(a,b) return a[1]+(a[4]*.05) < b[1]+(b[4]*.05) end)
                    else
                        -- seeksafest and goalseek
                        LOUDSORT(positions, function(a,b) return a[1]+((a[4]+a[5])*.05) < b[1]+((b[4]+b[5])*.05) end)
                    end
                end
                
                --LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind checking marker positions maxthreat is "..repr(maxthreat).." positions are "..repr(positions) )

				local bestThreat = maxthreat
				local bestMarker = positions[1][2]	-- default to the one closest to goalseek
			
				-- loop thru to find one with lowest threat	-- if all threats are equal we'll end up with the closest
				if seeksafest then
			
					for _,v in positions do
				
						if v[1] < bestThreat then
							bestThreat = v[1]
							bestMarker = v[2]
						end
					end
				end

				if bestMarker then
               
					return ScenarioInfo.PathGraphs[platoonLayer][bestMarker],bestMarker or GetPathGraphs()[platoonLayer][bestMarker],bestMarker
				else
                
                    if nomarkers then
                        --WARN("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." -- no "..repr(platoonLayer).." markers found within "..MaxMarkerDist.." range of "..repr(location).." closest marker is "..repr(markerlist[1].position).." at "..repr(VDist3(markerlist[1].position, location)) )
                    else
                        if PathFindingDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." No safe "..repr(platoonLayer).." marker was found - using "..maxthreat.." threat - near "..repr(location).." available positions were "..repr(positions) )
                        end
                    end
                    
                end
            end
			
			return false, false
		end	

        -- when a path returns 'No Path' we'll cache it for six seconds to minimize immediate thrashing
		local AddBadPath = function( layer, startnode, endnode )

			if not ScenarioInfo.BadPaths[layer][startnode] then
			
				ScenarioInfo.BadPaths[layer][startnode] = {}
			end

			if not ScenarioInfo.BadPaths[layer][startnode][endnode] then
	
				ScenarioInfo.BadPaths[layer][startnode][endnode] = {}

				if not ScenarioInfo.BadPaths[layer][endnode] then
					ScenarioInfo.BadPaths[layer][endnode] = {}
				end
		
				ScenarioInfo.BadPaths[layer][endnode][startnode] = {}
			end
            
            WaitTicks(61)
            
            ScenarioInfo.BadPaths[layer][endnode][startnode] = nil
            ScenarioInfo.BadPaths[layer][startnode][endnode] = nil
		end

		-- this flag is set but passed into the path generator
		-- was originally used to allow the path generator to 'cut corners' on final step
		local testPath = true
		
		if platoonLayer == 'Air' or platoonLayer == 'Amphibious' then
			testPath = true
		end
        
        if PathFindingDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." wants to find a path from "..repr(start).." to "..repr(destination).." Distance is "..VDist3(start,destination) )
        end
	
		-- Get the node at platoon position which is closest to the destination
		local startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayerLOUD( start, false, destination, 1.5, true )

		if not startNode and platoonLayer == 'Amphibious' then
		
            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." no safe "..platoonLayer.." startnode using "..threatallowed.." threat within "..MaxMarkerDist.." of "..repr(start).." - trying Land")
            end
            
			platoonLayer = 'Land'
			startNode, startNodeName = GetClosestSafePathNodeInRadiusByLayerLOUD( start, false, destination, 1.5, true )

        end
	
		if not startNode then
            
			WaitTicks(1)
			return false, 'NoSafeStart', 0, 0
			
		end
		
		if DestinationBetweenPoints( destination, start, startNode.position ) then

            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." goes DIRECT from "..repr(startNodeName) )
            end            

			return {destination}, 'Direct', VDist2( start[1],start[3], destination[1],destination[3] ), 0
			
		end			
    

        local blockingcheck = true
        
        if string.find( platoon.BuilderName or platoon, "AttackPlanner") then
            blockingcheck = false
        end

		-- Get the closest safe node at the destination which is closest to the start        
		local endNode, endNodeName = GetClosestSafePathNodeInRadiusByLayerLOUD( destination, true, start, 1, blockingcheck )

		if not endNode then
            
			WaitTicks(1)
			return false, 'NoSafeEnd', 0, 0

        end
		
		if startNodeName == endNodeName then

            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." goes DIRECT from "..repr(startNodeName) )
            end            

			return {destination}, 'Direct', VDist2( start[1],start[3], destination[1],destination[3] ), 0
			
		end
		
		local path = false
        local pathcost = 5
		local pathlength = VDist2(start[1],start[3],startNode.position[1],startNode.position[3])
	
		local BadPath = ScenarioInfo.BadPaths[platoonLayer]
	
		-- if the nodes are not in the bad path cache generate a path for them
		-- Generate the safest path between the start and destination nodes
		if not BadPath[startNodeName][endNodeName] then

            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." requests "..platoonLayer.." path from "..repr(startNodeName).." "..repr(startNode.position).." to "..repr(endNodeName).." "..repr(endNode.position) )
            end            

			-- add the platoons request for a path to the respective path generator for that layer
			LOUDINSERT(aiBrain.PathRequests[platoonLayer], {
															Dest = destination,
															EndNode = endNode,
															Location = start,
															Platoon = platoon,
                                                            Startlength = pathlength,
															StartNode = startNode,
															Stepsize = stepsize,
															Testpath = testPath,
															ThreatLayer = threattype,
															ThreatWeight = threatallowed,
			} )

			aiBrain.PathRequests['Replies'][platoon] = false
            
            local Replies = aiBrain.PathRequests['Replies']
			
			local waitcount = 1
			
			-- loop here until reply or 90 seconds
			while waitcount < 100 do

				WaitTicks(3)

				waitcount = waitcount + 1
				
				if Replies[platoon].path then
					break
				end
			end

			if waitcount < 100 then
			
				path = Replies[platoon].path
                pathcost = Replies[platoon].cost                
				pathlength = Replies[platoon].length + pathlength
			else
			
				Replies[platoon] = false
				return false, 'NoResponse',0,0
			end

            -- remove reply
			Replies[platoon] = nil  --false
		else
            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." got a BAD "..platoonLayer.." PATH from startnode "..repr(startNodeName).." to endnode "..repr(endNodeName) )
            end            
        end

		if not path or path == 'NoPath' then

			-- if no path can be found (versus too much threat or no reply) then add to badpath cache
			if path == 'NoPath' and not BadPath[startNodeName][endNodeName] then
				ForkTo(AddBadPath, platoonLayer, startNodeName, endNodeName )
			end

            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." gets NO PATH response " )
            end            
	
			return false, 'NoPath', 0, 0
		end
	
		
        pathlength = pathlength + VDist3( path[LOUDGETN(path)], destination )
        
        path[LOUDGETN(path)+1] = destination

        if PathFindingDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." gets path response "..repr(path) )
        end            
	
		return path, 'Pathing', pathlength, pathcost
	end,	
	
	-- Finds a base to return to & disband
	ReturnToBaseAI = function( self, aiBrain )
    
        local RTBDialog = false

        local EngineerDialog    = ScenarioInfo.EngineerDialog    
        local NameEngineers     = ScenarioInfo.NameEngineers
        local PlatoonDialog     = ScenarioInfo.PlatoonDialog
	
		-- since RTB always deals with MOBILE units we use the Entity based GetPosition
        local CalculatePlatoonThreat    = CalculatePlatoonThreat
		local GetPosition               = GetPosition
		local GetCommandQueue           = moho.unit_methods.GetCommandQueue
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetPlatoonUnits           = GetPlatoonUnits
        local PlatoonExists             = PlatoonExists        

        local LOUDCOPY      = LOUDCOPY
        local LOUDENTITY    = LOUDENTITY
        local LOUDMOD       = LOUDMOD
        local LOUDSORT      = LOUDSORT
		local VDist3        = VDist3
		local VDist2        = VDist2
  		local VDist2Sq      = VDist2Sq
        local VDist3Sq      = VDist3Sq
        local WaitTicks     = WaitTicks

        local MergeIntoNearbyPlatoons           = self.MergeIntoNearbyPlatoons
        local PlatoonGenerateSafePathToLOUD     = self.PlatoonGenerateSafePathToLOUD

		if not aiBrain then
			aiBrain = GetBrain(self)
		end

		if self == aiBrain.ArmyPool or not PlatoonExists(aiBrain, self) then
			return
		end
		
		if self.DistressResponseAIRunning then
			self.DistressResponseAIRunning = false
		end

		if self.MoveThread then
			self:KillMoveThread()
		end
		
		if not self.MovementLayer then
			GetMostRestrictiveLayer(self)
		end
        
        -- local the movement layer
        local MovementLayer = self.MovementLayer
		
		-- assume platoon is dead 
		local platoonDead = true

		-- set the desired RTBLocation (specified base, source base or false)
        local RTBLocation = self.RTBLocation or false

		-- flag for experimentals (no air transports)
		local experimental = PlatoonCategoryCount(self, EXPERIMENTALS) > 0
		
		-- assume no engineer in platoon
		local engineer = false
        
        local platPos = GetPlatoonPosition(self)

        local BuilderName, LocationType

		-- process the units to identify engineers and the CDR
		-- and to determine which base to RTB to
		for k,v in GetPlatoonUnits(self) do
		
			-- set the 'platoonDead' to false
			if not v.Dead then
            
                BuilderName = v.BuilderName
                LocationType = v.LocationType
			
				platoonDead = false
                
				-- set the 'engineer' flag
				if LOUDENTITY( ENGINEERS, v ) then
                
                    if EngineerDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..v.EntityID.." "..repr(BuilderName).." now in RTB to "..LocationType )                        
                    end
				
					engineer = v

					-- Engineer naming
                    if BuilderName and NameEngineers then
					
						if not LOUDENTITY( COMMANDER, v ) then
							v:SetCustomName("Eng "..v.EntityID.." RTB from "..BuilderName.." to "..LocationType )
						end
                    end
                    
                    v.lastbuild = nil
					
					-- force CDR to disband - he never leaves home
	                if LOUDENTITY( COMMANDER, v ) then
						self:PlatoonDisband( aiBrain )
						return
					end
					
					RTBLocation = LocationType
				end
				
				-- if no RTBLocation then force one
				if not RTBLocation or RTBLocation == "Any" then
                
                    -- no provided RTBLocation - use LocationType from unit
                    if not RTBLocation then
                    
                        if aiBrain.BuilderManagers[LocationType].EngineerManager.Active then
                        
                            RTBLocation = LocationType
                        end
                    end
				
					-- if the unit has a LocationType and it exists -- we might use that for the platoon
					if not RTBLocation or RTBLocation == "Any"  then

						-- find the closest manager 
						if MovementLayer == "Land" then

							RTBLocation = FindClosestBaseName( aiBrain, platPos, false, false )
						else
							
							if MovementLayer == "Air" or MovementLayer == "Amphibious" then
								
								-- use any kind of base --
								RTBLocation = FindClosestBaseName( aiBrain, platPos, true, false )
							else
								
								-- use only naval bases for 'Sea' platoons
								RTBLocation = FindClosestBaseName( aiBrain, platPos, true, true )
							end
						end
					end

                end
				
				-- default attached processing (something is not doing this properly)
				if IsUnitState( v, 'Attached') then
				
					v:DetachFrom()
					v:SetCanTakeDamage(true)
					v:SetDoNotTarget(false)
					v:SetReclaimable(true)
					v:SetCapturable(true)
					v:ShowBone(0, true)
					v:MarkWeaponsOnTransport(v, false)
				end
			end
        end

		-- exit if no units --
		if platoonDead then
            return 
		end
		
		if RTBDialog then
			LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..self.BuilderName.." "..repr(self.BuilderInstance).." begins RTB to "..repr(RTBLocation).." at tick "..GetGameTick() )
		end

       	self:Stop()

		local lastpos = { 0, 0, 0 }

        lastpos[1] = platPos[1]
        lastpos[2] = platPos[2]
        lastpos[3] = platPos[3]
        
		local transportLocation = false	
        local bestBase = false
        local bestBaseName = ""
        local bestDistance = 99999999

        local baseName, base, calltransport, count, cyclecount, distance, markerradius, merged, mythreat, path, platooncount, reason, rtbdistance, slackdistance, StuckCount, unitpos, units, usedTransports, UseFormation
		
		local bases = aiBrain.BuilderManagers
		
		-- confirm RTB location exists or pick closest
		if bases and platPos then
		
			-- if specified base exists and is active - use it
			-- otherwise locate nearest suitable base as RTBLocation
			if RTBLocation and bases[RTBLocation].EngineerManager.Active then
				
				bestBase = bases[RTBLocation]
				bestBaseName = RTBLocation
                RTBLocation = bestBase.Position
			else
				
				RTBLocation = 'Any'
				
				-- loop thru all existing 'active' bases and use the closest suitable base --
				-- if no base -- use 'MAIN' --
				for baseName, base in bases do
				
					-- if the base is active --
					if base.EngineerManager.Active then
					
						-- record distance to base
						distance = VDist2Sq( platPos[1],platPos[3], base.Position[1],base.Position[3] )                
				
						-- is this base suitable for this platoon 
						if (distance < bestDistance) and ( (RTBLocation == 'Any') or (not engineer and not RTBLocation) ) then
                
							-- dont allow RTB to Naval Bases for Land --
							-- and dont allow RTB to anything BUT Naval for Water
							if (MovementLayer == 'Land' and base.BaseType == "Sea") or
							   (MovementLayer == 'Water' and base.BaseType != "Sea") then
							   
								continue
							else
							
								bestBase = base
								bestBaseName = baseName
								RTBLocation = bestBase.Position
								bestDistance = distance    
							end
						end
					end
				end
            
				if (not bestBase) and aiBrain.BuilderManagers['MAIN'] then
			
					LOG("*AI DEBUG "..aiBrain.Nickname.." RTB "..repr(self.BuilderName).." Couldn't find base "..repr(RTBLocation).." - using MAIN")
				
					bestBase = aiBrain.BuilderManagers['MAIN']
					bestBaseName = 'MAIN'
					RTBLocation = bestBase.Position
				end
			end

			-- set transportlocation - engineers always use base centre	
			if bestBase.Position then
			
				transportLocation = LOUDCOPY(bestBase.Position)
			else
				
				--LOG("*AI DEBUG "..aiBrain.Nickname.." RTB cant locate a bestBase")
				
				return self:PlatoonDisband(aiBrain)
			end
			
			-- others will seek closest rally point of that base
			if not engineer then
			
				-- use the base generated rally points
				LOUDSORT( bestBase.RallyPoints, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq( a[1],a[3], platPos[1],platPos[3] ) < VDist2Sq( b[1],b[3], platPos[1],platPos[3] ) end )

				transportLocation = LOUDCOPY( bestBase.RallyPoints[1] )
				
				-- if cannot find rally marker - use base centre
				if not transportLocation then
					transportLocation = LOUDCOPY(bestBase.Position)
				end
				
			end

            RTBLocation[2] = GetTerrainHeight( RTBLocation[1], RTBLocation[3] )
			transportLocation[2] = GetTerrainHeight(transportLocation[1],transportLocation[3])
		else
            LOG("*AI DEBUG "..aiBrain.Nickname.." RTB reports no platoon position or no bases")
			
			return self:PlatoonDisband(aiBrain)
        end
		
		distance = VDist3( platPos, RTBLocation )
		
		if RTBDialog then
			LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon "..self.BuilderName.." "..repr(self.BuilderInstance).." RTB to "..repr(RTBLocation).." distance is "..string.format("%.1f",distance) )
		end

        UseFormation = 'GrowthFormation'
        slackdistance = 21

        if MovementLayer == 'Air' then
            UseFormation = 'None'
            slackdistance = 50
        end

		-- Move the platoon to the transportLocation either by ground, transport or teleportation (engineers only)
		-- NOTE: distance is calculated above - it's always distance from the base (RTBLocation) - not from the transport location - 
        -- NOTE: When the platoon is within 60 of the base we just bypass this code
        if platPos and transportLocation and distance > 60 then
        
            mythreat = CalculatePlatoonThreat( self, 'Overall', ALLUNITS)
            
            if mythreat < 10 then
				mythreat = 15
            end
			
			-- set marker radius for path finding
			markerradius = 160
			
			if MovementLayer == 'Air' or MovementLayer == 'Water' then
			
				markerradius = 250

			elseif MovementLayer == 'Amphibious' then
            
                markerradius = 200
                
            end

            -- we use normal threat first
            path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, transportLocation, mythreat, markerradius )
			
			-- then we'll try elevated threat
			if not path then
            
                path = false
                
                -- we use an elevated threat value to help insure that we'll get a path
				path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, transportLocation, mythreat * 4, markerradius )
			end
            
			-- engineer teleportation
			if engineer and engineer:HasEnhancement('Teleporter') then

                if VDist3( platPos, transportLocation ) > 50 then
                
                    IssueTeleport( {engineer}, transportLocation )

                    WaitTicks(3)

                    while not engineer.Dead and engineer.teleporting do
                        WaitTicks(3)
                    end

                    if engineer.teleported then
                
                        path = {transportLocation}
                        distance = 1
                    
                    end
                end
			end

			-- execute the path movement
			if path then

                if RTBDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." executes path movement "..repr(path) )
                end

				if PlatoonExists(aiBrain, self) then

					self.MoveThread = self:ForkThread( self.MovePlatoon, path, UseFormation, false, slackdistance)

				end
			end

			-- if there is no path try transport call
			if (not path) and PlatoonExists(aiBrain, self) then
            
				usedTransports = false

                if RTBDialog then				
                    LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." gets NO path "..repr(path))
                end

				-- try to use transports --
				if (MovementLayer == 'Land' or MovementLayer == 'Amphibious') and not experimental then
				
					usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, transportLocation, 2, false )
                
                end
				
                -- if no transport reply resubmit LAND platoons, others will set a direct path
                if not usedTransports and PlatoonExists(aiBrain,self) then

                    WaitTicks(31)

                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)

                end

            end

		else

			-- closer than 60 - move directly --
			if platPos and transportLocation then

				self.MoveThread = self:ForkThread( self.MovePlatoon, {transportLocation}, UseFormation, false, 30 )

			end

		end

		-- At this point the platoon should be on its way back to base (or may be there)        

        local PlanName = self.PlanName

        rtbdistance = 60
       
        if engineer then
            rtbdistance = 35
        end

		count = false       -- signals completion of the RTB process
        cyclecount = 0      -- counts the iterations of the process
		StuckCount = 0      -- the number of consecutive iterations without movement
		
		-- Monitor the platoons distance to the base watching for death, stuck or idle, and checking for transports
        while (not count) and PlatoonExists(aiBrain, self) and distance > rtbdistance do

            if RTBDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).."  cycle "..cyclecount.."  distance "..string.format("%.1f",distance).."  RTBLocation is "..repr(RTBLocation ) )
            end

            merged = false
            
            -- if not an engineer try merge every 4th iteration
            if (not engineer) and LOUDMOD(cyclecount,4) == 0 then

                -- while in RTB -- look for platoons to merge into
                merged = MergeIntoNearbyPlatoons( self, aiBrain, PlanName, 60, false, 30 )

            end

            platPos = GetPlatoonPosition(self) or false
            
            if not platPos then

                return self:PlatoonDisband(aiBrain)
            end
            
            distance = VDist3( platPos, RTBLocation )            

            -- check for stuck/idle units and warp or kill them            
            if platPos and cyclecount > 10 then -- about 50 seconds 
            
                units = GetPlatoonUnits(self)

                for _,v in units do
				
                    if not v.Dead then
					
						unitpos = GetPosition(v) or false
                        
                        if not unitpos then
                            continue
                        end
                        
                        local unitdistance = VDist3( unitpos, platPos )
						
						-- if the unit hasn't gotten within range of the platoon
						if unitdistance > 80 then
					
							if not LOUDENTITY(EXPERIMENTALS,v) then
						
								if not v.WasWarped then
								
									--WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit "..v.EntityID.." at "..distance.." warped to platPos "..repr(platPos) )

                                    IssueStop( {v} )

									Warp( v, RandomLocation( platPos[1],platPos[3], 12 ) )

									IssueMove( {v}, RTBLocation )

									v.WasWarped = true

								else
								
									--WARN("*AI DEBUG "..aiBrain.Nickname.." RTB "..self.BuilderName.." Unit at "..repr(unitpos).." from platoon at "..repr(platPos).." Killed in RTB")
									
									v:Kill()
								end
							end
						end
					end
				end
            end
			
			-- call for transport every 3rd iteration
			if platPos and transportLocation and LOUDMOD(cyclecount,3) == 0 then

				usedTransports = false

				-- call for transports for those platoons that need it -- standard or if stuck
				if (not experimental) and (MovementLayer == 'Land' or MovementLayer == 'Amphibious')  then
				
					if ( distance >  (300 * LOUDMAX( 1, (1/aiBrain.AirRatio) )) or StuckCount > 5 ) and PlatoonExists(aiBrain, self) then

						usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, transportLocation, 1, false, path )

						-- if we used tranports we need to update position and distance
						if usedTransports then
							
							platPos = GetPlatoonPosition(self) or false

                            if platPos then
                                distance = VDist3( platPos, RTBLocation )
                            end

                            usedTransports = false
						end

					end

				end
                
			end
			
			-- while moving - check for proximity to base (not transportlocation) --
            -- and monitor for stuck platoon status
			if platPos and RTBLocation then
			
				-- proximity to base --
				if distance <= rtbdistance then
				
					count = true -- we are near the base - trigger the end of the loop
                    break
				end
				
				-- proximity to transportlocation --
                if transportLocation and VDist3Sq( platPos, transportLocation ) < (35*35) then
				
                    count = true
                    break
                end
				
				-- if haven't moved much - check for stuck 
				if (not count) and ( cyclecount > 0 and VDist3Sq( lastpos, platPos ) < 0.15 ) then

					StuckCount = StuckCount + 1

                    if RTBDialog then                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..self.BuilderName.." "..repr(self.BuilderInstance).." appears to be stuck - count is "..StuckCount.." moved "..VDist3Sq( lastpos, platPos) )
                    end
				else
					lastpos[1] = platPos[1]
                    lastpos[2] = platPos[2]
                    lastpos[3] = platPos[3]
                    
                    if StuckCount > 0 and RTBDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..self.BuilderName.." "..repr(self.BuilderInstance).." appears to have moved "..VDist3Sq( lastpos, platPos) )
                    end

					StuckCount = 0
				end

			end

			-- if platoon stuck/idle or base is now inactive -- resubmit the platoon
			if platPos and (StuckCount > 10 or (not bestBase )) then
				
				if self.MoveThread then
					self:KillMoveThread()
				end
				
				platooncount = 0
                
                units = GetPlatoonUnits(self)				

				-- count units and clear out dead
				for k,v in units do
					if not v.Dead then
						platooncount = platooncount + 1
					end
				end
                
				-- dead platoon
                if platooncount == 0 then
                	return
                end                
                
				-- if there is only one unit -- just move it
                -- if the distance is more than 150 ogrids - create a new platoon and resubmit to RTB
                -- otherwise send units individually to the RTBLocation
                if platooncount == 1 and bestBase then
					
                    IssueMove( units, RTBLocation)
                    StuckCount = 0
                    count = false

				else

                	self:Stop()
					
                    if distance > 150 then        -- create a new platoon --

                        returnpool = aiBrain:MakePlatoon('ReturnToBase '..tostring(Random(1,999999)), 'none' )
					
                        returnpool.PlanName = 'ReturnToBaseAI'
                        returnpool.BuilderName = 'RTBStuck'
                        returnpool.BuilderLocation = LocationType or false
                        returnpool.RTBLocation = self.RTBLocation or false
                        returnpool.MovementLayer = MovementLayer
                    end
					
					for _,u in units do
					
						if not u.Dead then
						
							if distance > 150 then    -- use the new platoon
						
								AssignUnitsToPlatoon( aiBrain, returnpool, {u}, 'Unassigned', 'None' )
								u.PlatoonHandle = {returnpool}
								u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
							else
                                -- go direct --
								IssueMove( {u}, RandomLocation( RTBLocation[1],RTBLocation[3], 9 ) )
							end
						end

					end

					if distance > 150 and (not returnpool.BuilderLocation) then   -- if we used a new platoon
					
						GetMostRestrictiveLayer(returnpool)
						
						if MovementLayer == "Land" then
						
							-- dont use naval bases for land --
							returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), false )

						else
						
							if MovementLayer == "Air" or MovementLayer == "Amphibious" then
							
								-- use any kind of base --
								returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), true, false )
							else
							
								-- use only naval bases --
								returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), true, true )
							end
						end
						
						returnpool.RTBLocation = returnpool.BuilderLocation	-- this should insure the RTB to a particular base

					end
					
                    count = true -- signal the end of the primary loop

                    if distance > 150 then

                        -- send the new platoon off to RTB
                        returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)

                        WaitTicks(2)
                        
                    end
                    
					break
				end

			end
            
            WaitTicks(11 + LOUDFLOOR(distance/30) )

            if self.MoveThread then
                WaitTicks(40)
            end
            
            cyclecount = cyclecount + 1
        end
        
		if PlatoonExists(aiBrain, self) then

            if RTBDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." RTB AI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).."  cycle "..cyclecount.."  appears to have arrived" )		
            end

			if self.MoveThread then
				self:KillMoveThread()
			end
            
            self:Stop()
			
			-- all units are spread out to the rally points except engineers (we want them back to work ASAP)
			if not engineer then
				DisperseUnitsToRallyPoints( aiBrain, GetPlatoonUnits(self), RTBLocation, bestBase.RallyPoints or false, GetPlatoonPosition(self), 4 )
			else
				-- without this, engineers will continue right to the heart of the base
				self:Stop()
			end
        
			self:PlatoonDisband(aiBrain)
		end

    end,

	-- not reviewed by me
    SatelliteAI = function( self, aiBrain)
		
		local data = self.PlatoonData
		local atkPri = {}
		local atkPriTable = {}
		
        if data.PrioritizedCategories then
		
            for _,v in data.PrioritizedCategories do
                LOUDINSERT( atkPri, v )
                LOUDINSERT( atkPriTable, LOUDPARSE( v ) )
            end
			
        end
		
        LOUDINSERT( atkPriTable, ALLUNITS - categories.WALL )
        self:SetPrioritizedTargetList( 'Attack', atkPriTable )
		
		local maxRadius = data.SearchRadius or 50
		local oldTarget = false
		local target = false
        
        while PlatoonExists(aiBrain,self) do
			
			if self:IsOpponentAIRunning() then
			
                target = AIFindUndefendedBrainTargetInRangeSorian( aiBrain, self, 'Attack', maxRadius, atkPri )

                if target and target != oldTarget and not target.Dead then
				
					--LOG("*AI DEBUG Satellite AI finds target")
					self:Stop()
					self:AttackTarget(target)
					oldTarget = target
					
				end
            end
			
            WaitTicks(300)
        end
    end,

	TacticalAI = function( self, aiBrain )
	
		LOG("*AI DEBUG Launched TacticalAI")
		
	end,
	
	ArtilleryAI = function( self, aiBrain )
    
        local GetPlatoonPosition    = GetPlatoonPosition
        local GetPlatoonUnits       = GetPlatoonUnits
        local PlatoonExists         = PlatoonExists
        local WaitTicks             = WaitTicks

        -- focusing on hardpoints
        local SurfacePriorities = { 
            'STRUCTURE ARTILLERY -TECH2',
            'STRUCTURE INTELLIGENCE -TECH1',
            'ANTIMISSILE -TECH2',
            'SHIELD',
            'DEFENSE STRUCTURE ANTIAIR TECH3',
            'DEFENSE STRUCTURE DIRECTFIRE TECH3',
            'FACTORY STRUCTURE -TECH1',
            'STRUCTURE ANTINAVY',
            'EXPERIMENTAL STRUCTURE',
            'ENERGYPRODUCTION STRUCTURE TECH3',
            'MOBILE LAND TECH3',	
            'COMMAND',
            'SUBCOMMANDER',
        }

        -- economic attack
        local SurfacePriorities2 = { 
            'MASSEXTRACTION -TECH2',
            'ENERGYPRODUCTION STRUCTURE -TECH1',
            'FACTORY STRUCTURE',
            'GATE',
        }

        -- antiair attack
        local SurfacePriorities3 = { 
            'DEFENSE STRUCTURE ANTIAIR TECH3',
            'DEFENSE STRUCTURE ANTIAIR -TECH3',
        }
    
        local DistressPriorities = { 
            'SHIELD',
            'ANTIMISSILE -TECH2',
            'ARTILLERY',
            'MOBILE LAND EXPERIMENTAL',
            'COMMAND',
            'SUBCOMMANDER',
            'MOBILE LAND TECH3',	
        }

        -- we turn the Priorities into a table (rather than a string) because the
        -- AIFindTargetInRangeInCategory function requires a table to function correctly
        local DistressCategories = {}
        local count = 0
        
        for _,v in DistressPriorities do
            count = count + 1
            DistressCategories[count] = LOUDPARSE(v)
        end

        local DistressResponseDialog = ScenarioInfo.DistressResponseDialog 

        local threatThreshold = 125     -- this determines which distress calls we'll look at
        local distressRange = 1000      -- controls how far afield we'll look
        local distresstype = 'Land'     -- respond only to 'Land', at this time - would like to add 'Naval' as well at some point
        
        local distressLocation, distressplatoon, previousdistress
        
        local platoonPos = GetPlatoonPosition(self)
        
        local target, targetdistance, targetposition
        local firecount = 0
        

        local function AssignArtilleryPriorities( priorities )
	
            for _,v in GetPlatoonUnits(self) do
            
                if v != nil then
                    v:SetTargetPriorities( priorities )
                end
                
            end
            
        end
        
        local function ResetArtilleryWeapon()

            for _,u in GetPlatoonUnits(self) do
			
                for i=1, u:GetWeaponCount() do
                    u:GetWeapon(i):ResetTarget()
                end

            end
        
        end
	
		-- this function returns the location of any distress call within range
		local function PlatoonMonitorDistressLocations()

			local selfindex = aiBrain.ArmyIndex
		
			local VDist3 = VDist3
			local VDist2 = VDist2
		
			local index, brain, baseName, base

            local alerts
			local alertposition = false
			local alertrange = 9999999
			local alertplatoon
            local rangetoalert
		
			local Brains = ArmyBrains
		
			for index,brain in Brains do
		
				if index == selfindex or IsAlly( selfindex, brain.ArmyIndex ) and brain.BuilderManagers != nil then
			
					-- First check for CDR Distress -- respond at distress range
					-- note that we don't care what kind of distresstype it is -- a commander needs help
					-- we wont look at other distress calls
					if brain.CDRDistress then
					
						if GetUnitsAroundPoint( brain, COMMANDER, brain.CDRDistress, 100, 'Ally')[1] then
					
							if VDist3( platoonPos, brain.CDRDistress ) < distressRange then

                                if DistressResponseDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI DR "..self.BuilderName.." "..repr(self.MovementLayer).." selects ACU ALERT "..repr(brain.CDRDistress))
                                end

								return brain.CDRDistress, distresstype, 'Commander'
							end
                            
						else
							LOG("*AI DEBUG "..brain.Nickname.." CDR Dead - CDR Distress deactivated")
						
							brain.CDRDistress = nil
						end
                        
					end
				
					-- Secondly - look for BASE and self alerts
					-- respond to the closest ALERT (Base alerts at double range)
					-- that exceeds our threat threshold
					if brain.BaseAlertSounded then
				
						-- loop thru bases for this brain
						for baseName,base in brain.BuilderManagers do

							-- must have an EM and be active
							if base.EngineerManager.Active then

								-- is EM sounding an alert for my kind of distress response ? --
								-- remember - each base will only track one alert for each type --
								-- therefore - we either have an alert or we don't for any given base -- 
								if base.EngineerManager.BaseMonitor.AlertsTable[distresstype] then
							
									alerts = base.EngineerManager.BaseMonitor.AlertsTable[distresstype]

									-- is threat high enough for me to notice ?
									if alerts.Threat >= threatThreshold then
							
										rangetoalert = VDist2( platoonPos[1],platoonPos[3], alerts.Position[1], alerts.Position[3])
								
										if rangetoalert <= distressRange then
                                
											-- Always capture the CLOSEST ALERT
											if rangetoalert < alertrange then
											
												alertposition = LOUDCOPY(alerts.Position)
												alertplatoon = 'BaseAlert'
												alertrange = rangetoalert
                                                
                                                if DistressResponseDialog then
                                                    LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI DR "..self.BuilderName.." "..repr(self.MovementLayer).." selects BASE ALERT "..repr(alertposition).." threat is "..alerts.Threat)
                                                end
											end
										end
									end
								end
							end
                            
						end		-- next base in this brain
                        
					end
				
					-- if self alerts see if one of those is closer
					if brain.PlatoonDistress.AlertSounded then

						alerts = brain.PlatoonDistress.Platoons
                    
						if alerts[1] then

							for _,v in alerts do

								if v.DistressType == distresstype then

									-- is calling self still alive and it's not ourselves and threat is high enough to be of interest
									if PlatoonExists( brain, v.Platoon) and (not LOUDEQUAL(v.Platoon, self)) then

										rangetoalert = VDist2(platoonPos[1],platoonPos[3],v.Position[1],v.Position[3])
									
										-- is it within my distress response range 
										if rangetoalert > 60 and rangetoalert < distressRange then

                                            local threat = GetThreatAtPosition( aiBrain, v.Position, 0, true, 'AntiSurface' )

                                            if threat > threatThreshold then

                                                if rangetoalert < alertrange then
										
                                                    alertposition = LOUDCOPY(v.Position)
                                                    alertplatoon = v.Platoon
                                                    alertrange = rangetoalert
                                                
                                                    if DistressResponseDialog then
                                                        LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI DR "..self.BuilderName.." with threat threshold "..threatThreshold.." threat - selects Platoon ALERT "..repr(alertposition).." reported enemy threat is "..threat.." - time "..repr(GetGameTimeSeconds()) )
                                                    end
                                                end
											end
                                        end
									end
								end
							end
						end
					end
				end
			end		-- next brain --
	
			if alertposition then
				return alertposition, distresstype, alertplatoon
			else
				return false, false, false
			end
            
		end	

        local AIFindTargetInRangeInCategoryWithThreatFromPosition = AIFindTargetInRangeInCategoryWithThreatFromPosition

        AssignArtilleryPriorities( SurfacePriorities )
        
        -- So, for now, this process is relatively simple -- Under normal conditions the Artillery will pick it's own targets
        -- However, when a distress call is acknowledged, the artillery will
        -- get a new set of priority targets, and will look for those targets with a radius of the distress call
        -- as long as the distress call lasts, it will pick targets, from that list, in that area
        -- if none exist, or the distress call ends, the artillery will revert to its normal priorities and go
        -- back to picking it's own targets
        while PlatoonExists( aiBrain, self) do
        
            WaitTicks(36)   -- wait 3.5 seconds

            distressLocation, distressType, distressplatoon = PlatoonMonitorDistressLocations()

            if distressLocation then
            
                firecount = 0
                target = false
			
				if DistressResponseDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI DR "..self.BuilderName.." at "..repr(platoonPos).." responds to "..distressType.." DISTRESS at "..repr(distressLocation).." distance "..VDist3(platoonPos,distressLocation) )
				end

                -- Assign targeting priority
                AssignArtilleryPriorities( DistressCategories )
                
                ResetArtilleryWeapon()

                -- While we have a distress call
                repeat
                
                    target = false
                    
                    -- seek a target - but we dont provide threat information so that 1st available target closest to distressLocation is selected
                    target,targetposition,targetdistance = AIFindTargetInRangeInCategoryWithThreatFromPosition(aiBrain, distressLocation, self, 'Artillery', 0, 100, DistressCategories )

                    if target then
                    
                        if DistressResponseDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Artillery AI found a target "..repr(target:GetBlueprint().Description).." near "..repr(distressLocation))
                        end
                        
                        firecount = 0
                    
                        IssueAttack ( GetPlatoonUnits(self), target)
                    
                        while (not target.Dead) and firecount <= 3 do
                        
                            WaitTicks(80)   -- 8 seconds
                        
                            firecount = firecount + 1
                        
                        end

                        if DistressResponseDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI finishes fire mission - target is dead "..repr(target.Dead))
                        end

                    end

                    -- check for distress call
                    distressLocation, distressType, distressplatoon = PlatoonMonitorDistressLocations()
                    
                until (not distressLocation) or (not target)
                
                firecount = 0
                
                -- Assign normal priorities
          		AssignArtilleryPriorities( SurfacePriorities )

                ResetArtilleryWeapon()
				
			end

            firecount = firecount + 1
            
            if firecount > 6 then
			
				if DistressResponseDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." ArtilleryAI - standard priorities "..self.BuilderName.." at "..repr(platoonPos) )
				end
            
                AssignArtilleryPriorities( SurfacePriorities )
                
                -- attempt to find better target under normal conditions
                ResetArtilleryWeapon()
                
                firecount = 0
                
            end
        end
		
	end,

	NukeAIHub = function ( self, aiBrain )
	
		for _, unit in self:GetPlatoonUnits() do
		
			if not aiBrain.NukePlatoon or not aiBrain:PlatoonExists( aiBrain.NukePlatoon ) then
			
				aiBrain.NukePlatoon = aiBrain:MakePlatoon( 'NukePlatoon', 'none')
				
				AssignUnitsToPlatoon( aiBrain, aiBrain.NukePlatoon, {unit}, 'Attack', 'none' )
		
				aiBrain.NukePlatoon:ForkThread( Behaviors.NukeAI, aiBrain )
			else
				AssignUnitsToPlatoon( aiBrain, aiBrain.NukePlatoon, {unit}, 'Attack', 'none' )
			end
		end
    end,
	
	CzarAttack = function( self, aiBrain )
	
		self:ForkAIThread( Behaviors.CzarBehaviorSorian, aiBrain )
	
	end,

	-- Loops thru each experimental assigning it to its own platoon and coded behavior
	-- This permits the AI to launch waves of experimentals while still allowing each experimental its
	-- own custom behavior and target selection
    ExperimentalAIHub = function( self, aiBrain )
		
		for _,v in GetPlatoonUnits(self) do
		
			local ID = v.BlueprintID
		
			local newplatoon = aiBrain:MakePlatoon('Experimental', 'none')
			
			AssignUnitsToPlatoon( aiBrain, newplatoon, { v }, 'Attack', 'None')
			
			newplatoon.PlatoonData = self.PlatoonData

			LOG("*AI DEBUG Starting experimental behaviour for " .. ID)
		
			if ID == 'xsa0402' then
				newplatoon:ForkAIThread( Behaviors.AhwassaBehavior )
		
			elseif ID == 'xrl0308' or ID == 'xrl0308b' or ID == 'xrl0308c' then
				newplatoon:ForkAIThread( Behaviors.BasiliskBehavior )

			elseif ID == 'xea0402' then
				newplatoon:ForkAIThread( Behaviors.CitadelBehavior )
			
			elseif ID == 'uaa0310' then
				newplatoon:ForkAIThread( Behaviors.CzarBehaviorSorian, aiBrain )
			
			elseif ID == 'uel0401' then
				newplatoon:ForkAIThread( Behaviors.FatBoyBehavior, aiBrain )

			elseif ID == 'xrl0403' then
				newplatoon:ForkAIThread( Behaviors.MegalithBehavior )

			-- elseif ID == 'url0401' then
				-- newplatoon:ForkAIThread(Behaviors.ScathisBehavior )
				-- #return Behaviors.ScathisBehavior(self)

			elseif ID == 'ura0401' then
				newplatoon:ForkAIThread( Behaviors.TickBehavior )
			
			elseif ID == 'uas0401' or ID =='ues0401' then
				newplatoon:ForkAIThread( self.NavalForceAILOUD )

			else
				newplatoon:ForkAIThread( Behaviors.BehemothBehavior )
			end
			
		end
		
		return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		
    end,

	
	GuardPointStructureCheck = function( self, aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax )

		local StructureCount = 0
	
		if PFaction == 'Self' then
		
			StructureCount = GetNumberOfOwnUnitsAroundPoint( aiBrain, StrCat, marker, StrRadius )
            
		else
		
			StructureCount = LOUDGETN( GetUnitsAroundPoint( aiBrain, StrCat, marker, StrRadius, PFaction ) )
            
		end

		if StructureCount < StrMin or StructureCount > StrMax then
		
			return true
            
		end
	
		return false
	end,
	
	GuardPointUnitCheck = function( self, aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax )

        local PlatoonHandle
		local Structures
		local StructureCount = 0
	
		if PFaction == 'Self' then
		
			Structures = GetOwnUnitsAroundPoint( aiBrain, UntCat, marker, UntRadius )
		else
		
			Structures = GetUnitsAroundPoint( aiBrain, UntCat, marker, UntRadius, PFaction )
		end

		for _,v in Structures do
		
            PlatoonHandle = v.PlatoonHandle or false
            
			if not v.Dead and ((not PlatoonHandle) or (PlatoonHandle and PlatoonHandle != self)) then
			
				StructureCount = StructureCount + 1
			end
		end
	
		if StructureCount < UntMin or StructureCount > UntMax then

			return true
		end

		return false
	end,
	
	CheckForStuckPlatoon = function( platoon, platoonpos, oldplatpos)
	
		if platoonpos and oldplatpos then

			if LOUDABS(oldplatpos[1] - platoonpos[1]) < 1 and LOUDABS(oldplatpos[3] - platoonpos[3]) < 1 then
				return true
			end
		end
		
		return false
	end,
	
	ProcessStuckPlatoon = function( platoon, desiredlocation )

        local EntityCategoryContains = EntityCategoryContains
        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists
        
        local VDist2 = VDist2

		local GetPosition = GetPosition
        
		local platoonunits = GetPlatoonUnits(platoon)
		local platpos = GetPlatoonPosition(platoon)
        
		local killedunit = false
		
		-- sort units so that units furthest from desiredlocation are first - those are usually the hung units
		LOUDSORT(platoonunits, function(a,b) local GetPosition = GetPosition local VDist3Sq = VDist3Sq return VDist3Sq( GetPosition(a), desiredlocation) > VDist3Sq( GetPosition(b), desiredlocation) end )
		
		local unitskilled = 0
        local unitpos, distance
		
		for _,v in platoonunits do
		
			if not v.Dead and not EntityCategoryContains(EXPERIMENTALS, v) then
			
				unitpos = GetPosition(v)
				distance = VDist2( platpos[1],platpos[3], unitpos[1],unitpos[3])
				
				-- if the unit is not within 80 of the platpos - warp it
				if distance > 80 then
				
					LOG("*AI DEBUG Warping stuck "..v.BlueprintID.." at "..repr( GetPosition(v)).." Distance to "..repr(platpos).." is "..distance)
                    
                    IssueStop( {v} )
					
                    Warp( v, RandomLocation( platpos[1],platpos[3], 12 ) )
                    
                    IssueMove( {v}, desiredlocation )
					
					unitskilled = unitskilled + 1
                    
				else
				
					break
				end
			end
		end
		
		if unitskilled > 0 then
		
			return false  -- this should kill the platoons present orders and force it to locate a new goal
		else
		
			return true
		end
	end,
	
    -- GuardPoint for land units
    GuardPoint = function( self, aiBrain )
    
        local GuardpointDialog = ScenarioInfo.GuardPointDialog

        local CalculatePlatoonThreat    = CalculatePlatoonThreat
		local GetDirectionInDegrees     = GetDirection
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetPlatoonUnits           = GetPlatoonUnits
        local GetSquadUnits             = GetSquadUnits
        local PlatoonExists             = PlatoonExists

        local VDist3        = VDist3
        local WaitTicks     = WaitTicks
        
        local LOUDCEIL      = LOUDCEIL
        local LOUDEQUAL     = LOUDEQUAL
        local LOUDINSERT    = LOUDINSERT
        local LOUDMAX       = LOUDMAX
        local LOUDMIN       = LOUDMIN
        local LOUDREMOVE    = LOUDREMOVE
    
        if not PlatoonExists(aiBrain, self) then
            return
        end
        
        if GuardpointDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." begins")
        end

        -- other platoon functions 
        local CheckForStuckPlatoon              = self.CheckForStuckPlatoon
        local GuardPointStructureCheck          = self.GuardPointStructureCheck
        local GuardPointUnitCheck               = self.GuardPointUnitCheck
        local MergeWithNearbyPlatoons           = self.MergeWithNearbyPlatoons
        local ProcessStuckPlatoon               = self.ProcessStuckPlatoon
        local PlatoonFindTarget                 = self.PlatoonFindTarget
        local PlatoonGenerateSafePathToLOUD     = self.PlatoonGenerateSafePathToLOUD
   
		for _,v in GetPlatoonUnits(self) do
		
			if not v.Dead then
			
				if v:TestToggleCaps('RULEUTC_StealthToggle') then
					v:SetScriptBit('RULEUTC_StealthToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_CloakToggle') then
					v:SetScriptBit('RULEUTC_CloakToggle', false)
				end
			end
		end

        local PlatoonData = self.PlatoonData

        -- Platoon Data
		local PType         = PlatoonData.PointType or 'Unit'				-- must be either Unit or Marker
		local PCat          = PlatoonData.PointCategory or 'MASSEXTRACTION'	-- unit/Structure or markertype to find
		local PSourceSelf   = PlatoonData.PointSourceSelf or true	        -- true will use Main base to source distances, false will use Enemy Main Base location

		local PSource
		local startx, startz
		
		if PSourceSelf then
			
			if aiBrain.BuilderManagers[self.BuilderLocation] then
			
				PSource = aiBrain.BuilderManagers[self.BuilderLocation].Position
			else
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
		else
			startx, startz = aiBrain:GetCurrentEnemy():GetArmyStartPos()
			PSource = {startx, 0, startz}
		end
		
		local PFaction      = PlatoonData.PointFaction or 'Ally'	 	-- must be Ally, Enemy or Self - determines which Structures and Units to check
		local PRadius       = PlatoonData.PointRadius or 999999			-- controls the finding of points based upon distance from PointSource
		local PSort         = PlatoonData.PointSort or 'Closest'		-- options are Closest or Furthest
		local PMin          = PlatoonData.PointMin or 1					-- allows you to filter found points by range from PointSource
		local PMax          = PlatoonData.PointMax or 999999			-- as above
		
		local StrCat        = PlatoonData.StrCategory or nil			-- allows you to filter out points based upon presence of units/structures at point
		local StrRadius     = PlatoonData.StrRadius or 20
		local StrTrigger    = PlatoonData.StrTrigger or nil			    -- end guardtimer if parameters exceeded when true
		local StrMin        = PlatoonData.StrMin or 0
		local StrMax        = PlatoonData.StrMax or 99
        
        local ThreatMin         = PlatoonData.ThreatMin or -999         -- control minimum threat so we can go to points WITH threat if provided
        local ThreatMaxRatio    = PlatoonData.ThreatMaxRatio or 0.8     -- control maximum threat based on platoon value
        local ThreatRings       = PlatoonData.ThreatRings or nil        -- allow use of 'rings' value
        
        local UseMassPointList = PlatoonData.UseMassPointList or nil    -- use Starting Mass point list instead of FindPoint if present
		
		local UntCat        = PlatoonData.UntCategory or nil			-- a secondary filter on the presence of units/structures at point
		local UntRadius     = PlatoonData.UntRadius or 20
		local UntTrigger    = PlatoonData.UntTrigger or nil 			-- end guardtimer if parameters exceeded when true
		local UntMin        = PlatoonData.UntMin or 0
		local UntMax        = PlatoonData.UntMax or 99
		
		if PType == 'Unit' and type(PCat) == 'string' then
			PCat = LOUDPARSE(PCat)
		end
		
		if type(StrCat) == 'string' then
			StrCat = LOUDPARSE(StrCat)
		end
		
		if type(UntCat) == 'string' then
			UntCat = LOUDPARSE(UntCat)
		end

        local bAggroMove        = PlatoonData.AggressiveMove or false
		local allowinwater      = PlatoonData.AllowInWater or 'false'	-- platoon will consider points on/under water
		local AssistRange       = PlatoonData.AssistRange or 0			-- range at which the platoon will set an assist marker
		local AvoidBases        = PlatoonData.AvoidBases or 'false'		-- Platoon will avoid points within PMin of allied base positions
		local guardRadius       = PlatoonData.GuardRadius or 75			-- range at which platoon will engage enemy targets around point
        local guardTimer        = PlatoonData.GuardTimer or 600	 		-- how long platoon will remain at point before moving on
		local MergeLimit        = PlatoonData.MergeLimit or false		-- unit count at which to prevent merging
        local MergePlanMatch    = PlatoonData.MergePlanMatch or false   -- if merging, the behavior AND the plan name must match.
		local MissionTimer      = PlatoonData.MissionTime or 1200		-- how long platoon will operate before RTB
		local PatrolRadius      = PlatoonData.PatrolRadius or 60
        local PlatoonFormation  = PlatoonData.UseFormation or 'None'
		local SetPatrol         = PlatoonData.SetPatrol or false

        local CategoryList = {}
		local dataList = {}
		
        if PlatoonData.PrioritizedCategories then
		
            for k,v in PlatoonData.PrioritizedCategories do
			
                LOUDINSERT( CategoryList, LOUDPARSE( v ) )
				
            end
        else

			LOUDINSERT( CategoryList, ALLUNITS )
		end
		
        self:SetPrioritizedTargetList( 'Attack', CategoryList )
		
        self:SetPlatoonFormationOverride(PlatoonFormation)

        -- time platoon was created
        local CreationTime = self.CreationTime        

        -- are we currently in guard posture ( onsite at the marker )
		local guarding = false
        
        -- the amount of elapsed time we've been on the way to, or at - the desired marker
		local guardtime	= 0

        -- we use lastmarker to identify completed or failed marker positions
        -- whenever you see me set this value (structure/unit/base breaks) - you know that's what I'm doing
		local lastmarker = false

        -- record the layer this platoon works on
        local MovementLayer = self.MovementLayer
        
        -- if we are to guard a specific unit
		local UnitToGuard = false
		
        -- other locals in use
		local choice, counter, delay, distance, marker, NumberOfUnitsInPlatoon, OldNumberOfUnitsInPlatoon, oldplatpos, OriginalThreat, path, pathlength, position, randlist, reason, target
     
		while PlatoonExists(aiBrain, self) do
		
			if MissionTimer != 'Abort' and (LOUDTIME() - CreationTime ) > MissionTimer then
				break
			end
			
			position = GetPlatoonPosition(self) or false

			OriginalThreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )

			-- FIRST TASK -- FIND A POINT WE CAN GET TO --
            dataList = {}
			marker = false
			
			if position then

                if UseMassPointList and aiBrain.StartingMassPointList[1] then

                    -- test for in water --
                    choice = aiBrain.StartingMassPointList[1].Position
                    
                    -- but choice must be 90 away from PSource (usually MAIN)
                    -- quickly, into the game, the StartingMassPointList will be used up and empty
                    if VDist3( choice, PSource ) > 90 then

                        if (choice[2] + 1) >= GetSurfaceHeight( choice[1],choice[3] ) then
                    
                            dataList[1] = aiBrain.StartingMassPointList[1].Position

                        end
                        
                    end

                end
                
                if not dataList[1] then
                
                    -- Get a list of points that meet all of the required conditions 
                    dataList = FindPointMeetsConditions( self, aiBrain, PType, PCat, PSource, PRadius, PSort, PFaction, PMin, PMax, AvoidBases, StrCat, StrRadius, StrMin, StrMax, UntCat, UntRadius, UntMin, UntMax, allowinwater, ThreatMin, OriginalThreat * ThreatMaxRatio, 'AntiSurface')

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." datalist is "..repr(dataList) )
                    end

                end
                
				-- if dataList then select random marker but never re-select the same point if it just failed
				if dataList[1] then

					-- randomly pick a marker (but cannot be the same as recently failed)
					while marker == false do
					
						choice = LOUDCEIL(LOUDGETN(dataList))
						
						if choice < 1 then 
							break
						end
						
						choice = Random( 1, choice )

						-- format the marker --
						marker = {dataList[choice][1], dataList[choice][2], dataList[choice][3]}
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." selects "..repr(choice).." from list "..repr(dataList) )
                        end
						
						-- and remove the marker from the list so it cant be picked again
						LOUDREMOVE( dataList, choice )
						
						-- is it the same as last failed marker
						if lastmarker and LOUDEQUAL( marker, lastmarker ) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." trying to select same point "..repr(marker))
                            end
						
							marker = false
						end
					end

					guardtime = 0
					guarding = false
                end
                
			else
                break
            end
			
			if not marker then
            
                if position then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." could not pick a "..repr(PCat).." marker from position "..repr(position).." using radius "..repr(PRadius).." - RTB")
                    end
                    
                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                else
                    return
                end
			end
           
            path = false
            pathlength = 0
            
            -- FIND A PATH or TRANSPORT to marker
			if marker and PlatoonExists(aiBrain, self) then
        
                if GuardpointDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." Picked "..repr(PCat).." marker at "..repr(marker))
                end

                path, reason, pathlength = PlatoonGenerateSafePathToLOUD(aiBrain, self, MovementLayer, position, marker, OriginalThreat * ThreatMaxRatio, 160)

                self:Stop()

				if path then

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." "..MovementLayer.." path to "..repr(marker).." pathlength is "..pathlength.." reason is "..repr(reason).." Path is "..repr(path) )
                    end

                    self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove)

                else

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." "..MovementLayer.." NO path to "..repr(marker).." calling for transport - reason is "..repr(reason) )
                    end

					-- try 3 transport calls -- if they fail - record this marker so it doesn't get
					-- picked again the next time this platoon picks a new point
					choice = SendPlatoonWithTransportsLOUD( self, aiBrain, marker, 3, false )
				
					if not choice then

                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." no response to transport call" )
                        end
				
						lastmarker = LOUDCOPY(marker)
						marker = false
						
						break

					else

                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." used transports" )
                        end
                        
                    end

				end
            else
                break
            end
			
			-- SECOND TASK -- TRAVEL TO THE MARKER --
			-- checking for exit, stuck and call for transports
			oldplatpos = false
			counter = 0
           
            if marker and GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." moving to "..repr(PCat).." marker "..repr(marker).." distance "..VDist3( position, marker).." proximity trigger is "..UntRadius )
            end

			while PlatoonExists(aiBrain,self) and marker and guardtime < guardTimer do
				
				position = GetPlatoonPosition(self) or false
			
                if not position then
                    marker = false
                    break
                end

                distance = VDist3( position, marker )

                if distance <= LOUDMAX(UntRadius,StrRadius) then

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." at "..repr(LOUDMAX(UntRadius,StrRadius)).." of "..repr(marker).." - end movement")
                    end

                    break
                else
                
                    if not self.MoveThread then

                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." at "..distance.." but I don't see a MoveThread to "..repr(marker) )
                        end
                        
                        self.MoveThread = self:ForkThread( self.MovePlatoon, {marker}, PlatoonFormation, bAggroMove, 25 )
                    
                    end

                end

				if position then
			
					if StrCat and StrTrigger then
				
						if GuardPointStructureCheck( self, aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." STRUCTURE Trigger > "..repr(StrMax).." at distance "..repr(StrRadius).." during travel to "..repr(marker).." - seeking new point")
                            end

                            lastmarker = LOUDCOPY(marker)

							marker = false
							break
						end
					end
				
					if UntCat and UntTrigger then
				
						if GuardPointUnitCheck( self, aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." UNIT Trigger "..repr(UntMax).." at distance "..repr(UntRadius).." during travel to "..repr(marker).." - seeking new point")
                            end

                            lastmarker = LOUDCOPY(marker)
                            
							marker = false
							break
						end
					end
				
					if CheckForStuckPlatoon( self, position, oldplatpos ) then
				
						counter = counter + 1
					
						-- if counter > 15 (about 15 seconds) then process out the stuck units
						if marker and counter > 15 then
					
							if ProcessStuckPlatoon( self, marker ) then
							
								counter = 0
							else
        
                                if GuardpointDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." STUCK during travel "..counter.." - seeking new point")
                                end

                                lastmarker = LOUDCOPY(marker)
                                
								marker = false
								break
							end
						end
                        
					else
                    
						if position then
					
							oldplatpos = LOUDCOPY(position)
							counter = 0
						else
							continue
						end
					end

                    -- insert a structure/unit check of the current waypoint which could make marker false
                    -- or do a pathcheck for this platoon, either to the current waypoint - or the marker (can't decide at this time)
                    if path[1] then
                    
                        if GetThreatBetweenPositions( aiBrain, position, path[1], false, 'AntiSurface' ) > OriginalThreat then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." sees more than my "..OriginalThreat.." between here and current waypoint")
                            end

                            lastmarker = LOUDCOPY(marker)
                            
                            marker = false
                            break
                        end
                    end
                    
                    -- check marker distance/call for transport
					if PlatoonExists( aiBrain, self ) and distance > ( 300 * math.max(1, (1/aiBrain.AirRatio)) ) then
                    
                        if marker then
                        
                            position = GetPlatoonPosition(self) or false
                            
                            if position then

                                choice = SendPlatoonWithTransportsLOUD( self, aiBrain, marker, 1, false, path )

                                --- we used transports - update position and distance
                                if choice then
                                
                                    position    = GetPlatoonPosition(self) or false
                                    distance    = VDist3( position, marker )

                                    if GuardpointDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." used transports for "..repr(PCat).." marker "..repr(marker))
                                        
                                        if path then
                                            --for _,v in path do
                                                --LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." path is "..repr(v).." distance "..VDist3(GetPlatoonPosition(self),v) ) 
                                            --end
                                        end
                                    end

                                else
                                    if GuardpointDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." failed transport call at "..repr(distance).." from marker "..repr(marker))
                                    end
                                end
                            else
                                marker = false
                            end
                        end
					end

                    if marker then

                        delay = LOUDMAX(0, (distance - LOUDMAX(UntRadius,StrRadius)/LOUDMAX(UntRadius,StrRadius)* 31 ))

                        if delay > 0 then

                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." still "..repr(distance).." from "..repr(marker).." delay "..delay.." ticks")
                            end                    

                            WaitTicks(delay)
                        end

                    end
                    
                end

			end
            
			if PlatoonExists(aiBrain,self) and self.MoveThread then
				self:KillMoveThread()
			end
            
            self:Stop()
            
			-- if marker no longer valid continue to find a new point
			if not marker then
				continue
			end
            
			-- THIRD TASK -- Set up around marker and guard it until exit parameters, guardtime or exhausted
			-- we'll either have a target or be guarding the point --
			guarding = false
			guardtime = 0
            
            if marker and GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." starts guard cycle - Radius is "..repr(guardRadius))
            end
            
            local ATTACKS, ARTILLERY, GUARDS, SUPPORTS, SCOUTS, scoutradius

			while marker and guardtime < guardTimer and PlatoonExists(aiBrain, self) do
                
                -- this will prevent things like DistressResponse from running
                self.UsingTransport = true 

                -- prosecute a local target within the radius
                target = PlatoonFindTarget( self, aiBrain, 'Attack', marker, guardRadius, CategoryList )
                
                -- if we had a target then we need to reset the guard
                if target then
                  
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." had a target ")
                    end

                    guarding = false
                end
				
				dataList = GetPlatoonUnits(self)

				NumberOfUnitsInPlatoon = 0

                -- count units in platoon
				for _,v in dataList do
					if not v.Dead then
						NumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon + 1
					end
				end
                
                -- if not stored - store it now --
                if not OldNumberOfUnitsInPlatoon then
                    OldNumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon
                end
                
                if NumberOfUnitsInPlatoon < 1 then
                    return aiBrain:DisbandPlatoon(self)
                end

				if marker and UnitToGuard and not UnitToGuard.Dead then
					marker = UnitToGuard:GetPosition()
				end

				-- if not already guarding - setup a guard around the marker point --
				if (not guarding) and PlatoonExists(aiBrain, self) then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." setting up guard at "..repr(PCat).." marker "..repr(marker))
                    end

					if NumberOfUnitsInPlatoon > 0 then
                
                        choice = GetDirection( GetPlatoonPosition(self), marker )

                        randlist = { AssistRange, AssistRange * -1 }

                        ATTACKS = GetSquadUnits( self,'Attack' )
                        
                        if ATTACKS[1] then

                            IssueClearCommands( ATTACKS )
                        
                            IssueFormMove( ATTACKS, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) }, 'DMSCircleFormation', GetDirectionInDegrees( GetPlatoonPosition(self), marker )) 
                        end

                        ARTILLERY = GetSquadUnits( self, 'Artillery' )
                        
                        if ARTILLERY[1] then
                        
                            IssueClearCommands( ARTILLERY )
                        
                            IssueFormMove( ARTILLERY, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) }, 'LOUDClusterFormation', GetDirectionInDegrees( GetPlatoonPosition(self), marker ))
                        end
                        
                        GUARDS = GetSquadUnits( self, 'Guard' )

                        if GUARDS[1] then
                            
                            IssueClearCommands( GUARDS )
                     
                            if not ARTILLERY[1] and not ATTACKS[1] then

                                IssueFormMove( GUARDS, marker, 'DMSCircleFormation', choice)
                                
                            elseif ARTILLERY[1] then
                                
                                IssueGuard( GUARDS, ARTILLERY[1] )
                                
                            elseif ATTACKS[1] then
                                
                                IssueGuard( GUARDS, ATTACKS[1] )
                            end
                        end
                        
                        SUPPORTS = GetSquadUnits( self, 'Support' )
                        
                        if SUPPORTS[1] then

                            IssueClearCommands( SUPPORTS )

                            if not ATTACKS[1] and not ARTILLERY[1] then
                            
                                IssueFormAggressiveMove( SUPPORTS, marker, 'DMSCircleFormation', choice)
                                
                            elseif ATTACKS[1] then
                            
                                IssueGuard( SUPPORTS, ATTACKS[1] )
                                
                            elseif ARTILLERY[1] then
                            
                                IssueGuard( SUPPORTS, ARTILLERY[1] )
                            end
                        end
                        
						for _,u in dataList do
					
							if LOUDENTITY( categories.REPAIR, u ) then
								IssueGuard({u}, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) })
                            end
                        end
                        
                        SCOUTS = GetSquadUnits( self, 'Scout' )
                        
                        if SCOUTS[1] then

                            scoutradius = ((PlatoonData.GuardRadius or 75)/2) - 4

                            for _,u in SCOUTS do
                            
                                scoutradius = scoutradius + 8
						
                                local loclist = GetBasePerimeterPoints( aiBrain, marker, scoutradius, 'ALL', false, MovementLayer, true )

                                IssueStop( {u} )							

                                for k,v in loclist do

                                    if not u.Dead then 
                                        if k == 1 then

                                            IssueMove( {u}, v )

                                        elseif k != 4 and k !=7 and k != 10 then
                                        
                                            IssuePatrol( {u}, v )
                                        end
                                    end
                                end
                            end
                        end

                    end
					
					guarding = true
                    
					target = false
				end

				-- check exit parameters --
				if StrCat and StrTrigger then
                
					if GuardPointStructureCheck( self, aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." structure trigger during guard")
                        end

                        lastmarker = LOUDCOPY(marker)
						guardtime = guardTimer
					end
				end
				
				if UntCat and UntTrigger then
                
					if GuardPointUnitCheck( self, aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." unit trigger during guard")
                        end

                        lastmarker = LOUDCOPY(marker)
						guardtime = guardTimer
					end
				end		

                choice = false
                distance = 0
                
                -- check for nearby base --
                choice, distance = FindClosestBaseName( aiBrain, marker, false )
                
                if choice and distance < PMin then
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." finds base "..repr(choice).." at "..distance)
                    end

                    lastmarker = LOUDCOPY(marker)
                    guardtime = guardTimer
                end
                
                -- allow DistressResponse to run
                self.UsingTransport = false 

                -- check for merge
				if NumberOfUnitsInPlatoon < MergeLimit then
                
                    -- MERGE with other GuardPoint Platoons	-- during regular guardtime	-- check randomly about 33%
                    if Random(1,3) == 1 and MergeLimit and (guardtime <= guardTimer) and PlatoonExists(aiBrain, self) then

                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." checking to merge "..NumberOfUnitsInPlatoon )
                        end
                       
						if MergeWithNearbyPlatoons( self, aiBrain, 'GuardPoint', 90, MergePlanMatch or false, MergeLimit) then

							dataList = GetPlatoonUnits(self)
						
							NumberOfUnitsInPlatoon = 0
						
							for _,v in dataList do
							
								if not v.Dead then
									NumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon + 1
								end
							end
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." merge with occurred - old "..OldNumberOfUnitsInPlatoon.." new is "..NumberOfUnitsInPlatoon)
                            end

                            OldNumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon
							
							target = false
							guarding = false
                            
                            -- reset guardtime
                            guardtime = 0
                            
                            -- expand the guardRadius by 15%
                            guardRadius = guardRadius * 1.15
                        end
                    end
				end

                -- check for Abort Mission on marker --
				if MissionTimer == 'Abort' then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." ABORT (Disband) in the field")
                    end

					-- assign them to the structure pool so they dont interfere with normal unit pools
					AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, GetPlatoonUnits(self), 'Guard', 'none' )
					
					return aiBrain:DisbandPlatoon(self)
				end
                
                -- check elapsed guardtime
                if guardtime < guardTimer then

                    WaitTicks(31)
                    guardtime = guardtime + 3
                    
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." cycles - guardtime is "..guardtime )
                    end
                    
                end

			end
        
            if GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Land "..self.BuilderName.." "..self.BuilderInstance.." guard complete - seeking new point - resetting PSource to my current location "..repr(position) )
            end
            
            PSource = table.copy(position)
 
		end

        if PlatoonExists(aiBrain, self) then
        
            -- when about to RTB try to merge into nearby platoons
            self.MergeIntoNearbyPlatoons( self, aiBrain, 'GuardPoint', 100, false )

            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
        
    end,  

	-- GuardPoint for air units
    GuardPointAir = function( self, aiBrain )
    
        local GuardpointDialog = ScenarioInfo.GuardPointDialog

		local AggressiveMoveToLocation = PlatoonMethods.AggressiveMoveToLocation
        local CalculatePlatoonThreat = CalculatePlatoonThreat
        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local GetSquadUnits = GetSquadUnits
        local GetUnitsAroundPoint = GetUnitsAroundPoint
        local PlatoonExists = PlatoonExists

        local VDist3 = VDist3
        local WaitTicks = WaitTicks
        
        local LOUDCEIL = LOUDCEIL
        local LOUDCOPY = LOUDCOPY
        local LOUDEQUAL = LOUDEQUAL
		local LOUDGETN = LOUDGETN        
        local LOUDINSERT = LOUDINSERT
        local LOUDREMOVE = LOUDREMOVE
		
		local units = GetPlatoonUnits(self)
		
		if units[1] then
		
			for _,v in units do
			
				if not v.Dead then
				
					if v:TestToggleCaps('RULEUTC_StealthToggle') then
					
						v:SetScriptBit('RULEUTC_StealthToggle', false)
					end
					
					if v:TestToggleCaps('RULEUTC_CloakToggle') then
					
						v:SetScriptBit('RULEUTC_CloakToggle', false)
					end
				end
			end
		else
		
			return
		end

        -- Platoon Data
		local PType = self.PlatoonData.PointType or 'Unit'				-- must be either Unit or Marker
		local PCat = self.PlatoonData.PointCategory or 'MASSEXTRACTION'	-- unit/Structure or markertype to find
		local PSourceSelf = self.PlatoonData.PointSourceSelf or true	-- true will use Main base to source distances, false will use Enemy Main Base location
		
		local PSource
		local startx, startz
		
		if PSourceSelf then
		
			startx, startz = aiBrain.BuilderManagers[self.BuilderLocation].Position
			PSource = {startx[1], 0, startx[3]}
		else
		
			startx, startz = aiBrain:GetCurrentEnemy():GetArmyStartPos()
			PSource = {startx, 0, startz}
		end
		
		local PFaction = self.PlatoonData.PointFaction or 'Ally'
		local PRadius = self.PlatoonData.PointRadius or 999999	
		local PSort = self.PlatoonData.PointSort or 'Closest'	
		local PMin = self.PlatoonData.PointMin or -999999				
		local PMax = self.PlatoonData.PointMax or 999999		
		
		local StrCat = self.PlatoonData.StrCategory or nil		
		local StrRadius = self.PlatoonData.StrRadius or 20
		local StrTrigger = self.PlatoonData.StrTrigger or false	
		local StrMin = self.PlatoonData.StrMin or 0
		local StrMax = self.PlatoonData.StrMax or 99
        
        local ThreatMin = self.PlatoonData.ThreatMin or -999            -- control minimum threat so we can go to points WITH threat if provided
        local ThreatMaxRatio = self.PlatoonData.ThreatMaxRatio or 0.8   -- control maximum threat based on platoon value
        local ThreatRings = self.PlatoonData.ThreatRings or 0           -- allow use of 'rings' value
        local ThreatType = self.PlatoonData.ThreatType or 'AntiAir'
		
		local UntCat = self.PlatoonData.UntCategory or nil		
		local UntRadius = self.PlatoonData.UntRadius or 100             -- we use a larger default UntRadius for air guardpoint
		local UntTrigger = self.PlatoonData.UntTrigger or false	
		local UntMin = self.PlatoonData.UntMin or 0
		local UntMax = self.PlatoonData.UntMax or 99
	
		if PType == 'Unit' and type(PCat) == 'string' then
			PCat = LOUDPARSE(PCat)
		end
		
		if type(StrCat) == 'string' then
			StrCat = LOUDPARSE(StrCat)
		end
		
		if type(UntCat) == 'string' then
			UntCat = LOUDPARSE(UntCat)
		end

        local guardTimer = self.PlatoonData.GuardTimer or 300	
		
		local MissionTimer = self.PlatoonData.MissionTime or 1200
		
		local guardRadius = self.PlatoonData.GuardRadius or 60	
		local MergeLimit = self.PlatoonData.MergeLimit or false	
        
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        local PlatoonFormation = self.PlatoonData.UseFormation or 'None'
		local allowinwater = self.PlatoonData.AllowInWater or 'true'
		local AvoidBases = self.PlatoonData.AvoidBases or 'false'
		
		local SetPatrol = self.PlatoonData.SetPatrol or false
		local PatrolRadius = self.PlatoonData.PatrolRadius or 60
		
		local categoryList = {}
		
        if self.PlatoonData.PrioritizedCategories then
		
            for _,v in self.PlatoonData.PrioritizedCategories do
			
                LOUDINSERT( categoryList, LOUDPARSE( v ) )
            end
        else
		
			LOUDINSERT( categoryList, ALLUNITS )
		end
		
        self:SetPrioritizedTargetList( 'Attack', categoryList )        

        self:SetPlatoonFormationOverride(PlatoonFormation)

        local CreationTime = self.CreationTime

		local OriginalThreat = CalculatePlatoonThreat( self, ThreatType, ALLUNITS )
        
        local oldNumberOfUnitsInPlatoon = LOUDGETN(units)

        local myThreat = OriginalThreat

		local choice, dataList, guarding, guardtime, lastmarker, marker, oldPlatPos, path, position, platLoc, PlatoonToGuard, StuckCount, travelradius, UnitToGuard

		
		while PlatoonExists(aiBrain,self) do
		
			marker = false
			UnitToGuard = false
            PlatoonToGuard = false
			guarding = false
		
			oldPlatPos = LOUDCOPY(GetPlatoonPosition(self) or false)
		
			-- Get a point that meets all of the required conditions
			dataList = FindPointMeetsConditions( self, aiBrain, PType, PCat, PSource, PRadius, PSort, PFaction, PMin, PMax, AvoidBases, StrCat, StrRadius, StrMin, StrMax, UntCat, UntRadius, UntMin, UntMax, allowinwater, -999999, OriginalThreat, 'AntiAir')

			if PlatoonExists( aiBrain, self ) then
			
				-- use the first one -- RTB if none --
				if dataList then

					-- randomly pick a marker (but cannot be the same as recently failed)
					while marker == false do
					
						choice = LOUDCEIL(LOUDGETN(dataList))
						
						if choice < 1 then 
							break
						end
						
						choice = Random( 1, choice )
					
						-- format the marker --
						marker = {dataList[choice][1], dataList[choice][2], dataList[choice][3]}
						
						-- and remove the marker from the list so it cannot be picked again
						LOUDREMOVE( dataList, choice )
						
						-- is it the same as last failed marker
						if lastmarker and LOUDEQUAL( marker, lastmarker ) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Air "..self.BuilderName.." trying to select same point "..repr(marker))
                            end
						
							marker = false
						end
					end

					guardtime = 0
					guarding = false
				else
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Air "..self.BuilderName.." finds no point")
					
                    WaitTicks(10)
                    
					return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				end

			end
		
			-- if guarding a unit find a suitable unit to guard around the selected point --
			-- if can be either an Allied unit or one of your own BUT cannot be in the ArmyPool
			if PType == 'Unit' then

				if PFaction == 'Ally' then
				
					dataList = GetUnitsAroundPoint( aiBrain, PCat, marker, StrRadius, PFaction )
					
				elseif PFaction == 'Self' then
				
					dataList = GetOwnUnitsAroundPoint( aiBrain, PCat, marker, StrRadius )
					
				end
                
                marker = false      -- default to nothing until we find a unit NOT in the ArmyPool --
				
				local armypool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
			
				if dataList[1] then
				
					for _,v in dataList do
					
						if not v.Dead then
						
							if v.PlatoonHandle != armypool then
							
                                PlatoonToGuard = v.PlatoonHandle
								UnitToGuard = v
								marker = LOUDCOPY( v:GetPosition() )
                                
								break
							end
						end
					end
				end	
				
                if not marker then
				
					LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Air "..self.BuilderName.." finds no UNIT to guard")
					
					WaitTicks(10)

                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)

				end
                
			end

			self:Stop()

            path = false

			path = self.PlatoonGenerateSafePathToLOUD(aiBrain, self, 'Air', oldPlatPos, marker, OriginalThreat * ThreatMaxRatio, 256)
			
			if PlatoonExists(aiBrain, self) then
			
				if not path then

					lastmarker = LOUDCOPY(marker)
					marker = false
				else

					if PlatoonExists(aiBrain,self) then
						self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove, 32)
					end
				
					if PlatoonExists(aiBrain,self) and not self.MoveThread then

                        lastmarker = LOUDCOPY(marker)
						marker = false
					end
				end
                
			end			

			StuckCount = 0

            platLoc = GetPlatoonPosition(self) or false
            distance = VDist3( platLoc, marker )
            oldplatpos = LOUDCOPY(platLoc)

			-- TRAVEL TO THE MARKER POINT -- Check exit parameters along the way
			while PlatoonExists(aiBrain,self) and marker and distance > UntRadius and guardtime < guardTimer do

                if platLoc then

                    -- is mission timer expired --
                    if marker and (LOUDTIME() - CreationTime ) > MissionTimer then
                        guardtime = guardTimer
                        marker = false
                        break
                    end
  			
					if marker and StrCat and StrTrigger then
				
						if self:GuardPointStructureCheck( aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
						
							marker = false
							break
						end
					end
				
					if marker and UntCat and UntTrigger then
				
						if self:GuardPointUnitCheck( aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
						
							marker = false
							break
						end
					end

                    if marker and UnitToGuard and (UnitToGuard.Dead or not PlatoonExists(aiBrain,PlatoonToGuard)) then
                    
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." Unit/Platoon ToGuard is dead")
                        
                        PlatoonToGuard = false
                        UnitToGuard = false
                        marker = false
                        break
                    end
				
					if marker and self:CheckForStuckPlatoon( platLoc, oldplatpos ) then
				
						StuckCount = StuckCount + 1
					
						-- if stuck count > 4 (about 32 seconds) then process out the stuck units
						if marker and StuckCount > 3 then
					
							if self:ProcessStuckPlatoon( marker ) then
							
								StuckCount = 0
							else
						
								marker = false
                                guardtime = guardTimer
								break
							end
						end	
					else
					
                        oldplatpos = LOUDCOPY(platLoc)
						StuckCount = 0
					end

                end
              
                if marker and guardtime < guardTimer then

                    WaitTicks(32)
                    
                    platLoc = GetPlatoonPosition(self) or false

                    if platLoc then
                        distance = VDist3( platLoc, marker )
                    else
                        marker = false
                    end
                end
                
			end
		
			-- If Exit parameters have been met -- bypass guard cycle --
			if guardtime >= guardTimer then

				-- the guard cycle will be bypassed
				marker = false
            end
            
            if self.MoveThread then
                self:KillMoveThread()
            end
	
			-- Guard Point and Attack Enemy within guardRadius
			guarding = false
			guardtime = 0
            
			-- used for platoon depleted check
			local numberOfUnitsInPlatoon = 0

			-- the guard cycle starts here --
			while PlatoonExists(aiBrain,self) and marker and guardtime < guardTimer do
			
				if not guarding then
            
                    units = GetPlatoonUnits(self)

					self:Stop()
				
					if UnitToGuard and not UnitToGuard.Dead then

						if not UnitToGuard.Dead and PlatoonExists(aiBrain,PlatoonToGuard) then
						
							marker = LOUDCOPY(UnitToGuard:GetPosition()) or false
						else
						
							marker = false
							guardtime = guardTimer
                            break
						end
						
						if marker then

							if not SetPatrol then
							
								IssueGuard( GetPlatoonUnits(self), marker )
							else
							
								dataList = GetBasePerimeterPoints(aiBrain, marker, PatrolRadius, 'ALL', false,'Air')
							
								for k,v in dataList do
								
									if k == 1 then
								
										self:MoveToLocation(v, false)
									else
									
										IssuePatrol( units, v )
									end
								end
							end
							
							guarding = true
						end
                        
					else
					
						if marker then
					
							if not SetPatrol then

								local randlist = { '-6', '6' }
								
								IssueGuard( units, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) } )
							else
							
								dataList = GetBasePerimeterPoints(aiBrain, marker, PatrolRadius, 'ALL', false, 'Air')
							
								for k,v in dataList do
								
									if k == 1 then
									
										self:MoveToLocation(v, false)
									else
									
										if k != 4 and k !=7 and k != 10 then
										
											IssuePatrol( units, v )
										end
									end
								end
							end
							
							guarding = true
						end
					end
                    
				end
				
				numberOfUnitsInPlatoon = 0
				
				-- count units in platoon and peel off those needing fuel
				for _,v in units do
				
					if not v.Dead then
					
						local bp = __blueprints[v.BlueprintID].Physics

						if bp.FuelUseTime > 0 then
                       
                            -- get the unit out of the platoon and send it off to refuel --
							if v:GetFuelRatio() < .2 then

								v:DoUnitCallbacks('OnRunOutOfFuel')
							else
                            
                                numberOfUnitsInPlatoon = numberOfUnitsInPlatoon + 1                            
                            end
						end	
                    end
                    
				end

				if numberOfUnitsInPlatoon > 0 then
                
                    WaitTicks(1)

                    -- MERGE other GuardPoint Platoons into us during regular guardtime -- if we have space -- 50% of the time
                    if numberOfUnitsInPlatoon < MergeLimit and Random(1,2) == 2 and guarding and guardtime <= guardTimer then
					
                        if self:MergeWithNearbyPlatoons( aiBrain, 'GuardPointAir', 100, true, MergeLimit) then
                        
                            if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
							
                                self:Stop()

                                self:SetPlatoonFormationOverride(PlatoonFormation)
                            end                        
					
                            -- reset platoon values --
                            oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
    
                            OriginalThreat = CalculatePlatoonThreat( self, ThreatType, ALLUNITS )
						
                            -- guard cycle will reposition itself --
                            guarding = false
                        end
                        
                    end

                    -- Check Structure Parameters -- check randomly about 25% to minimize
                    -- 'bouncing' when multiple platoons are trying to get to the same point
                    if Random(1,4) == 1 then
				
                        if StrCat and StrTrigger then
					
                            if self:GuardPointStructureCheck(  aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
						
                                -- abort the guard cycle --
                                guardtime = guardTimer
                            end
                        end
                        
                    end

                    if marker then
              
                        WaitTicks(80)
                        guardtime = guardtime + 8
                    end
				
                    -- check for unit death or position moved --
                    if marker and UnitToGuard then
				
                        if UnitToGuard.Dead then
					
                            -- get a new unit --
                            marker = false
                            break 
                        else
					
                            -- if the guarded unit has moved significantly -- 
                            if VDist3( marker, UnitToGuard:GetPosition()) > 35 then
						
                                -- guard cycle will reposition -- 
                                guarding = false
                            end
                        end
                    end
                else
                
                    marker = false
                end
                
			end
            
			-- if the mission is to be 'aborted' at a certain marker/unit
			-- then simply disband the platoon (left doing whatever forever)
			if marker and MissionTimer == 'Abort' then

				-- assign them to the structure pool so they dont interfere with normal unit pools
				AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, GetPlatoonUnits(self), 'Guard', 'none' )

				return self:PlatoonDisband(aiBrain)
			end
			
			-- the overall mission timer expires -- merge or RTB -- 
			if (LOUDTIME() - CreationTime ) > MissionTimer then
            
                self.MergeIntoNearbyPlatoons( self, aiBrain, self.PlanName, 100, false )
			
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
	
			WaitTicks(10)
		end
        
    end,  

	-- GuardPoint for amphibious platoons
    GuardPointAmphibious = function( self, aiBrain )
    
        local GuardpointDialog = ScenarioInfo.GuardPointDialog

        local CalculatePlatoonThreat = CalculatePlatoonThreat
		local GetDirectionInDegrees = GetDirection
        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local GetSquadUnits = GetSquadUnits
        local PlatoonExists = PlatoonExists
        local type = type
        local VDist3 = VDist3
        local WaitTicks = WaitTicks
        
        local LOUDCEIL = LOUDCEIL
        local LOUDEQUAL = LOUDEQUAL
        local LOUDINSERT = LOUDINSERT
        local LOUDREMOVE = LOUDREMOVE
    
        if not PlatoonExists(aiBrain, self) then
            return
        end
        
        if GuardpointDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." begins")
        end

        -- other platoon functions 
        local CheckForStuckPlatoon = self.CheckForStuckPlatoon
        local GuardPointStructureCheck = self.GuardPointStructureCheck
        local GuardPointUnitCheck = self.GuardPointUnitCheck
        local MergeWithNearbyPlatoons = self.MergeWithNearbyPlatoons
        local ProcessStuckPlatoon = self.ProcessStuckPlatoon

        local PlatoonFindTarget = self.PlatoonFindTarget
        local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD

		for _,v in GetPlatoonUnits(self) do
		
			if not v.Dead then
			
				if v:TestToggleCaps('RULEUTC_StealthToggle') then
					v:SetScriptBit('RULEUTC_StealthToggle', false)
				end
				
				if v:TestToggleCaps('RULEUTC_CloakToggle') then
					v:SetScriptBit('RULEUTC_CloakToggle', false)
				end
			end
		end

        local PlatoonData = self.PlatoonData

        -- Platoon Data
		local PType = PlatoonData.PointType or 'Unit'				-- must be either Unit or Marker
		local PCat = PlatoonData.PointCategory or 'MASSEXTRACTION'	-- unit/Structure or markertype to find
		local PSourceSelf = PlatoonData.PointSourceSelf or true	-- true will use Main base to source distances, false will use Enemy Main Base location

		local PSource
		local startx, startz
		
		if PSourceSelf then
			
			if aiBrain.BuilderManagers[self.BuilderLocation] then
			
				PSource = aiBrain.BuilderManagers[self.BuilderLocation].Position
			else
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
		else
			startx, startz = aiBrain:GetCurrentEnemy():GetArmyStartPos()
			PSource = {startx, 0, startz}
		end
		
		local PFaction = PlatoonData.PointFaction or 'Ally'	 	-- must be Ally, Enemy or Self - determines which Structures and Units to check
		local PRadius = PlatoonData.PointRadius or 999999			-- controls the finding of points based upon distance from PointSource
		local PSort = PlatoonData.PointSort or 'Closest'			-- options are Closest or Furthest
		local PMin = PlatoonData.PointMin or 1						-- allows you to filter found points by range from PointSource
		local PMax = PlatoonData.PointMax or 999999				-- as above
		
		local StrCat = PlatoonData.StrCategory or nil				-- allows you to filter out points based upon presence of units/structures at point
		local StrRadius = PlatoonData.StrRadius or 20
		local StrTrigger = PlatoonData.StrTrigger or false			-- end guardtimer if parameters exceeded when true
		local StrMin = PlatoonData.StrMin or 0
		local StrMax = PlatoonData.StrMax or 99
        
        local ThreatMin = PlatoonData.ThreatMin or -999            -- control minimum threat so we can go to points WITH threat if provided
        local ThreatMaxRatio = PlatoonData.ThreatMaxRatio or 0.8   -- control maximum threat based on platoon value
        local ThreatRings = PlatoonData.ThreatRings or 0           -- allow use of 'rings' value
        
        local UseMassPointList = PlatoonData.UseMassPointList or false     -- use Starting Mass point list instead of FindPoint if present
		
		local UntCat = PlatoonData.UntCategory or nil				-- a secondary filter on the presence of units/structures at point
		local UntRadius = PlatoonData.UntRadius or 20
		local UntTrigger = PlatoonData.UntTrigger or false			-- end guardtimer if parameters exceeded when true
		local UntMin = PlatoonData.UntMin or 0
		local UntMax = PlatoonData.UntMax or 99
		
		if PType == 'Unit' and type(PCat) == 'string' then
			PCat = LOUDPARSE(PCat)
		end
		
		if type(StrCat) == 'string' then
			StrCat = LOUDPARSE(StrCat)
		end
		
		if type(UntCat) == 'string' then
			UntCat = LOUDPARSE(UntCat)
		end

        local bAggroMove = PlatoonData.AggressiveMove or false
		local allowinwater = PlatoonData.AllowInWater or 'true'		-- platoon will consider points on/under water
		local AssistRange = PlatoonData.AssistRange or 0			-- range at which the platoon will set an assist marker
		local AvoidBases = PlatoonData.AvoidBases or 'false'			-- Platoon will avoid points within PMin of allied base positions
		local guardRadius = PlatoonData.GuardRadius or 75			-- range at which platoon will engage enemy targets around point
        local guardTimer = PlatoonData.GuardTimer or 600	 		-- how long platoon will remain at point before moving on        
		local MergeLimit = PlatoonData.MergeLimit or false			-- unit count at which to prevent merging
        local MergePlanMatch = PlatoonData.MergePlanMatch or false -- if merging, the behavior AND the plan name must match.
		local MissionTimer = PlatoonData.MissionTime or 1200		-- how long platoon will operate before RTB        
		local PatrolRadius = PlatoonData.PatrolRadius or 60
        local PlatoonFormation = PlatoonData.UseFormation or 'None'
		local SetPatrol = PlatoonData.SetPatrol or false

		
        local CategoryList = {}
		local dataList = {}
		
        if PlatoonData.PrioritizedCategories then
		
            for k,v in PlatoonData.PrioritizedCategories do
                LOUDINSERT( CategoryList, LOUDPARSE( v ) )
            end
        else
			LOUDINSERT( CategoryList, ALLUNITS )
		end
		
        self:SetPrioritizedTargetList( 'Attack', CategoryList )        
		
        self:SetPlatoonFormationOverride(PlatoonFormation)

        local CreationTime = self.CreationTime        

		local guarding = false
        
		local guardtime	= 0

		local lastmarker = false

        local MovementLayer = self.MovementLayer

		local UnitToGuard = false
		
        -- other locals in use
		local choice, counter, delay, distance, marker, NumberOfUnitsInPlatoon, OldNumberOfUnitsInPlatoon, oldplatpos, OriginalThreat, path, pathlength, position, randlist, reason, target
		
		while PlatoonExists(aiBrain,self) do
		
			if MissionTimer != 'Abort' and (LOUDTIME() - self.CreationTime ) > MissionTimer then
				break
			end
			
			position = GetPlatoonPosition(self) or false

			OriginalThreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )

			-- FIRST TASK -- FIND A POINT WE CAN GET TO --
            dataList = {}
			marker = false
			
			if position then

                if UseMassPointList and aiBrain.StartingMassPointList[1] then

                    if VDist3( choice, PSource ) > 90 then

                        choice = aiBrain.StartingMassPointList[1].Position

                        dataList[1] = aiBrain.StartingMassPointList[1].Position

                    end

                end
                
                if not dataList[1] then
                
                    -- Get a list of points that meet all of the required conditions 
                    dataList = FindPointMeetsConditions( self, aiBrain, PType, PCat, PSource, PRadius, PSort, PFaction, PMin, PMax, AvoidBases, StrCat, StrRadius, StrMin, StrMax, UntCat, UntRadius, UntMin, UntMax, allowinwater, ThreatMin, OriginalThreat * ThreatMaxRatio, 'AntiSurface')

                end
                
				-- if dataList then select random marker but never re-select the same point if it just failed
				if dataList[1] then

					-- randomly pick a marker (but cannot be the same as recently failed)
					while marker == false do
					
						choice = LOUDCEIL(LOUDGETN(dataList))
						
						if choice < 1 then 
							break
						end
						
						choice = Random( 1, choice )

						-- format the marker --
						marker = {dataList[choice][1], dataList[choice][2], dataList[choice][3]}
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." selects "..repr(choice).." from list "..repr(dataList) )
                        end
						
						-- and remove the marker from the list so it cant be picked again
						LOUDREMOVE( dataList, choice )
						
						-- is it the same as last failed marker
						if lastmarker and LOUDEQUAL( marker, lastmarker ) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." trying to select same point "..repr(marker))
                            end
						
							marker = false
						end
					end

					guardtime = 0
					guarding = false
                end
                
			else
                break
            end
			
			if not marker then
            
                if position then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." could not pick a "..repr(PCat).." marker from position "..repr(position).." using radius "..repr(PRadius).." - RTB")
                    end
                    
                    return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                else
                    return
                end
			end
           
            path = false
            pathlength = 0
            
            -- FIND A PATH or TRANSPORT to marker
			if marker and PlatoonExists(aiBrain, self) then
        
                if GuardpointDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." Picked "..repr(PCat).." marker at "..repr(marker))
                end

                path, reason, pathlength = PlatoonGenerateSafePathToLOUD(aiBrain, self, MovementLayer, position, marker, OriginalThreat * ThreatMaxRatio, 250)

                IssueClearCommands(self)

				if path then
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." gets path to "..repr(marker).."  length "..pathlength.."  reason "..repr(reason) )
                    end

                    self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove, 24)
                else
					-- try 3 transport calls -- if they fail - record this marker so it doesn't get
					-- picked again the next time this platoon picks a new point
					choice = SendPlatoonWithTransportsLOUD( self, aiBrain, marker, 3, false )
				
					if not choice then
				
						lastmarker = LOUDCOPY(marker)
						marker = false
						
						break
					end
				end
            else
                break
            end
			
			-- SECOND TASK -- TRAVEL TO THE MARKER --
			-- checking for exit, stuck and call for transports
			oldplatpos = false
			counter = 0
           
            if marker and GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." moving to "..repr(PCat).." marker "..repr(marker).." distance "..VDist3( position, marker).." proximity trigger is "..UntRadius )
            end

			while PlatoonExists(aiBrain,self) and marker and guardtime < guardTimer do
				
				position = GetPlatoonPosition(self) or false
			
                if position then
                    distance = VDist3( position, marker )
                else
                    marker = false
                    break
                end
                
                if distance <= LOUDMAX(UntRadius,StrRadius) then

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." in range "..repr(LOUDMAX(UntRadius,StrRadius)).." of "..repr(PCat).." marker "..repr(marker).." - end movement")
                    end

                    break
                end

				if position then
			
					if StrCat and StrTrigger then
				
						if GuardPointStructureCheck( self, aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." STRUCTURE Trigger > "..repr(StrMax).." at distance "..repr(StrRadius).." during travel to "..repr(marker).." - seeking new point")
                            end

                            lastmarker = LOUDCOPY(marker)

							marker = false
							break
						end
					end
				
					if UntCat and UntTrigger then
				
						if GuardPointUnitCheck( self, aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." UNIT Trigger "..repr(UntMax).." at distance "..repr(UntRadius).." during travel to "..repr(marker).." - seeking new point")
                            end

                            lastmarker = LOUDCOPY(marker)
                            
							marker = false
							break
						end
					end
				
					if CheckForStuckPlatoon( self, position, oldplatpos ) then
				
						counter = counter + 1
					
						-- if counter > 15 (about 15 seconds) then process out the stuck units
						if marker and counter > 15 then
					
							if ProcessStuckPlatoon( self, marker ) then
							
								counter = 0
							else
        
                                if GuardpointDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." STUCK during travel "..counter.." - seeking new point")
                                end

                                lastmarker = LOUDCOPY(marker)
                                
								marker = false
								break
							end
						end
                        
					else
                    
						if position then
					
							oldplatpos = LOUDCOPY(position)
							counter = 0
						else
							continue
						end
					end

                    -- insert a structure/unit check of the current waypoint which could make marker false
                    -- or do a pathcheck for this platoon, either to the current waypoint - or the marker (can't decide at this time)
                    if path[1] then
                    
                        if GetThreatBetweenPositions( aiBrain, position, path[1], false, 'AntiSurface' ) > OriginalThreat then
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." sees more than my "..OriginalThreat.." between here and current waypoint")
                            end

                            lastmarker = LOUDCOPY(marker)
                            
                            marker = false
                            break
                        end
                    end
                    
                    -- check marker distance/call for transport
					if PlatoonExists( aiBrain, self ) and distance > ( 300 * math.max( 1, (1/aiBrain.AirRatio) ) ) then
                    
                        if marker then
                        
                            position = GetPlatoonPosition(self) or false
                            
                            if position then

                                -- call transports if still far (every 30 seconds)
                                choice = SendPlatoonWithTransportsLOUD( self, aiBrain, marker, 1, false, path )

                                if choice then

                                    if GuardpointDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." used transports for "..repr(PCat).." marker "..repr(marker))
                                    end
                                else
                                    if GuardpointDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." failed transport call at "..repr(distance).." from marker "..repr(marker))
                                    end
                                end
                            else
                                marker = false
                            end
                        end
					end

                    if marker then

                        delay = LOUDMAX(0.3, (distance - LOUDMAX(UntRadius,StrRadius))/3 ) * 10

                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." still at "..repr(distance).." from marker "..repr(marker).." delay is "..delay.." ticks")
                        end                    

                        WaitTicks(delay)

                    end
                    
                end

                if GuardpointDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." still at "..repr(distance).." from marker "..repr(marker))
                end
			end
            
			if PlatoonExists(aiBrain,self) and self.MoveThread then
				self:KillMoveThread()
			end
            
			-- if marker no longer valid continue to find a new point
			if not marker then
				continue
			end
            
			-- THIRD TASK -- Set up around marker and guard it until exit parameters, guardtime or exhausted
			-- we'll either have a target or be guarding the point --
			guarding = false
			guardtime = 0
            
            if marker and GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." starts guard cycle - Radius is "..repr(guardRadius))
            end
            
            local ATTACKS, ARTILLERY, GUARDS, SUPPORTS, SCOUTS, scoutradius

			while marker and guardtime < guardTimer and PlatoonExists(aiBrain, self) do
                
                -- this will prevent things like DistressResponse from running
                self.UsingTransport = true 

                -- prosecute a local target within the radius
                target = PlatoonFindTarget( self, aiBrain, 'Attack', marker, guardRadius, CategoryList )
                
                -- if we had a target then we need to reset the guard
                if target then
                    guarding = false
                end
				
				dataList = GetPlatoonUnits(self)

				NumberOfUnitsInPlatoon = 0

                -- count units in platoon
				for _,v in dataList do
					if not v.Dead then
						NumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon + 1
					end
				end
                
                -- if not stored - store it now --
                if not OldNumberOfUnitsInPlatoon then
                    OldNumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon
                end
                
                if NumberOfUnitsInPlatoon < 1 then
                    return aiBrain:DisbandPlatoon(self)
                end

				if marker and UnitToGuard and not UnitToGuard.Dead then
					marker = UnitToGuard:GetPosition()
				end

				-- if not already guarding - setup a guard around the marker point --
				if (not guarding) and PlatoonExists(aiBrain, self) then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." setting up guard at "..repr(PCat).." marker "..repr(marker))
                    end
                    
                    self:Stop()

					if NumberOfUnitsInPlatoon > 0 then
                
                        choice = GetDirection( GetPlatoonPosition(self), marker )

                        randlist = { AssistRange, AssistRange * -1 }

                        ATTACKS = GetSquadUnits( self,'Attack' )
                        
                        if ATTACKS[1] then

                            IssueClearCommands( ATTACKS )
                        
                            IssueFormMove( ATTACKS, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) }, 'DMSCircleFormation', GetDirectionInDegrees( GetPlatoonPosition(self), marker )) 
                        end

                        ARTILLERY = GetSquadUnits( self, 'Artillery' )
                        
                        if ARTILLERY[1] then
                        
                            IssueClearCommands( ARTILLERY )
                        
                            IssueFormMove( ARTILLERY, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) }, 'LOUDClusterFormation', GetDirectionInDegrees( GetPlatoonPosition(self), marker ))
                        end
                        
                        GUARDS = GetSquadUnits( self, 'Guard' )

                        if GUARDS[1] then
                            
                            IssueClearCommands( GUARDS )
                     
                            if not ARTILLERY[1] and not ATTACKS[1] then

                                IssueFormMove( GUARDS, marker, 'DMSCircleFormation', choice)
                                
                            elseif ARTILLERY[1] then
                                
                                IssueGuard( GUARDS, ARTILLERY[1] )
                                
                            elseif ATTACKS[1] then
                                
                                IssueGuard( GUARDS, ATTACKS[1] )
                            end
                        end
                        
                        SUPPORTS = GetSquadUnits( self, 'Support' )
                        
                        if SUPPORTS[1] then

                            IssueClearCommands( SUPPORTS )

                            if not ATTACKS[1] and not ARTILLERY[1] then
                            
                                IssueFormAggressiveMove( SUPPORTS, marker, 'DMSCircleFormation', choice)
                                
                            elseif ATTACKS[1] then
                            
                                IssueGuard( SUPPORTS, ATTACKS[1] )
                                
                            elseif ARTILLERY[1] then
                            
                                IssueGuard( SUPPORTS, ARTILLERY[1] )
                            end
                        end
                        
						for _,u in dataList do
					
							if LOUDENTITY( categories.REPAIR, u ) then
								IssueGuard({u}, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) })
                            end
                        end
                        
                        SCOUTS = GetSquadUnits( self, 'Scout' )
                        
                        if SCOUTS[1] then
                        
                            IssueClearCommands( SCOUTS )

                            scoutradius = ((PlatoonData.GuardRadius or 75)/2) - 4
                            
                            for _,u in SCOUTS do
                            
                                scoutradius = scoutradius + 8
						
                                local loclist = GetBasePerimeterPoints( aiBrain, marker, scoutradius, 'ALL', false, MovementLayer, true )
							
                                for k,v in loclist do
								
                                    if not u.Dead then
                                        
                                        v[2] = GetSurfaceHeight(v[1], v[3])
							
                                        if k == 1 then
                                    
                                            IssueStop( {u} )
								
                                            IssueMove( {u}, v )

                                        elseif k != 4 and k !=7 and k != 10 then
                                        
                                            IssuePatrol( {u}, v )
                                        end
                                    end
                                end
                            end
                        end

                    end
					
					guarding = true
                    
					target = false
				end

				-- check exit parameters --
				if StrCat and StrTrigger then
                
					if GuardPointStructureCheck( self, aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." structure trigger during guard")
                        end

                        lastmarker = LOUDCOPY(marker)
						guardtime = guardTimer
					end
				end
				
				if UntCat and UntTrigger then
                
					if GuardPointUnitCheck( self, aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." unit trigger during guard")
                        end

                        lastmarker = LOUDCOPY(marker)
						guardtime = guardTimer
					end
				end		

                choice = false
                distance = 0
                
                -- check for nearby base --
                choice, distance = FindClosestBaseName( aiBrain, marker, false )
                
                if choice and distance < PMin then
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." finds base "..repr(choice).." at "..distance)
                    end

                    lastmarker = LOUDCOPY(marker)
                    guardtime = guardTimer
                end
                
                -- allow DistressResponse to run
                self.UsingTransport = false 

                -- check for merge
				if NumberOfUnitsInPlatoon < MergeLimit then
                
                    -- MERGE with other GuardPoint Platoons	-- during regular guardtime	-- check randomly about 33%
                    if Random(1,3) == 1 and MergeLimit and (guardtime <= guardTimer) and PlatoonExists(aiBrain, self) then
                       
						if MergeWithNearbyPlatoons( self, aiBrain, 'GuardPointAmphibious', 90, MergePlanMatch or false, MergeLimit) then

							dataList = GetPlatoonUnits(self)
						
							NumberOfUnitsInPlatoon = 0
						
							for _,v in dataList do
							
								if not v.Dead then
									NumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon + 1
								end
							end
        
                            if GuardpointDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." merge with occurred - old "..OldNumberOfUnitsInPlatoon.." new is "..NumberOfUnitsInPlatoon)
                            end

                            OldNumberOfUnitsInPlatoon = NumberOfUnitsInPlatoon
							
							target = false
							guarding = false
                            
                            -- reset guardtime
                            guardtime = 0
                            
                            -- expand the guardRadius by 15%
                            guardRadius = guardRadius * 1.15
                        end
                    end
				end

                -- check for Abort Mission on marker --
				if MissionTimer == 'Abort' then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." ABORT (Disband) in the field")
                    end

					-- assign them to the structure pool so they dont interfere with normal unit pools
					AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, GetPlatoonUnits(self), 'Guard', 'none' )
					
					return aiBrain:DisbandPlatoon(self)
				end
                
                -- check elapsed guardtime
                if guardtime < guardTimer then

                    WaitTicks(31)
                    guardtime = guardtime + 3
                end

			end

            if GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Amphib "..self.BuilderName.." "..self.BuilderInstance.." guard complete - seeking new point")
            end

            self:Stop()

			WaitTicks(21)

		end

        if PlatoonExists(aiBrain, self) then
        
            -- when about to RTB try to merge into nearby platoons
            self.MergeIntoNearbyPlatoons( self, aiBrain, 'GuardPointAmphibious', 100, false )

            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end

    end,  

	-- GuardPoint for naval platoons
    GuardPointNaval = function( self, aiBrain )
    
        local GuardpointDialog = ScenarioInfo.GuardPointNavalDialog

        local CalculatePlatoonThreat = CalculatePlatoonThreat
        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local GetSquadUnits = GetSquadUnits

        local PlatoonExists = PlatoonExists
        
        local LOUDCEIL = LOUDCEIL
        local LOUDEQUAL = LOUDEQUAL
		local LOUDGETN = LOUDGETN        
        local LOUDINSERT = LOUDINSERT
        local LOUDREMOVE = LOUDREMOVE
        
        local type = type
        local VDist3 = VDist3
        
        local WaitTicks = WaitTicks


        local platLoc = GetPlatoonPosition(self)
		
        if not PlatoonExists(aiBrain, self) or not platLoc then
            return
        end
        
        if GuardpointDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." "..self.BuilderInstance.." begins")
        end
		
		local units = GetPlatoonUnits(self)
		
		if units[1] then 
		
			for _,v in units do 
			
				if not v.Dead then
				
					if v:TestToggleCaps('RULEUTC_StealthToggle') then
					
						v:SetScriptBit('RULEUTC_StealthToggle', false)
					end
					
					if v:TestToggleCaps('RULEUTC_CloakToggle') then
					
						v:SetScriptBit('RULEUTC_CloakToggle', false)
					end
				end
			end
		else
		
			return
		end

        -- Platoon Data
        -----------------
		local PType = self.PlatoonData.PointType or 'Unit'
		local PCat = self.PlatoonData.PointCategory or 'MASSEXTRACTION'
		local PSourceSelf = self.PlatoonData.PointSourceSelf or true	

		local PSource
		local startx, startz
		
		if PSourceSelf then
			
			if aiBrain.BuilderManagers[self.BuilderLocation] then
			
				PSource = aiBrain.BuilderManagers[self.BuilderLocation].Position
			else
			
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
		else
		
			startx, startz = aiBrain:GetCurrentEnemy():GetArmyStartPos()

			PSource = {startx, 0, startz}
		end
		
		local PFaction = self.PlatoonData.PointFaction or 'Ally'	 	
		local PRadius = self.PlatoonData.PointRadius or 999999			
		local PSort = self.PlatoonData.PointSort or 'Closest'			
		local PMin = self.PlatoonData.PointMin or 1						
		local PMax = self.PlatoonData.PointMax or 999999				
		
		local StrCat = self.PlatoonData.StrCategory or nil	
		local StrRadius = self.PlatoonData.StrRadius or 20
		local StrTrigger = self.PlatoonData.StrTrigger or false
		local StrMin = self.PlatoonData.StrMin or 0
		local StrMax = self.PlatoonData.StrMax or 99
        
        local ThreatMin = self.PlatoonData.ThreatMin or -999            -- control minimum threat so we can go to points WITH threat if provided
        local ThreatMaxRatio = self.PlatoonData.ThreatMaxRatio or 0.8   -- control maximum threat based on platoon value
        local ThreatRings = self.PlatoonData.ThreatRings or 0           -- allow use of 'rings' value
        local ThreatType = self.PlatoonData.ThreatType or 'AntiSurface'

		local UntCat = self.PlatoonData.UntCategory or nil	
		local UntRadius = self.PlatoonData.UntRadius or 20
		local UntTrigger = self.PlatoonData.UntTrigger or false
		local UntMin = self.PlatoonData.UntMin or 0
		local UntMax = self.PlatoonData.UntMax or 99
		
		if PType == 'Unit' and type(PCat) == 'string' then
		
			PCat = LOUDPARSE(PCat)
		end
		
		if type(StrCat) == 'string' then
		
			StrCat = LOUDPARSE(StrCat)
		end
		
		if type(UntCat) == 'string' then
		
			UntCat = LOUDPARSE(UntCat)
		end
		
		local AssistRange = self.PlatoonData.AssistRange or 0	
        local guardTimer = self.PlatoonData.GuardTimer or 600	
		
		local MissionTimer = self.PlatoonData.MissionTime or 1200
		
		local guardRadius = self.PlatoonData.GuardRadius or 75	
		local MergeLimit = self.PlatoonData.MergeLimit or false	
        
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        local PlatoonFormation = self.PlatoonData.UseFormation or 'None'

		local allowinwater = self.PlatoonData.AllowInWater or 'true'
		local AvoidBases = self.PlatoonData.AvoidBases or 'false'
		
		local categoryList = {}
		
        if self.PlatoonData.PrioritizedCategories then
		
            for k,v in self.PlatoonData.PrioritizedCategories do

                LOUDINSERT( categoryList, LOUDPARSE( v ) )
            end
			
        else

			LOUDINSERT( categoryList, ALLUNITS )
		end
		
        self:SetPrioritizedTargetList( 'Attack', categoryList )        
		
        self:SetPlatoonFormationOverride(PlatoonFormation)
		
		local GetDirectionInDegrees = GetDirection
		
		local lastmarker = false
		local marker
		local UnitToGuard = false
		local guarding = false
		local guardtime = 0

		local OriginalThreat, position, pointlist, distance, usedTransports, path, reason, pathlength, choice
		local stuckcount, oldplatpos, calltransport
		local target, targetposition, units, direction
		local oldNumberOfUnitsInPlatoon, numberOfUnitsInPlatoon
        
        local MovementLayer = self.MovementLayer
		
		while PlatoonExists(aiBrain,self) do
		
			OriginalThreat = CalculatePlatoonThreat( self, 'Overall', ALLUNITS)
        
            if GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." "..self.BuilderInstance.." top - OriginalThreat is "..repr(OriginalThreat) )
            end
		
			if MissionTimer != 'Abort' and (LOUDTIME() - self.CreationTime ) > MissionTimer then
			
				break
			end
		
            units = GetPlatoonUnits(self)
			
			position = GetPlatoonPosition(self) or false
			
			marker = false
			
			if position then

				-- Get a point that meets all of the required conditions
				pointlist = FindPointMeetsConditions( self, aiBrain, PType, PCat, PSource, PRadius, PSort, PFaction, PMin, PMax, AvoidBases, StrCat, StrRadius, StrMin, StrMax, UntCat, UntRadius, UntMin, UntMax, allowinwater, ThreatMin, OriginalThreat * ThreatMaxRatio, ThreatType )
			
				if pointlist then
				
					while marker == false do
				
						local choices = LOUDCEIL(LOUDGETN(pointlist))
						
						if choices < 1 then
							break
						end
						
						choice = Random( 1, choices )
						
						-- format the marker --
						marker = {pointlist[choice][1], pointlist[choice][2], pointlist[choice][3]}
						
						-- and remove the marker so it cant be picked again
						LOUDREMOVE( pointlist, choice )
						
						-- is it the same as last failed marker
						if LOUDEQUAL( marker, lastmarker ) then
						
							marker = false
						end
					end

					guardtime = 0
					guarding = false
					
				end
			end
			
			if not position or not marker then
        
                if GuardpointDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." "..self.BuilderInstance.." RTB - fails to find position is "..repr(position))
                end
				
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

			IssueClearCommands(self)
			
			distance = VDist3( position, marker )
        
            if GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..self.BuilderInstance.." getting path to "..repr(marker).." from "..repr(position) )
            end
            
            path = false
            pathlength = 0

			path, reason, pathlength = self.PlatoonGenerateSafePathToLOUD(aiBrain, self, MovementLayer, position, marker, OriginalThreat * ThreatMaxRatio, 250)

			if PlatoonExists(aiBrain, self) then
			
				if not path then
				
					lastmarker = LOUDCOPY(marker)

					marker = false

					break

				else

					if PlatoonExists(aiBrain,self) then
				
						self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove, 25)
					end
				
					if PlatoonExists(aiBrain,self) and not self.MoveThread then
					
						lastmarker = LOUDCOPY(marker)
				
						marker = false
						
						break
					end
				end
			end			

			-- TRAVEL TO THE MARKER POINT
			-- Check for exit along the way
			stuckcount = 0
			oldplatpos = false

			distance = VDist3( GetPlatoonPosition(self), marker )			

			while PlatoonExists(aiBrain,self) and marker and distance > UntRadius and guardtime < guardTimer do

				position = GetPlatoonPosition(self) or false
				
				if position then
			
					if StrCat and StrTrigger then
				
						if self:GuardPointStructureCheck( aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
						
							marker = false
							break
						end
					end
				
					if UntCat and UntTrigger then
				
						if self:GuardPointUnitCheck( aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
						
							marker = false
							break
						end
					end
				
					if self:CheckForStuckPlatoon( position, oldplatpos ) then
				
						stuckcount = stuckcount + 1
					
						-- if stuck count > 4 (about 32 seconds) then process out the stuck units
						if marker and stuckcount > 3 then
					
							if self:ProcessStuckPlatoon( marker ) then
							
								stuckcount = 0
							else
						
								marker = false
								break
							end
						end	
					
					else
				
						if position then
					
							oldplatpos = LOUDCOPY(position)
							stuckcount = 0
						else
					
							continue
						end
					end

					WaitTicks(80)
				
					if marker and PlatoonExists( aiBrain, self ) then

						distance = VDist3( GetPlatoonPosition(self), marker )
					end
				end
			end
        
            if GuardpointDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." in range of marker - marker is "..repr(marker) )
            end
            
			-- if we still have a marker - stop any move thread -- otherwise find a new point
			if marker then
			
				if PlatoonExists(aiBrain,self) and self.MoveThread then

					self:KillMoveThread()
				end
			else
			
				continue
			end

			
			-- Guard Point and Attack Enemy within guardRadius
			guarding = false
			guardtime = 0

			while marker and guardtime < guardTimer and PlatoonExists(aiBrain,self) do
			
				target = false
        
                if GuardpointDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." "..self.BuilderInstance.." seeking target using range of "..guardRadius )
                end
			
				target, targetposition = FindTargetInRange( self, aiBrain, 'Attack', guardRadius, categoryList, false)

				units = GetPlatoonUnits(self)
				
				if target then

                    targetposition = LOUDCOPY(targetposition)

                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..self.BuilderInstance.." has target "..repr(target:GetBlueprint().Description) )
                    end

					-- issue attack orders on target --
					if target.EntityID and not target.Dead then
                    
                        self.UsingTransport = true      -- turn off Distress Response and merges
					
						self:Stop()
						
						position = GetPlatoonPosition(self) or false
						
						if position then
						
							direction = GetDirection( GetPlatoonPosition(self), targetposition )
                           
                            local ATTACKS = GetSquadUnits(self,'Attack')
                            
                            if ATTACKS[1] then
						
                                IssueFormAttack( ATTACKS, target, 'AttackFormation', direction)
                                
                            end
                            
                            local ARTILLERY = GetSquadUnits(self,'Artillery')
						
							if ARTILLERY[1] then
							
								IssueFormAggressiveMove( ARTILLERY,targetposition,'AttackFormation', direction)
                                
							end
                            
                            local GUARDS = GetSquadUnits(self,'Guard')
						
							if GUARDS[1] then
							
								IssueFormAggressiveMove( GUARDS,targetposition,'DMSCircleFormation', direction)
                                
							end
                            
                            local SUPPORTS = GetSquadUnits(self,'Support')
						
							if SUPPORTS[1] then
							
								IssueFormAggressiveMove( SUPPORTS,targetposition,'ScatterFormation', direction)
								
							end

							guarding = false
							
						end
					else
						
						target = false
					end
					
					-- Engage target until dead or target is outside guard radius
					while target and (not target.Dead) and PlatoonExists(aiBrain, self) do 
        
                        if GuardpointDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." "..self.BuilderInstance.." attacking target "..repr(target:GetBlueprint().Description))
                        end

						WaitTicks(90)
						guardtime = guardtime + 9
						
						if PlatoonExists(aiBrain,self) then
					
							if UnitToGuard and not UnitToGuard.Dead then
					
								marker = GetPosition(UnitToGuard)
							end
					
							if target.Dead or VDist3( GetPosition(target), marker) > guardRadius then

								self:Stop()
								break
							end
					
							-- if platoon is exhausted --
							if CalculatePlatoonThreat( self, 'Surface', ALLUNITS) <= (OriginalThreat * .40) then
						
								self:MergeIntoNearbyPlatoons( aiBrain, 'GuardPointNaval', 100, false)
								
								-- RTB any leftovers
								return self:SetAIPlan('ReturnToBaseAI',aiBrain)
							end
						
							target = false
							guarding = false
						end
					end
                    
                    self.UsingTransport = false     -- turn on DistressRepsonse and merges

				end				
				
				-- if no target and not already guarding - setup a guard around the point --
				if (not target) and (not guarding) and PlatoonExists(aiBrain, self) then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..self.BuilderName.." starting guard")
                    end

					self:Stop()
				
					local randlist = { AssistRange, AssistRange * -1 }
					
					local counter = 0
					local newunits = {}
					
					for k,unit in units do
					
						if not unit.Dead then
						
							counter = counter + 1
							newunits[counter] = unit
						end
					end
					
					if counter < LOUDGETN(GetPlatoonUnits(self)) then
					
						units = newunits
					end
					
					if counter > 0 then
					
						IssueFormMove( units, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) }, PlatoonFormation, GetDirectionInDegrees( GetPlatoonPosition(self), marker )) 
					
						for _,u in units do
					
							if LOUDENTITY( categories.REPAIR, u ) then
							
								IssueGuard({u}, { marker[1] + tonumber(randlist[Random(1,2)]), marker[2], marker[3] + tonumber(randlist[Random(1,2)]) })
							end
						
							if LOUDENTITY( categories.SCOUT, u ) then
						
								local loclist = GetBasePerimeterPoints( aiBrain, marker, guardRadius/2, 'ALL', false, 'Water', true )
							
								for k,v in loclist do
								
									if (not u.Dead) and u:CanPathTo( v ) then
									
										v[2] = GetSurfaceHeight(v[1], v[3])
										
                                        -- check that position is below water --
										if GetTerrainHeight(v[1],v[3]) > (v[2] - 1.5) then
										
											continue
										end
							
										if k == 1 then
								
											IssueMove( {u}, v )
										else
								
											if k != 4 and k !=7 and k != 10 then
										
												IssuePatrol( {u}, v )
											end
										end
									end
								end
							end
						end
					end
					
					guarding = true
					target = false
				end
				
				-- Check Str/Unit Parameters 
				if StrCat and StrTrigger then
				
					if self:GuardPointStructureCheck(  aiBrain, marker, StrCat, StrRadius, PFaction, StrMin, StrMax) then
					
						guardtime = guardTimer
					end
				end
				
				if UntCat and UntTrigger then
				
					if self:GuardPointUnitCheck( aiBrain, marker, UntCat, UntRadius, PFaction, UntMin, UntMax) then
					
						guardtime = guardTimer
					end
				end		
				
				-- MERGE with other GuardPoint Platoons during regular guardtime
				if Random(1,3) == 1 and MergeLimit and (guardtime <= guardTimer) and PlatoonExists(aiBrain, self) then
				
					oldNumberOfUnitsInPlatoon = 0
				
					for _,v in units do
					
						if not v.Dead then
						
							oldNumberOfUnitsInPlatoon = oldNumberOfUnitsInPlatoon + 1
						end
					end
				
					if oldNumberOfUnitsInPlatoon > 0 and oldNumberOfUnitsInPlatoon < MergeLimit then
					
						if self.MergeWithNearbyPlatoons( self, aiBrain, 'GuardPointNaval', 90, false, MergeLimit) then
				
							units = GetPlatoonUnits(self)
						
							numberOfUnitsInPlatoon = 0
						
							for _,v in units do
							
								if not v.Dead then
								
									numberOfUnitsInPlatoon = numberOfUnitsInPlatoon + 1
								end
							end

							if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
							
								self:Stop()
								self:SetPlatoonFormationOverride(PlatoonFormation)
							end

							OriginalThreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS)
							
							target = false
							guarding = false
						end
					end
				end

				-- Check SelfThreat for Retreat
				if CalculatePlatoonThreat( self, 'Overall', ALLUNITS) <= (OriginalThreat * .40) then
				
					self.MergeIntoNearbyPlatoons( self, aiBrain, 'GuardPointAmphibious', 100, false)
					
					return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				end

				if marker and UnitToGuard and not UnitToGuard.Dead then
				
					marker = GetPosition(UnitToGuard)
				end
				
				if MissionTimer == 'Abort' then
        
                    if GuardpointDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." GPAI Naval "..repr(self.BuilderName).." "..self.BuilderInstance.." Abort Platoon")
                    end
					
					-- assign them to the structure pool so they dont interfere with normal unit pools
					AssignUnitsToPlatoon( aiBrain, aiBrain.StructurePool, GetPlatoonUnits(self), 'Guard', 'none' )
					
					return aiBrain:DisbandPlatoon(self)
				end
				
				WaitTicks(80)
				guardtime = guardtime + 8

			end
			
			marker = false
			
            WaitTicks(35)
           
		end		-- end of current marker - get new marker

		return self:SetAIPlan('ReturnToBaseAI',aiBrain)

    end,  

	
    ScoutingAI = function( self, aiBrain )
        
        if self.MovementLayer == 'Air' then
		
			self:ForkAIThread( Behaviors.AirScoutingAI, aiBrain) 
		end
		
        if self.MovementLayer == 'Water' then
		
			self:ForkAIThread( Behaviors.NavalScoutingAI, aiBrain)
		end

		if self.MovementLayer == 'Land' or self.MovementLayer == 'Amphibious' then
		
			self:ForkAIThread( Behaviors.LandScoutingAI, aiBrain)
		end
    end,

	AttackForceAI = function( self, aiBrain )
	
        if self.MovementLayer == 'Air' then
		
			self:ForkAIThread( Behaviors.AirForceAILOUD, aiBrain) 
		end
		
        if self.MovementLayer == 'Water' then
        
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..self.BuilderInstance.." in AttackForceAI")
		
			self:ForkAIThread( Behaviors.NavalForceAILOUD, aiBrain)
		end	

		if self.MovementLayer == 'Land' then
		
			self:ForkAIThread( Behaviors.LandForceAILOUD, aiBrain)
		end
		
		if self.MovementLayer == 'Amphibious' then
		
			self:ForkAIThread( Behaviors.AmphibForceAILOUD, aiBrain)
		end
	end,
    
    AttackForceAI_Bomber = function( self, aiBrain )
	
        if self.MovementLayer == 'Air' then
		
			self:ForkAIThread( Behaviors.AirForceAI_Bomber_LOUD, aiBrain) 
		end
    end,
    
    AttackForceAI_Gunship = function( self, aiBrain )
	
        if self.MovementLayer == 'Air' then
		
			self:ForkAIThread( Behaviors.AirForceAI_Gunship_LOUD, aiBrain) 
		end
    end,
    
    AttackForceAI_Torpedo = function( self, aiBrain )
	
        if self.MovementLayer == 'Air' then
		
			self:ForkAIThread( Behaviors.AirForceAI_Torpedo_LOUD, aiBrain) 
		end
    end,

	BombardForceAI = function( self, aiBrain )

        if self.MovementLayer == 'Water' then
		
			self:ForkAIThread( Behaviors.NavalBombardAILOUD, aiBrain)
		end	

		if self.MovementLayer == 'Land' then
		
			self:ForkAIThread( Behaviors.LandForceAILOUD, aiBrain)
		end
		
		if self.MovementLayer == 'Amphibious' then
		
			self:ForkAIThread( Behaviors.AmphibForceAILOUD, aiBrain)
		end
	end,

	-- platoon will patrol in a circle around a point 
    PlatoonPatrolPointAI = function( self, aiBrain )

        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists
        local WaitTicks = WaitTicks

        local location = self.BuilderLocation or self.LocationType or GetPlatoonPosition(self)
		local orientation = self.PlatoonData.BasePerimeterOrientation or 'FRONT'
		local patroltime = self.PlatoonData.PatrolTime or nil
		local patroltype = self.PlatoonData.PatrolType or false
		local PlatoonFormation = self.PlatoonData.UseFormation or 'AttackFormation'
        local radius = self.PlatoonData.Radius or 90		
		
        self:SetPlatoonFormationOverride(PlatoonFormation)

        self:Stop()

        local CreationTime = self.CreationTime

        local units = GetPlatoonUnits(self)		

        local landunit = false
		local layer = 'Air'

		for _,v in units do
		
			if not v.Dead and LOUDENTITY( categories.LAND, v ) then
			
				landunit = v
				layer = 'Land'
				break
			end
			
			if not v.Dead and LOUDENTITY( categories.NAVAL, v ) then
			
				landunit = v
				layer = 'Water'
				break
			end
			
		end

        local numberOfUnitsInPlatoon = LOUDGETN(units)
        local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
        
        -- Scouts are never considered for merges
        self.UsingTransport = true
		
        local platPos = GetPlatoonPosition(self)

		local loclist = GetBasePerimeterPoints(aiBrain, location, radius, orientation, false, layer, patroltype)
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." PatrolPointAI "..self.BuilderName.." "..self.BuilderInstance.." gets "..layer.." perimeter points - radius "..radius.." - "..repr(loclist) )

        -- set up the patrol
		for k,v in loclist do
		
			-- we want a circular pattern so we'll exclude the corners
			if k != 1 and k != 4 and k != 7 and k != 10 then
			
				if landunit and CheckUnitPathingEx( v, platPos, landunit ) then
				
					IssueFormPatrol( units, v, PlatoonFormation, 0)
					
				elseif not landunit then
				
					IssueFormPatrol( units, v, PlatoonFormation, 0)
				end
			end
		end

        -- a patrolling platoon checks for patroltime expiry or 
        -- having lost 50% of it's numerical size in order to 
        -- begin RTB
		while PlatoonExists(aiBrain, self) do
			
			if patroltime and ( (LOUDTIME() - CreationTime) > patroltime ) then
			
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
			
			numberOfUnitsInPlatoon = 0
			
			for _,v in units do
			
				if not v.Dead then
					numberOfUnitsInPlatoon = numberOfUnitsInPlatoon + 1
				end
				
			end
			
			if numberOfUnitsInPlatoon < (oldNumberOfUnitsInPlatoon * .5) then
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

			WaitTicks(100)
			
        end
		
    end,
	
	-- This function complements the work of Platoon Call For Help AI
	-- It manages the UnderAttack flag which is set when any unit is damaged - flag is reset after 7.5 seconds
	PlatoonUnderAttack = function(self, aiBrain)
        
        local platPos = GetPlatoonPosition(self) or false

        if platPos then
        
            self.UnderAttack = true

            ForkTo( AIAddMustScoutArea, aiBrain, platPos )
		
            WaitTicks(76)
		
            if PlatoonExists( aiBrain, self) then
                self.UnderAttack = nil
            end

        end

	end,
	
	------------- Platoon Call For Help AI --------------------
	-- This function allows platoons to issue ALERTS
	-- recording platoon, position, threat response required and a timestamp
	-- The brain will monitor such ALERTS and expire them after 30 seconds
	-- allowing the platoon to issue another after that
	-- also note that a platoon which has just begun responding to an ALERT
	-- cannot raise one of it's own for at least 15 seconds

	-- I put in some new logic to allow me to run this thread hotter
	-- essentially I hooked the OnDamage function (see Unit.lua) to
	-- record if any unit in the platoon is taking damage
	-- that will be the trigger from now on - instead of doing expensive
	-- radius based threat look ups every 10 seconds - so if a unit in the 
	-- platoon takes damage - only then will we look for local threat
	-- and then if the threat is there - and high enough - trigger an alert 

    PlatoonCallForHelpAI = function( self, aiBrain, threatcheck )

		self.CallForHelpAI = true
        
        local DistressResponseDialog    = ScenarioInfo.DistressResponseDialog or false

        local CalculatePlatoonThreat    = CalculatePlatoonThreat
        local GetEnemyUnitsInRect       = import('/lua/loudutilities.lua').GetEnemyUnitsInRect
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetThreatAtPosition       = GetThreatAtPosition
        local GetUnitsAroundPoint       = GetUnitsAroundPoint
        local PlatoonExists             = PlatoonExists
        
        local LOUDCOPY      = LOUDCOPY
        local LOUDEQUAL     = LOUDEQUAL
		local LOUDGETN      = LOUDGETN
        local LOUDINSERT    = LOUDINSERT
        local VDist3        = VDist3
        local WaitTicks     = WaitTicks
		
		if not self.MovementLayer then
			GetMostRestrictiveLayer(self)
		end
       
        local AIRUNITS      = categories.GROUNDATTACK + categories.BOMBER - categories.ANTINAVY
        local LANDUNITS     = categories.LAND * categories.MOBILE
        local SEAUNITS      = categories.MOBILE * categories.NAVAL
        
        local AIRFIGHTERS   = categories.AIR * categories.ANTIAIR
        local LANDAA        = (categories.LAND * categories.ANTIAIR) + (categories.STRUCTURE * categories.ANTIAIR)
        local TORPBOMBERS   = categories.AIR * categories.ANTINAVY
		
        local checkinterval = 12	-- every 1.2 seconds
   
        WaitTicks(checkinterval)

		local MovementLayer         = self.MovementLayer
		local threatcheckthreshold  = threatcheck or 6		

        local IMAPblocks        = LOUDFLOOR( 128/ScenarioInfo.IMAPSize)
        local threatrangeadjust = ScenarioInfo.IMAPRadius
        local threatringrange   = LOUDFLOOR(IMAPblocks/2)

		local distresscalltype, mythreat, threat
        local airunits, landunits, seaunits
		
        local pos = GetPlatoonPosition(self) or false

	
        local AIGetThreatLevelsAroundPoint = function(unitposition,threattype)
        
            local adjust = threatrangeadjust + ( threatringrange * threatrangeadjust ) 

            local units,counter = GetEnemyUnitsInRect( aiBrain, unitposition[1]-adjust, unitposition[3]-adjust, unitposition[1]+adjust, unitposition[3]+adjust )
            
            if DistressResponseDialog and counter > 0 then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI "..self.BuilderName.." "..repr(self.BuilderInstance).." finds "..counter.." enemy units around Point "..repr(unitposition) )
            end

            if units then
        
                local bp, threat
            
                threat = 0
                counter = 0
        
                if threattype == 'Air' or threattype == 'AntiAir' then
            
                    for _,v in units do
                
                        bp = __blueprints[v.BlueprintID].Defense.AirThreatLevel or 0
                    
                        if bp then
                            threat = threat + bp
                            counter = counter + 1
                        end
                    end
            
                elseif threattype == 'AntiSurface' then
            
                    for _,v in units do
                
                        bp = __blueprints[v.BlueprintID].Defense.SurfaceThreatLevel or 0
                    
                        if bp then
                            threat = threat + bp
                            counter = counter + 1
                        end
                    end
            
                elseif threattype == 'AntiSub' then
            
                    for _,v in units do
                
                        bp = __blueprints[v.BlueprintID].Defense.SubThreatLevel or 0
                    
                        if bp then
                            threat = threat + bp
                            counter = counter + 1
                        end
                    end

                elseif threattype == 'Economy' then
            
                    for _,v in units do
                
                        bp = __blueprints[v.BlueprintID].Defense.EconomyThreatLevel or 0
                    
                        if bp then
                            threat = threat + bp
                            counter = counter + 1
                        end
                    end
        
                else
            
                    for _,v in units do
                
                        bp = __blueprints[v.BlueprintID].Defense
                    
                        bp = bp.AirThreatLevel + bp.SurfaceThreatLevel + bp.SubThreatLevel + bp.EconomyThreatLevel
                    
                        if bp > 0 then
                            threat = threat + bp
                            counter = counter + 1
                        end
                    end
                
                end

                if counter > 0 then
                    return threat
                end
            end
        
            return 0
        end


		while PlatoonExists(aiBrain,self) do

			if self.UnderAttack and (not self.DistressCall) and (not self.RespondingToDistress) then

                pos = GetPlatoonPosition(self) or false
				
				if pos then
				
					-- Based upon the platoons movement MovementLayer get the local threats
					if MovementLayer == 'Land' then
					
						threat = AIGetThreatLevelsAroundPoint( pos,'AntiSurface' )
					
					elseif MovementLayer == 'Air' then
					
						threat = AIGetThreatLevelsAroundPoint( pos,'AntiAir' )
					
					elseif MovementLayer == 'Water' then
					
						threat = AIGetThreatLevelsAroundPoint( pos,'AntiSurface' )
						threat = threat + AIGetThreatLevelsAroundPoint( pos,'AntiSub' )
					
					elseif MovementLayer == 'Amphibious' then
					
						threat = AIGetThreatLevelsAroundPoint( pos,'AntiSurface' )
						
					end
            
                    if DistressResponseDialog then
                        LOG('*AI DEBUG '..aiBrain.Nickname..' PCAI '..self.BuilderName.." "..repr(self.BuilderInstance).." is Under Attack at "..repr(pos).." threat is "..string.format("%2.1f",threat).." threshold is "..threatcheckthreshold.." on tick "..GetGameTick() )
                    end

					if threat >= threatcheckthreshold then

						distresscalltype = false
						airunits = 0
						landunits = 0
						seaunits = 0

						-- determine what kind of help is needed - if Land or Amphib and the position is on Land it could be either a Land or Air threat
						if MovementLayer == 'Land' or (MovementLayer == 'Amphibious' and GetTerrainHeight(pos[1],pos[3]) >= GetSurfaceHeight(pos[1],pos[3])) then
						
							mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
						
							airunits    = GetUnitsAroundPoint( aiBrain, AIRUNITS, pos, 80, 'Enemy')
							landunits   = GetUnitsAroundPoint( aiBrain, LANDUNITS, pos, 65, 'Enemy')						
							seaunits    = GetUnitsAroundPoint( aiBrain, SEAUNITS, pos, 75, 'Enemy')
                            
							if LOUDGETN(landunits) > LOUDGETN(airunits) and LOUDGETN(landunits) > LOUDGETN(seaunits) then
							
								distresscalltype = 'Land'
							
							elseif LOUDGETN(airunits)> LOUDGETN(seaunits) then
							
								distresscalltype = 'Air'
								
								mythreat = CalculatePlatoonThreat( self, 'Air', ALLUNITS)
                                
                            elseif seaunits[1] then
                            
                                distresscalltype = 'Naval'
							end						
						
						-- if Air the threat could be either from Land, Naval or Air
						elseif MovementLayer == 'Air' then
					
							-- get my own air threat
							mythreat = CalculatePlatoonThreat( self, 'Air', ALLUNITS)
						
							-- get enemy air threat units within 65
							airunits    = GetUnitsAroundPoint( aiBrain, AIRFIGHTERS, pos, 60, 'Enemy')
							landunits   = GetUnitsAroundPoint( aiBrain, LANDAA, pos, 60, 'Enemy')
 							seaunits    = GetUnitsAroundPoint( aiBrain, SEAUNITS, pos, 60, 'Enemy')                           
						
							if LOUDGETN(landunits) > LOUDGETN(airunits) and LOUDGETN(landunits) > LOUDGETN(seaunits) then
							
								distresscalltype = 'Land'
							
							elseif LOUDGETN(airunits) > LOUDGETN(seaunits) then
							
								distresscalltype = 'Air'
                                
                            elseif seaunits[1] then
                            
                                distresscalltype = 'Naval'
							end
						
						-- if Water or Amphibious and the position is on or underwater
						elseif MovementLayer == 'Water' or (MovementLayer == 'Amphibious' and GetTerrainHeight(pos[1],pos[3]) <= GetSurfaceHeight(pos[1],pos[3])) then
					
							mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
							mythreat = mythreat + GetThreatAtPosition( aiBrain, pos, 0, true, 'AntiSub', aiBrain.ArmyIndex)
						
							seaunits = GetUnitsAroundPoint( aiBrain, SEAUNITS, pos, 75, 'Enemy')
							airunits = GetUnitsAroundPoint( aiBrain, TORPBOMBERS, pos, 75, 'Enemy')						
						
							if LOUDGETN(seaunits) > LOUDGETN(airunits) then
							
								distresscalltype = 'Naval'
							
							elseif airunits[1] then
							
								distresscalltype = 'Air'
							end
						end

						-- Store the Distress Call if threat is truly a danger to me
						if distresscalltype and threat >= (mythreat * 0.8) then
					
							if PlatoonExists(aiBrain, self) then
            
                                if DistressResponseDialog then
                                    LOG('*AI DEBUG '..aiBrain.Nickname..' PCAI '..self.BuilderName.." calls for "..distresscalltype.." help at "..repr(pos).." threat is "..threat.." threshold is "..threatcheckthreshold.." mythreat is "..mythreat )
                                end
								
								LOUDINSERT(aiBrain.PlatoonDistress.Platoons, { Platoon = self, DistressType = distresscalltype, Position = LOUDCOPY(pos), Threat = threat, CreationTime = LOUDTIME() } )

								aiBrain.PlatoonDistress.AlertSounded = true
								
								self.DistressCall = true
								
								if ScenarioInfo.DisplayPingAlerts or DistressResponseDialog then
									AISendPing( LOUDCOPY(pos), 'alert', aiBrain.ArmyIndex )
								end
							end
                        else
            
                            if DistressResponseDialog then
                                LOG('*AI DEBUG '..aiBrain.Nickname..' PCAI '..self.BuilderName.." is not threatened threat is "..threat.." mythreat is "..mythreat.." on tick "..GetGameTick() )
                            end
                            
                            self.DistressCall = nil

                        end
                        
                        WaitTicks(6)
                        
					else
						self.DistressCall = nil
					end

                else
                   break    -- no position -- must be dead
                end

			end

			WaitTicks(6)
 
        end
    end,

	------------------  Distress Response AI ------------------
	-- This thread allows a platoon to react to distress ALERTS
	-- these come from 3 different sources - CDR, Base, platoons
	-- Once a platoon responds it cannot raise an ALERT of it's 
	-- own for 10 seconds
    DistressResponseAI = function( self, aiBrain )
        
        local DistressResponseDialog = ScenarioInfo.DistressResponseDialog or false

		local oldPlan = self.PlanName -- we do this here to maintain the original plan, some platoons change the plan name

        local CalculatePlatoonThreat    = CalculatePlatoonThreat
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetPlatoonUnits           = GetPlatoonUnits
        local GetSquadUnits             = GetSquadUnits
        local GetThreatAtPosition       = GetThreatAtPosition
        local GetUnitsAroundPoint       = GetUnitsAroundPoint
        local PlatoonExists             = PlatoonExists
        
        local LOUDABS       = LOUDABS
        local LOUDCOPY      = LOUDCOPY
        local LOUDEQUAL     = LOUDEQUAL
        local LOUDFLOOR     = LOUDFLOOR
		local LOUDGETN      = LOUDGETN        
        local LOUDINSERT    = LOUDINSERT
        local LOUDREMOVE    = LOUDREMOVE
        local type          = type
        local VDist2        = VDist2
        local WaitTicks     = WaitTicks

        local PlatoonFindTarget = self.PlatoonFindTarget

        local distressRange     = self.PlatoonData.DistressRange or 100
		local distressTypes     = self.PlatoonData.DistressTypes or 'Land'
        local PlatoonFormation  = self.PlatoonData.UseFormation or 'None'
        local reactionTime      = self.PlatoonData.DistressReactionTime or 12   
        local threatThreshold   = self.PlatoonData.DistressThreshold or 10

        local MissionStartTime  = LOUDFLOOR(LOUDTIME())     
        local missiontime       = self.PlatoonData.MissionTime or 600
        
        local categoryList = {}
		
        if self.PlatoonData.PrioritizedCategories then
        
            LOUDINSERT( categoryList, LOUDPARSE(string.upper(distressTypes)))
		
            for k,v in self.PlatoonData.PrioritizedCategories do

                if type(v) == 'string' then
                    LOUDINSERT( categoryList, LOUDPARSE(v) )
                else
                    LOUDINSERT( categoryList, v )
                end

            end
            
        else
            LOUDINSERT( categoryList, ALLUNITS )
		end

		local direction, distance, distressLocation, distressType, distressplatoon, inwater, moveLocation, myThreatatPos, platoonPos, previousdistress, prevpos, startPos
        local threatatPos, target, targetingrange, units, unit
        
        local MovementLayer = self.MovementLayer
        local selfindex     = aiBrain.ArmyIndex
		
		WaitTicks(25)

		-- the intent of this function is to make sure that we don't try and respond over mountains
		-- and rivers and other serious terrain blockages -- these are generally identified by
        -- a rapid elevation change over a very short distance
		local function CheckBlockingTerrain( pos, targetPos )
        
            if MovementLayer == 'Air' then
                return false
            end
            
            local lastpos, lastposHeight, nextposHeight
            local InWater, nextpos, steps, xstep, ystep
            local LOUDABS = LOUDABS

            -- alter the function according to layer
            local terrainfunction = GetTerrainHeight
            local deviation = 2.5
            
            if MovementLayer == 'Water' then
                terrainfunction = GetSurfaceHeight
                deviation = 0.5
            end
	
			-- This gives us the number of approx. 8 ogrid steps in the distance
			steps = LOUDFLOOR( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 8 ) + 1
	
			xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
			ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step
			
			lastpos = {pos[1], 0, pos[3]}
            lastposHeight = terrainfunction( lastpos[1], lastpos[3] )
            
            nextpos = { 0, 0, 0 }
	
			-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
			for i = 1, steps do

                InWater = lastposHeight < (GetSurfaceHeight( lastpos[1], lastpos[3] ) - 1)		

                nextpos[1] = pos[1] - (xstep * i)
                nextpos[3] = pos[3] - (ystep * i)

				nextposHeight = terrainfunction( nextpos[1], nextpos[3] )

				-- if more than deviation ogrids change over 8 ogrids distance
				if LOUDABS(lastposHeight - nextposHeight) > deviation or (InWater and MovementLayer != 'Amphibious') then
					return true
				end

				lastpos[1] = nextpos[1]
                lastpos[3] = nextpos[3]
                lastposHeight = nextposHeight

			end
	
			return false
		end
	
		-- this function returns the location of any distress call within range
		local function PlatoonMonitorDistressLocations( platoon, aibrain, platoonposition, distressrange, distresstype, threatthreshold )

			local VDist3 = VDist3
			local VDist2 = VDist2

			local alertposition = false
			local alertrange = 9999999

			local Brains = ArmyBrains

			local alertplatoon, alerts, EM, position, rangetoalert, selfthreat, threat
		
			for index,brain in Brains do
		
				if index == selfindex or IsAlly( selfindex, brain.ArmyIndex ) and brain.BuilderManagers != nil then
			
                    position = brain.CDRDistress or false

					--- First check CDR Distress -- respond at twice the normal distress range
					if position then
					
						if GetUnitsAroundPoint( brain, COMMANDER, position, 100, 'Ally')[1] then
                        
                            rangetoalert = VDist3( platoonposition, position )
					
                            -- if more than 20 but less than double the distressrange - respond
							if rangetoalert > 20 and rangetoalert < ( distressrange * 2) then

                                if DistressResponseDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(platoon.MovementLayer).." selects ACU ALERT "..repr(position) )
                                end

								return position, distresstype, 'Commander'
							end
                            
						else
							LOG("*AI DEBUG "..brain.Nickname.." CDR Dead - CDR Distress deactivated")
						
							brain.CDRDistress = nil
						end
					end
				
					--- Secondly - look for BASE and PLATOON alerts
					-- respond to the closest ALERT (Base alerts at double range)
					-- that exceeds our threat threshold
					if brain.BaseAlertSounded then
				
						-- loop thru bases for this brain
						for baseName,base in brain.BuilderManagers do
                        
                            EM = base.EngineerManager

							-- must have an EM and be active
							if EM.Active then
                            
                                alerts = EM.BaseMonitor.AlertsTable[distresstype]

								-- is EM sounding an alert for my kind of distress response ? --
								-- remember - each base will only track one alert for each type --
								-- therefore - we either have an alert or we don't for any given base -- 
								if alerts then

									-- is threat high enough for me to notice ?
									if alerts.Threat >= threatthreshold then
                                    
                                        position = alerts.Position
							
										rangetoalert = VDist3( platoonposition, position )
								
										if rangetoalert > 20 and rangetoalert <= (distressrange * 2) then

                                            if not CheckBlockingTerrain( platoonposition, position ) then
                                
                                                -- Always capture the CLOSEST ALERT
                                                if rangetoalert < alertrange then
											
                                                    alertposition = LOUDCOPY(position)
                                                    alertplatoon = 'BaseAlert'
                                                    alertrange = rangetoalert

                                                end
											end
										end
									end
								end
							end
						end		-- next base in this brain
					end

			
					--- if platoon alerts see if one of those is closer
					if brain.PlatoonDistress.AlertSounded then

                        --if DistressResponseDialog then
                          --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." sees Distress calls from "..brain.Nickname )
                        --end

						alerts = brain.PlatoonDistress.Platoons
                    
						if alerts[1] then

							for _,v in alerts do
 
								if v.DistressType == distresstype then
                               
                                    distressplatoon = v.Platoon

                                    position = v.Position

									-- is calling platoon still alive and it's not ourselves
									if PlatoonExists(brain, distressplatoon) and (not LOUDEQUAL( distressplatoon, platoon)) then

										rangetoalert = VDist3( platoonposition, position )

                                        --if DistressResponseDialog then
                                          --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." sees "..v.DistressType.." alert from "..brain.Nickname.." "..distressplatoon.BuilderName.." "..repr(distressplatoon.BuilderInstance).." at "..rangetoalert.." response is "..distressrange )
                                        --end
									
										-- is it within my distress response range 
										if rangetoalert > 20 and rangetoalert <= distressrange then

                                            if not CheckBlockingTerrain( platoonposition, position ) then

                                                if v.Threat >= threatthreshold then
                                            
                                                    if MovementLayer == 'Air' then
                                                        --- Air is only concerned about AntiAir threats --
                                                        threat      = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiAir')
                                                        selfthreat  = CalculatePlatoonThreat( platoon, 'Surface', ALLUNITS )

                                                        if distresstype == 'Naval' then
                                                            selfthreat = selfthreat + CalculatePlatoonThreat( platoon, 'Sub', ALLUNITS )
                                                        end
                                                
                                                        if distresstype == 'Air' then
                                                            selfthreat = CalculatePlatoonThreat( platoon, 'AntiAir', ALLUNITS )
                                                        end
                                                    end    
                                                    
                                                    if MovementLayer == 'Water' then
                                                        --- Water is concerned with both surface and antisub threat
                                                        --- however, it would be ideal if we knew if we were a sub formation or not
                                                        threat      = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSurface') + GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSub')
                                                        selfthreat  = CalculatePlatoonThreat( platoon, 'Surface', ALLUNITS) + CalculatePlatoonThreat( platoon, 'Sub', ALLUNITS )
                                                    end
                                                    
                                                    if MovementLayer == 'Land' or MovementLayer == 'Amphibious' then
                                                        --- Land & Amphib are only concerned with surface attack
                                                        threat      = GetThreatAtPosition( aiBrain, position, 0, true, 'AntiSurface')
                                                        selfthreat  = CalculatePlatoonThreat( platoon, 'Surface', ALLUNITS)
                                                    end

                                                    --- is the enemy threat dangerous to me (we already know that the alert is already dangerous to them)
                                                    --- it has to be very threatening to not respond
                                                    if threat >= (selfthreat * 2) then

                                                        if DistressResponseDialog then
                                                            LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." "..repr(platoon.MovementLayer).." not responding - threat "..threat.." self is "..selfthreat )
                                                        end
                                                
                                                        continue
                                                    end

                                                    if DistressResponseDialog then
                                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." "..repr(platoon.MovementLayer).." records alert at "..repr(position).." distance "..rangetoalert.." threat "..threat )
                                                    end

                                                    alertposition = LOUDCOPY( position )
                                                    alertplatoon = distressplatoon
                                                    alertrange = rangetoalert

                                                else
                                                    --if DistressResponseDialog then
                                                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." "..repr(platoon.MovementLayer).." not responding - threat "..threat.." below threshold "..threatthreshold )
                                                    --end
                                                end

                                            end

                                        else
                                            --if DistressResponseDialog then
                                              --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." distress at "..rangetoalert.." response range is "..distressrange )
                                            --end
                                        end

                                    end
                                    
								else
                                    --if DistressResponseDialog then
                                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..repr(self.BuilderInstance).." "..repr(platoon.MovementLayer).." ignores "..v.DistressType.." alert" )
                                    --end
                                end

							end
						end
					end
				end
			end		-- next brain --
	
			if alertposition then
                if DistressResponseDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." selects "..repr(alertposition).." from "..( repr(alertplatoon.BuilderName) or repr(alertplatoon) ).." distance "..alertrange.." - time "..repr(GetGameTimeSeconds()))
                end

				return alertposition, distresstype, alertplatoon
			else
				return false, false, false
			end
            
		end	
	
		-- mark the platoon as running the AI
		self.DistressResponseAIRunning = true
		
		while PlatoonExists(aiBrain,self) and self.DistressResponseAIRunning do

			platoonPos = GetPlatoonPosition(self) or false
			
			-- Find a distress location within the platoons range
            if platoonPos and (not self.DistressCall) and (not self.UsingTransport) and (not self.RespondingToDistress) then

                distressLocation, distressType, distressplatoon = PlatoonMonitorDistressLocations( self, aiBrain, platoonPos, distressRange, distressTypes, threatThreshold )

                if distressLocation then
                    
                    --- store this distressLocation so that we can ignore it
                    --- if it comes up after we've cleared the area
                    previousdistress = LOUDCOPY(distressLocation)                    

                    if not unit or unit.Dead then
					
                        -- find a unit in the platoon --
                        for _,u in GetPlatoonUnits(self) do
					
                            if not u.Dead then
                                unit = u
                                break
                            end
                        end
                    end
					
					if unit and unit:CanPathTo(distressLocation) and (not CheckBlockingTerrain( platoonPos, distressLocation )) then

						if self.AIThread then
							self:StopAI()
						end

						if self.MoveThread then
                            self:KillMoveThread()
						end
				
						-- This keeps the platoon from issuing a distress ALERT of it's own 
						-- or responding to another distress call
						self.RespondingToDistress = true
                        self.UsingTransport = true

                        -- record the starting position of the platoon for reference to later distress checks
                        startPos = LOUDCOPY(platoonPos)

                        local ATTACKS, ARTILLERY, GUARDS, SUPPORTS, SCOUTS
			
                        if DistressResponseDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." responds to "..distressType.." DISTRESS at "..repr(distressLocation).." distance "..VDist3(platoonPos,distressLocation).." check interval is "..repr(reactionTime * 10) )
                        end
                        
                        IssueClearCommands( GetPlatoonUnits(self) )

						-- Head towards position and repeat until there is no distressLocation
						while PlatoonExists(aiBrain, self) and distressLocation and self.DistressResponseAIRunning do
                        
							moveLocation = LOUDCOPY(distressLocation)

                            inWater = false
                            
                            if MovementLayer != 'Air' then
                                -- am I in the water ?
                                inWater = InWaterCheck(self)
                            end

                            if DistressResponseDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." continues response to "..distressType.." DISTRESS at "..repr(distressLocation).." distance "..VDist3(platoonPos,distressLocation).." on tick "..GetGameTick() )
                            end

							-- move directly to distressLocation
							if not inWater then

                                direction = GetDirection( GetPlatoonPosition(self), distressLocation )

                                if DistressResponseDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." moving to "..repr(distressLocation).." distance "..VDist3(platoonPos,distressLocation).." on tick "..GetGameTick() )
                                end
                                
                                ATTACKS = table.merged(GetSquadUnits(self,'Attack'),GetSquadUnits(self,'Unassigned'))
                            
                                if ATTACKS[1] then
                            
                                    IssueStop( ATTACKS )
				
                                    IssueFormAggressiveMove( ATTACKS, distressLocation, 'AttackFormation', direction)
                                end
                                
                                ARTILLERY = GetSquadUnits(self,'Artillery')
					
                                if ARTILLERY[1] then
                            
                                    IssueStop(ARTILLERY)
                        
                                    IssueFormAggressiveMove( ARTILLERY, distressLocation, PlatoonFormation, direction)
                                end
                                
                                GUARDS = GetSquadUnits(self,'Guard')
                            
                                if GUARDS[1] then
                            
                                    IssueStop(GUARDS)
                     
                                    if not ARTILLERY[1] and not ATTACKS[1] then

                                        IssueFormMove( GUARDS, distressLocation, 'BlockFormation', direction)
                                
                                    elseif ARTILLERY[1] then
                                
                                        IssueGuard( GUARDS, ARTILLERY[1] )
                                
                                    elseif ATTACKS[1] then
                                
                                        IssueGuard( GUARDS, ATTACKS[1] )
                                    end
                                end
                                
                                SUPPORTS = GetSquadUnits(self,'Support')
					
                                if SUPPORTS[1] then

                                    IssueStop(SUPPORTS)
                                
                                    if not ATTACKS[1] and not ARTILLERY[1] then
                                
                                        IssueFormAggressiveMove( SUPPORTS, distressLocation, 'BlockFormation', direction)
                                
                                    elseif ATTACKS[1] then
                            
                                        IssueGuard( SUPPORTS, ATTACKS[1] )
                                
                                    elseif ARTILLERY[1] then
                            
                                        IssueGuard( SUPPORTS, ARTILLERY[1] )
                                    end
                                end
                                
                                SCOUTS = GetSquadUnits(self,'Scout')

                                if SCOUTS[1] then
                                    
                                    IssueStop( SCOUTS )
                                    
                                    IssueFormMove( SCOUTS, distressLocation, 'BlockFormation', direction)
                                end
							else

								self:MoveToLocation( distressLocation, false )
							end
                            
							prevpos = false

							-- underway to distress position, check threat at position still greater than threshold
                            -- also, watch for stalled movement
                            -- when within 65 start seeking local targets to prosecute
							while PlatoonExists(aiBrain, self) and moveLocation do

                                if self.DistressResponseAIRunning then

                                    platoonPos = GetPlatoonPosition(self) or false
							
                                    if platoonPos then

                                        -- if we have a prevpos and we haven't moved much
                                        if prevpos and VDist2(platoonPos[1],platoonPos[3], prevpos[1],prevpos[3]) < 4 then

                                            if DistressResponseDialog then
                                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." seems to have stopped moving "..math.floor(VDist2(platoonPos[1],platoonPos[3], prevpos[1],prevpos[3])))
                                            end

                                            moveLocation = false
                                        else
                                            prevpos = LOUDCOPY(platoonPos)

                                            if DistressResponseDialog then
                                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." is moving - distance "..math.floor(VDist2(platoonPos[1],platoonPos[3], prevpos[1],prevpos[3])).." on tick "..GetGameTick() )
                                            end
                                            
                                        end

                                        -- if we have a distress location check the threat is still past threshold
                                        if moveLocation then

                                            threatatPos = threatThreshold
                                            
                                            targetingrange = 65
                                            
                                            if distressType == 'Air' then
                                                targetingrange = 50
                                            end
                                            
                                            --- see if distress platoon still exists
                                            if (distressplatoon != 'Commander') and (distressplatoon != 'BaseAlert') then

                                                -- abort distress response if it's below threshold
                                                if not PlatoonExists( aiBrain, distressplatoon ) then

                                                    if DistressResponseDialog then
                                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." distress platoon destroyed ")
                                                    end
                                            
                                                    moveLocation = false
                                                end
                                                
                                            end

                                            --- check for proximity and scan for (and prosecute) targets if so
                                            if moveLocation then
                                        
                                                distance = LOUDFLOOR(VDist3( platoonPos, moveLocation ))

                                                --if DistressResponseDialog then
                                                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." now at "..repr(distance).." to "..repr(moveLocation) )
                                                --end
                                            
                                                -- if within proximity to the distress -check for target
                                                if distance <= targetingrange then
                                                
                                                    target = true
                                                    
                                                    while target do 
                                                    
                                                        -- find a target within range of the distress and prosecute it
                                                        target = PlatoonFindTarget( self, aiBrain, 'Attack', moveLocation, targetingrange, categoryList )

                                                        if DistressResponseDialog then
                                                            LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." engaged target within "..targetingrange.." of distress position "..repr(moveLocation) )
                                                        end                                                        
                                                    end

                                                    if DistressResponseDialog then
                                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." no target within "..targetingrange.." of distress position "..repr(moveLocation) )
                                                    end
                                                    
                                                    target = false
                                                    moveLocation = false
                                                    distressLocation = false

                                                end
                                            end
                                            
                                        end
                                        
                                    else
                                        return
                                    end
    
                                    -- delay between threat checks modified by distance
                                    if moveLocation then
                                        WaitTicks( 1 + (reactionTime * 5) + LOUDFLOOR(distance/25) )
                                    end
                                    
                                    self.RespondingToDistress = nil	-- allow platoon to issue it's own distress calls after the first pass
                                    
                                else
                                    moveLocation = false
                                    distressLocation = false
                                    break
                                end
								
                            end    

							if PlatoonExists(aiBrain, self) and self.DistressResponseAIRunning then
                            
                                WaitTicks(6)
							
								platoonPos = GetPlatoonPosition(self) or false
                                
                                if platoonPos then
                                
                                    distressLocation    = false
                                    distressType        = false
                                    distressPlatoon     = false

									distressLocation, distressType, distressplatoon = PlatoonMonitorDistressLocations( self, aiBrain, startPos, distressRange, distressTypes, threatThreshold)
                                    
                                    if distressLocation and LOUDEQUAL(distressLocation, previousdistress) then
                                        distressLocation = false
                                    end
								else
                                    return
                                end
                                
							end
						end

                        -- return to previous task if no distressLocation
						if PlatoonExists(aiBrain, self) and not distressLocation then
                        
                            self.UsingTransport = false
                            
                            movelocation = false
			
							if DistressResponseDialog then
								LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." response complete -- oldplan is "..repr(oldPlan) )
							end

							if (not oldPlan) or (not self.DistressResponseAIRunning) then
                            
								self:Stop()
							else
                            
								self:Stop()
                                
                                if self.PlatoonData.MissionTime then

                                    self.PlatoonData.MissionTime = LOUDMAX( 0, self.PlatoonData.MissionTime - (LOUDTIME() - MissionStartTime) )

                                    if DistressResponseDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." -- Mission Time set to "..self.PlatoonData.MissionTime )
                                    end
                                    
                                    if self.PlatoonData.MissionTime <= 10 then
                                        oldPlan = 'ReturnToBaseAI'
                                    end
                                end
			
                                if DistressResponseDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." -- plan is "..repr(oldPlan) )
                                end

								self:SetAIPlan(oldPlan, aiBrain)
							end
						end

					else
                   
                        if DistressResponseDialog then
                        
                            if not unit then 
                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." finds no unit" )
                            elseif (not unit:CanPathTo(distressLocation)) then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." "..repr(MovementLayer).." cannot path to "..repr(distressLocation) )
                            else
                                LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." "..repr(MovementLayer).." sees blocking terrain between "..repr(distressLocation).." and "..repr(platoonPos) )
                            end
                        end
                        
                        distressLocation = false
                        movelocation = false
                    end

                else
                    --if DistressResponseDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." sees no distress calls "..GetGameTick() )
                    --end
                end

            else
        
                if DistressResponseDialog then
                
                    if self.UsingTranport then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." response disabled in Transit ")
                    elseif self.RespondingToDistress then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." Responding to distress " )
                    elseif self.Distress then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PCAI DR "..self.BuilderName.." "..self.BuilderInstance.." In Distress " )
                    end
                end
                
                WaitTicks(11)
            
            end
			
			WaitTicks( 1 + reactionTime )
        end
        
    end,

    EngineerAssistShield = function( self, aiBrain )
	
		local function EconDamagedShield()
		
			local eng = GetPlatoonUnits(self)[1]
			
			if eng then
			
				local beingBuilt = self.PlatoonData.Assist.BeingBuiltCategories or ALLUNITS
                local BuilderLocation = self.BuilderLocation
				
				for _,catString in beingBuilt do
				
					local assistList = FindDamagedShield( aiBrain, BuilderLocation, catString )
					
					if assistList then
					
						self:Stop()
						IssueGuard( {eng}, assistList )
						
						return true
					end
					
				end
			end
			
			return false
		end
		
        if EconDamagedShield() then
		
			WaitSeconds(self.PlatoonData.Assist.Time or 15)
		end
		
		self:Stop()
		
		IssueClearCommands(self)
		
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end,
	
	EngineerReclaimStructureAI = function( self, aiBrain )

        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local GetUnitsAroundPoint = GetUnitsAroundPoint
		local IsIdleState = IsIdleState        
        local PlatoonExists = PlatoonExists
        
        local LOUDSORT = LOUDSORT
        local LOUDREMOVE = LOUDREMOVE

		local VDist3Sq = VDist3Sq
        
        local WaitTicks = WaitTicks
        
		local baseposition = aiBrain.BuilderManagers[self.BuilderLocation].Position
        
		local data = self.PlatoonData
		local baseradius = data.ReclaimRange or aiBrain.BuilderManagers[self.BuilderLocation].EngineerManager.Radius
		local categories = data.Reclaim

        local counter, distance, reclaimables, unitPos
        
        local units = GetPlatoonUnits(self)
		
        while PlatoonExists(aiBrain,self) do
        
            unitPos = GetPlatoonPosition(self)
			
			if not unitPos then
				return
			end

			distance = false			

			local reclaimlist = {}

			counter = 0
			
			for _,cat in categories do
			
				reclaimables = GetUnitsAroundPoint( aiBrain, cat, baseposition, baseradius, 'Ally' ) 
				
				for _,v in reclaimables do
					counter = counter + 1
					reclaimlist[counter] = { ID = v, Position = v:GetPosition(), Distance = VDist3Sq( GetPosition(v), unitPos) }
				end
			end
		
			LOUDSORT(reclaimlist, function(a,b) return a.Distance > b.Distance end)
			
			local sortedreclaimlist = {}
            
			counter = 0
            
			local lastpos
			
			while reclaimlist[1] do
			
				sortedreclaimlist[counter+1] = reclaimlist[1]
				counter = counter + 1
				
				lastpos = reclaimlist[1].Position
				
				LOUDREMOVE( reclaimlist, 1 )

				LOUDSORT( reclaimlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], lastpos[1],lastpos[3]) < VDist2Sq(b.Position[1],b.Position[3], lastpos[1],lastpos[3]) end)
			end
			
			for _,v in sortedreclaimlist do
				v.ID.BeingReclaimed = true
				IssueReclaim( units, v.ID )
			end
            
            repeat
                WaitTicks(40)

                if not PlatoonExists(aiBrain, self) then
                    return
                end

                allIdle = true

                for _,v in units do
                    if not v.Dead and not IsIdleState(v) then
                        allIdle = false
                        break
                    end
                end
                
            until allIdle
			
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
    end,

    EngineerReclaimAI = function( self, aiBrain )

        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists
        local VDist2Sq = VDist2Sq
        local WaitTicks = WaitTicks
	
        self:Stop()

		local reclaimtime = self.PlatoonData.ReclaimTime or 60
		local reclaimtype = self.PlatoonData.ReclaimType or 'Mass'
        local reclaimrange = self.PlatoonData.ReclaimRange or aiBrain.BuilderManagers[self.BuilderLocation].EngineerManager.Radius

        local timeAlive = 0
		local stuckCount = 0

        local closest, closeDist, energycount, ents, entType, masscount, num, oldClosest, reclaimables, recPos,  rectable, recType, tempdist, unitPos
		
		if not aiBrain.BadReclaimables then
			aiBrain.BadReclaimables = {}
		end
        
		local eng = GetPlatoonUnits(self)[1]
		
        while PlatoonExists(aiBrain,self) do
		
			-- this gives us all the reclaimables in a rectangle
            ents = AIGetReclaimablesAroundLocation( aiBrain, self.BuilderLocation, reclaimrange )
			
            if not ents[1] then
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
            end
			
			reclaimables = { Mass = {}, Energy = {} }

			rectable = false

			masscount = 0
			energycount = 0
			
            for _,v in ents do
			
				if not aiBrain.BadReclaimables[v] then
			
					if v.MassReclaim and v.MassReclaim > 0 then

						masscount = masscount + 1					
						reclaimables.Mass[masscount] = v
                        
						rectable = true
					end
					
					if v.EnergyReclaim and v.EnergyReclaim > 0 then

						energycount = energycount + 1					
						reclaimables.Energy[energycount] = v
                        
						rectable = true
					end
				end
				
            end
            
			if not rectable then
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
			
            unitPos = GetPlatoonPosition(self)
            recPos = nil
            
            closest = false

			for num, recType in reclaimables do
            
				if num == reclaimtype then
                
					for _,v in recType do
                    
						recPos = v:GetCachePosition()
					
						if recPos and unitPos then
                        
							tempDist = VDist2Sq( unitPos[1],unitPos[3], recPos[1],recPos[3] )
						
							if ( ( not closest or tempDist < closeDist ) and ( not oldClosest or closest != oldClosest ) ) then
								closest = v
								entType = num
								closeDist = tempDist
							end
						end
					end
				end
				
                if closest then
                    break
				end
			end
			
			if timeAlive >= reclaimtime then
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
            end
			
            if closest then

				if closest == oldClosest then
					stuckCount = stuckCount + 1
				else
					stuckCount = 0
				end
				
                oldClosest = closest
				
                IssueClearCommands(self)
				
				IssueReclaim( GetPlatoonUnits(self), closest )
				
				local allIdle = false
				
				if stuckCount > 5 then
				
					stuckCount = 0

					aiBrain.BadReclaimables[closest] = true
					
					if aiBrain.BadReclaimables[closest] then
					
						closest:Destroy()
						aiBrain.BadReclaimables[closest] = nil
						
					end
					
					WaitTicks(6)
				end
				
                repeat
				
                    WaitTicks(6)
                    timeAlive = timeAlive + .5
					
					if (not IsUnitState(eng,'Reclaiming')) and not IsUnitState(eng,'Moving') then
					
						allIdle = true
						
					end
					
                until allIdle or timeAlive >= reclaimtime
				
            else

				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
        end
    end,

	EngineerRepairAI = function( self, aiBrain )

		local eng = GetPlatoonUnits(self)[1]
        
		local IsIdleState = IsIdleState        
        local WaitTicks = WaitTicks
        
        local Structures = GetOwnUnitsAroundPoint( aiBrain, categories.STRUCTURE, aiBrain.BuilderManagers[self.BuilderLocation].Position, 80 )
		
        local allIdle = false
		local unitbeingrepaired = false
		
        local units = GetPlatoonUnits(self)
        
        for _,v in Structures do
            if (not v.Dead) and v:GetHealthPercent() < .8 and (not v.BeingReclaimed) then
                self:Stop()
                IssueRepair( units, v )
				unitbeingrepaired = v
				break
            end
        end
		
		local count = 0
		
		-- continue repair until fixed, dead or 60 seconds elapsed
        while unitbeingrepaired and (not allIdle) and (not BeenDestroyed(unitbeingrepaired)) and unitbeingrepaired:GetHealthPercent() < .98  do
		
            WaitTicks(30)
            
            if not PlatoonExists(aiBrain, self) then
				return
            end
            
            count = count + 1
            
			if IsIdleState(eng) or count >20 then
                allIdle = true
            end
        end
		
		self:Stop()
        IssueClearCommands(self)
        
        return self:SetAIPlan('ReturnToBaseAI',aiBrain)
    end,
	
	EngineerUnfinishedAI = function( self, aiBrain )
 
		local beingBuilt = false
		
		local eng = self:GetPlatoonUnits()[1]

		eng.AssistPlatoon = self
		
		-- go out and find an unfinished unit and assist it
        ForkThread( UnfinishedBody, self, eng, aiBrain )
		
		WaitTicks(30)	-- give time to search for unfinished units
		
		if eng.UnitBeingBuilt then
		
			beingBuilt = eng.UnitBeingBuilt

			repeat
				WaitTicks(50)
			until eng.Dead or (not eng.AssistPlatoon) or GetFractionComplete(beingBuilt) == 1 or BeenDestroyed(beingBuilt)
		end
        
        if not eng.Dead then
		
			self:Stop()
			IssueClearCommands(self)

			eng.AssistPlatoon = nil
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		end
    end,
    
    EngineerAssistAI = function( self, aiBrain )
		
		local eng = false

        -- isolate the engineer in the platoon
		for _,v in GetPlatoonUnits(self) do
		
			if not v.Dead and LOUDENTITY( ENGINEERS, v) then
			
				eng = v
				break
			end
		end
		
		if eng then
		
			local GetEconomyStored  = GetEconomyStored
			local IsIdleState       = IsIdleState
            
            local WaitTicks = WaitTicks
			
			-- we have an assist platoon store it on the engineer
			eng.AssistPlatoon = self
		
			-- go out and find an assist target and and guard it
			self:ForkThread( AssistBody, eng, aiBrain)
		
			local assisttime = self.PlatoonData.Assist.Time or 90
            
            -- now we can take assist eco limits from the platoon data
            -- this allows the assist operation to start at one level, and continue
            -- until we reach these levels, thus giving a little extra assist 'oomph' to this task
            -- I currently use it in the Assist Energy builders, and in the ACU assist builders for M & E
            local assistenergy  = self.PlatoonData.Assist.AssistEnergy or 1250
            local assistmass    = self.PlatoonData.Assist.AssistMass or 250
		
            -- continue to guard until eco runs short, eng death, timer runs out, or eng loses guard
			repeat
		
                -- break-off if either mass or energy storage drops below the trigger point
				if (GetEconomyStored(aiBrain,'MASS') < assistmass or GetEconomyStored(aiBrain,'ENERGY') < assistenergy ) then
					break
				end

				assisttime = assisttime - 4

                if assisttime >= 1 then
                    WaitTicks(31)
                end
			
			until assisttime < 1 or eng.Dead or (not eng.AssistPlatoon) or IsIdleState(eng)
			
		end
		
		if not eng.Dead then

            self:Stop()
			
            IssueClearCommands(self)
			
            eng.AssistPlatoon = nil
			
            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		end
		
    end,

    -- a single-unit platoon made up of an engineer, this AI will determine
    -- what needs to be built and then issue the build commands to the engineer
    EngineerBuildAI = function( self, aiBrain )
    
        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." enters EBAI")
    
        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists
        
        local LOUDDEEPCOPY = LOUDDEEPCOPY
        local LOUDENTITY = LOUDENTITY
        local LOUDGETN = LOUDGETN
		
        local eng = false

        for _, v in GetPlatoonUnits(self) do
		
            if not v.Dead and LOUDENTITY( ENGINEERS, v ) then
			
                if not eng then
                    IssueClearCommands( {v} )
                    eng = v
					break
                end
            end
        end

        local cons = self.PlatoonData.Construction
        local BuildStructures = cons.BuildStructures or nil
        local FactionName = aiBrain.FactionName

        if not eng or eng.Dead or not BuildStructures then
		
			if not eng or eng.Dead then
				return
			end
			
			if not BuildStructures then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." exits EBAI - no structures")
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
        end

        local factionIndex = cons.FactionIndex or aiBrain.FactionIndex
		
		-- the faction based subset of the buildingtemplates -- equates a structure name to a specific unitID for this faction
        local buildingTmpl = import(cons.BuildingTemplateFile or '/lua/buildingtemplates.lua')[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]		
		
		-- a reference file of potential building layouts
        local baseTmplFile = import(cons.BaseTemplateFile or '/lua/basetemplates.lua')
		
		-- the specific reference within the basetemplates file that contains the relative positions for specific groups of structures
		-- this is what allows you to have faction specific building layouts with unique facility names
		-- we'll take a copy of this table so that we can modify it for rotations without altering the source
        local baseTmpl = LOUDDEEPCOPY( baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex] )

		eng.EngineerBuildQueue = {} 	-- clear the engineers build queue		

        local reference = false
		local refName = false
		local orient = false
        local relative = false
		local rotation = false
		local startpos = false
		local baselineref = false

        local BasePerimeterOrientation = cons.BasePerimeterOrientation or 'FRONT'
        local addrotations = cons.AddRotations or 0
		local buildpoint = cons.BasePerimeterSelection or false	-- true, false, or a specific number (0-12) depending upon Orientation (FRONT,REAR,ALL)
		local iterations = cons.Iterations or false

        local NearMarkerType = cons.NearMarkerType or nil
        local Radius = cons.Radius or 1
		
        local buildFunction = false

        local baseTmplList = {}
		local counter = 0
		
		local function RotateBuildLayout()
		
			if orient then
			
				-- standard orientation is always South
				rotation = 0 + addrotations
				baselineref = reference[1][1] -- store the vertical position line
			
				if orient == 'W' then
				
					rotation = 1 + addrotations
					baselineref = reference[1][3] -- store the horizontal position line
					
				elseif orient == "N" then
				
					rotation = 2 + addrotations
					baselineref = reference[1][1] -- store the vertical line
					
				elseif orient == "E" then
				
					rotation = 3 + addrotations
					baselineref = reference[1][3]	-- store the horizontal line
					
				end
				
			end

			local repeatbuilds = 0
            local layout, rotatefactor

			for k,v in reference do
			
				if not buildpoint or buildpoint == k then

					layout = LOUDDEEPCOPY(baseTmpl)

					if rotation then
					
						rotatefactor = rotation
	
						if k > 3  and k < 10 then

							if orient == 'E' and v[3] < baselineref or
                                orient == 'N' and v[1] < baselineref or
								orient == 'W' and v[3] > baselineref or
								orient == 'S' and v[1] > baselineref then
						
								rotatefactor = rotation + 3
							else
								rotatefactor = rotation + 1
							end
						
						elseif k > 9 then
						
							rotatefactor = rotation + 2
						end
					
						if rotatefactor > 3 then
						
							rotatefactor = rotatefactor - 4
						end
					
						-- loop thru each building in the template - each building(s) is accompanied by a table of possible positions
						for _,building in layout do
						
							if rotatefactor > 0 then
							
								for r = 2, LOUDGETN(building) do
								
									for s = 1, rotatefactor do
									
										local x = building[r][1]
										local y = building[r][2]
								
										building[r][1] = 0 - y
										building[r][2] = x
									end
								end
							end
						end
						
					end

					counter = counter + 1
					baseTmplList[counter] = AIBuildBaseTemplateFromLocation( layout, v )

					repeatbuilds = repeatbuilds + 1
				end

			end
			
			return
		end

		-- used by anything that needs a rotation as well
		if cons.NearBasePerimeterPoints then
			
			-- this reference passes along the NAME of the location -- this should trigger the function to record the ORIENT value on the manager
			-- the other places where this function is called are used when building a NEW base so the orient value is not available 
            reference, orient, buildpoint = GetBasePerimeterPoints(aiBrain, self.BuilderLocation, Radius, BasePerimeterOrientation, cons.BasePerimeterSelection or false)

			RotateBuildLayout()
			
			-- use BuildBaseTemplateOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildBaseTemplateOrdered
		end
		
		if cons.ExpansionBase then
			
			if NearMarkerType == 'Naval Area' then
			
				-- Naval Base
				startpos, refName = AIFindNavalAreaForExpansion( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType )
				
			elseif NearMarkerType == 'Defensive Point' then
			
				-- Defensive Points with ExpansionBase == true
				startpos, refName = AIFindDefensivePointForDP( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType, false )

			elseif NearMarkerType == 'Naval Defensive Point' then	
			
				startpos, refName = AIFindNavalDefensivePointNeedsStructure( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType )			
				
			else
				
				if cons.CountedBase == false then
					
					startpos, refName = AIFindBaseAreaForDP( aiBrain, self.BuilderLocation, (cons.LocationRadius or 2000), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType, false )
					
				else
				
					-- Land Base - finds both Starts and Large Expansion areas
					startpos, refName = AIFindBaseAreaForExpansion( aiBrain, self.BuilderLocation, (cons.LocationRadius or 2000), cons.ExpansionRadius, cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType, false )
				end
			end

			-- didn't find a location to build at
			if not startpos then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." No location found for new base!")
				
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
            end
			
			for _,v in eng:GetGuards() do

				if not v.Dead and v.PlatoonHandle then
					v.PlatoonHandle:ReturnToBaseAI(aiBrain)
				end
			end
			
			reference, orient, buildpoint = GetBasePerimeterPoints(aiBrain, startpos, Radius, BasePerimeterOrientation, false)

			RotateBuildLayout()

            buildFunction = AIBuildBaseTemplateOrdered
		end
		
		if cons.DefensivePoint then
			
			local startpos, refName
			
			if NearMarkerType == 'Defensive Point' then
            
                --  this will actually locate Defensive Points and 'small' Expansion Base markers --
				startpos, refName = AIFindDefensivePointNeedsStructure( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 5), (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )
			
			elseif NearMarkerType == 'Start Location' then
			
				startpos, refName = AIFindStartPointNeedsStructure( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 5), (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )										

			elseif NearMarkerType == 'Expansion Area' then
			
				startpos, refName = AIFindBasePointNeedsStructure( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 5), (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )						

			elseif NearMarkerType == 'Naval Defensive Point' then	
			
				startpos, refName = AIFindNavalDefensivePointNeedsStructure( aiBrain, self.BuilderLocation, (cons.LocationRadius or 100), cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 5), (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )			
			
			end
			
			if not startpos then
			
				LOG("*AI DEBUG No "..NearMarkerType.." reference found")
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				
			end
			
			reference, orient, buildpoint = GetBasePerimeterPoints(aiBrain, startpos, Radius, BasePerimeterOrientation, false)

			if orient then
			
				-- assume that standard orientation is always S
				rotation = 0 + addrotations
				baselineref = reference[1][1] -- store the vertical position line
			
				if orient == 'W' then
				
					rotation = 1 + addrotations
					baselineref = reference[1][3] -- store the horizontal position line
					
				elseif orient == "N" then
				
					rotation = 2 + addrotations
					baselineref = reference[1][1] -- store the vertical line
					
				elseif orient == "E" then
				
					rotation = 3 + addrotations
					baselineref = reference[1][3]	-- store the horizontal line
					
				end
				
			end

			local repeatbuilds = 0
            local layout, rotatefactor

		    for k,v in reference do
			
				if not buildpoint or buildpoint == k then
				
					-- get a copy of the potential build locations
					layout = LOUDDEEPCOPY(baseTmpl)
					
					-- the rotation flag tells us we might have some rotation to do
					if rotation then
					
						rotatefactor = rotation
					
						-- this should rotate the side positions by an additional 1

						-- 1 to 3 will be front positions -- while 4 to 9 would be sides and 10 to 12 would be rear
						-- coming into this function we'll either have 1 (specific point no rotation required)
						-- 9 positions (FRONT) -- 12 positions (nil or ALL)	-- or 3 positions (REAR)
	
						-- rotation for side positions
						if k > 3 and k < 10 then
							-- this is where we'd have to determine which side the reference is on
							-- and its relation to the base orientation (baselineref)
						
							-- so if E and the y value is less than the baseline y value
							-- or if N and the x value is less than the baseline x value
							-- or if W and the y value is greater than the baseline y value
							-- or if S and the x value is greater than the baseline x value
							if orient == 'E' and v[3] < baselineref or
								orient == 'N' and v[1] < baselineref or
								orient == 'W' and v[3] > baselineref or
								orient == 'S' and v[1] > baselineref then
						
								rotatefactor = rotation + 3
							else
								-- otherwise
								rotatefactor = rotation + 1
							end
						
						-- rotation for rear
						elseif k > 9 then
							rotatefactor = rotation + 2
						end
					
						-- cycle the rotatefactor around if over 3
						if rotatefactor > 3 then
							rotatefactor = rotatefactor - 4
						end
					
						-- loop thru each building in the template - each building(s) is accompanied by a table of possible positions
						for _,building in layout do
							-- if there is a rotation to do
							if rotatefactor > 0 then
								--LOG("*AI DEBUG Doing a rotation of "..rotatefactor.." for building "..repr(building).." to layout "..repr(layout))
								-- loop thru all the position entries for this building
								for r = 2, LOUDGETN(building) do
						
									-- and do the rotation
									for s = 1, rotatefactor do
										local x = building[r][1]
										local y = building[r][2]
								
										building[r][1] = 0 - y
										building[r][2] = x
									end
								end
							end
						end
					end			

					counter = counter + 1
					baseTmplList[counter] = AIBuildBaseTemplateFromLocation( layout, v )

					repeatbuilds = repeatbuilds + 1
				end
				
				if (iterations and repeatbuilds == iterations) or (not iterations and repeatbuilds == 1) then
					break
				end
			end
			
			buildFunction = AIBuildBaseTemplateOrdered  
		end
		
		if cons.AdjacencyCategory then

			local pos = aiBrain.BuilderManagers[eng.LocationType].Position
			
			if not pos then
				LOG("*AI DEBUG No position found for Adjacency category ")
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

			reference = GetOwnUnitsAroundPointWithThreatCheck( aiBrain, cons.AdjacencyCategory, pos, cons.AdjacencyDistance or 50, cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)

			buildFunction = AIBuildAdjacency
			LOUDINSERT( baseTmplList, baseTmpl )
		end
		
		--  Everything else (like MEX)
		if not buildFunction then
        
			LOUDINSERT( baseTmplList, baseTmpl )
			relative = true	
			reference = true

			buildFunction = AIExecuteBuildStructure
		end

		-- OK ALL Setup Complete -- lets create a queue of things for the engy to build
		local did_a_build = false
        local replacement
		
		local builditem = buildingTmpl

		
        for _, baseListData in baseTmplList do
		
            for _,v in BuildStructures do
				
                if not eng.Dead then
				
					builditem = buildingTmpl

					replacement = false
					
					if ScenarioInfo.CustomUnits[v][FactionName] then
						replacement = GetTemplateReplacement( v, FactionName, ScenarioInfo.CustomUnits[v][FactionName])
					end
					
					if replacement then
						builditem = replacement
					end

					if buildFunction(aiBrain, eng, v, cons.BuildClose, relative, builditem, baseListData, reference, cons ) then
						did_a_build = true
					end
                    
                end
            end
        end
        
        if not eng.Dead then
		
			if did_a_build then

				if cons.ExpansionBase then
				
					local function MonitorNewBaseThread( self, refName, refposition, cons)

						aiBrain.BaseExpansionUnderway = true
	
						eng.NeedsBaseData = false
	
						-- this callback removes the ExpansionUnderway flag from the brain
						local deathFunction = function() aiBrain.BaseExpansionUnderway = false end
	
						-- it will get called if the platoon is destroyed
						self:AddDestroyCallback(deathFunction)
	
						-- loop here until the engineer signals that he's ready to start building
						while PlatoonExists(aiBrain, self) and not eng.Dead and not eng.NeedsBaseData do
							WaitTicks(15)
						end

						if not eng.Dead then
	
							if PlatoonExists( aiBrain, self ) then
								eng.NewExpansion = { refName, refposition, cons }
							end
		
							eng.NewBaseThread = nil
						end				
					
					end

					-- we fork a thread (on the platoon) to carry the new base information and pass along when called for
					eng.NewBaseThread = self:ForkThread( MonitorNewBaseThread, refName, LOUDCOPY(reference[1]), cons )
			
					eng.NewExpansion = { refName, {reference[1][1],reference[1][2],reference[1][3]}, cons}

					self.LocationType = refName
				end

			else
            
                --LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..self.BuilderInstance.." could not find a location for "..repr(builditem) )

				eng.EngineerBuildQueue = {}

				eng.failedbuilds = eng.failedbuilds + 1
				
				self.CreationTime = LOUDTIME()
				
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end
			
			self:ProcessBuildCommand(eng,false)

        end
	end,
	
    EngineerBuildMassDefenseAdjacencyAI = function( self, aiBrain )
    
		local VDist2Sq = VDist2Sq    
        
        local eng
		
		for _,v in GetPlatoonUnits(self) do
		
			if not v.Dead and LOUDENTITY( ENGINEERS, v ) then
			
				if not eng then
				
					eng = v
					
				else
				
					IssueClearCommands( {v} )
					IssueGuard({v}, eng)
					
				end
				
			end
			
		end

		if not eng or eng.Dead then
		
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
		end

		local homepos = aiBrain.BuilderManagers[self.BuilderLocation].Position
		
        local cons = self.PlatoonData.Construction
        local factionIndex = cons.FactionIndex or aiBrain.FactionIndex 

        local buildingTmpl = import(cons.BuildingTemplateFile or '/lua/buildingtemplates.lua')[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        local baseTmpl = import(cons.BaseTemplateFile or '/lua/basetemplates.lua')[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]		

		local closeToBuilder, relative, distance, mexposition
		local position, reference, referencefound
        
		eng.EngineerBuildQueue = {} 	-- clear the engineers build queue 
		
        if PlatoonExists(aiBrain, self) then
            
            if UnitCapCheckGreater( aiBrain, .75 ) then
			
				LOG("*AI DEBUG MassAdjacencyDefenseAI near unit cap")
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				
            end
            
            -- get all T2/T3 mexs within radius of home            
            local Mexs = GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION - categories.TECH1, homepos, cons.Radius)
            
            if not Mexs or eng.Dead then
			
				LOG("*AI DEBUG MassAdjacencyDefenseAI finds no mexs")
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				
            end

            -- sort mexes by distance from the engineer --            
            position = GetPlatoonPosition(self)
			
            LOUDSORT( Mexs, function(a,b) local GetPosition = GetPosition local VDist2Sq = VDist2Sq return VDist2Sq( GetPosition(a)[1], GetPosition(a)[3], position[1],position[3]) < VDist2Sq( GetPosition(b)[1], GetPosition(b)[3], position[1],position[3]) end )
            
            reference = {}            
            referencefound = false
		
            for _,v in Mexs do
			
                mexposition = LOUDCOPY( GetPosition(v))
                
                distance = VDist2Sq( homepos[1],homepos[3], mexposition[1],mexposition[3])
                
                -- check number of storage units
                if distance >= (cons.MinRadius*cons.MinRadius) then
				
					local STORS = GetOwnUnitsAroundPoint(aiBrain, categories.MASSSTORAGE, mexposition, 5)
                    
                    if ScenarioInfo.LOUD_IS_Installed then
                        cons.MinStructureUnits = 0
                    end
                    
                    -- if storage check number of defense units
                    if LOUDGETN(STORS) >= cons.MinStructureUnits then
					
                        local DEFS = GetUnitsAroundPoint( aiBrain, cons.MaxDefenseCategories, mexposition, 20, 'Ally')
			
                        -- all passed - its a valid location
                        if LOUDGETN(DEFS) < cons.MaxDefenseStructures then
						
                            LOUDINSERT(reference, mexposition)
                            referencefound = true
                            break
							
                        end
						
                    end
					
                end
				
            end

            -- no valid locations or dead
            if not referencefound or eng.Dead then
			
				--LOG("*AI DEBUG MassAdjacencyDefenseAI finds no reference")
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
				
            end
		
            local baseTmplList = {}
        
            for _,v in reference do
			
                LOUDINSERT( baseTmplList, AIBuildBaseTemplateFromLocation( baseTmpl, v ) )
				
            end

            local buildFunction = AIBuildBaseTemplateOrdered
			
			local builtsomething = false

            for _, baseListData in baseTmplList do
			
                for _, v in cons.BuildStructures do
				
                    if not eng.Dead then
					
                        if ScenarioInfo.CustomUnits[v][aiBrain.FactionName] then
						
                            local replacement = GetTemplateReplacement( v, aiBrain.FactionName, ScenarioInfo.CustomUnits[v][aiBrain.FactionName] )
							
                            if replacement then
							
                                builtsomething = buildFunction(aiBrain, eng, v, closeToBuilder, relative, replacement, baseListData, reference, cons )
								
                            else
							
                                builtsomething = buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons )
								
                            end
							
                        else
						
                            builtsomething = buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons )
							
                        end

                    end
					
                end
				
            end
        
            if not eng.Dead then
			
                local count = 0
				
                while IsUnitState(eng,'Attached' ) and count < 15 do
				
                    WaitTicks(60)
                    count = count + 1
					
                end

				if not eng.Dead and builtsomething then
			
					self:ProcessBuildCommand(eng,false)
				
					return
				
				end
			
            end
			
		end
		
		return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		
    end,
	
    EngineerBuildMassAdjacencyAI = function( self, aiBrain )
        
		local homepos = aiBrain.BuilderManagers[self.BuilderLocation].Position
        
        local cons = self.PlatoonData.Construction
		
        local factionIndex = cons.FactionIndex or aiBrain.FactionIndex
		
        local buildingTmpl = import(cons.BuildingTemplateFile or '/lua/buildingtemplates.lua')[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        local baseTmpl = import(cons.BaseTemplateFile or '/lua/basetemplates.lua')[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]
        
        local adjacencytest = cons.AdjacencyStructure or categories.MASSSTORAGE

        local eng
        local platoonUnits = GetPlatoonUnits(self)
        
		for _, v in platoonUnits do
			if not v.Dead and LOUDENTITY( ENGINEERS, v ) then
				if not eng then
					eng = v
				else
					IssueClearCommands( {v} )
					IssueGuard({v}, eng)
				end
			end
		end
		
		if not eng or eng.Dead then
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
		end


		local closeToBuilder
		local relative
		local distance
        
		eng.EngineerBuildQueue = {} 	-- clear the engineers build queue 		
        
        if PlatoonExists(aiBrain, self) then
		
            local reference = {}
            
			local baseTmplList = {}
			local counter = 0
            
            -- get all T2/T3 mexs within radius of home
            local Mexs = GetOwnUnitsAroundPoint(aiBrain, categories.MASSEXTRACTION - categories.TECH1, homepos, cons.Radius)
            
            if not Mexs or eng.Dead then
				LOG("*AI DEBUG "..aiBrain.Nickname.." MassAdjacencyAI No Mexs found")
                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
            end

            -- sort mexes by distance from the engineer --            
            local position = GetPlatoonPosition(self)
			
            LOUDSORT( Mexs, function(a,b) local GetPosition = GetPosition local VDist3 = VDist3 return VDist3( GetPosition(a), position) < VDist3( GetPosition(b), position) end )
            
            for _,v in Mexs do
            
                local mexposition = LOUDCOPY( GetPosition(v))
                
                distance = VDist3( mexposition, homepos )
                
                if distance >= cons.MinRadius and distance <= cons.Radius then
                
                    -- get the number of structure units around there
                    local STORS = GetOwnUnitsAroundPoint(aiBrain, adjacencytest, mexposition, 5)
                    
                    if LOUDGETN(STORS) < cons.MinStructureUnits then
                    
						counter = counter + 1
                        reference[counter] = mexposition
                        break
                        
                    end
                end
            end

            if counter < 1 or eng.Dead then

                return self:SetAIPlan('ReturnToBaseAI',aiBrain)
                
            end
		
            baseTmplList = {}
			counter = 0
            
            -- create a table of all possible build locations for all building types in this template
            -- utilizing the position and the offset values provided by the base template (baseTmpl)
            for _,v in reference do

				counter = counter + 1
                baseTmplList[counter] = AIBuildBaseTemplateFromLocation( baseTmpl, v )

            end

            local buildFunction = AIBuildBaseTemplateOrdered
			
            -- process the list of structures requested by the platoon data
			local builtsomething = false
            
            for _,baseListData in baseTmplList do
			
                for _,v in cons.BuildStructures do
				
                    if not eng.Dead then
                        builtsomething = buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons )
                    end

                end
            end
        
            if not eng.Dead then
            
                local count = 0
                
                while IsUnitState(eng,'Attached' ) and count < 10 do
                    WaitTicks(60)
                    count = count + 1
                end
                
            end

            if not eng.Dead and builtsomething then
                self:ProcessBuildCommand( eng, false )
				return
            end
			
        end
		
		return self:SetAIPlan('ReturnToBaseAI',aiBrain)
	end,

    -- Runs once all build orders are submitted to the engineers queue
	-- Processes the first entry in the queue and the runs this again using the removeLastBuild flag
	-- which will remove the previous item from the queue
	-- when the queue is empty the engy will either RTB or repeat his plan (loopbuilders)

    ProcessBuildCommand = function( self, eng, removeLastBuild )
	
		if eng.Dead or not self then return end

		local aiBrain = GetAIBrain(eng)

        local EngineerDialog = ScenarioInfo.EngineerDialog or false

        if EngineerDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." enters ProcessBuildCommand" )
        end
        
        local LOUDCOPY      = LOUDCOPY
        local LOUDEQUAL     = LOUDEQUAL
        local LOUDREMOVE    = LOUDREMOVE
        
        local GetEconomyStored      = GetEconomyStored
        local GetEconomyStoredRatio = GetEconomyStoredRatio

		-- remove first item from the build queue
        if removeLastBuild and eng.EngineerBuildQueue[1] then
        
            local FOG = LOUDREMOVE(eng.EngineerBuildQueue, 1)

            if EngineerDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." removes queue item "..repr(FOG).." lastbuild was "..repr(eng.lastbuild) )
            end
            
            if eng.lastbuild and ( FOG[1] == eng.lastbuild[1] and LOUDEQUAL(FOG[2],eng.lastbuild[2]) ) then

                --WARN("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." trying to build same thing "..repr(FOG) )

                if self.PlatoonData.Construction.LoopBuild then
                
                    self.PlatoonData.Construction.LoopBuild = false
                    
                    eng.failedbuilds = eng.failedbuilds + 1
                    
                    eng.EngineerBuildQueue = {}
                end
            end
        
            -- record the last item we tried to build
            eng.lastbuild = LOUDCOPY(FOG)
            FOG = nil
        end

        if eng.NotBuildingThread then
            KillThread(eng.NotBuildingThread)
			eng.NotBuildingThread = false
        end
		
		if self.WaypointCallback then

			KillThread(self.WaypointCallback)
			self.WaypointCallback = false
		end

        eng.IssuedBuildCommand = false
		eng.IssuedReclaimCommand = false
		
        IssueClearCommands({eng})
        
        local STRUCTURES = categories.STRUCTURE
        local OTHERSTUFF = categories.STRUCTURE + ( categories.MOBILE * categories.LAND ) - ENGINEERS

		-- THE MAINLINE CODE --- issue a build order if the engineer has items in queue
        if (not eng.Fighting) and (eng.EngineerBuildQueue[1]) then
        
            local LOUDMAX = LOUDMAX
            local LOUDMIN = LOUDMIN
			local LOUDMOD = LOUDMOD
            
            local BeenDestroyed = BeenDestroyed
			local CanBuildStructureAt = CanBuildStructureAt
            local GetUnitsAroundPoint = GetUnitsAroundPoint
            local GetPosition = GetPosition
            local PlatoonExists = PlatoonExists
			local WaitTicks = WaitTicks
            local VDist2 = VDist2
            local VDist3 = VDist3

            -- engineer is using aggressive move order
            local aggromove = self.PlatoonData.Construction.AggressiveMove or false
            -- this table stores the location of any reclaimable item that seems unreclaimable (ie.- out of reach)
            local BadReclaimables = aiBrain.BadReclaimables
			-- this allows me to specify acceptable threat levels in the engineer task or have it based on the SurfaceThreatLevel
			local mythreat = self.PlatoonData.Construction.ThreatMax or (__blueprints[eng.BlueprintID].Defense.SurfaceThreatLevel + 10)
			-- the viewrange of the engineer
			local viewrange = LOUDMIN(LOUDMAX(10,eng:GetIntelRadius('Vision')), 70) -- between 10 and 70 -- but never 0
            -- the buildrange of the engineer
            local buildrange = LOUDMAX(__blueprints[eng.BlueprintID].Economy.MaxBuildDistance, 10)
            
            local LocationType = eng.LocationType
 
            local ProcessBuildCommand               = self.ProcessBuildCommand
            local SetupPlatoonAtWaypointCallbacks   = self.SetupPlatoonAtWaypointCallbacks
            
            local basetaken, count, distance, enemythreat, EnergyReclaim, engPos, engLastPos, MassReclaim, path, prevpoint, reason, reclaims

			local buildItem = eng.EngineerBuildQueue[1][1]
			local buildLocation = eng.EngineerBuildQueue[1][2]
            local buildPosition = {buildLocation[1], 0, buildLocation[2]}

			-- LOCAL FUNCTIONS FOR PBC --
			
			-- Used to watch an eng after he's ordered to build/reclaim/capture - when idle eng is resent to PBC
			local function WatchForNotBuilding()
            
                local BeenDestroyed = BeenDestroyed
                local GetPosition = GetPosition
				local GetWorkProgress = moho.unit_methods.GetWorkProgress
                local IsIdleState = IsIdleState
				local IsUnitState = IsUnitState
                local LOUDCOPY = LOUDCOPY
                local WaitTicks = WaitTicks
	
				engPos = GetPosition(eng) or false
				engLastPos = false
				
                count = 0

				WaitTicks(4)
		
				while eng and (not eng.Dead) and (not IsIdleState(eng)) and not eng.Fighting do	
		
					WaitTicks(20)
			
					if (not BeenDestroyed(eng)) and (not eng.Dead) and engLastPos then
					
						if (not IsUnitState( eng, "Capturing" )) and (not IsUnitState( eng, "Reclaiming" ))
							and (not IsUnitState( eng, "Repairing" )) and (not IsUnitState( eng, "Moving" ))
							and (not IsUnitState( eng, "Building" )) and GetWorkProgress(eng) == 0
							and VDist3( engLastPos, engPos ) < 1
							then
				
							engPos = GetPosition(eng) or false
						
							if count > 10 and not eng.Dead then
						
								LOG("*AI DEBUG Eng "..eng.EntityID.." "..eng.PlatoonHandle.BuilderName.." Stuck in WatchForNotBuilding")
								
								ProcessBuildCommand( self, eng, false )
							
								return
							else
								count = count + 1
							end
						end
					else
						count = 0
					end
                    
                    if IsIdleState(eng) then
                        eng.failedmoves = eng.failedmoves + 1
                    end
			
					engLastPos = LOUDCOPY(engPos)
				end
				
				if (not BeenDestroyed(eng)) and (not eng.Dead) and ( IsIdleState(eng) or eng.Fighting ) then
					
					-- we didn't issue a build or we did a reclaim then just run PBC as is --
					if eng.IssuedReclaimCommand then
						
						ProcessBuildCommand( self, eng, false )
						return
				
					-- we had issued a build/repair order -- remove it and then PBC --
					elseif eng.IssuedBuildCommand then
						
						ProcessBuildCommand( self, eng, true )
						return
                    end
				end
				
				if (not BeenDestroyed(eng)) and not eng.Dead then
				
					WARN("*AI DEBUG Eng "..repr(eng.EntityID).." exits WFNB from ????? - dead is "..repr(eng.Dead))
				end
				
			end

			local function EngineerThreatened()
                
                enemythreat = GetThreatAtPosition( aiBrain, buildPosition, 0, true, 'AntiSurface') 
                
                if ScenarioInfo.EngineerDialog then
                    if enemythreat > mythreat then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." threat at "..repr(buildPosition).." is "..enemythreat.." my threatmax is "..mythreat)
                    end
                end
			
				return mythreat <= enemythreat
			end		

			local function EngineerTryReclaimCaptureArea( test )
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." trys reclaiming - test is "..repr(test).." for buildPosition "..repr(buildPosition) )
                end

				buildPosition[2] = GetTerrainHeight(buildLocation[1],buildLocation[2])
	
				eng.IssuedReclaimCommand = false
                
                local GetPosition = GetPosition
                local GetUnitsAroundPoint = GetUnitsAroundPoint
                local IssueReclaim = IssueReclaim
    
				-- Check if enemy units are at location -- if so reclaim one 
				for _,v in { ENGINEERS - categories.COMMAND, OTHERSTUFF } do

					for _,unit in GetUnitsAroundPoint( aiBrain, v, buildPosition, 10, 'Enemy' ) do
					
						if not unit.Dead then

							if not eng.Dead then
							
								if not test then
							
									IssueReclaim( {eng}, unit )
								end
								
								eng.IssuedReclaimCommand = true
                
                                if EngineerDialog and not test then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." orders reclaim of units "..repr(buildPosition) )
                                end

								break
							end
						end
					end
				end
				
				if (not eng.Dead) and (not eng.IssuedReclaimCommand) then
				
					-- check reclaimables - note - unlike units we issue reclaims to all and then return to PBC to continue with the build order
					reclaims = AIGetReclaimablesAroundLocation( aiBrain, LocationType, 2, buildPosition ) or {}
					
					if reclaims[1] then
                    
                        engPos = eng:GetPosition()

						-- sort for closest to engineer -- 
						LOUDSORT(reclaims, function(a,b) local GetPosition = GetPosition local VDist3 = VDist3 return VDist3( engPos, a:GetPosition() ) < VDist3( engPos, b:GetPosition() ) end )

						for _,v in reclaims do
                        
                            MassReclaim = v.MassReclaim or 0
                            EnergyReclaim = v.EnergyReclaim or 0

							-- just a note - the v.MassReclaim and v.EnergyReclaim insure we dont reclaim valid structures (which wont have those values)
							if (MassReclaim > 0 or EnergyReclaim > 0) and (not BadReclaimables[v]) then
						
								if not eng.Dead then
									if not test then
										IssueReclaim( {eng}, v )
									end
								
									eng.IssuedReclaimCommand = true
                
                                    if EngineerDialog and not test then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." orders reclaim of props "..repr(buildPosition) )
                                    end

								end
							end
						end
					end
				end
				
				-- all tests will return to the call BUT
				-- anytime we actually reclaim, we terminate since WFNB will
				-- restart the PBC and carry on with the build
				if eng.IssuedReclaimCommand then
				
					if test then
						return not eng.Dead
					end

					-- if we actually issued the reclaim then we'll terminate
					-- WFNB will relaunch the PBC for us
					eng.NotBuildingThread = eng:ForkThread(WatchForNotBuilding)
				end
				
				if test then
					return eng.Dead
				end
			end

			local function EngineerTryRepair()

				for _,v in GetUnitsAroundPoint( aiBrain, STRUCTURES, buildPosition, 1, 'Ally' ) do
			
					if not v.Dead and GetFractionComplete(v) < 1 then
					
						IssueRepair( {eng}, v )

						eng.IssuedBuildCommand = true
						eng.IssuedReclaimCommand = false

						eng.NotBuildingThread = eng:ForkThread(WatchForNotBuilding)
					end
				end
				
				if not eng.IssuedBuildCommand then
					return false
				end
			end

			-- this is a bit different than the MovePlatoon function 
            -- do a reclaim move towards goal if there is more than 1 
            -- stage in the path except engineers that are starting a new base
			local function MoveEngineer( self, path )
            
                local LOUDCOPY = LOUDCOPY
                local prevpoint = { 0, 0, 0 }

				for wpidx, waypointPath in path do
                
                    -- use aggro move if allowed except on first move
                    if wpidx > 1 and aggromove then
                        self:AggressiveMoveToLocation( waypointPath )
                    else
                        self:MoveToLocation( waypointPath, false )
                    end

					prevpoint[1] = waypointPath[1]
                    prevpoint[2] = waypointPath[2]
                    prevpoint[3] = waypointPath[3]
				end
                
                if prevpoint[2] == 0 then
                    prevpoint[2] = GetSurfaceHeight(prevpoint[1],prevpoint[3])
                end
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." sets Waypoint to "..repr(prevpoint) )
                end
			
				self.WaypointCallback = SetupPlatoonAtWaypointCallbacks( self, prevpoint, viewrange )
			end

			local function EngineerMoveWithSafePath()
            
                local GetPosition = GetPosition
                
                engPos = GetPosition(eng)

				if eng:HasEnhancement( 'Teleporter' ) then

                    if VDist2( engPos[1],engPos[3], buildPosition[1],buildPosition[3] ) > 50 then

                        IssueTeleport( {eng}, RandomLocation( buildPosition[1],buildPosition[3], 12 ) )
					
                        WaitTicks(2)
                    
                        while not eng.Dead and eng.teleporting do
                            WaitTicks(3)
                        end
                    
                        if eng.teleported then
                            return not eng.Dead
                        end
                    end

                end

				distance = VDist2( engPos[1],engPos[3], buildPosition[1],buildPosition[3] )
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." distance from "..repr(engPos).." to "..repr(buildPosition).." is "..distance )
                end
                
				if distance < viewrange then
					return not eng.Dead
				end

				if distance <= 100 then
					self:ForkThread( MoveEngineer, {buildPosition} )
					return not eng.Dead
				end

				-- path to destination and use move thread
				if not eng.Dead then

					path, reason = self.PlatoonGenerateSafePathToLOUD( aiBrain, self, 'Amphibious', engPos, buildPosition, mythreat, 200 )

					if PlatoonExists(aiBrain,self) and (path and distance < 1200) and not eng.Dead then
                
                        if EngineerDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." forks to MoveEngineer with path "..repr(path) )
                        end

						self:ForkThread( MoveEngineer, path )
						
						WaitTicks(15)	-- to insure engy is underway --
						
						return not eng.Dead

					else
                    
                        if SendPlatoonWithTransportsLOUD( self, aiBrain, RandomLocation( buildPosition[1],buildPosition[3], 8 ), 2, false ) then
                            
                            if EngineerDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." says reason is "..repr(reason).." distance is "..repr(distance).." but found transport ")
                            end

                            return not eng.Dead
                        end

                        if EngineerDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." says reason is "..repr(reason).." distance is "..repr(distance).." returning false - mythreat is "..repr(mythreat))
                        end

						return false
					end
				end
			end

			local function EngineerBuildValid ()
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." checks if build valid" )
                end
			
				if CanBuildStructureAt( aiBrain, buildItem, buildPosition ) then
					return true
				end
			
				if EngineerTryReclaimCaptureArea( true ) then
					return true
				end
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." build is NOT valid at "..repr(buildPosition) )
                end
				
				return false
			end

			-- handles getting the engy safely to his build location and
			-- checking if the site is valid and safe along the way
			local function EngineerMoving()
 
                local LOUDENTITY = LOUDENTITY
                local LOUDMOD = LOUDMOD
                local VDist2 = VDist2
                local WaitTicks = WaitTicks
                
                local GetPosition = GetPosition

                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." moving to "..repr(buildPosition) )
                end
                
				if EngineerThreatened() then
				
					eng.failedmoves = 10	-- clear this order, but continue looping --
					
                    if EngineerDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." threatened")
                    end

					ForkTo( AIAddMustScoutArea, aiBrain, buildPosition )
					
					return false
				end
			
				if not EngineerMoveWithSafePath() then
				
					eng.failedmoves = 10	-- clear this orders --

                    if EngineerDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." cannot move with safe path")
                    end

					ForkTo( AIAddMustScoutArea, aiBrain, buildPosition )
					
					return false
				else
			
					count = 0  --  use this to keep the loop responsive to arrival but not check conditions every iteration

					-- loop in here if there is a movement thread
                    
					-- it will continue to check conditions and will call for transport every 12th cycle
					while (not eng.Dead) and eng.failedmoves < 10 and PlatoonExists(aiBrain, self) and self.MovingToWaypoint do
                    
                        engPos = GetPosition(eng) or false

						-- check every 6th iteration --
						if engPos and LOUDMOD(count,6) == 0 then
					
							if not EngineerBuildValid() then
						
								eng.failedmoves = eng.failedmoves + 2
                                
                                if EngineerDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." build invalid while moving")
                                end
								
								ForkTo( AIAddMustScoutArea, aiBrain, buildPosition )								
							
								return false
							end
						
							if EngineerThreatened() then
						
								eng.failedmoves = 10    --eng.failedmoves + 2

                                if EngineerDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." threatened while moving")
                                end

                                ForkTo( AIAddMustScoutArea, aiBrain, buildPosition )
					
                                return false                                
							end
						
							if count == 12 or eng.failedmoves > 2 then
						
								distance = VDist2( engPos[1],engPos[3], buildPosition[1],buildPosition[3] )
							
								if (distance > 160 or eng.failedmoves > 0) and not LOUDENTITY( COMMANDER, eng ) then

                                    if EngineerDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." calls for transport - count is "..count.." failed moves is "..eng.failedmoves )
                                    end

									-- we use a random location within 8 so that we dont drop right on the target but near it 
									-- had to do this becuase engies would land on MEX points (causing CanBuildAtLocation to fail)
									-- a successful transport will clear the waypoint callback and end the loop --
									if SendPlatoonWithTransportsLOUD( self, aiBrain, RandomLocation( buildPosition[1],buildPosition[3], 8 ), 1, false ) then
                                    
                                        -- clear failedmoves on transport call
                                        if eng.failedmoves > 2 then
                                            eng.failedmoves = 0
                                        end

										WaitTicks(2)

										break
									else
									
										WaitTicks(12)
									end
								end
							
								count = 0
							end

						end
                        
                        if engPos then
                
                            if EngineerDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." watching while moving "..repr(count) )
                            end
					
                            WaitTicks(6)
					
                            count = count + 1
                        end

					end

				end

				if not eng.Dead and eng.failedmoves >= 10 then

					ForkTo( AIAddMustScoutArea, aiBrain, buildPosition )

					return false
				end
				
				return not eng.Dead
			end			

            if EngineerDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." buildPosition is "..repr(buildPosition))
            end

			-- get the engineer moved to the goal --
			if not eng.Dead and EngineerMoving() then
			
				if PlatoonExists( aiBrain, self ) and not eng.Dead then

					self:Stop()
                    
                    if self.WaypointCallback then
                        KillThread(self.WaypointCallback)
                    end
				end

                -- try to capture/reclaim -- if we do - we exit here
				if  not eng.Dead then
					EngineerTryReclaimCaptureArea( false )
				end

                -- try to repair - if we do exit here
				if not eng.Dead then
					EngineerTryRepair()
				end

				-- build the structure -- STD callbacks will relaunch PBC
                if buildItem then

					if not eng.Dead then
                        
						-- if engy building new base get base data
						if eng.NewBaseThread then

							basetaken = false
                            
                            WaitTicks(2)     -- new wait to make sure NewBaseThread is established

							-- signal the NewBaseThread that we need the data now
							eng.NeedsBaseData = true

							-- at this point the engineer will get the NewExpansion data back from the NewBaseThread
							-- in the form of eng.NewExpansion[1] = basename, [2] = 3D position, [3] = the construction data
							repeat 
								WaitTicks(10)
							until eng.Dead or not eng.NewBaseThread

                            local NewBaseName = eng.NewExpansion[1]
                            local NewBasePos = eng.NewExpansion[2]

							if not eng.Dead then

                                local BRAINS = ArmyBrains

								-- loop thru brains to see if it's been taken by another
								for _,brain in BRAINS do
								
									if brain.BuilderManagers[ NewBaseName ] then
				
										-- if not an ally or it's a counted base then it's already taken
										-- in this way Enemy bases and full allied bases can be marked as taken
										-- while still allowing Allied players to share other markers
										
										-- I no longer permit any base sharing --	
										if IsAlly( aiBrain.ArmyIndex, brain.ArmyIndex) then
	
											basetaken = true
											
											--WARN("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." Eng "..eng.EntityID.." "..self.BuilderName.." Base already taken "..repr(NewBaseName) )
											
											break
										end
									end
								end
							end
							
							if eng.Dead or basetaken or not NewBasePos then
							
								if not eng.Dead then
									
									-- clear the expansion data
									eng.NeedsBaseData = nil
									eng.NewExpansion = nil
									eng.NewBaseThread = nil
									-- clear all queue items
									eng.EngineerBuildQueue = {}

									ProcessBuildCommand( self, eng, false )
									return
								end

							else
								
								-- start the new base --
								if AINewExpansionBase( aiBrain, NewBaseName, NewBasePos, eng, eng.NewExpansion[3] ) then
                                
                               		if ScenarioInfo.BaseMonitorDialog or EngineerDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." Eng "..eng.EntityID.." creates new base "..repr(NewBaseName).." at "..repr(NewBasePos) )
                                        LOG("*AI DEBUG Engineer is presently at "..repr(eng:GetPosition()))
                                    end
									
									self.LocationType = NewBaseName
									self.RTBLocation = NewBasePos
                                    
								else
									
									WARN("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." Eng "..eng.EntityID.." failed to start new base "..repr(NewBaseName).." at "..repr(NewBasePos) )

									-- clear the expansion data
									eng.NewExpansion = nil
									-- clear all queue items
									eng.EngineerBuildQueue = {}
									
									ProcessBuildCommand( self, eng, false )
									return
								end
							end
						end

						-- build an item --
						if not eng.Dead then

							-- if we aren't monitoring a build/reclaim already --
							if not eng.NotBuildingThread then
							
								if CanBuildStructureAt( aiBrain, buildItem, buildPosition ) then
								
                                    if EngineerDialog then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." orders build of "..repr(buildItem).." at "..repr(buildPosition) )
                                    end

									eng.IssuedBuildCommand = true
									eng.IssuedReclaimCommand = false
									eng.failedmoves = 0

									BuildStructure( aiBrain, eng, buildItem, buildLocation, false)
								
									eng.NotBuildingThread = eng:ForkThread(WatchForNotBuilding)
								else
                                    if EngineerDialog then    
                                        WARN("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." fails CanBuildStructureAt "..repr(buildPosition).." for "..repr(buildItem) )
                                    end

									-- remove the item via PBC --
									if not eng.Dead then
						
										-- cancel a looping builder --
										self.PlatoonData.Construction.LoopBuild = false
										
										ProcessBuildCommand( self, eng, true )
										return
									end
								end
							end
						end
					end

					return
				end

			else
				-- this happens if the build site is no good or not safe or we simply can't or don't want to move there
				-- it will cancel loopbuilding engineers and will bypass this queue item and move on to the next
				-- if the failedmoves is 10+ then all builds will be cancelled and trigger an RTB
				-- and the job will be put in delay so it isn't selected again right away --
				if not eng.Dead then
                
                    if self.WaypointCallback then
                        KillThread( self.WaypointCallback)
                    end
				
					if eng.failedmoves < 10 then

						-- move onto next item to build
						if EngineerDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." Failed to build")
                        end
						
						ProcessBuildCommand( self, eng, true )
						return
					else
                    
						self.CreationTime = GetGameTimeSeconds()

						if self.PlatoonData.Construction then
							-- cancel looping builders --
							self.PlatoonData.Construction.LoopBuild = false
						end
                    end
				end
			end
            
        end

		-- We only get here if we enter PBC with an empty queue or we failed a build after a sucessful engineermoving 
		-- and we didn't capture or reclaim -- either restart a looping builder or RTB those that are not
        if (not eng.Fighting) and (not eng.Dead) then
		
			eng.EngineerBuildQueue = {}		
			
		    if self.PlatoonData.Construction.LoopBuild and self.PlanName then
            
                local LoopMass = self.PlatoonData.Construction.LoopMass or 200
                local LoopEnergy = self.PlatoonData.Construction.LoopEnergy or 2500
                
                -- this is where engineers actually loop their plan if set to do so
                -- this energy requirement is hardcoded for now - should be something carried as self data
                -- if the energy requirement is NOT met - then the 'loop' behavior is cancelled and RTB will happen

                -- we could use this process to select other 'plans' - like a 'follow on' behavior
                -- real roadblock to that, is making sure that the necessary data, to support the 
                -- follow on AIPlan, is there - otherwise the follow on plan may not function as intended
                if GetEconomyStored(aiBrain,'MASS') >= LoopMass and (GetEconomyStoredRatio(aiBrain,'MASS') *100) < 75 then
                
                    if GetEconomyStored(aiBrain,'ENERGY') >= LoopEnergy then
                    
                        eng.failedmoves = 0
                        eng.failedbuilds = 1
			
                        self:SetAIPlan( self.PlanName, aiBrain)
                        return
                    end
                end
                
                if EngineerDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Eng "..eng.EntityID.." "..repr(self.BuilderName).." ends loop due to resource shortage")
                end

                self.PlatoonData.Construction.LoopBuild = false
			end
			
			if eng.NewExpansion then
				
				eng.NeedsBaseData = nil
				eng.NewExpansion = nil
				
				if eng.NewBaseThread then
					KillThread(eng.NewBaseThread)
					eng.NewBaseThread = nil
				end
			end

			eng.failedmoves = 0
			
			self:SetAIPlan( 'ReturnToBaseAI', aiBrain )
        end
    end,


    -- intended to be used to have one platoon guard another
	-- each guard will guard every unit in 
    GuardPlatoonAI = function( self, aiBrain )

        if PlatoonExists(aiBrain, self) then 
        
            if PlatoonExists( aiBrain, self.GuardedPlatoon ) then
            
				LOG("*AI DEBUG Found Platoon to be guarded "..repr(self.GuardedPlatoon.BuilderName) )
				
                for _,w in GetPlatoonUnits(self.GuardedPlatoon) do
                    if not w.Dead then
                        IssueGuard( GetPlatoonUnits(self), w )
                    end
                end
            end
        
            while PlatoonExists( aiBrain, self.GuardedPlatoon ) and PlatoonExists( aiBrain, self) do
                WaitTicks(40)
            end
            
            return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        end
    end,

	PoolAI = function( self )
	end,

    -- Basic attack logic. Look first for a local target, and if not, find one on the HiPri list
	-- Build a path to the target and if necessary, request transports
	-- If the threat of the platoon drops too low, it will try to Return To Base
    LandForceAILOUD = function( self, aiBrain )
    
        local LandForceAIDialog = ScenarioInfo.LandForceDialog

        local CalculatePlatoonThreat    = CalculatePlatoonThreat
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetPlatoonUnits           = GetPlatoonUnits
        local GetPosition               = GetPosition
        local GetUnitsAroundPoint       = GetUnitsAroundPoint
        local PlatoonExists             = PlatoonExists
        
        local LOUDCOPY      = LOUDCOPY
        local LOUDENTITY    = LOUDENTITY
		local LOUDGETN      = LOUDGETN
        local LOUDLOG10     = LOUDLOG10
        local LOUDMAX       = LOUDMAX
        local LOUDMOD       = LOUDMOD
        local LOUDSORT      = LOUDSORT
		local VDist2Sq      = VDist2Sq        
		local VDist3        = VDist3
        local WaitTicks     = WaitTicks
        
        local dataList                  = GetPlatoonUnits(self)
        local numberOfUnitsInPlatoon    = LOUDGETN(dataList)
        local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
		local OriginalSurfaceThreat     = CalculatePlatoonThreat( self,'Surface', ALLUNITS)

		local bAggroMove    = self.PlatoonData.AggressiveMove or false		
		local MergeLimit    = self.PlatoonData.MergeLimit or numberOfUnitsInPlatoon
        local Slackdistance = self.PlatoonData.WaypointSlackDistance or 25
		
        self.PlatoonAttackForce = true
        
        self.PlanName = 'LandForceAILOUD'
		
        self:SetPlatoonFormationOverride('LOUDClusterFormation')
		
		local GetPrimaryLandAttackBase = GetPrimaryLandAttackBase
		local MaximumAttackRange = self.PlatoonData.MaxAttackRange or 1024        
		local PlatoonFormation = self.PlatoonData.UseFormation or 'AttackFormation'
 
        local CheckForStuckPlatoon          = self.CheckForStuckPlatoon
        local MergeWithNearbyPlatoons       = self.MergeWithNearbyPlatoons
        local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD
        local ProcessStuckPlatoon           = self.ProcessStuckPlatoon
        local RecheckHiPriTarget            = RecheckHiPriTarget

        local TARGETSTUFF = {categories.ECONOMIC, categories.LAND + categories.MOBILE, categories.STRUCTURE - categories.WALL}

        local MovementLayer = self.MovementLayer
		local notargetcount = 0
		local targetLocation = false
		local targetclass = false
		local targettype = false
		local target = false        

        if LandForceAIDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." begins")
        end
        
        local bNeedTransports, distancefactor, ecovalue, enemyindex, ethreat, experimentalunit, milvalue, mythreat, name, travelcount
        local newposition, oldplatpos, path, pathlength, platPos, reason, sthreat, stuckcount, targetthreat, targetmilvalue, targetvalue, usedTransports, value
		
        local targettypes = {}
        
        targettypes["AntiAir"] = true
        targettypes["Economy"] = true
        targettypes["Commander"] = true
        targettypes["Land"] = true
        targettypes["StructuresNotMex"] = true

        while PlatoonExists(aiBrain, self) do
			
			if self.MoveThread then
				self:KillMoveThread()
			end
		
            platPos = GetPlatoonPosition(self) or false
        
            if not platPos then
                return
            end
			
            dataList = GetPlatoonUnits(self)

			experimentalunit = false

            for _,v in dataList do
				if not experimentalunit and LOUDENTITY(EXPERIMENTALS,v) then
					experimentalunit = v
					break
				end
            end
			
			if MergeLimit and oldNumberOfUnitsInPlatoon < MergeLimit then

				if MergeWithNearbyPlatoons( self, aiBrain, 'LandForceAILOUD', 85, false, MergeLimit) then

					numberOfUnitsInPlatoon = 0
					
					for _,v in dataList do

						if not v.Dead then
							numberOfUnitsInPlatoon = numberOfUnitsInPlatoon + 1
                            
                            if LOUDENTITY(EXPERIMENTALS,v) then
                                experimentalunit = v
							end
						end
					end
			
					self:SetPlatoonFormationOverride(PlatoonFormation)
				
					OriginalSurfaceThreat = CalculatePlatoonThreat( self,'Surface', ALLUNITS)
					oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
					GetMostRestrictiveLayer(self)
				end
			end
			
            -- Find A Local target, HiPri Target or a Defensive Point -- or instead of DP - current Attack Plan goal ?
			targetLocation = false
			targetclass = false
			targettype = false
            targetvalue = 0
			target = false
			
            if LandForceAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeks local target from "..repr(platPos))
            end

			target, targetLocation = FindTargetInRange( self, aiBrain, 'Attack', 90, TARGETSTUFF, false )
			
			if target and not target.Dead and PlatoonExists( aiBrain, self) then
			
				if Behaviors.LocationInWaterCheck( GetPosition(target) ) then
					target = false
					targetLocation = false
				else
                    targettype = 'Local'
                    targetLocation = LOUDCOPY(targetLocation)
				end
			end

            -- if no local target then seek one on the HiPri list
			if (not target) and (not targetLocation) then
			
                if LandForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeks HiPri target from "..repr(platPos))
				end
                
				_, newposition = GetPrimaryLandAttackBase(aiBrain)
                
       			mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )

				dataList = GetHiPriTargetList( aiBrain, newposition, targettypes, MaximumAttackRange, true )

				targetvalue = 0
				
				for _,Target in dataList do

                    targetLocation = Target.Position
                    targetclass = Target.Type                

					sthreat = Target.Threats.Sur
					ethreat = Target.Threats.Eco
					
					if sthreat < 1 then
						sthreat = 1
					end
                    
					if ethreat < 1 then
						ethreat = 1
					end

                    ecovalue = LOUDMAX(.5, ethreat/mythreat)
                    
					if ecovalue > 1.5 then
						ecovalue = LOUDMIN( 3, LOUDSQRT(ecovalue))
					end

					milvalue =  (mythreat/sthreat) 
                    
                    if milvalue > 1.5 then 
                        
                        milvalue = LOUDMIN( 4, LOUDSQRT(milvalue) )

                        -- inflate eco value by ratio of our mil superiority
                        ecovalue = LOUDMIN( 3, ecovalue * milvalue )
						
                    elseif milvalue < 1.5 then

                        if milvalue >= 1 then
                            milvalue = LOUDMAX( 1, LOUDSQRT(milvalue) )
                        else
                            milvalue = milvalue * milvalue
                            ecovalue = ecovalue * .8
                        end
                    end
                    
                    value = ecovalue * milvalue

                    -- ignore targets we are still too weak against
					-- todo: REPLACE THIS VALUE WITH PLATOON DATA VALUE - VALUE BREAKPOINT
                    if value <= 0.85 then
                        continue
                    end
 
                    -- skip targets in the water
					if Behaviors.LocationInWaterCheck(targetLocation) then
						continue
					end
					
					-- this next segement of code is designed to help the AI stay focused on his current enemy
					-- by increasing the value of targets where his current enemy is present
					enemyindex = aiBrain.CurrentEnemyIndex
				
					for _,v in GetUnitsAroundPoint( aiBrain, ALLUNITS, targetLocation, 90, 'Enemy') do
					
						if enemyindex == GetAIBrain(v).ArmyIndex then
							value = value * 1.1
							break
						end
					end
					
					-- ok - the 'real' distancefactor is not the 'as the crow flies' distance
					-- but the length of the path the platoon would have to take to get there
					-- this is returned to us so we compare it against the Target.Distance and 
					-- use the greater of them
                    path = false
                    pathlength = 0
                    
					path, reason, pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, targetLocation, mythreat, 160 )
				
					if path then

                        -- this value will multiply the value of the target - closer = greater distancefactor result
                        -- anything less than 600 distance gets increased -- beyond that decreased
                        distancefactor = pathlength/(ScenarioInfo.IMAPSize*.5)

                        distancefactor = 1 / ( LOUDLOG10(distancefactor))
                        
                        distancefactor = distancefactor * (MaximumAttackRange / pathlength)    --- factor in the maximum allowed attack distance
                    
                        -- now use distance to modify the value and go after the most valuable
                        if (value * distancefactor) > targetvalue then
					
                            target = Target
                            targetmilvalue = milvalue
                            targetvalue = value * distancefactor
                            targetLocation = LOUDCOPY(Target.Position)

                            targetdistancefactor = distancefactor

                            targettype = 'HiPri'                            
                            notargetcount = 0
                        end
                    end
					
                    if not path then
                        WaitTicks(2)
                    end
				end
                
			end
			
			-- if no target then seek a DP and increase the number of tries by 1
			if not target then

                if LandForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeks DP marker from "..repr(platPos))
                end
                
                if aiBrain.AttackPlan then
                    local stagepoints = aiBrain.AttackPlan.StagePoints
                end

				targetLocation, name = AIGetClosestMarkerLocation( aiBrain, 'Defensive Point', platPos[1], platPos[3] )
                target = false
                targetclass = false
				targettype = 'DP'
				notargetcount = notargetcount + 1
			end

            -- if no target after 6 tries - RTB --
			if (not targettype) or notargetcount > 6 then
                
                if LandForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." failed 6 target seeks - RTB")
                end
                
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			end

            -- we have a location - move to it or transports
			if targetLocation then

                if LandForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." selects "..repr(targettype).." target at "..repr(targetLocation).." class "..repr(targetclass).." value "..repr(targetvalue).." fails "..notargetcount)
                end
                
                mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )            
			
				path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, targetLocation, mythreat, 160 )

				if self.MoveThread then
					self:KillMoveThread()
				end

				self:Stop()    

				usedTransports = false
		
				if not experimentalunit then

                    -- force transport use if NoPath --
					if ((not path and reason == 'NoPath') or bNeedTransports) then

                        if LandForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." calls for transport 8")
                        end
                        
						usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetLocation, 8, false )
                    end
				end
        
				if not usedTransports and PlatoonExists(aiBrain,self) then
				
					if not path then
					
                        if LandForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." has no path & no transport - restart target process")
                        end

                        targetLocation = false
                        -- break out and return to target selection process --
                        break
					else
						self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove, Slackdistance )

						-- having issued the movement commands, this would be a good place to setup a callback
						-- that would fire off a signal of some kind when the platoon is near the target
						-- so we could do something like call for air cover, recon, or a bomber strike
						
						--LOG("*AI DEBUG setting up PlatoonAtGoal Callback for location "..repr(targetLocation))
						-- might just be easier to have a thread that monitors this
						-- and store the handle on the platoon so we can just destroy it
						-- and recreate it if the target changes
						--self.SetupPlatoonAtGoalCallbacks(self, targetLocation, 90)
					end
				end

            end
			
			platPos = GetPlatoonPosition(self) or false
            
			stuckcount = 0
			travelcount = 0
			
			-- Run this while moving to target location	-- check for stuck & re-check HiPri targets
			while PlatoonExists(aiBrain, self) and platPos and targetLocation and VDist3( platPos, targetLocation ) > 35 do

                oldplatpos = LOUDCOPY(platPos)

				WaitTicks(81)
				
				platPos = GetPlatoonPosition(self) or false

                if platPos then
                
                    travelcount = travelcount + 1

                    if LandForceAIDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." at "..VDist3( platPos, targetLocation).." to targetLocation")    
                    end

                    -- stuck behavior --
                    if CheckForStuckPlatoon( self, platPos, oldplatpos ) then
				
                        stuckcount = stuckcount + 1
					
                        if stuckcount > 1 then
					
                            if LandForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." looks stuck at "..repr(platPos))
                            end
                        
                            if ProcessStuckPlatoon( self, targetLocation ) then
                                stuckcount = 0
                            end
                        end
                    else
                        stuckcount = 0
                    end

                    -- confirm HiPri target is still valid every 3rd iteration
                    if targettype == 'HiPri' and LOUDMOD( travelcount, 3 ) == 0 then
                
                        reason, targetthreat, newposition = RecheckHiPriTarget( aiBrain, targetLocation, targetclass, 0, true  )
				
                        if reason then      -- target is still on HiPri list
                        
                            mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )					

                            if (mythreat/targetthreat.Sur) > targetmilvalue then        -- we have as much force as when we took the target to begin with

                                targetLocation = LOUDCOPY(newposition)
                            
                                if LandForceAIDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." validates HiPri target at "..repr(targetLocation))
                                end

                            else

                                if LandForceAIDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." HiPri recheck - target threat too high at "..repr(targetLocation).." threat is "..repr(targetthreat.Sur).." - mine is "..mystrength.." - milvalue is "..targetmilvalue )
                                end
                                
                                targetLocation = false

                                self:KillMoveThread()                             

                                break
                            end
                        
                        else
                        
                            if LandForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." HiPri recheck reports "..targetclass.." target at "..repr(targetLocation).." is no longer valid")
                            end
                            
                            targetLocation = false
 
                            self:KillMoveThread()  

                            break                        
                        end
					
                    end
                    
                end

                -- seek transport every 4th iteration
				if (not experimentalunit) and targetLocation and platPos then

                    if LOUDMOD( travelcount, 4 ) == 0 then

                        if VDist3( platPos, targetLocation ) > 350 then

                            if LandForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." calls for transport 1")
                            end

                            usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetLocation, 1, false, path )
                            
                            if not usedTransports and not self.MoveThread then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." LandForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." used transport but no longer has a movement order")
                                
                                targetLocation = false
                                
                                break
                            end
                        end
                    end
				end

			end
			
			WaitTicks(41)
		end
	end,

    -- Basic amphibious attack logic.  Searches for a good area to go attack, and will use
    -- a safe path (if available) to get there.  If the threat of the platoon
    -- drops too low, it will try and Return To Base and disband
    AmphibForceAILOUD = function( self, aiBrain )

        local AmphibForceAIDialog = ScenarioInfo.AmphibForceDialog or false
        
        local CalculatePlatoonThreat    = CalculatePlatoonThreat
        local GetPlatoonPosition        = GetPlatoonPosition
        local GetPlatoonUnits           = GetPlatoonUnits
   		local GetPosition               = GetPosition
        local GetUnitsAroundPoint       = GetUnitsAroundPoint
        local PlatoonExists             = PlatoonExists
    
        local LOUDCOPY      = LOUDCOPY
        local LOUDENTITY    = LOUDENTITY
		local LOUDGETN      = LOUDGETN
        local LOUDLOG10     = LOUDLOG10
        local LOUDMAX       = LOUDMAX
        local LOUDMOD       = LOUDMOD
        local LOUDSORT      = LOUDSORT
		local VDist2Sq      = VDist2Sq        
		local VDist3        = VDist3
        local WaitTicks     = WaitTicks
		
        local platoonUnits              = GetPlatoonUnits(self)
        local numberOfUnitsInPlatoon    = LOUDGETN(platoonUnits)
        local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
		local OriginalSurfaceThreat     = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
		
		local bAggroMove    = self.PlatoonData.AggressiveMove or false
        local MergeLimit    = self.PlatoonData.MergeLimit or false
        local Slackdistance = self.PlatoonData.WaypointSlackDistance or 25

        self.PlatoonAttackForce = true
		
		self.PlanName = 'AmphibForceAILOUD'

        self:SetPlatoonFormationOverride('LOUDClusterFormation')

		local GetPrimaryLandAttackBase  = GetPrimaryLandAttackBase
		local MaximumAttackRange        = self.PlatoonData.MaxAttackRange or 1024
		local PlatoonFormation          = self.PlatoonData.UseFormation or 'None'

        local CheckForStuckPlatoon          = self.CheckForStuckPlatoon
        local MergeWithNearbyPlatoons       = self.MergeWithNearbyPlatoons
        local PlatoonGenerateSafePathToLOUD = self.PlatoonGenerateSafePathToLOUD
        local ProcessStuckPlatoon           = self.ProcessStuckPlatoon
        local RecheckHiPriTarget            = RecheckHiPriTarget

        local TARGETSTUFF = { categories.ECONOMIC, categories.LAND + categories.MOBILE, categories.NAVAL + categories.MOBILE, categories.STRUCTURE - categories.WALL }

        local MovementLayer = self.MovementLayer
        local notargetcount = 0
		local oldTargetLocation = false

        if AmphibForceAIDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." begins")
        end

		local distancefactor, ecovalue, enemyindex, ethreat, experimentalunit, landattackposition, milvalue, mythreat, newposition, path, pathlength, platPos, travelcount
		local reason, sthreat, stuckcount, target, targetclass, targetcount, targetlist, targetLocation, targettype, targetmilvalue, targetvalue, usedTransports, value

        local targettypes = {}      -- this table marks the kind of targets that are to be considered during the HiPri selection process
        
        targettypes["AntiAir"]          = true
        targettypes["Commander"]        = true
        targettypes["Economy"]          = true
        targettypes["Land"]             = true
        targettypes["Naval"]            = true
        targettypes["StructuresNotMex"] = true

        while PlatoonExists(aiBrain,self) do
        
            AmphibForceAIDialog = ScenarioInfo.AmphibForceDialog or false

			if self.MoveThread then
				self:KillMoveThread()
			end

            platPos = GetPlatoonPosition(self) or false
            
            if not platPos then
                return
            end
			
            platoonUnits = GetPlatoonUnits(self)
            
            experimentalunit = false

            for _,v in platoonUnits do
				if not experimentalunit and LOUDENTITY(EXPERIMENTALS,v) then
					experimentalunit = v
					break
				end
            end

            if MergeLimit and oldNumberOfUnitsInPlatoon < MergeLimit then

                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." checking merge")
                end

				if MergeWithNearbyPlatoons( self, aiBrain, 'AmphibForceAILOUD', 75, false, MergeLimit) then
					
                    numberOfUnitsInPlatoon = 0

                    for _,v in platoonUnits do
					
						if not v.Dead then
                            numberOfUnitsInPlatoon = numberOfUnitsInPlatoon + 1
                            
                            if LOUDENTITY(EXPERIMENTALS,v) then
                                experimentalunit = v
							end
                        end
                    end
                    
                    self:SetPlatoonFormationOverride(PlatoonFormation)

                    OriginalSurfaceThreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
                    oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon                    
                    GetMostRestrictiveLayer(self)
                end
            end

            -- Find A Local target, Priority Target or a Defensive Point
			targetLocation = false
			targetclass = false
            targettype = false
            targetvalue = 0
			target = false

            if AmphibForceAIDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeking local target at range 90 from "..repr(GetPlatoonPosition(self)))
            end
			
            -- this can return a moving targetLocation
			target, targetLocation = FindTargetInRange( self, aiBrain, 'Attack', 90, TARGETSTUFF, false )
			
			if target and not target.Dead and PlatoonExists( aiBrain, self) then
			
				if Behaviors.LocationInWaterCheck( GetPosition(target) ) and not CanAttackTarget(self,'Attack',target) then
					target = false
					targetLocation = false
				else
                    targettype = 'Local'
                    targetLocation = LOUDCOPY(targetLocation)
				end
			end
			
            -- if no local target get a HiPri target 
			if (not target) and (not targetLocation) then

                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeks HiPri target from "..repr(platPos).." at range "..MaximumAttackRange)            
                end

				targetLocation = false
				target = false

				_, landattackposition = GetPrimaryLandAttackBase(aiBrain)
				
				targetlist, targetcount = GetHiPriTargetList( aiBrain, landattackposition, targettypes, MaximumAttackRange, true )

				targetvalue = 0

                mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
                
                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." mythreat is "..math.floor(mythreat).." using IMAPSize "..ScenarioInfo.IMAPSize.." here is the ("..targetcount..") sorted targetlist based from "..repr(landattackposition).." "..repr(targetlist))
                end

				-- process the hipri list to find a target
				for _, Target in targetlist do

					sthreat = Target.Threats.Sur
					ethreat = Target.Threats.Eco
					
					if sthreat < 1 then
						sthreat = 1
					end
					
					if ethreat < 1 then 
						ethreat = 1
                    end

                    ecovalue = LOUDMAX(.5, ethreat/mythreat)
                    
					if ecovalue > 1.5 then
						ecovalue = LOUDMIN( 3, LOUDSQRT(ecovalue))
					end
                    
					-- target value is relative to the platoons surface strength vs. the targets surface strength
                    -- but we'll rapidly devalue anything we aren't twice as strong as
                    -- and retard the gain from being more than twice as strong
					milvalue =  (mythreat/sthreat) 
                    
                    if milvalue >= 2 then 
                    
                        milvalue = LOUDMIN( 4, LOUDSQRT(milvalue) )
                        -- increase the ecovalue to as much as 3
                        ecovalue = LOUDMIN( 3, ecovalue * milvalue )
						
                    elseif milvalue < 2 then

                        if milvalue >= 1 then
                            milvalue = LOUDMAX( 1, LOUDSQRT(milvalue))

                        else
                            -- devalue the values more when below 1
                            milvalue = milvalue * milvalue
                            ecovalue = ecovalue * .8
                        end
                    end
                    
                    -- now factor in the economic value of the target
                    -- this will make targets that we are stronger than, that have eco value, even more valuable
                    -- and targets that have overpowering military value made even less valuable
                    value = ecovalue * milvalue

                    -- ignore targets we are still too weak against
                    if value <= 0.85 then

                        if AmphibForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." ignores "..repr(Target.Type).." target value is "..value.." - mil "..milvalue.." - eco "..ecovalue)
                        end
                    
                        continue
                    end
                    
                    -- ignore targets that may be in or on the water -- if we don't have any subthreat
					if Behaviors.LocationInWaterCheck(Target.Position) then
                    
                        local subthreat = CalculatePlatoonThreat( self, 'Sub', ALLUNITS )
                        
                        if subthreat <  1 then

                            if AmphibForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." ignores target "..repr(Target.Type).." at "..repr(Target.Position).." is in water")
                            end
                    
                            continue
                        end
					end
                    
					-- this next segement of code is designed to help the AI stay focused on his current enemy
					-- by increasing the value of targets where his current enemy is present
					enemyindex = aiBrain.CurrentEnemyIndex

					for _,v in GetUnitsAroundPoint( aiBrain, ALLUNITS, Target.Position, ScenarioInfo.IMAPSize, 'Enemy') do
					
						if enemyindex == GetAIBrain(v).ArmyIndex then
							value = value * 1.1
							break
						end
					end
					
					-- ok - the 'real' distancefactor is not the 'as the crow flies' distance
					-- but the length of the path the platoon would have to take to get there
					-- so we'll calculate that here and we'll use this as the basis for our
					-- distancefactor
                    path = false
                    pathlength = 0
                   
					path, reason, pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, Target.Position, mythreat, 200 )

					if path then

						distancefactor = pathlength/(ScenarioInfo.IMAPSize*.5)
                        
                        distancefactor = 1 / (LOUDLOG10(distancefactor))
                        
                        distancefactor = distancefactor * (MaximumAttackRange / pathlength)    --- factor in the maximum allowed attack distance

                        if AmphibForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." evaluates "..repr(Target.Type).." pathdistance ("..math.floor(pathlength)..") - factor "..distancefactor.." - mil "..milvalue.." - eco "..ecovalue.." result value "..value * distancefactor )
                        end
                      
						-- the targetvalue is essentially (value * distancefactor)
						-- keep track of best choice so far
						if (value * distancefactor) > targetvalue then
							
							target = Target
                            targetmilvalue = milvalue
							targetvalue = value * distancefactor
							targetLocation = LOUDCOPY(Target.Position)
							targetclass = Target.Type
							targettype = 'HiPri'
                            
							oldTargetLocation = false
                            notargetcount = 0
						end
                      
					else

                        if AmphibForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." ignores target type "..repr(Target.Type).." at "..repr(Target.Position).." no path - "..reason)
                        end
                    
                    end
					
					WaitTicks(2)
				end

			end
			
			-- if no target then locate nearest DP and increase the try counter by one
			if not targetLocation then

                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." seeks DP marker from "..repr(platPos))
                end

                if aiBrain.AttackPlan then
                    local stagepoints = aiBrain.AttackPlan.StagePoints
                end

				targetLocation, name = AIGetClosestMarkerLocation( aiBrain, 'Defensive Point', platPos[1], platPos[3] )
                target = false
                targetclass = false
				targettype = 'DP'
				notargetcount = notargetcount + 1
			end
			
			-- if still no target then RTB
			if (not targetLocation) or notargetcount > 6 then 
			
                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." failed 6 target seeks - RTB")
                end
				
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
            end

            -- we have a target - move to it or transports
            if targetLocation then
                
                if AmphibForceAIDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." selects "..repr(targettype).." target at "..repr(targetLocation).." class "..repr(targetclass).." value "..repr(targetvalue).." fails "..notargetcount)
                end

                mythreat = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )            
            
                path, reason = PlatoonGenerateSafePathToLOUD( aiBrain, self, MovementLayer, platPos, targetLocation, mythreat, 200 )

                if self.MoveThread then
                    self:KillMoveThread()
                end

                self:Stop()    
   
                usedTransports = false

                if not experimentalunit then

                    -- if no path is returned, versus NoStart or NoEnd
                    if (not path and reason == 'NoPath') then
                        
                        if AmphibForceAIDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." calls for transport 5")
                        end
					
                        usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetLocation, 5, true )
                    end
                end
        
                -- use path or RTB --
                if not usedTransports then
			
                    if not path then
					
                        return self:SetAIPlan('ReturnToBaseAI',aiBrain)

                    -- or begin walking --
                    else

                        self.MoveThread = self:ForkThread( self.MovePlatoon, path, PlatoonFormation, bAggroMove, Slackdistance)
                    end
                end

            end
            
            platPos = GetPlatoonPosition(self) or false
			
            stuckcount = 0
            travelcount = 0
			
            -- Move to target location and check self along the way -- try to call for transport if distant
            while PlatoonExists(aiBrain, self) and platPos and targetLocation and VDist3( platPos, targetLocation ) > 35 do

                oldplatpos = LOUDCOPY(platPos)

				WaitTicks(81)
                
                travelcount = travelcount + 1
				
				platPos = GetPlatoonPosition(self) or false
                
                if platPos then

                    -- stuck platoon 
                    if CheckForStuckPlatoon( self, platPos, oldplatpos ) then
				
                        stuckcount = stuckcount + 1
					
                        if stuckcount > 3 then
                            
                            if AmphibForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." looks stuck at "..repr(platPos))
                            end

                            if ProcessStuckPlatoon( self, targetLocation ) then
                                stuckcount = 0
                            end
                        end

                    else
                        stuckcount = 0
                    end

                    -- target still valid every 3rd iteration
                    if targettype == 'HiPri' and LOUDMOD(travelcount,3) == 0 then
				
                        reason, targetthreat, newposition = RecheckHiPriTarget( aiBrain, targetLocation, targetclass, 0, true )
				
                        if reason then
    
                            mystrength = CalculatePlatoonThreat( self, 'Surface', ALLUNITS )
					
                            if (mystrength/targetthreat.Sur) >= targetmilvalue then

                                targetLocation = LOUDCOPY(newposition)
                            
                                if AmphibForceAIDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." HiPri recheck - target valid at "..repr(targetLocation))
                                end
                            
                            else
                            
                                if AmphibForceAIDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." HiPri recheck - target milvalue "..repr(mystrength/targetthreat.Sur).." at "..repr(targetLocation).." threat is "..repr(targetthreat.Sur).." - mine is "..mystrength.." - original milvalue "..targetmilvalue)
                                end

                                self:KillMoveThread()                                 

                                targetLocation = false
                            
                                break
                            end

                        else
                        
                            if AmphibForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." HiPri recheck reports "..targetclass.." target at "..repr(targetLocation).." is no longer valid")
                            end
                            
                            targetLocation = false
                            
                            self:KillMoveThread() 
                            
                            break
                        end

                    end
                
                end

                if (not experimentalunit) and targetLocation and platPos then

                    -- call for transport every 4th iteration --
                    if LOUDMOD( travelcount, 4 ) == 0 then
                        
                        if VDist3( platPos, targetLocation ) > 400 then

                            if AmphibForceAIDialog then
                                LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." calls for transport 1 " )
                            end

                            usedTransports = SendPlatoonWithTransportsLOUD( self, aiBrain, targetLocation, 1, true, path )
                            
                            if not usedTransports and not self.MoveThread then

                                if AmphibForceAIDialog then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." AmphibForceAI "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." used transport but no longer has a movement order " )
                                end
                                
                                targetLocation = false
                                break
                            end
                        end

                    end

                end

            end
			
			WaitTicks(46)
            
		end

    end,

    -- Function: MergeWithNearbyPlatoons
    --    self - the single platoon to run the AI on
    --    planName - AI plan to merge with
    --    radius - merge with platoons in this radius 
	--    planmatchrequired 	- if true merge platoons only with same builder name AND the same plan
	--							- if false then merging will be done with all platoons using same plan
	--    mergelimit - if set, the merge can only be taken upto that size
	--
    -- Finds platoon nearby (when self platoon is not near a base) and merge with them if they're a good fit.
	--		Dont allow smaller platoons to merge larger platoons into themselves
    --   Returns:  
    --       nil if no merge was done, true if a merge was done
	
	-- NOTE: The platoon executing this function will 'grab' units
	-- 		from the allied platoons - so in effect, it's reinforcing itself
    MergeWithNearbyPlatoons = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )

        if self.UsingTransport then
            return false
        end

        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local PlatoonExists = PlatoonExists

		if not PlatoonExists(aiBrain,self) then
			return false
		end
        
        local LOUDCOPY = LOUDCOPY
        local LOUDSORT = LOUDSORT
   		local VDist3Sq = VDist3Sq

        local radiusSq = radius*radius	-- maximum range to check allied platoons --
        
        local PlatoonMergeDialog = ScenarioInfo.PlatoonMergeDialog

        local dataList = GetPlatoonUnits(self)

		local platooncount = 0

		for _,v in dataList do
			if not v.Dead then
				platooncount = platooncount + 1
			end
		end

		if (mergelimit and platooncount > mergelimit) or platooncount < 1 then
			return false
		end

		local platPos = LOUDCOPY(GetPlatoonPosition(self))

		-- get a list of all the platoons for this brain
		local GetPlatoonsList = GetPlatoonsList
        local AlliedPlatoons = LOUDCOPY(GetPlatoonsList(aiBrain))
		
		LOUDSORT(AlliedPlatoons, function(a,b) local GetPlatoonPosition = GetPlatoonPosition local VDist3Sq = VDist3Sq return VDist3Sq( GetPlatoonPosition(a), platPos ) < VDist3Sq( GetPlatoonPosition(b), platPos ) end)

        self.UsingTransport = true
        
        local BuilderName = self.BuilderName
        local MovementLayer = self.MovementLayer

		local mergedunits = false        
        local Squads = { 'Unassigned','Attack','Artillery','Guard','Support','Scout' }
		local aPlatUnits, allyPlatoonSize, validUnits
        local count = 0
        local counter = 0
		
		-- loop thru all the platoons in the list
        for _,aPlat in AlliedPlatoons do
	
			-- ignore yourself
            if aPlat == self then
                continue
            end

			-- otherwise it must a least have the same plan
            if aPlat.PlanName != planName then
                continue
            end

			-- not only the plan must match but the buildername as well
			if planmatchrequired and aPlat.BuilderName != BuilderName then
				continue
			end
		
			-- and be on the same movement layer
            if aPlat.MovementLayer != MovementLayer then
                continue
            end
		
			-- if allied platoon is busy (not necessarily transports - this is really a general 'busy' flag --
            if aPlat.UsingTransport then
                continue
            end
            
			-- check distance of allied platoon -- as soon as we hit one farther away then we're done
			if VDist3Sq( platPos, GetPlatoonPosition(aPlat) ) > radiusSq then
				break
			end

            count = count + 1

			-- mark the allied platoon as being busy
			aPlat.UsingTransport = true

            if PlatoonMergeDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..repr(self.BuilderInstance).." evaluating "..aPlat.BuilderName.." "..repr(aPlat.BuilderInstance) )
            end
            
            -- the allied platoons size
			allyPlatoonSize = 0
            
            for _, squad in Squads do

                validUnits = {}
                counter = 0

                -- count and check validity of allied units
                dataList = GetSquadUnits( aPlat, squad )
            
                if dataList then
            
                    for _,v in dataList do
			
                        if not v.Dead then
				
                            allyPlatoonSize = allyPlatoonSize + 1

                            if not IsUnitState(v,'Attached' )then
				
                                -- if we have space in our platoon --
                                if (counter + platooncount) <= mergelimit then
						
                                    counter = counter + 1
                                    validUnits[counter] = v
                                end
                            end
                        end
                    end
                end

                -- if no valid units or we are smaller than the allied platoon then dont allow
                if counter < 1 or platooncount < allyPlatoonSize or allyPlatoonSize == 0 then
                    continue
                end

                -- otherwise we do the merge
                if PlatoonMergeDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..self.BuilderName.." "..repr(self.BuilderInstance).." MERGE_WITH takes "..counter.." "..repr(squad).." units from "..aPlat.BuilderName.." "..repr(aPlat.BuilderInstance).." now has "..platooncount+counter)
                end

                IssueClearCommands( validUnits )
                
                IssueMove( validUnits, GetPlatoonPosition(self) )                

                -- assign the valid units to us - this may end the allied platoon --
                AssignUnitsToPlatoon( aiBrain, self, validUnits, squad, 'none' )
			
                -- add the new units to our count --
                platooncount = platooncount + counter
			
                -- flag that we did a merge --
                mergedunits = true
            end
            
			-- unmark the allied platoon
			aPlat.UsingTransport = false

        end
    
        self.UsingTransport = false
        
		return mergedunits
    end,

    --  Function: MergeIntoNearbyPlatoons
	--  This is a variation of the MergeWithNearbyPlatoons 
	--	this one will 'insert' units into another platoon.
	--  used when a depleted platoon would otherwise retreat
    MergeIntoNearbyPlatoons = function( self, aiBrain, planName, radius, planmatchrequired, mergelimit )
	
        if self.UsingTransport then 
            return false
        end		

        local platPos = GetPlatoonPosition(self) or false
		
		if not platPos then
			return false
		end

        local PlatoonMergeDialog = ScenarioInfo.PlatoonMergeDialog

        local GetPlatoonPosition = GetPlatoonPosition
        local GetPlatoonUnits = GetPlatoonUnits
        local GetSquadUnits = GetSquadUnits
        local PlatoonExists = PlatoonExists
        
        local LOUDCOPY = LOUDCOPY
        local LOUDSORT = LOUDSORT
        local VDist3 = VDist3

        -- dont merge when within radius of a base
        for _, base in aiBrain.BuilderManagers do
		
            if VDist3( platPos, base.Position ) <= radius then
                return false
            end 
        end
		
        -- get all the platoons
		local GetPlatoonsList = GetPlatoonsList
        local AlliedPlatoons = GetPlatoonsList(aiBrain)
        
        local count = 0     -- number of allied platoons reviewed
        local Squads = { 'Scout','Attack','Artillery','Guard','Support' }
        
        local BuilderName = self.BuilderName
        local MovementLayer = self.MovementLayer

        local alliedcount, ourunitcount, unitlist

        ourunitcount = 0

		unitlist = GetPlatoonUnits(self)
        
        for _,u in unitlist do
            
            if not u.Dead then
                ourunitcount = ourunitcount + 1
            end
        end
		
		LOUDSORT(AlliedPlatoons, function(a,b) local GetPlatoonPosition = GetPlatoonPosition local VDist3 = VDist3 return VDist3(GetPlatoonPosition(a), platPos) < VDist3(GetPlatoonPosition(b), platPos) end)

        for _,AlliedPlatoon in AlliedPlatoons do

            if AlliedPlatoon == self then
                continue
            end
			
			if VDist3( platPos, GetPlatoonPosition(AlliedPlatoon) ) > radius then
				break
			end
			
            if AlliedPlatoon.UsingTransport then
                continue
            end
			
			if planmatchrequired and AlliedPlatoon.BuilderName != BuilderName then
				continue
			end
			
            if AlliedPlatoon.PlanName != planName then
                continue
            end
			
            if MovementLayer != AlliedPlatoon.MovementLayer then
                continue
            end
            
            alliedcount = 0
            
            -- dont merge with platoons larger than mergelimit
            unitlist = GetPlatoonUnits(AlliedPlatoon)

            for _,u in unitlist do

                if not u.Dead then
                    alliedcount = alliedcount + 1
                end

            end

            -- if there is a mergelimit - and the allied platoon already exceeds it
            -- of if the allied platoon is smaller than us - ignore this platoon
            if (mergelimit and alliedcount > mergelimit) or (ourunitcount > alliedcount) then

                if PlatoonMergeDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." with "..ourunitcount.." ignored  "..repr(AlliedPlatoon.BuilderName).." "..repr(AlliedPlatoon.BuilderInstance).." with "..alliedcount )
                end

                continue
            end
            
            count = count + 1

			
            ourunitcount = 0

			unitlist = GetPlatoonUnits(self)

			for _,u in unitlist do
			
                if (not u.Dead) and (not IsUnitState( u, 'Attached' )) then
				
					ourunitcount = ourunitcount + 1

                end

            end

            if ourunitcount > 0 then

                local goalposition = false

                if not AlliedPlatoon:GetPlatoonUnits()[1].Dead then

                    -- what I really need here is WHERE the Allied Platoon is going but this is close
                    goalposition = AlliedPlatoon:GetPlatoonUnits()[1]:GetNavigator():GetGoalPos()

                end

                local gotoposition = GetPlatoonPosition( AlliedPlatoon )

                for _, squad in Squads do

                    unitlist = GetSquadUnits(self,squad)

                    if unitlist[1] then

                        if PlatoonMergeDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." assigns "..LOUDGETN(unitlist).." units to "..repr(squad).." squad in "..repr(AlliedPlatoon.BuilderName).." "..repr(AlliedPlatoon.BuilderInstance) )
                        end

                        IssueClearCommands( unitlist )

                        for _, u in unitlist do

                            if not u.Dead then

                                if goalposition then
                                    IssueMove( {u}, RandomLocation(goalposition[1], goalposition[3], 11 ) )
                                else
                                    IssueMove( {u}, RandomLocation(gotoposition[1], gotoposition[3], 11 ) )
                                end

                            end

                        end
                        
                        AssignUnitsToPlatoon( aiBrain, AlliedPlatoon, unitlist, squad, 'none' )

                    end
                    
                end
			
				if PlatoonMergeDialog then
					LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." with "..ourunitcount.." units MERGED_INTO "..repr(AlliedPlatoon.BuilderName).." "..repr(AlliedPlatoon.BuilderInstance).." with "..alliedcount )
				end		

				return true
			end

            if PlatoonMergeDialog then
                if count > 0 then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." "..repr(self.BuilderInstance).." MERGE_INTO reviewed "..count.." platoons without merge")
                end
            end

        end

		return false
    end,

	SetupPlatoonAtWaypointCallbacks = function( platoon, waypoint, distance )
	
		platoon.MovingToWaypoint = true

        --LOG("*AI DEBUG "..platoon:GetBrain().Nickname.." MTWayPt "..repr(platoon.BuilderName).." "..repr(platoon.BuilderInstance).." sets MTWayPt trigger for "..repr(waypoint).." slack value "..repr(distance) )

		return CreatePlatoonToPositionDistanceTrigger( platoon.PlatoonAtWaypoint, platoon, waypoint, distance)
	end,
	
	PlatoonAtWaypoint = function( platoon, params )
    
        --LOG("*AI DEBUG "..platoon:GetBrain().Nickname.." "..repr(platoon.BuilderName).." "..repr(platoon.BuilderInstance).." now at Waypoint "..repr(params))

		local CmdQ = false
		
		for k,v in GetPlatoonUnits(platoon) do
		
			if not v.Dead then
			
				CmdQ = v:GetCommandQueue()
		
				break
			end
		end
		
		if CmdQ[2] then
		
			--LOG("*AI DEBUG Platoon still has "..LOUDGETN(CmdQ).." steps")
			
		else

            --LOG("*AI DEBUG "..platoon:GetBrain().Nickname.." "..repr(platoon.BuilderName).." "..repr(platoon.BuilderInstance).." stops "..repr(params))

			platoon:Stop()
		end

        --LOG("*AI DEBUG "..platoon:GetBrain().Nickname.." "..repr(platoon.BuilderName).." "..repr(platoon.BuilderInstance).." clears MovingToWaypoint ")

		platoon.MovingToWaypoint = false
		
		if platoon.WaypointCallback then
        
            --LOG("*AI DEBUG "..platoon:GetBrain().Nickname.." "..repr(platoon.BuilderName).." "..repr(platoon.BuilderInstance).." killing MoveThread")

			KillThread(platoon.WaypointCallback)
			platoon.WaypointCallback = false
		end
	end,
	
	SetupPlatoonAtGoalCallbacks = function( platoon, goalposition, distance )
		CreatePlatoonToPositionDistanceTrigger( platoon.PlatoonOnFinalStep, platoon, goalposition, distance)
	end,
	
	PlatoonOnFinalStep = function( self, params )
    
        local aiBrain = GetBrain(self)
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(self.BuilderName).." Platoon Triggers AtGoal params are "..repr(params) )
	end,

    -- will send reinforcement air platoons to randomly selected primary attack base ( Primary Land or Primary Sea )
    ReinforceAirAI = function( self )
    
        local GetThreatAtPosition = GetThreatAtPosition
        local LOUDGETN = LOUDGETN
        local LOUDINSERT = LOUDINSERT
        
        local Random = Random
    
        self:Stop()
		
        local aiBrain = GetBrain(self)
		
        local AttackBase1, AttackBase1Position = GetPrimaryLandAttackBase(aiBrain)	-- may return a false
		local AttackBase2, AttackBase2Position = GetPrimarySeaAttackBase(aiBrain) -- may return a false
		
		local selections = {}
		local count = 0
		
		if AttackBase1 then

			if self.RTBLocation != AttackBase1 then
			
				LOUDINSERT( selections, AttackBase1 )
				count = count + 1
			end
		end
		
		if AttackBase2 then
		
			if self.RTBLocation != AttackBase2 then
			
				LOUDINSERT( selections, AttackBase2 )
				count = count + 1
			end
		end

		-- the idea here is to give priority to the base which has the most nearby threat
		-- thus increasing the odds that this is the base which will get reinforced
		if AttackBase1 and AttackBase2 then
		
			local rings = 2
		
			if GetThreatAtPosition( aiBrain, AttackBase1Position, rings, true, 'Overall') > aiBrain:GetThreatAtPosition( AttackBase2Position, rings, true, 'Overall') then
			
				LOUDINSERT( selections, AttackBase1 )
			end

			if GetThreatAtPosition( aiBrain, AttackBase2Position, rings, true, 'Overall') > aiBrain:GetThreatAtPosition( AttackBase1Position, rings, true, 'Overall') then
			
				LOUDINSERT( selections, AttackBase2 )
			end
		end
		
		-- if there is more than one choice --
		if count > 0 then
		
			local choice = Random( 1, LOUDGETN(selections) )
			
			local AttackBase = selections[choice]
        
			if AttackBase and AttackBase != self.BuilderLocation then
		
				self.RTBLocation = AttackBase
			
				local units = GetPlatoonUnits(self)
			
				for _,v in units do
					v.LocationType = AttackBase
				end

				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			else
				LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_AIR "..repr(self.BuilderName).." got attack base same as source "..repr(self.RTBLocation).." selections are "..repr(selections) )
			end
		end

		return self:PlatoonDisband( aiBrain )
    end,
	
	-- this one will reinforce the Primary Land Attack position
    ReinforceAirLandAI = function( self )
        
        local LOUDGETN = LOUDGETN
        local LOUDINSERT = LOUDINSERT
        
        local Random = Random
    
        self:Stop()
		
        local aiBrain = GetBrain(self)
		
        local AttackBase1 = GetPrimaryLandAttackBase(aiBrain)	-- may return a false
		local AttackBase2 = false	
		
		local selections = {}
		local count = 0
		
		if AttackBase1 then

			if self.RTBLocation != AttackBase1 then
			
				LOUDINSERT( selections, AttackBase1 )
				count = count + 1
			end
		end
		
		if AttackBase2 then
		
			if self.RTBLocation != AttackBase2 then
			
				LOUDINSERT( selections, AttackBase2 )
				count = count + 1
			end
		end

		if count > 0 then
		
			local choice = Random( 1, LOUDGETN(selections) )
			
			local AttackBase = selections[choice]
        
			if AttackBase and AttackBase != self.BuilderLocation then
		
				self.RTBLocation = AttackBase
			
				local units = GetPlatoonUnits(self)
			
				for _,v in units do
					v.LocationType = AttackBase
				end
				
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
			else
				LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_AIR_LAND "..repr(self.BuilderName).." got attack base same as source "..repr(self.RTBLocation).." selections are "..repr(selections) )
			end
			
		end

		return self:PlatoonDisband( aiBrain )
    end,

	-- this one will reinforce the Primary Sea Attack position
    ReinforceAirNavalAI = function( self )
        
        local LOUDGETN = LOUDGETN
        local LOUDINSERT = LOUDINSERT
        
        local Random = Random
        
        self:Stop()
		
        local aiBrain = GetBrain(self)
		
        local AttackBase1 = GetBaseWithGreatestThreatAtDistance( aiBrain, 'NAVAL', 5, 350 )
		local AttackBase2 = GetPrimarySeaAttackBase(aiBrain) -- may return a false
		
		local selections = {}
		local count = 0
		
		if AttackBase1 then

			if self.RTBLocation != AttackBase1 then
			
				LOUDINSERT( selections, AttackBase1 )
				count = count + 1
			end
		end
		
		if AttackBase2 then
		
			if self.RTBLocation != AttackBase2 then
			
				LOUDINSERT( selections, AttackBase2 )
				count = count + 1
			end
		end

		if count > 0 then
		
			local choice = Random( 1, LOUDGETN(selections) )
			
			local AttackBase = selections[choice]
        
			if AttackBase and AttackBase != self.BuilderLocation then
		
				self.RTBLocation = AttackBase
			
				local units = GetPlatoonUnits(self)
			
				for _,v in units do
					v.LocationType = AttackBase
				end
				
				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
			else
				--LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_AIR_NAVAL "..repr(self.BuilderName).." got attack base same as source "..repr(self.RTBLocation))
			end
		end

		return self:PlatoonDisband( aiBrain )
    end,

    -- will send reinforcement amphib platoons to a primary attack base ( Primary Land or Primary Sea )
	-- the one which is closest to the Attack Planner goal
    ReinforceAmphibAI = function( self )

        local LOUDGETN = LOUDGETN
        local LOUDINSERT = LOUDINSERT
        local LOUDSORT = LOUDSORT
        
        self:Stop()
		
        local aiBrain = GetBrain(self)
		
        local AttackBase1, AttackBase1Position = GetPrimaryLandAttackBase(aiBrain)	-- may return a false
		local AttackBase2, AttackBase2Position = GetPrimarySeaAttackBase(aiBrain) -- may return a false

		local selections = {}
		local count = 0
		
		if AttackBase1 then

			if self.RTBLocation != AttackBase1 then
			
				LOUDINSERT( selections, AttackBase1 )
				count = count + 1
			end
		end
		
		if AttackBase2 then
		
			if self.RTBLocation != AttackBase2 then
			
				LOUDINSERT( selections, AttackBase2 )
				count = count + 1
			end
		end

		-- if there is more than one choice select the one closest to the attack plan goal --
		if count > 0 and aiBrain.AttackPlan.Goal != nil then

			-- sort the bases by distance to the attack plan goal
			LOUDSORT( selections, function(a,b) local VDist3Sq = VDist3Sq return VDist3Sq( aiBrain.BuilderManagers[a].Position, aiBrain.AttackPlan.Goal ) < VDist3Sq( aiBrain.BuilderManagers[b].Position, aiBrain.AttackPlan.Goal ) end )
			
			local AttackBase = selections[1]

			if AttackBase and AttackBase != self.BuilderLocation then
		
				self.RTBLocation = AttackBase
			
				local units = GetPlatoonUnits(self)
			
				for _,v in units do
					v.LocationType = AttackBase
				end

				return self:SetAIPlan('ReturnToBaseAI',aiBrain)
			
			else
				LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_AMPHIB "..repr(self.BuilderName).." got attack base same as source "..repr(self.RTBLocation))
			end
			
		else
            LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_AMPHIB from "..self.RTBLocation.." "..repr(self.BuilderName).." gets no reinforce goal - Primary Land "..repr(AttackBase1).." - Naval "..repr(AttackBase2).." - Goal "..repr(aiBrain.AttackPlanGoal) )
        end

		return self:PlatoonDisband( aiBrain )
		
    end,
	
	-- like above -- we could use platoon layers to establish where platoons can reinforce to
	-- for example, platoons on the Land layer could have Amphibious bases suppressed or vice versa
	-- thus allowing the creation of additional bases (ie. PrimaryAmphibBase)
    ReinforceLandAI = function( self )
        
        self:Stop()
		
        local aiBrain = GetBrain(self)
        local AttackBase = GetPrimaryLandAttackBase(aiBrain)
        
        if AttackBase and AttackBase != self.BuilderLocation then

            self.RTBLocation = AttackBase
			
			local units = GetPlatoonUnits(self)
			
            for _,v in units do
                v.LocationType = AttackBase
            end
			
			return self:SetAIPlan('ReturnToBaseAI',aiBrain)
        else
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_LAND "..repr(self.BuilderName).." from "..repr(self.BuilderLocation).." got primary land attack base same as source")

		end
		
        return self:PlatoonDisband( aiBrain )
    end,
	
    ReinforceNavalAI = function( self )
    
        self:Stop()
		
        local aiBrain = GetBrain(self)
        local AttackBase = GetPrimarySeaAttackBase(aiBrain)
        
        if AttackBase and AttackBase != self.BuilderLocation then

            self.RTBLocation = AttackBase

            for _,v in GetPlatoonUnits(self) do
                v.LocationType = AttackBase
            end
			
			return self:SetAIPlan( 'ReturnToBaseAI', aiBrain )
        else
		
			LOG("*AI DEBUG "..aiBrain.Nickname.." REINFORCE_NAVAL "..repr(self.BuilderName).." got primary sea attack base same as source")
		end
		
        return self:PlatoonDisband( aiBrain )
    end,

}
    
--[[
    DummyAI = function( self )
    end,
--]]
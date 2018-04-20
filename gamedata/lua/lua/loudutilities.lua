--  /lua/loudutilities.lua
--  LOUD specific things

-- You will find lots of useful notes in here 

local AIGetMarkersAroundLocation = import('/lua/ai/aiutilities.lua').AIGetMarkersAroundLocation
local AIPickEnemyLogic = import('/lua/ai/aiutilities.lua').AIPickEnemyLogic
local RandomLocation = import('/lua/ai/aiutilities.lua').RandomLocation

local AssignTransportToPool = import('/lua/ai/altaiutilities.lua').AssignTransportToPool

local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat
local AISendPing = import('/lua/ai/altaiutilities.lua').AISendPing

local LOUDENTITY = EntityCategoryContains
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove
local LOUDSORT = table.sort
local LOUDFLOOR = math.floor

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local WaitTicks = coroutine.yield
local VDist3 = VDist3

local GetCurrentUnits = moho.aibrain_methods.GetCurrentUnits
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetPosition = moho.entity_methods.GetPosition
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome

-- static version of function from EBC
function GreaterThanEnergyIncome(aiBrain, eIncome)

	return (GetEconomyIncome( aiBrain, 'ENERGY')*10) >= eIncome
	
end

-- static versions of functions from UCBC
function IsBaseExpansionUnderway(aiBrain, bool)

	return bool == aiBrain.BaseExpansionUnderway
	
end

function FactoryGreaterAtLocation( aiBrain, locationType, unitCount, testCat)

	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) > unitCount	
	
end

function UnitsLessAtLocation( aiBrain, locationType, unitCount, testCat )

	if aiBrain.BuilderManagers[locationType].EngineerManager then
	
		return GetNumUnitsAroundPoint( aiBrain, testCat, aiBrain.BuilderManagers[locationType].Position, aiBrain.BuilderManagers[locationType].EngineerManager.Radius, 'Ally') < unitCount
		
	end
	
	return false
	
end

function HaveGreaterThanUnitsWithCategory(aiBrain, numReq, testCat, idleReq)

    return GetCurrentUnits(aiBrain,testCat) > numReq

end

function HaveGreaterThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)

	return GetNumUnitsAroundPoint( aiBrain, testCat, Vector(0,0,0), 999999, alliance ) > numReq
	
end

function HaveLessThanUnitsWithCategory(aiBrain, numReq, testCat, idleReq)
	
    return GetCurrentUnits(aiBrain,testCat) < numReq
	
end


function UnitCapCheckGreater(aiBrain, percent)

	if aiBrain.IgnoreArmyCaps then
	
		return false
		
	end
	
    return ( GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) ) > percent 
	
end

function UnitCapCheckLess(aiBrain, percent)

	if aiBrain.IgnoreArmyCaps then
	
		return true
		
	end
	
	return ( GetArmyUnitCostTotal(aiBrain.ArmyIndex) / GetArmyUnitCap(aiBrain.ArmyIndex) ) < percent 	
	
end


-- This routine returns the location of the closest base that has engineers or factories
function AIFindClosestBuilderManagerPosition( aiBrain, position)

    local distance = 9999999
	local closest = false

    for k,v in aiBrain.BuilderManagers do
	
		if v.EngineerManager.Active then
		
			if v.EngineerManager.EngineerList.Count > 0 or v.FactoryManager:GetNumCategoryFactories(categories.FACTORY - categories.NAVAL) > 0 then
			
				if VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] ) <= distance then
				
					distance = VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] )
					closest = v.Position
					
				end
				
			end
			
        end
		
    end
	
    return closest
	
end

-- similar to above but returns the name of the location
-- a bit different in that it can filter FOR naval bases or filter OUT naval bases
function AIFindClosestBuilderManagerName( aiBrain, position, allownavalbases, onlynavalbases)

    local distance = 99999999
	local closest = false
	
    for k,v in aiBrain.BuilderManagers do
	
		if position and v.EngineerManager.Active then
		
			-- process all bases except 'Sea' unless allownavalbases is true and process only 'Sea' if onlynavalbases
			if (v.BaseType != 'Sea' and (not onlynavalbases)) or (v.BaseType == 'Sea' and allownavalbases) then
			
				if VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] ) < distance then
				
					distance = VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] )
					closest = v.BaseName
					
				end
				
			end
			
		end
		
    end

    return closest
	
end

-- Sorts the list of scouting areas by time since scouted, and then distance from main base.
function AISortScoutingAreas( aiBrain, list )

    local MainX = aiBrain.StartPosX
	local MainZ = aiBrain.StartPosZ
	
    LOUDSORT( list, function(a,b)	
	
		if a.LastScouted and b.LastScouted then
		
			if a.LastScouted == b.LastScouted then
		
				return VDist2Sq(MainX, MainZ, a.Position[1], a.Position[3]) < VDist2Sq(MainX, MainZ, b.Position[1], b.Position[3])
			
			else
		
				return a.LastScouted < b.LastScouted
			
			end
			
		else
		
			return a.LastScouted
			
		end
		
    end)
	
end


-- if the AI has its share of mass points
function HasMassPointShare( aiBrain )

	local LOUDGETN = table.getn

    local ArmyCount = 0
	local TeamCount = 0
	
    local NumMassPoints = ScenarioInfo.NumMassPoints
    
    for _,brain in ArmyBrains do
		
		local armyindex = brain.ArmyIndex
	
        if not brain:IsDefeated() and not ArmyIsCivilian(armyindex) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain.ArmyIndex, armyindex ) then
			
				TeamCount = TeamCount + 1 	-- number of players on this team
				
			end
			
        end
		
    end

	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	
    local extractorCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSEXTRACTION, false))
	local fabricatorCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.TECH3, false))
	local res_genCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.EXPERIMENTAL, false))
	
	extractorCount = extractorCount + (fabricatorCount * .5) + (res_genCount * 3)
	
	return extractorCount >= LOUDFLOOR( (NumMassPoints/ ArmyCount)-1 )
	
end

-- a variant of the above
function NeedMassPointShare( aiBrain )

	local LOUDGETN = table.getn

    local ArmyCount = 0
	local TeamCount = 0
    
    for _,brain in ArmyBrains do
		
		local armyindex = brain.ArmyIndex
	
        if not brain:IsDefeated() and not ArmyIsCivilian(armyindex) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain.ArmyIndex, armyindex ) then
			
				TeamCount = TeamCount + 1 	-- number of players on this team
				
			end
			
        end
		
    end

	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	
    local extractorCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSEXTRACTION, false))
	local fabricatorCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.TECH3, false))
	local res_genCount = LOUDGETN(GetListOfUnits(aiBrain,categories.MASSFABRICATION * categories.EXPERIMENTAL, false))
	
	extractorCount = extractorCount + (fabricatorCount * .5) + (res_genCount * 3)
	
	return extractorCount <= LOUDFLOOR( (ScenarioInfo.NumMassPoints/ ArmyCount)-1 )	
	
end

-- verifies if the TEAM has its share of mass points
function TeamMassPointShare( aiBrain, bool )

	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn

    local ArmyCount = 0
	local TeamCount = 0
    
    for _,brain in ArmyBrains do
		
		local armyindex = brain.ArmyIndex
	
        if not brain:IsDefeated() and not ArmyIsCivilian(armyindex) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain.ArmyIndex, armyindex ) then
			
				TeamCount = TeamCount + 1 	-- number of players on this team
				
			end
			
        end
		
    end

	local TeamExtractors = LOUDGETN(aiBrain:GetUnitsAroundPoint( categories.MASSEXTRACTION, Vector(0,0,0), 9999, 'Ally' ))
	local TeamNeeded = LOUDFLOOR( ((ScenarioInfo.NumMassPoints/ArmyCount) - 1) * TeamCount)
	
	if TeamExtractors >= TeamNeeded then
		
		if bool then
		
			return true
			
		end

		
	elseif TeamExtractors < TeamNeeded then
		
		if not bool then
		
			return true
			
		end
		
	end
	
	return false
	
end

-- returns true if the TEAM does not have its share of mass points
-- modified this so that T1 mass extractors DONT count
function NeedTeamMassPointShare( aiBrain )

	local LOUDFLOOR = math.floor

    local ArmyCount = 0
	local TeamCount = 0
    
    for _,brain in ArmyBrains do
	
        if not brain:IsDefeated() and not ArmyIsCivilian( brain.ArmyIndex ) then
		
			ArmyCount = ArmyCount + 1		-- number of players in the game
			
			if IsAlly( aiBrain.ArmyIndex, brain.ArmyIndex ) then
			
				TeamCount = TeamCount + 1 	-- number of players on this team
				
			end
			
        end
		
    end

	local TeamExtractors = LOUDGETN(aiBrain:GetUnitsAroundPoint( categories.MASSEXTRACTION - categories.TECH1, Vector(0,0,0), 9999, 'Ally' ))
	local TeamNeeded = LOUDFLOOR( ((ScenarioInfo.NumMassPoints/ArmyCount) - 1) * TeamCount)
	
	return TeamExtractors < TeamNeeded
	
end

-- if there is not a base alert at this location	
function NoBaseAlert( aiBrain, locType )

	if aiBrain.BuilderManagers[locType].EngineerManager.Active then
	
		return aiBrain.BuilderManagers[locType].EngineerManager.BaseMonitor.ActiveAlerts == 0
		
	end

	return true
	
end

function AirStrengthRatioGreaterThan( aiBrain, value )

	return aiBrain.AirRatio >= value
	
end

function AirStrengthRatioLessThan ( aiBrain, value )

	return aiBrain.AirRatio < value
	
end

function LandStrengthRatioGreaterThan( aiBrain, value )

	return aiBrain.LandRatio >= value
	
end

function LandStrengthRatioLessThan ( aiBrain, value )

	return aiBrain.LandRatio < value
	
end

function NavalStrengthRatioGreaterThan( aiBrain, value )

	return aiBrain.NavalRatio >= value
	
end

function NavalStrengthRatioLessThan ( aiBrain, value )

    return aiBrain.NavalRatio < value
	
end

function GetEnemyUnitsInRect( aiBrain, x1, z1, x2, z2 )
    
    local units = GetUnitsInRect(x1, z1, x2, z2)
    
    if units then
	
        local enemyunits = {}
		local counter = 0
		
        local IsEnemy = IsEnemy
		local GetAIBrain = moho.entity_methods.GetAIBrain
		
        for _,v in units do
		
            if not v.Dead and IsEnemy( GetAIBrain(v).ArmyIndex, aiBrain.ArmyIndex) then
			
                enemyunits[counter+1] =  v
				counter = counter + 1
				
            end
			
        end 
		
        if counter > 0 then
		
            return enemyunits, counter
			
        end
		
    end
    
    return {}, 0
	
end

function GreaterThanEnemyUnitsAroundBase( aiBrain, locationtype, numUnits, unitCat, radius )

    if aiBrain.BuilderManagers[locationtype] then
	
		return GetNumUnitsAroundPoint(aiBrain, unitCat, aiBrain.BuilderManagers[locationtype].Position, radius, 'Enemy') > numUnits
		
	end
	
	return false
	
end

-- gets units that are NOT in a platoon around a point
function GetFreeUnitsAroundPoint( aiBrain, category, location, radius, tmin, tmax, rings, tType )

    local units = aiBrain:GetUnitsAroundPoint( category, location, radius, 'Ally' )
    
    local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	
    local retUnits = {}
	local counter = 0
	
    local checkThreat = true	-- default to true which means include all if no threat check 
	local threat = 0
    
    if tmin and tmax and rings then -- if threat parameters provided validate threat and set checkThreat
	
		threat = GetThreatAtPosition( aiBrain, location, rings, true, tType or 'Overall' )
		
		checkThreat = (threat >= tmin and threat <= tmax)
		
    end
	
	if checkThreat then
	
		for k,v in units do
		
			if not v.Dead and not v:IsBeingBuilt() and v:GetAIBrain().ArmyIndex == aiBrain.ArmyIndex then
			
				-- select only units in the Army pool or not attached
				if not v.PlatoonHandle or v.PlatoonHandle == aiBrain.ArmyPool then

					retUnits[counter+1] = v
					counter = counter + 1

				end
				
			end
			
        end
		
    end
	
    return retUnits,counter
	
end

--	The SpawnWave is a bonus given only to the AIx
-- 	Essentially every spawndelay period, the AI will receive a few 'free' air units (based upon AIx cheat bonus.
--  The number gradually grows with each iteration over the course of the game and the period between
--  iterations gradually shrinks making the AIx an ever increasing threat.  Growth is capped at 10 iterations
function SpawnWaveThread( aiBrain )

	local initialUnits = false
	
	local testUnits = {}
	local coreunits = {}
	local faction = aiBrain.FactionIndex
	local startx, startz = aiBrain:GetArmyStartPos()
	local wave = 1
	
	local spawndelay = 1320 * (1 / tonumber(ScenarioInfo.Options.BuildMult))	-- every 22 minutes but reduced cheat build multiplier
	
	local hold_wave = true
    
    if faction == 1 then
	
		testUnits = { 'UEA0303', 'UEA0304', 'UEA0305', 'UEA0104', 'UEA0302' }
		
    elseif faction == 2 then
	
		testUnits = { 'UAA0303', 'UAA0304', 'XAA0305', 'UAA0104', 'UAA0302' }
		
    elseif faction == 3 then
	
		testUnits = { 'URA0303', 'URA0304', 'XRA0305', 'URA0104', 'URA0302' }
		
	elseif faction == 4 then
	
		testUnits = { 'XSA0303', 'XSA0304', 'XSA0203', 'XSA0104', 'XSA0302' }
		
    end
	
	-- validate our testUnits list against build restrictions --
	-- and build the initialUnits list of allowed unit id --
	for _,test_unit_id in testUnits do
	
		local Game = import('game.lua')
	
		if not Game.UnitRestricted( false, test_unit_id ) then
		
			-- if we haven't added a unit yet then convert
			-- initialUnits into a table
			if not initialUnits then 
			
				initialUnits = {}
				
			end
			
			-- add the unit to the list --
			table.insert(initialUnits, test_unit_id)
			
		end
		
	end
	
	--LOG("*AI DEBUG testunits is "..repr(testUnits))
	--LOG("*AI DEBUG initialUnits is "..repr(initialUnits))
	
	if initialUnits then
	
		LOG("*AI DEBUG "..aiBrain.Nickname.." Spawnwave initialized")
		
	end

	-- IF there is an initial units list then
	-- spawnwave will begin once the first T3 Air Factory is online - check every 60 seconds until it does
	while initialUnits do
	
		WaitSeconds(60)
	
		local T3AirFacs = aiBrain:GetListOfUnits( categories.AIR * categories.FACTORY * categories.TECH3, false )
		
		if table.getn(T3AirFacs) > 0 then
		
			for _,v in T3AirFacs do

				-- the factory must be fully built --
				if v:GetFractionComplete() == 1 then

					break
					
				end
				
			end
			
		end
		
	end
	
	local ArmyPool = aiBrain.ArmyPool

	while initialUnits do
		
		-- increase the size of the wave each time and vary it with the build cheat level
		local units = math.floor((wave * 2) * tonumber(ScenarioInfo.Options.BuildMult) )
		
		-- the unit we'll create
		local unit
		
		for spawn = 1, units do

			-- fighters --
			unit = aiBrain:CreateUnitNearSpot(initialUnits[1],startx,startz)
			SimulateFactoryBuilt( unit )
			WaitTicks(1)

			-- bombers --
			unit = aiBrain:CreateUnitNearSpot(initialUnits[2],startx,startz)
			SimulateFactoryBuilt( unit )
			WaitTicks(1)

			-- gunships --
			unit = aiBrain:CreateUnitNearSpot(initialUnits[3],startx,startz)
			SimulateFactoryBuilt( unit )
			WaitTicks(1)

			-- transports  --
			if spawn < 6 then
			
				unit = aiBrain:CreateUnitNearSpot(initialUnits[4],startx,startz)
				SimulateFactoryBuilt( unit )
				WaitTicks(1)
				
			end

			-- spy planes --
			unit = aiBrain:CreateUnitNearSpot(initialUnits[5],startx,startz)
			SimulateFactoryBuilt( unit )			
			WaitTicks(1)
			
		end
		
		wave = wave + 1

		if wave > 10 then
		
			wave = 10
			
		end
		
		-- we'll just send everything in the core to a disperse point --
		coreunits = GetFreeUnitsAroundPoint( aiBrain, categories.MOBILE - categories.ENGINEER, {startx, 0, startz}, 26 )
		
		DisperseUnitsToRallyPoints( aiBrain, coreunits, aiBrain.BuilderManagers['MAIN'].Position, aiBrain.BuilderManagers['MAIN'].RallyPoints )
		
		-- decrease the period until the next wave  -- modified by the build cheat level
		spawndelay = spawndelay - ( (30 - wave) * tonumber(ScenarioInfo.Options.BuildMult) )
		
		-- wait for the next spawn wave
		WaitTicks(spawndelay * 10)
		
	end
	
	aiBrain.WaveThread = nil
	
end

function SimulateFactoryBuilt (finishedUnit)

	-- this is a copy of what you'll find in the FactoryBuilderManager --
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
			finishedUnit:ForkThread( AssignTransportToPool, finishedUnit:GetAIBrain() )
			
		end
		
	end
	
end
	

-- Maintains table of platoons issuing distress calls and what kind of help they are looking for
-- The thread executes every 10 seconds and simly purges any distress entry more than 30 seconds old
-- or where the platoon that issued it is no longer around
-- Lastly - it maintains a flag to signify if there are ANY platoon distress calls at all
function PlatoonDistressMonitor( aiBrain )
	
	LOG("*AI DEBUG "..aiBrain.Nickname.." starts PlatoonDistressMonitor")

	-- create the data structure
    aiBrain.PlatoonDistress = { ['AlertSounded'] = false, ['Platoons'] = {} }

    local PlatoonExists = moho.aibrain_methods.PlatoonExists
	local LOUDGETN = table.getn
    local RebuildTable = aiBrain.RebuildTable

    local change = false

	while true do

		WaitTicks(100)

		if aiBrain.PlatoonDistress.AlertSounded then
		
			change = false

			for k,v in aiBrain.PlatoonDistress.Platoons do
			
				if (not PlatoonExists(aiBrain, v.Platoon)) or (GetGameTimeSeconds() - v.CreationTime > 30) then

					aiBrain.PlatoonDistress.Platoons[k] = nil
					change = true

					if PlatoonExists(aiBrain, v.Platoon) then
					
						v.Platoon.DistressCall = nil
						
					end
					
				end
				
			end

			if change then
		
				aiBrain.PlatoonDistress.Platoons = RebuildTable( aiBrain, aiBrain.PlatoonDistress.Platoons)

				if LOUDGETN(aiBrain.PlatoonDistress.Platoons) == 0 then
			
					aiBrain.PlatoonDistress.AlertSounded = false
					
				--else
				
					--LOG("*AI DEBUG "..aiBrain.Nickname.." is monitoring "..LOUDGETN(aiBrain.PlatoonDistress.Platoons).." distress platoons")
					
				end
			
			end
			
		end
		
	end
	
end


function DisperseUnitsToRallyPoints( aiBrain, units, position, rallypointtable )

	if not rallypointtable then

		local rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Rally Point', position, 90)
	
		if table.getn(rallypoints) < 1 then
		
			rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Naval Rally Point', position, 90)
			
		end
		
		rallypointtable = {}
		
		for _,v in rallypoints do
		
			table.insert( rallypointtable, v.Position )
			
		end
		
	end

	if table.getn(rallypointtable) > 0 then
	
		local rallycount = table.getn(rallypointtable)
		
		for _,u in units do
		
			local rp = rallypointtable[ Random( 1, rallycount) ]
			
			IssueMove( {u}, RandomLocation(rp[1],rp[3], 9))
			
		end
		
	else
	
		-- try and catch units being dispersed to what may now be a dead base --
		-- the idea is to drop them back into an RTB which should find another base
		--WARN("*AI DEBUG "..aiBrain.Nickname.." DISPERSE FAIL - No rally points at "..repr(position))

       	IssueClearCommands( units )

        local ident = Random(1,999999)

		returnpool = aiBrain:MakePlatoon('ReturnToBase '..tostring(ident), 'none' )

        returnpool.PlanName = 'ReturnToBaseAI'
        returnpool.BuilderName = 'DisperseFail'
		
        returnpool.BuilderLocation = false
		returnpool.RTBLocation = false

		import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer(returnpool) 

		for _,u in units do

			if not u.Dead then

				aiBrain:AssignUnitsToPlatoon( returnpool, {u}, 'Unassigned', 'None' )
				
				u.PlatoonHandle = {returnpool}
				u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
				
			end
			
		end
		
		if returnpool.MovementLayer == "Land" then

			-- dont use naval bases for land --
			returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), false )

		else

			if returnpool.MovementLayer == "Air" or returnpool.PlatoonLayer == "Amphibious" then

				-- use any kind of base --
				returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), true, false )

			else

				-- use only naval bases --
				returnpool.BuilderLocation = AIFindClosestBuilderManagerName( aiBrain, returnpool:GetPlatoonPosition(), true, true )

			end

		end

		returnpool.RTBLocation = returnpool.BuilderLocation	-- this should insure the RTB to that base

		--LOG("*AI DEBUG "..aiBrain.Nickname.." DISPERSE FAIL Platoon at "..repr(returnpool:GetPlatoonPosition()).." submitted to RTB at "..repr(returnpool.BuilderLocation))

		-- send the new platoon off to RTB
		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)
		
	end

	return
	
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimaryLandAttackBase( aiBrain )

    if aiBrain.AttackPlan.Goal then
    
        local goal = aiBrain.AttackPlan.Goal
        local Bases = {}
		local counter = 0

		local LOUDSORT = table.sort
        local VDist2Sq = VDist2Sq
		
		-- make a table of all land bases
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Land" then
			
				-- here is the distance calculation - very crude since it only accounts for the 'as the crow flies' distance
				-- ideally we should get a path (Land or Amphib) and use that value instead
				Bases[counter+1] = { BaseName = v.BaseName, Position = v.Position, Distance = VDist2Sq(v.Position[1],v.Position[3], goal[1],goal[3]) }
				counter = counter + 1
				
			end
			
        end
        
		-- sort them by distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)
        
        -- make the closest one the Primary
        local Primary = Bases[1].BaseName
        
        -- iterate thru all existing LAND bases
        for k,v in Bases do		--aiBrain.BuilderManagers do
			
			local builderManager = aiBrain.BuilderManagers[v.BaseName].PlatoonFormManager

			-- if the position is to be the primary --
			if v.BaseName == Primary then
				
				aiBrain.BuilderManagers[v.BaseName].PrimaryLandAttackBase = true

				aiBrain.PrimaryLandAttackBase = builderManager.LocationType

				-- if this is NOT already the current primary Land Attack Base
				-- save the current position on the brain and notify allies
				if not aiBrain.LastPrimaryLandAttackBase or aiBrain.LastPrimaryLandAttackBase != aiBrain.PrimaryLandAttackBase then
					
					LOG("*AI DEBUG "..aiBrain.Nickname.." PFM at "..builderManager.LocationType.." Set to Primary LAND Attack Base")
					
					-- reset the tasks with Priority Functions at this PFM
					builderManager:ForkThread( ResetPFMTasks, aiBrain )

					aiBrain.LastPrimaryLandAttackBase = aiBrain.PrimaryLandAttackBase or false
				
					-- if a human ally has requested status updates
					if aiBrain.DeliverStatus then
						
						ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My Primary LAND Base is now '..aiBrain.PrimaryLandAttackBase )

					end

				end

			-- if the location is not the primary
			-- check for any units that need to be moved up 
			else

				aiBrain.BuilderManagers[v.BaseName].PrimaryLandAttackBase = false

				builderManager:ForkThread( ClearOutBase, aiBrain )

			end
			
		end
		
    else
	
        aiBrain.BuilderManagers.MAIN.PrimaryLandAttackBase = true
		aiBrain.PrimaryLandAttackBase = 'MAIN'
		
    end
	
end

function GetPrimaryLandAttackBase( aiBrain )

	if aiBrain.PrimaryLandAttackBase then
	
		--LOG("*AI DEBUG Returning PLAB "..repr(aiBrain.PrimaryLandAttackBase))
		
		return aiBrain.PrimaryLandAttackBase, aiBrain.BuilderManagers[ aiBrain.PrimaryLandAttackBase ].Position
		
	end
	
	--LOG("*AI DEBUG Searching for Primary Land Attack Base")
   
    for k,v in aiBrain.BuilderManagers do
	
        if v.PrimaryLandAttackBase then
		
			LOG("*AI DEBUG Returning search for PLAB "..repr(k) )
			
            return k, v.Position
			
        end
		
    end
    
	WARN("*AI DEBUG "..aiBrain.Nickname.." has no Primary Land Attack Base")
	
    return false, nil
	
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimarySeaAttackBase( aiBrain )

    if aiBrain.AttackPlan.Goal then
    
        local goal = aiBrain.AttackPlan.Goal
        local Bases = {}
		local counter = 0

		local LOUDSORT = table.sort
        local VDist2Sq = VDist2Sq
		
		-- make a table of all sea bases
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Sea" then
			
				-- here is the distance calculation - very crude since it only accounts for the 'as the crow flies' distance
				-- ideally we should get a path (Land or Amphib) and use that value instead
				Bases[counter+1] = { BaseName = v.BaseName, Position = v.Position, Distance = VDist2Sq(v.Position[1],v.Position[3], goal[1],goal[3]) }
				counter = counter + 1
				
			end
			
        end
        
		-- sort them by distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)
		
        -- make the closest one the Primary
        local Primary = Bases[1].BaseName
        
        -- iterate thru all existing SEA bases
        for k,v in Bases do 	

			local builderManager = aiBrain.BuilderManagers[v.BaseName].PlatoonFormManager

			-- if the position is to be the primary --
			if v.BaseName == Primary then
				
				aiBrain.BuilderManagers[v.BaseName].PrimarySeaAttackBase = true

				aiBrain.PrimarySeaAttackBase = builderManager.LocationType

				-- if this is NOT already the current primary Land Attack Base
				-- save the current position on the brain and notify allies
				if not aiBrain.LastPrimarySeaAttackBase or aiBrain.LastPrimarySeaAttackBase != aiBrain.PrimarySeaAttackBase then
					
					LOG("*AI DEBUG "..aiBrain.Nickname.." PFM at "..builderManager.LocationType.." Set to Primary SEA ATTACK Base")
					
					-- reset the tasks with Priority Functions at this PFM
					builderManager:ForkThread( ResetPFMTasks, aiBrain )

					aiBrain.LastPrimarySeaAttackBase = aiBrain.PrimarySeaAttackBase or false
				
					-- if a human ally has requested status updates
					if aiBrain.DeliverStatus then
						
						ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My Primary SEA Base is now '..aiBrain.PrimarySeaAttackBase )

					end

				end

			-- if the location is not the primary
			-- check for any units that need to be moved up 
			else

				aiBrain.BuilderManagers[v.BaseName].PrimarySeaAttackBase = false
				
				builderManager:ForkThread( ClearOutBase, aiBrain )

			end
			
		end
		
    else
	
		aiBrain.PrimarySeaAttackBase = false
		
    end
	
end

function GetPrimarySeaAttackBase( aiBrain )

	if ScenarioInfo.IsWaterMap then

		if aiBrain.PrimarySeaAttackBase then
	
			--LOG("*AI DEBUG Returning PSAB "..repr(aiBrain.PrimarySeaAttackBase))
		
			return aiBrain.PrimarySeaAttackBase, aiBrain.BuilderManagers[ aiBrain.PrimarySeaAttackBase ].Position
		
		end
	
		--LOG("*AI DEBUG Searching for Primary Sea Attack Base")
   
		for k,v in aiBrain.BuilderManagers do
	
			if v.PrimarySeaAttackBase then
		
				LOG("*AI DEBUG Returning search for PSAB "..repr(k) )
			
				return k, v.Position
			
			end
		
		end
    
		WARN("*AI DEBUG "..aiBrain.Nickname.." has no Primary Sea Attack Base")
		
	end
	
    return false, nil
	
end

function ClearOutBase( manager, aiBrain )

	local basename = manager.LocationType
	local Position = aiBrain.BuilderManagers[basename].Position
	
	--LOG("*AI DEBUG "..aiBrain.Nickname.." CLEAROUTBASE "..repr(basename).." running ")
	
	-- all standard land units but Not experimentals 
	local grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.AMPHIBIOUS - categories.COMMAND - categories.ENGINEER - categories.INSIGNIFICANTUNIT, Position, 90 )

	if grouplndcount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutLand','none')

		plat.BuilderName = 'ClearOutPrimary Land'
		plat.BulderLocation = basename

		local counter = 0

		for _,unit in grouplnd do

			if counter < 90 then

				aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')
				counter = counter + 1

			else

				break
				
			end

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceLandAI', aiBrain )

	end
	
	-- all amphibious land units including experimentals
	local groupamphib, groupamphibcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.AMPHIBIOUS * categories.MOBILE) - categories.COMMAND - categories.ENGINEER - categories.INSIGNIFICANTUNIT, Position, 90 )

	if groupamphibcount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutAmphib','none')

		plat.BuilderName = 'ClearOutPrimary Amphib'
		plat.BulderLocation = basename

		local counter = 0

		for _,unit in groupamphib do

			if counter < 90 then

				aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')
				counter = counter + 1

			else

				break
				
			end

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceAmphibAI', aiBrain )

	end
	
	-- all naval units 
	local groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, (categories.NAVAL * categories.MOBILE) - categories.MOBILESONAR - categories.INSIGNIFICANTUNIT, Position, 90 )

	if groupseacount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutSea','none')

		plat.BuilderName = 'ClearOutPrimary Sea'
		plat.BulderLocation = basename

		local counter = 0

		for _,unit in groupsea do

			if counter < 50 then

				aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')
				counter = counter + 1

			else

				break

			end

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceNavalAI', aiBrain )

	end

	-- all fighter units
	local groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.MOBILE * categories.ANTIAIR), Position, 95 )

	if groupaircount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutFighters','none')

		plat.BuilderName = 'ClearOut Fighters'
		plat.BuilderLocation = basename

		for _,unit in groupair do

			aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceAirAI', aiBrain )	-- either Land or Sea

	end
	
	-- all gunship units
	groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.GROUNDATTACK ), Position, 95 )

	if groupaircount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutGunships','none')

		plat.BuilderName = 'ClearOut Gunships'
		plat.BuilderLocation = basename

		for _,unit in groupair do

			aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceAirAI', aiBrain )	-- either Land or Sea

	end	

	-- all bomber units
	groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), Position, 95 )

	if groupaircount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutBombers','none')

		plat.BuilderName = 'ClearOut Bombers'
		plat.BuilderLocation = basename

		for _,unit in groupair do

			aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceAirLandAI', aiBrain )	-- Land bases only

	end
	
	-- all torpedo bomber units but NOT experimentals
	groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.ANTINAVY * categories.AIR ), Position, 95 )

	if groupaircount > 0 then

		local plat = aiBrain:MakePlatoon('ClearOutTorpedo','none')

		plat.BuilderName = 'ClearOut Torps'
		plat.BuilderLocation = basename

		for _,unit in groupair do

			aiBrain:AssignUnitsToPlatoon(plat, {unit},'Attack','None')

		end

		plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

		plat:SetAIPlan( 'ReinforceAirNavalAI', aiBrain )	-- Naval bases only

	end	
	
	manager:ForkThread( ResetPFMTasks, aiBrain )
	
	return
	
end

function ResetPFMTasks (manager, aiBrain)
	
	-- Review ALL the PFM Builders for PriorityFunction task changes
	local tasksaltered = 0

	local newtasks = 0
	local temporary

	for _,b in manager.BuilderData['Any'].Builders do

		for c,d in b do

			if c == 'BuilderName' then

				local newPri = false

				if Builders[d].PriorityFunction then

					temporary = true

					newPri, temporary = Builders[d]:PriorityFunction( aiBrain, manager)

					if newPri and newPri != b.Priority then

						tasksaltered = tasksaltered + 1

						--LOG("*AI DEBUG "..aiBrain.Nickname.." "..manager.ManagerType.." at "..manager.LocationType.." "..b.BuilderName.." is set to "..repr(newPri).." Permanent is "..repr(not temporary))

						manager:SetBuilderPriority(b.BuilderName, newPri, temporary)

					end

				end

				if (not newPri and b.Priority > 99) or (newPri and newPri > 99) then

					newtasks = newtasks + 1

				end

			end

		end

	end

	manager.NumBuilders = newtasks	

end

-- whenever the AI cannot find enough transports to move a platoon
-- it sets a value on the brain to produce more -- this function
-- is run whenever a factory responds to that need and starts building them
function ResetBrainNeedsTransport( aiBrain )
    aiBrain.NeedTransports = false
end

-- this function will direct all air units (ex. Transports) into the refit/refuel process if needed
-- this is fired off by the OnRunOutOfFuel event which triggers it as a callback -- only used by the AI --
-- or during the ReturnToBaseAI function 
function ProcessAirUnits( unit, aiBrain )

	if not unit.Dead then
		
		if unit:GetFuelRatio() < .75 or unit:GetHealthPercent() < .80 then
			
			-- put air unit into the refuel pool -- 
			aiBrain:AssignUnitsToPlatoon( aiBrain.RefuelPool, {unit}, 'Support', 'none' )
			
			--LOG("*AI DEBUG "..aiBrain.Nickname.." ProcessAirUnits for  "..unit:GetBlueprint().Description )
	
			-- and send it off to the refit thread --
			unit:ForkThread( AirUnitRefitThread, aiBrain )
			
			return true

		end
		
	end
	
	return false
	
end

-- this function will attempt to get the air unit to a repair pad
-- and will wait until the unit is fueled and repaired
function AirUnitRefitThread( unit, aiBrain )

	local GetFuelRatio = moho.unit_methods.GetFuelRatio
	
	-- if not dead 
	if (not unit:BeenDestroyed()) then

		local fuellimit = .75
		local healthlimit = .80
		
		local fuel, health, unitpos, plats, closestairpad, distance
		local platpos, tempDist
		
		local rtbissued = false
	
		while (not unit.Dead) do
		
			fuel = GetFuelRatio(unit)
			health = unit:GetHealthPercent()
			
			if fuel < fuellimit or health < healthlimit then

				-- check for any airpads -- 
				if GetCurrentUnits( aiBrain, categories.AIRSTAGINGPLATFORM - categories.MOBILE) > 0 then
				
					unitPos = table.copy(GetPosition(unit))
					
					-- now limit to airpads within 15k
					plats = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint( aiBrain, categories.AIRSTAGINGPLATFORM - categories.MOBILE, unitPos, 1500 )
					
					-- Locate closest airpad
					if LOUDGETN( plats ) > 0 then
					
						closestairpad = false
						distance = 999000
						
						-- loop thru and see if they have room
						for _,airpad in plats do
						
							if not airpad.Dead then
							
								platPos = GetPosition(airpad)
								
								tempDist = VDist2( unitPos[1],unitPos[3], platPos[1],platPos[3] )
								
								if ( not closestairpad or tempDist < distance ) then
								
									closestairpad = airpad
									distance = tempDist
									
								end
								
							end
							
						end
						
						-- Begin loading/refit sequence
						if closestairpad then
						
							AirStagingThread (unit, closestairpad, aiBrain )
							
							--break
							
						end

					end
					
				else
				
					-- no airpad - just send them home --
					if not rtbissued then
					
						rtbissued = true
				
						--LOG("*AI DEBUG "..aiBrain.Nickname.." cannot find airpad")
					
						-- find closest base
						local baseposition = AIFindClosestBuilderManagerName( aiBrain, unit:GetPosition(), true, false)
					
						--LOG("*AI DEBUG "..aiBrain.Nickname.." closest base is "..repr(baseposition))
						
						if baseposition then

							IssueStop ( {unit} )
							IssueClearCommands( {unit} )
					
							IssueMove( {unit}, aiBrain.BuilderManagers[baseposition].Position )
							
						end
						
					end
					
				end
				
			-- otherwise we may have refueled/repaired ourselves or don't need it
			else
			
				break
				
			end
	
			WaitTicks(65)
			
		end
		
	end
	
	-- return repaired/refuelled unit to pool
	if not unit.Dead then
	
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit:GetBlueprint().Description.." leaving refit thread")

		-- all units except TRUE transports are returned to ArmyPool --
		if not LOUDENTITY( categories.TRANSPORTFOCUS, unit) or LOUDENTITY( categories.uea0203, unit ) then
	
			aiBrain:AssignUnitsToPlatoon( aiBrain.ArmyPool, {unit}, 'Unassigned', '' )
			
			unit.PlatoonHandle = aiBrain.ArmyPool
			
			DisperseUnitsToRallyPoints( aiBrain, {unit}, GetPosition(unit), false )
			
		else
		
			ForkThread( import('/lua/ai/altaiutilities.lua').ReturnTransportsToPool, aiBrain, {unit}, true )
			
		end
		
	end
end

-- this function will be called if an airunit finds an airstage to go to
function AirStagingThread( unit, airstage, aiBrain )

	local loadstatus = 0
	
	if not airstage:BeenDestroyed() then
		
		if not unit:BeenDestroyed() then
		
			--LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit:GetBlueprint().Description.." starts air staging")

			IssueStop( {unit} )
			IssueClearCommands( {unit} )
			
			IssueMove( {unit}, GetPosition(airstage) )

			if not (unit:BeenDestroyed() or airstage:BeenDestroyed()) and (not unit:IsUnitState('Attached')) then
			
				IssueTransportLoad( {unit}, airstage )
				unit:MarkWeaponsOnTransport(unit, true)		-- disable weapons so they wont seek targets -- I hope
				
			end
			
		end
		
	end

	local waitcount = 0
	
	-- loop until unit attached, idle, dead or it's fixed itself
	while not (unit:BeenDestroyed()) and not (airstage:BeenDestroyed()) do
		
		--if (not unit:IsUnitState('Attached') and (not unit:IsIdleState())) and (unit:GetFuelRatio() < .75 or unit:GetHealthPercent() < .80) then
		if (unit:GetFuelRatio() < .75 or unit:GetHealthPercent() < .80) then
		
			WaitTicks(10)
			
			--waitcount = waitcount + 1.0
			
			if VDist3( GetPosition(unit), GetPosition(airstage) ) < 16 then
				import('/lua/sim/buff.lua').ApplyBuff( unit, 'CheatAIRSTAGING')
			end
			
		else
		
			break
			
		end
		
	end
	
	-- get it off the airpad
	if (not unit:BeenDestroyed()) and unit:IsUnitState('Attached') then
	
		WaitTicks(10)
		
		-- we should be loaded onto airpad at this point
		-- some interesting behaviour here - usually when a unit is ready 
		-- it will lift off and exit by itself BUT
		-- sometimes we have to force it off -- when we do so we have
		-- to manually restore it's normal conditions (ie. - can take damage)
		if (not unit.Dead) and (not airstage.Dead) and unit:IsUnitState('Attached') then
		
			local ready = false
			
			while (not ready) and (not airstage.Dead) do
			
				if (not unit.Dead) and (unit:GetFuelRatio() > .85 and unit:GetHealthPercent() > .85)  then
					ready = true
					break
				end
				
				WaitTicks(15)
			end
			
			if ready and unit:IsUnitState('Attached') and (not unit.Dead) and (not airstage.Dead) then

				unit:DetachFrom()
				
				unit:SetCanTakeDamage(true)
				unit:SetDoNotTarget(false)
				unit:SetReclaimable(true)
				unit:SetCapturable(true)
				unit:ShowBone(0, true)
				unit:OnRemoveFromStorage(airstage)
			end
			
		end
		
		--LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit:GetBlueprint().Description.." leaves air staging")
		
	end
	
	if not unit.Dead then
	
		unit:MarkWeaponsOnTransport(unit, false)
		
	end	
	
end

-- this will return true or false depending upon if an enemy ANTITELEPORT
-- unit is in range of the location
function TeleportLocationBlocked( self, location )

	local aiBrain = self.unit:GetAIBrain()
	
	for num, brain in ArmyBrains do
	
		if not IsAlly( aiBrain.ArmyIndex, brain.ArmyIndex ) and aiBrain.Armyindex != brain.ArmyIndex then
		
			local unitList = brain:GetListOfUnits(categories.ANTITELEPORT, false)
			
			for i, unit in unitList do
			
				local noTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
				local atposition = unit:GetPosition()
				local targetdestdistance = VDist2(location[1], location[3], atposition[1], atposition[3])
				
				-- if the antiteleport range covers the targetlocation
				if noTeleDistance and noTeleDistance > targetdestdistance then
				
					FloatingEntityText(self.unit.Sync.id,'Teleportation Malfunction')
					
					-- play audio warning
					if GetFocusArmy() == self.unit:GetArmy() then
						local Voice = Sound {Bank = 'LOUD', Cue = 'AttackRequestFailed',}

						ForkThread(aiBrain.PlayVOSound, aiBrain, Voice, 'RemoteViewingFailed')
					end
					
					return true
				end
			end
		end
	end
	
	return false
end

--  I didn't much like doing this but it made sense in the end as
--  it was going to be a chaotic job to allow Black Ops Adv Command Units
--  to work otherwise - since they had code which stomps all over the std
--  AIEconomicBuilders file.  That's kind of rude - so I bypassed all
--  those issues and got a more streamlined adaptation in the process - yes indeed.
--  Now we dont need all those engineer platoons to use the unique upgrades
function BOACU_Installed( aiBrain )

	if not ScenarioInfo.BOACU_Checked then
		return false
	else
		return ScenarioInfo.BOACU_Installed
	end
	
end

function BOU_Installed( aiBrain )

	if not ScenarioInfo.BOU_Checked then
		return false
	else
		return ScenarioInfo.BOU_Installed
	end
	
end

function LOUD_IS_Installed( aiBrain )
	
	if not ScenarioInfo.LOUD_IS_Checked then
		return false
	else
		return ScenarioInfo.LOUD_IS_Installed
	end
end

-- Ok - a rather significant change here - I've moved all the custom units into global memory - Why ?
-- Simple - carrying it around on each brain is a waste -  and loading factions that aren't used is also wasteful
function AddCustomUnitSupport( aiBrain )
	
	--Loop through active mods
	for i, m in __active_mods do
	
		if m.name == 'BlackOps Adv Command Units' then
			LOG("*AI DEBUG BOACU installed")
			ScenarioInfo.BOACU_Checked = true
			ScenarioInfo.BOACU_Installed = true
		end

		if m.name == 'BlackOps Unleashed' then
			LOG("*AI DEBUG BOU installed")
			ScenarioInfo.BOU_Checked = true
			ScenarioInfo.BOU_Installed = true
		end
		
		if m.name == 'LOUD Integrated Storage' then
			LOG("*AI DEBUG LOUD Integrated Storage installed")
			ScenarioInfo.LOUD_IS_Checked = true
			ScenarioInfo.LOUD_IS_Installed = true
		end
		
		--If mod has a CustomUnits folder
		local CustomUnitFiles = DiskFindFiles(m.location..'/lua/CustomUnits', '*.lua')
		--LOG('*AI DEBUG: Custom unit files found: '..repr(CustomUnitFiles))
		
		--Loop through files in CustomUnits folder
		for k, v in CustomUnitFiles do
		
			local tempfile = import(v).UnitList
			
			--Add each files entry into the appropriate table
			for plat, tbl in tempfile do
			
				for fac, entry in tbl do
				
					-- only add those that are same faction as the AI
					if fac == aiBrain.FactionName then
					
						if not ScenarioInfo.CustomUnits then
							ScenarioInfo.CustomUnits = {}
						end
				
						if ScenarioInfo.CustomUnits[plat] and ScenarioInfo.CustomUnits[plat][fac] then
							--LOG('*AI DEBUG: Adding to EXISTING template and EXISTING faction: '..plat..' faction = '..fac..' new ID = '..entry[1]..' chance = '..entry[2] )
							LOUDINSERT(ScenarioInfo.CustomUnits[plat][fac], { entry[1], entry[2] } )
						
						elseif ScenarioInfo.CustomUnits[plat] then
							--LOG('*AI DEBUG: Adding to EXISTING template and NEW faction: '..plat..' faction = '..fac..' new ID = '..entry[1]..' chance = '..entry[2] )                    
							ScenarioInfo.CustomUnits[plat][fac] = {}
							LOUDINSERT(ScenarioInfo.CustomUnits[plat][fac], { entry[1], entry[2] } )
						
						else
							--LOG('*AI DEBUG: Adding to NEW template and NEW faction: '..plat..' faction = '..fac..' new ID = '..entry[1]..' chance = '..entry[2] )
							ScenarioInfo.CustomUnits[plat] = {}
							ScenarioInfo.CustomUnits[plat][fac] = {}
							LOUDINSERT(ScenarioInfo.CustomUnits[plat][fac], { entry[1], entry[2] } )
						end
					end
				end
			end
		end
	end
end

-- names Engineer units with Sync id and current platoon name (enabled in InitializeSkirmishSystems)
-- useful for debugging engineer activities	-- the custom name is cleared in ReturnToBaseAI function when job is finished
function NameEngineerUnits( platoon, aiBrain )

	if ScenarioInfo.NameEngineers then
		
		local eng = platoon:GetPlatoonUnits()[1] or false

		if eng and not eng.Dead then

			if LOUDENTITY( categories.ENGINEER - categories.SUBCOMMANDER - categories.COMMAND, eng ) and eng.PlatoonHandle.BuilderName then

				eng:SetCustomName("Eng " .. eng.Sync.id .. ": " .. eng.PlatoonHandle.BuilderName)

			elseif LOUDENTITY( categories.SUBCOMMANDER, eng) and eng.PlatoonHandle.BuilderName then

				eng:SetCustomName("SCU " .. eng.Sync.id .. ": " .. eng.PlatoonHandle.BuilderName)

			elseif LOUDENTITY( categories.COMMAND, eng) and eng.PlatoonHandle.BuilderName then

				eng:SetCustomName( aiBrain.Nickname.." ".. eng.PlatoonHandle.BuilderName)

			end
		end
	end
end

-- Records economy values every 10 ticks - builds array of 90 sample points
-- which covers the values of the last 90 seconds - used as trend analysis
-- added in average Mass and Energy Trends
function EconomyMonitor( aiBrain )
	
    aiBrain.EcoData = { ['EnergyIncome'] = {}, ['EnergyRequested'] = {}, ['EnergyTrend'] = {}, ['MassIncome'] = {}, ['MassRequested'] = {}, ['MassTrend'] = {}, ['Period'] = 900, ['OverTime'] = { EnergyEfficiency = 0, EnergyIncome = 0, EnergyRequested = 0, EnergyTrend = 0, MassEfficiency = 0, MassIncome = 0, MassRequested = 0, MassTrend = 0} }

	-- number of sample points
	local point
	local samplerate = 10
	local samples = aiBrain.EcoData['Period'] / samplerate

	-- create the table to store the samples
	for point = 1, samples do
		aiBrain.EcoData['EnergyIncome'][point] = 0
		aiBrain.EcoData['EnergyRequested'][point] = 0
		aiBrain.EcoData['EnergyTrend'][point] = 0
		aiBrain.EcoData['MassIncome'][point] = 0
		aiBrain.EcoData['MassRequested'][point] = 0
		aiBrain.EcoData['MassTrend'][point] = 0
	end    

    local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
    local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
	local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend

	local LOUDMIN = math.min
	local LOUDMAX = math.max
	local WaitTicks = coroutine.yield

	-- array totals
    local eIncome = 0
    local mIncome = 0
    local eRequested = 0
    local mRequested = 0
	local eTrend = 0
	local mTrend = 0

	local samplefactor = 1/samples

    local EcoData = aiBrain.EcoData

    local EcoDataEnergyIncome = EcoData['EnergyIncome']
    local EcoDataMassIncome = EcoData['MassIncome']
    local EcoDataEnergyRequested = EcoData['EnergyRequested']
    local EcoDataMassRequested = EcoData['MassRequested']
    local EcoDataEnergyTrend = EcoData['EnergyTrend']
    local EcoDataMassTrend = EcoData['MassTrend']

    local EcoDataOverTime = EcoData['OverTime']

    while true do

		for point = 1, samples do

			eIncome = eIncome - EcoDataEnergyIncome[point]
			mIncome = mIncome - EcoDataMassIncome[point]
			eRequested = eRequested - EcoDataEnergyRequested[point]
			mRequested = mRequested - EcoDataMassRequested[point]
			eTrend = eTrend - EcoDataEnergyTrend[point]
			mTrend = mTrend - EcoDataMassTrend[point]

			EcoDataEnergyIncome[point] = GetEconomyIncome( aiBrain, 'ENERGY')
			EcoDataMassIncome[point] = GetEconomyIncome( aiBrain, 'MASS')

			EcoDataEnergyRequested[point] = GetEconomyRequested( aiBrain, 'ENERGY')
			EcoDataMassRequested[point] = GetEconomyRequested( aiBrain, 'MASS')

			local e = GetEconomyTrend( aiBrain, 'ENERGY')
			local m = GetEconomyTrend( aiBrain, 'MASS')

			if e > 0.1 then
				EcoDataEnergyTrend[point] = e
			else
				EcoDataEnergyTrend[point] = 0.1
			end
			
			if m > 0.1 then
				EcoDataMassTrend[point] = m
			else
				EcoDataMassTrend[point] = 0.1
			end

			eIncome = eIncome + EcoDataEnergyIncome[point]
			mIncome = mIncome + EcoDataMassIncome[point]
			eRequested = eRequested + EcoDataEnergyRequested[point]
			mRequested = mRequested + EcoDataMassRequested[point]
			eTrend = eTrend + EcoDataEnergyTrend[point]
			mTrend = mTrend + EcoDataMassTrend[point]

			EcoDataOverTime['EnergyIncome'] = eIncome * samplefactor
			EcoDataOverTime['MassIncome'] = mIncome * samplefactor
			EcoDataOverTime['EnergyRequested'] = eRequested * samplefactor
			EcoDataOverTime['MassRequested'] = mRequested * samplefactor
			EcoDataOverTime['EnergyTrend'] = eTrend * samplefactor
			EcoDataOverTime['MassTrend'] = mTrend * samplefactor

			EcoDataOverTime['EnergyEfficiency'] = LOUDMIN( (eIncome * samplefactor) / (eRequested * samplefactor), 2)
			EcoDataOverTime['MassEfficiency'] = LOUDMIN( (mIncome * samplefactor) / (mRequested * samplefactor), 2)
			
			WaitTicks(samplerate)
		end
    end
end

	-- Wow - look how crude and heavy handed my first function was !
	--
	-- GetBasePerimeterPoints  
	--
	--  This function will generate a set of 12 points around a given location
	--  The distance of the points is controlled by the radius value 
	--  If the radius value < 4 then just a single centrepoint is returned
	--
	--  The second more unique aspect of this function is to return an 'orientation' - in other words, a value
	--  is calculated which results in one of the four cardinal directions (E,W,N,S) -- this represents the closest
	--  approximation facing the centre of the map.
	--  
	--  By specifying an orientation value ('FRONT','REAR' or 'ALL') you can return a subset of the 12 generated points
	--  The orientation value can be FRONT, REAR or ALL (default) respectively returning 9, 3 or all 12 points
	--
	--  By specifying a postitionselection value ('false', 'true' or a value) you can specifiy the number of points returned
	--  either all points, a randomly selected point, or a specific point
	--
	--  The layer and patroltype values work together to alter the sequence of the points returned
	--  If the layer is Air or a patroltype is not nil, the points will be organized to form a roughly circular shape
	--  otherwise, the points will be returned in a sequence of those closest to map centre first 
	--  one is useful for patrol paths, the other for building positions at a base
function GetBasePerimeterPoints( aiBrain, location, radius, orientation, positionselection, layer, patroltype )

	local LOUDCEIL = math.ceil
	local GetDirectionInDegrees = import('/lua/utilities.lua').GetDirectionInDegrees
    
	local newloc = false
	local Orient = false
	local Basename = false
	
	-- we've been fed a base name rather than 3D co-ordinates
	-- store the Basename and convert location into a 3D position
	if type(location) == 'string' then
	
		Basename = location
		newloc = aiBrain.BuilderManagers[location].Position or false
		Orient = aiBrain.BuilderManagers[location].Orientation or false
		
		if newloc then
			location = table.copy(newloc)
		end
		
	end

	-- we dont have a valid 3D location
	-- likely base is no longer active --
	if not location[3] then
		return {}
	end

	if not layer then
		layer = 'Amphibious'
	end

	if not patroltype then
		patroltype = false
	end

	-- get the map dimension sizes
	local Mx = ScenarioInfo.size[1]
	local Mz = ScenarioInfo.size[2]	
	
	if orientation then
	
		local Sx = LOUDCEIL(location[1])
		local Sz = LOUDCEIL(location[3])
		
		if not Orient then

			-- tracks if we used threat to determine Orientation
			local Direction = false
			
			local threats = aiBrain:GetThreatsAroundPosition( location, 32, true, 'Economy' )
			
			LOUDSORT( threats, function(a,b) return VDist2(a[1],a[2],location[1],location[3]) + a[3] < VDist2(b[1],b[2],location[1],location[3]) + b[3] end )
			
			for _,v in threats do
			
				Direction = GetDirectionInDegrees( {v[1],location[2],v[2]}, location )
				break	-- process only the first one
				
			end
			
			if Direction then
			
				if Direction < 45 or Direction > 315 then
					Orient = 'S'
				elseif Direction >= 45 and Direction < 135 then
					Orient = 'E'
				elseif Direction >= 135 and Direction < 225 then
					Orient = 'N'
				else
					Orient = 'W'
				end

			else
				-- Use map position to determine orientation
				-- First step is too determine if you're in the top or bottom 25% of the map
				-- if you are then you will orient N or S otherwise E or W
				-- the OrientvalueREAR will be set to value of the REAR positions (either the X or Z value depending upon NSEW Orient value)

				-- check if upper or lower quarter		
				if ( Sz <= (Mz * .25) or Sz >= (Mz * .75) ) then
					Orient = 'NS'
				-- otherwise use East/West orientation
				else
					Orient = 'EW'
				end

				-- orientation will be overridden if we are particularily close to a map edge
				-- check if extremely close to an edge (within 11% of map size)
				if (Sz <= (Mz * .11) or Sz >= (Mz * .89)) then
					Orient = 'NS'
				end

				if (Sx <= (Mx * .11) or Sx >= (Mx * .89)) then
					Orient = 'EW'
				end

				-- Second step is to determine if we are N or S - or - E or W
				
				if Orient == 'NS' then 
					-- if N/S and in the lower half of map
					if (Sz > (Mz* 0.5)) then
						Orient = 'N'
					-- else we must be in upper half
					else	
						Orient = 'S'
					end
				else
					-- if E/W and we are in the right side of the map
					if (Sx > (Mx* 0.5)) then
						Orient = 'W'
					-- else we must on the left side
					else
						Orient = 'E'
					end
				end
			end

			-- store the Orientation for any given base
			if Basename then
				aiBrain.BuilderManagers[Basename].Orientation = Orient		
			end
		end
		
		if Orient == 'S' then
		
			OrientvalueREAR = Sz - radius
			OrientvalueFRONT = Sz + radius		
			
		elseif Orient == 'E' then
		
			OrientvalueREAR = Sx - radius
			OrientvalueFRONT = Sx + radius
			
		elseif Orient == 'N' then
		
			OrientvalueREAR = Sz + radius
			OrientvalueFRONT = Sz - radius
			
		elseif Orient == 'W' then
		
			OrientvalueREAR = Sx + radius
			OrientvalueFRONT = Sz - radius
			
		end
		
	end

	-- If radius is very small just return the centre point and orientation
	-- this is often used by engineers to build structures according to a base template with fixed positions
	-- and still maintain the appropriate rotation -- 
	if radius < 4 then
		return { {location[1],0,location[3]} }, Orient
	end	

	local locList = {}
	local counter = 0

	local lowlimit = (radius * -1)
	local highlimit = radius
	local steplimit = (radius / 2)
	
	-- build an array of points in the shape of a box w 5 points to a side
	-- eliminating the corner positions along the way
	-- the points will be numbered from upper left to lower right
	-- this code will always return the 12 points around whatever position it is fed
	-- even if those points result in some point off of the map
	for x = lowlimit, highlimit, steplimit do
		
		for y = lowlimit, highlimit, steplimit do
			
			-- this code lops off the corners of the box and the interior points leaving us with 3 points to a side
			-- basically it forms a '+' shape
			if not (x == 0 and y == 0)	and	(x == lowlimit or y == lowlimit or x == highlimit or y == highlimit)
			and not ((x == lowlimit and y == lowlimit) or (x == lowlimit and y == highlimit)
			or ( x == highlimit and y == highlimit) or ( x == highlimit and y == lowlimit)) then
			
				locList[counter+1] = { LOUDCEIL(location[1] + x), GetSurfaceHeight(location[1] + x, location[3] + y), LOUDCEIL(location[3] + y) }
				counter = counter + 1
			end
		end
	end

	-- if we have an orientation build a list of those points that meet that specification
	-- FRONT will have all points that do not match the OrientvalueREAR (9 points)
	-- REAR will have all point that DO match the OrientvalueREAR (3 points)
	-- otherwise we keep all 12 generated points
	if orientation == 'FRONT' or orientation == 'REAR' then
		
		local filterList = {}
		counter = 0

		for k,v in locList do
			local x = v[1]
			local z = v[3]

			if Orient == 'N' or Orient == 'S' then
				if orientation == 'FRONT' and z != OrientvalueREAR then
					filterList[counter+1] = v
					counter = counter + 1
				elseif orientation == 'REAR' and z == OrientvalueREAR then
					filterList[counter+1] = v
					counter = counter + 1
				end
			elseif Orient == 'W' or Orient == 'E' then
				if orientation == 'FRONT' and x != OrientvalueREAR then
					filterList[counter+1] = v
					counter = counter + 1
				elseif orientation == 'REAR' and x == OrientvalueREAR then
					filterList[counter+1] = v
					counter = counter + 1
				end
			end
		end
		locList = filterList
	end
	
	-- sort the points from front to rear based upon orientation
	if Orient == 'N' then
		table.sort(locList, function(a,b) return a[3] < b[3] end)
	elseif Orient == 'S' then
		table.sort(locList, function(a,b) return a[3] > b[3] end)
	elseif Orient == 'E' then 
		table.sort(locList, function(a,b) return a[1] > b[1] end)
	elseif Orient == 'W' then
		table.sort(locList, function(a,b) return a[1] < b[1] end)
	end

	local sortedList = {}
	
	if table.getsize(locList) == 0 then
		return {} 
	end
	
	-- Originally I always did this and it worked just fine but I want
	-- to find a way to get the AI to rotate templated builds so I need
	-- to provide a consistent result based upon orientation and NOT 
	-- sorted by proximity to map centre -- as I had been doing -- so 
	-- now I only sort the list if its a patrol or Air request
	-- I have kept the original code contained inside this loop but 
	-- it doesn't run
	if patroltype or layer == 'Air' then
		local lastX = Mx* 0.5
		local lastZ = Mz* 0.5
	
		if patroltype or layer == 'Air' then
			lastX = location[1]
			lastZ = location[3]
		end
		
	
		-- Sort points by distance from (lastX, lastZ) - map centre
		-- or if patrol or 'Air', then from the provided location
		for i = 1, counter do
		
			local lowest
			local czX, czZ, pos, distance, key
		
			for k, v in locList do
				local x = v[1]
				local z = v[3]
				
				distance = VDist2Sq(lastX, lastZ, x, z)
				
				if not lowest or distance < lowest then
					pos = v
					lowest = distance
					key = k
				end
			end
		
			if not pos then
				return {} 
			end
		
			sortedList[i] = pos
			
			-- use the last point selected as the start point for the next distance check
			if patroltype or layer == 'Air' then
				lastX = pos[1]
				lastZ = pos[3]
			end
			LOUDREMOVE(locList, key)
		end
	else
		sortedList = locList
	end

	-- pick a specific position
	if positionselection then
	
		if type(positionselection) == 'boolean' then
			positionselection = Random( 1, counter )	--table.getn(sortedList))
		end

	end


	return sortedList, Orient, positionselection
end

-- This function will generate a set of rally points around a given position at the given radius.
-- This eliminates the need for Naval or Land rally points to be set up with the marker editor
-- It insures consistent layout and eliminates the need to load rally points that 
-- may not even get used in the course of a game
function SetBaseRallyPoints( aiBrain, basename, basetype, rallypointradius, orientation )

	--LOG("*AI DEBUG "..aiBrain.Nickname.." sets Base Rally points for "..basename)
	
	local markertype = "Rally Point"
	local orientation = orientation or 'ALL'
	
	if basetype == "Sea" then
		markertype = "Naval Rally Point"
	end
	
	if not ScenarioInfo.Env.Scenario.MasterChain[markertype] then
		ScenarioInfo.Env.Scenario.MasterChain[markertype] = {}
	end
	
	local rallypointtable = {}
	
	for _,v in GetBasePerimeterPoints( aiBrain, basename, rallypointradius, orientation ) do
		-- I should put a check in here that confirms that the surface level differs by less than 5 units
		-- that would prevent the rally points from being on essentially different terrain that the base
		-- for example - a base near water would not put rally points in water - or rally points half way
		-- up a steep mountain
		table.insert(ScenarioInfo.Env.Scenario.MasterChain[markertype], { Name = markertype, Position = { v[1], v[2], v[3] } } )
		table.insert(rallypointtable, { v[1], v[2], v[3] }  )
	end
	
	return rallypointtable
end

-- This function will remove the rally points that were generated by the above function
-- this happens when a base manager is terminated
function RemoveBaseRallyPoints( aiBrain, basename, basetype, rallypointradius )

	local markertype = "Rally Point"
	
	if basetype == "Sea" then
		markertype = "Naval Rally Point"
	end
	
	for _,v in GetBasePerimeterPoints( aiBrain, basename, rallypointradius, 'ALL' ) do
		for k,r in ScenarioInfo.Env.Scenario.MasterChain[markertype] do
			if v[1] == r.Position[1] and v[3] == r.Position[3] then
				table.remove(ScenarioInfo.Env.Scenario.MasterChain[markertype], k )
			end
		end
	end
end


-- the DBM is designed to monitor the status of all Base Managers and shut them down if they are no longer valid
-- no longer valid means no engineers AND no factories for at least 200 seconds (10 loops)
-- This only applies to CountedBases -- non-counted bases are destroyed when all structures within 32 are dead
function DeadBaseMonitor( aiBrain )

	LOG("*AI DEBUG "..aiBrain.Nickname.." Dead Base Monitor begins..")

	WaitTicks(1800)	#-- dont start for 3 minutes

	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
    local RebuildTable = aiBrain.RebuildTable
	
	local changed, structurecount, platland, platair, platsea
	
	local grouplnd, grouplndcount, counter
	local groupair, groupaircount
	local groupsea, groupseacount

	while true do

		for k,v in aiBrain.BuilderManagers do
			
			changed = false
			structurecount = 0

			platland = false
			platair = false
			platsea = false

			if not v.CountedBase then
			
				structurecount = LOUDGETN(import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint( aiBrain, categories.STRUCTURE - categories.WALL, v.Position, 32))
				
			end

			-- if a base has no factories
			if (v.CountedBase and v.FactoryManager:GetNumCategoryFactories(categories.FACTORY) <= 0) or
				(not v.CountedBase and structurecount < 1) then
				
				-- increase the nofactory counter
				aiBrain.BuilderManagers[k].nofactorycount = aiBrain.BuilderManagers[k].nofactorycount + 1

				-- if base has no engineers AND has had no factories for about 200 seconds
				if v.EngineerManager:GetNumCategoryUnits(categories.ALLUNITS) <= 0 and aiBrain.BuilderManagers[k].nofactorycount >= 10 then
					
					-- handle the MAIN base
					if k == 'MAIN' then
					
						LOG("*AI DEBUG Detected Dead MAIN Base")

						-- Kill WaveSpawn thread if exists
						if aiBrain.WaveThread then
						
							LOG("*AI DEBUG Kill WaveSpawn Thread")
							
							KillThread(aiBrain.WaveThread)
							
							aiBrain.WaveThread = nil
							
						end

						-- record MainBaseDead
						aiBrain.MainBaseDead = true
						
					end

					-- clear any Primary flags
                    v.PrimaryLandAttackBase = false
					v.PrimarySeaAttackBase = false


					-- remove the dynamic rally points - using the basename (k) now instead of v.position
					RemoveBaseRallyPoints( aiBrain, k, v.BaseType, v.RallyPointRadius )
					
					-- disable and destroy the EM at this base (this will end BaseDistress and prevent the base from being re-selected as a Primary)
					if v.EngineerManager then
					
						v.EngineerManager:SetEnabled(aiBrain,false)
						v.EngineerManager:Destroy()
						
					end

					-- check if new primary bases are needed
					SetPrimaryLandAttackBase(aiBrain)
					SetPrimarySeaAttackBase(aiBrain)
					
					-- then clear it out
					ClearOutBase( v.PlatoonFormManager, aiBrain )
					
					-- disable and destroy the FBM and PFM now
					if v.FactoryManager then
					
						v.FactoryManager:SetEnabled(aiBrain,false)
						v.FactoryManager:Destroy()
						
					end
					
					if v.PlatoonFormManager then
					
						v.PlatoonFormManager:SetEnabled(aiBrain,false)
						v.PlatoonFormManager:Destroy()
						
					end

					-- update the base counter
					if v.CountedBase then
					
						if v.BaseType == 'Sea' then
						
							aiBrain.NumBasesNaval = aiBrain.NumBasesNaval - 1
							
						else
						
							aiBrain.NumBasesLand = aiBrain.NumBasesLand - 1
							
						end
					
						aiBrain.NumBases = aiBrain.NumBases - 1
						
					end

					-- remove the visible marker from the map
					if ScenarioInfo.DisplayBaseNames then
					
						ForkThread( RemoveBaseMarker, aiBrain, k, aiBrain.BuilderManagers[k].MarkerID)
						
					end
					
					--LOG("*AI DEBUG "..aiBrain.Nickname.." removing base "..repr(v.BaseName).." key is "..repr(k))

					-- remove base from table
                    aiBrain.BuilderManagers[k] = nil
					
					-- rebuild the bases table
					aiBrain.BuilderManagers = RebuildTable(aiBrain, aiBrain.BuilderManagers)

					break -- we changed -- start at the top again					
				
				end

			else
			
				aiBrain.BuilderManagers[k].nofactorycount = 0
				
			end
			
			WaitTicks(8)
			
		end
		
		WaitTicks(200)	#-- check every 20 seconds
		
	end
	
end

-- this will start the individual path generators
function PathGeneratorThread( aiBrain )
	
	aiBrain.PathRequests = { ['Air'] = {}, ['Amphibious'] = {}, ['Land'] = {}, ['Replies'] = {} }

	-- setup the path tables with precalculated distances
	if not ScenarioInfo.PathGraphs then
		import('/lua/ai/aiattackutilities.lua').GetPathGraphs()
	end
	-- the maximum possible distance you can travel on a map - corner to corner
	if not aiBrain.dist_comp then
		aiBrain.dist_comp = ( math.pow(ScenarioInfo.size[1],2) + math.pow(ScenarioInfo.size[2],2) )
		LOG("*AI DEBUG Setting Maximum distance value for this map to "..aiBrain.dist_comp)
	end

	WaitSeconds(20)

	-- start the path generators
	LOG("*AI DEBUG "..aiBrain.Nickname.." Starting Path Generators")
	
	aiBrain:ForkThread1( PathGeneratorAir )
	aiBrain:ForkThread1( PathGeneratorAmphibious )
	aiBrain:ForkThread1( PathGeneratorLand )

	if ScenarioInfo.IsWaterMap then
        aiBrain.PathRequests['Water'] = {}
		aiBrain:ForkThread1( PathGeneratorWater )
	end
end	

-- This particular version of the pathgenerator takes into account casualties along the path
-- which makes path selections sensitive to threat that might prevent them from getting to a goal
function PathGeneratorAir( aiBrain )
	
	-- localize this often used function
    local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions

	local LOUDCOPY = table.copy
	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local VDist2 = VDist2

	local WaitTicks = coroutine.yield

	local dist_comp = aiBrain.dist_comp
	
	-- get the table with all the nodes for this layer
	local graph = ScenarioInfo.PathGraphs['Air']

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
		local checkrange = (stepsize * stepsize)
	
		if steps > 0 then

			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
	
			for i = 1, steps do

				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) <= checkrange then
					return true
				end
			end	
		end
	
		return false
	end

	--this is the function which evaluates all the branches for a given node
	local AStarLoopBody = function( data, queue, closed)
		
		local queueitem = LOUDREMOVE(queue, 1)

		if closed[queueitem.Node[1]] then
			return false, 0, false
		end


		if queueitem.Node.position == data.EndNode.position then
			return queueitem.path, queueitem.length, false
		end
	
		closed[queueitem.Node[1]] = true
		
		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in queueitem.Node.adjacent do
		
			local newnode = adjacentNode[1]
			
			if closed[newnode] then
				continue
			end
			
			local testposition = LOUDCOPY(graph[newnode].position)
		
			if data.Testpath and DestinationBetweenPoints( data.Dest, queueitem.Node.position, testposition, data.Stepsize) then
				return queueitem.path, queueitem.length, true
			end
			
			local threat = GetThreatBetweenPositions( aiBrain, queueitem.Node.position, testposition, nil, data.ThreatLayer)

			if threat > (queueitem.threat) then
				continue
			end
			
			threat = GetThreatAtPosition( aiBrain, testposition, 0, true, data.ThreatLayer )
			
			if threat > (queueitem.threat) then
				continue
			end
			
			local fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }

			fork.cost = queueitem.cost + threat + 10

			fork.goaldist = VDist2( data.Dest[1], data.Dest[3], testposition[1], testposition[3] )

			fork.length = queueitem.length + adjacentNode[2]

			fork.path[queueitem.pathcount + 1] = LOUDCOPY(graph[newnode].position)

			fork.pathcount = queueitem.pathcount + 1
			
			fork.threat = queueitem.threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false
	end		
	
	local closed = {}
	local queue = {}
	local data = {}

    local PathRequests = aiBrain.PathRequests.Air
    local PathReplies = aiBrain.PathRequests['Replies']
	
	-- OK - some notes about the path requests - here is the data layout of path request;
	--	Dest = destination,
	--	EndNode = endNode,
	--	Location = start,
	--	Platoon = platoon, 
	--	StartNode = startNode,
	--	Stepsize = stepsize,
	--	Testpath = testPath,
	--	ThreatLayer = threattype,
	--	ThreatWeight = threatallowed,	-- this is the maximum threat this platoon will allow itaiBrain to encounter

	-- i've come to a conclusion about how pathing can take casualties into account along the way -- in our case this
	-- would be represented by the platoon having a declining threat as it encounters enemy threat along its chosen path
	-- two outcomes become clear when you do this;
	--	 the platoon will chose a path that gets there with survivable losses that allow it to get to the final destination
	--	 the platoon will refuse the task	
	while true do
		
		if PathRequests[1] then
		
			data = LOUDREMOVE(PathRequests, 1)
			closed = {}
			-- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
			-- we also no longer need to pass it to the AStar function as it is part of the queue data
			queue = { { cost = 0, goaldist = 0, length = 0, Node = data.StartNode, path = { data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight } }
    
			while LOUDGETN(queue) > 0 do
			
				local pathlist, pathlength, shortcut = AStarLoopBody( data, queue, closed )
        
				if pathlist then

					PathReplies[data.Platoon] = { length = pathlength, path = LOUDCOPY(pathlist) }
					break
				end
			end
			
			if not PathReplies[data.Platoon] then
				PathReplies[data.Platoon] = { length = 0, path = 'NoPath' }
			end
			
		end
		
		WaitTicks(1)
	end
end			

function PathGeneratorAmphibious(self)
	
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions

	local LOUDCOPY = table.copy		
	local LOUDFLOOR = math.floor		
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local WaitTicks = coroutine.yield
	
	local dist_comp = self.dist_comp
	
	-- get the table with all the nodes for this layer
	local graph = ScenarioInfo.PathGraphs['Amphibious']

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
	
		if steps > 0 then

			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
	
			for i = 1, steps do

				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
					return true
				end
			end	
		end
	
		return false
	end

	--this is the function which evaluates all the branches for a given node
	local AStarLoopBody = function( data, queue, closed)
	
		--LOG("*AI DEBUG AStar Starts")
		
		local queueitem = LOUDREMOVE(queue, 1)
		
		if closed[queueitem.Node[1]] then
		
			--LOG("*AI DEBUG ASTAR returns false")

			return false, 0, false
			
		end

		if queueitem.Node.position == data.EndNode.position then
		
			--LOG("*AI DEBUG ASTAR finds endpoint")
			return queueitem.path, queueitem.length, false
		end
		
		closed[queueitem.Node[1]] = true

		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in queueitem.Node.adjacent do
		
			if closed[adjacentNode[1]] then
				continue
			end

			local testposition = LOUDCOPY(graph[adjacentNode[1]].position)

			--LOG("*AI DEBUG looking at "..repr(queueitem.Node.position).." to "..repr(testposition))
			
			if data.Testpath and DestinationBetweenPoints( data.Dest, queueitem.Node.position, testposition, data.Stepsize) then
				--LOG("*AI DEBUG ASTAR finds DestBetweenPoints")
				return queueitem.path, queueitem.length, true
			end

			local threat = GetThreatBetweenPositions( self, queueitem.Node.position, testposition, nil, data.ThreatLayer)

			if threat > (queueitem.threat) then
				continue
			end

			local fork = { cost = 0, goaldist = 0, length = 0, Node = graph[adjacentNode[1]], path = LOUDCOPY(queueitem.path) }

			fork.cost = queueitem.cost + threat + 20

			fork.goaldist = VDist2( data.Dest[1], data.Dest[3], testposition[1], testposition[3] )

			fork.length = queueitem.length + adjacentNode[2]

			fork.path[queueitem.pathcount + 1] = LOUDCOPY(graph[adjacentNode[1]].position)

			fork.pathcount = queueitem.pathcount + 1
			
			fork.threat = queueitem.threat - threat
			
			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)
		
		return false, 0, false
		
	end

	local closed = {}
	local queue = {}
	local data = {}

    local PathRequests = self.PathRequests.Amphibious
	
    local PathReplies = self.PathRequests['Replies']

	while true do
		
		if PathRequests[1] then
		
			--LOG("*AI DEBUG Amphibious PATHGEN gets request "..repr(PathRequests[1]))
			
			data = LOUDREMOVE(PathRequests, 1)
			
			closed = {}
			
			-- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
			-- we also no longer need to pass it to the AStar function as it is part of the queue data
			queue = { { cost = 0, goaldist = 0, length = 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight } }
    
			while LOUDGETN(queue) > 0 do

				--LOG("*AI DEBUG Amphib PATHGEN is "..repr(LOUDGETN(queue)))
				
				local pathlist, pathlength, shortcut = AStarLoopBody( data, queue, closed )
        
				if pathlist then
				
					
					PathReplies[data.Platoon] = { length = pathlength, path = LOUDCOPY(pathlist) }
					
					break	-- to next request
				end
				
			end
			
			if not PathReplies[data.Platoon] then
			
				PathReplies[data.Platoon] = { length = 0, path = 'NoPath' }

			end
		
		end
		
		WaitTicks(4)
		
	end
	
end

function PathGeneratorLand(self)
	
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions

	local LOUDCOPY = table.copy
	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local WaitTicks = coroutine.yield
	
	local dist_comp = self.dist_comp
	local graph = ScenarioInfo.PathGraphs['Land']

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
	
		if steps > 0 then

			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
	
			for i = 1, steps do
				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
					return true
				end
			end	
		end
		return false
	end

	--this is the function which evaluates all the branches for a given node
	local AStarLoopBody = function( data, queue, closed, maxthreat, minthreat )
		
		local queueitem = LOUDREMOVE(queue, 1)

		if closed[queueitem.Node[1]] then

			return false, 0, false
		end

		
		if queueitem.Node.position == data.EndNode.position then
			return queueitem.path, queueitem.length, false
		end
	
		closed[queueitem.Node[1]] = true
	
		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in queueitem.Node.adjacent do
			
			if closed[adjacentNode[1]] then
			
				continue
			end

			local testposition = LOUDCOPY(graph[adjacentNode[1]].position)
		
			if data.Testpath and DestinationBetweenPoints( data.Dest, queueitem.Node.position, testposition, data.Stepsize) then
				return queueitem.path, queueitem.length, true
			end
			
			local threat = GetThreatBetweenPositions( self, queueitem.Node.position, testposition, nil, data.ThreatLayer)

			if threat <= data.ThreatWeight * minthreat then
				threat = 0
			elseif threat > data.ThreatWeight then
				threat = maxthreat * threat
			end

			local fork = { cost = queueitem.cost + threat, goaldist = VDist2( data.Dest[1], data.Dest[3], testposition[1], testposition[3] ), length = queueitem.length + adjacentNode[2], Node = graph[adjacentNode[1]], path = LOUDCOPY(queueitem.path), pathcount = queueitem.pathcount + 1 }

			--fork.goaldist = VDist2( data.Dest[1], data.Dest[3], testposition[1], testposition[3] )

			--fork.length = queueitem.length + adjacentNode[2]

			--fork.cost = queueitem.cost + threat --+ 20  -- + adjacentNode[2]

			fork.path = LOUDCOPY(queueitem.path)
			fork.path[queueitem.pathcount + 1] = LOUDCOPY(graph[adjacentNode[1]].position)

			--fork.pathcount = queueitem.pathcount + 1

			LOUDINSERT(queue,fork)
			
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false
	end		

	local data = {}
	local closed = {}
	local queue = {}

	local PathRequests = self.PathRequests.Land
    local PathReplies = self.PathRequests['Replies']


	while true do
		
		if PathRequests[1] then
	
			data = LOUDREMOVE(PathRequests, 1)
			closed = {}

			queue = { { cost = 0, goaldist = 0, length = 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1 } }

			while LOUDGETN(queue) > 0 do

				-- adjust these multipliers to make pathfinding more or less sensitive to threat
				-- local maxthreat = data.ThreatWeight * 1.2
				-- local minthreat = data.ThreatWeight * .5
				local pathlist, pathlength, shortcut = AStarLoopBody( data, queue, closed, data.ThreatWeight * 0.9, data.ThreatWeight * .3 )
        
				if pathlist then

					PathReplies[data.Platoon] = { length = pathlength, path = LOUDCOPY(pathlist) }
					
					break
				end
				
			end

			if not PathReplies[data.Platoon] then
				PathReplies[data.Platoon] = { length = 0, path = 'NoPath' }
			end
			
		end
		
		WaitTicks(3)
		
	end
	
end

-- this pathgenerator also takes into account casualties along the route
function PathGeneratorWater(self)
	
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions

	local LOUDCOPY = table.copy		
	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local VDist2 = VDist2
	local WaitTicks = coroutine.yield

	local dist_comp = self.dist_comp
	
	local graph = ScenarioInfo.PathGraphs['Water']

	local DestinationBetweenPoints = function( destination, start, finish, stepsize )

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / stepsize )
	
		if steps > 0 then

			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
	
			for i = 1, steps  do
				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < (stepsize * stepsize) then
					return true
				end
			end	
		end
		return false
	end

	--this is the function which evaluates all the branches for a given node
	local AStarLoopBody = function( data, queue, closed )
		
		local queueitem = LOUDREMOVE(queue, 1)
		local testnode = queueitem.Node[1]

		if closed[testnode] then
			return false, 0, false
		end

		local position = queueitem.Node.position
		local adjacentnodes = queueitem.Node.adjacent

		if position == data.EndNode.position then
			return queueitem.path, queueitem.length, false
		end
		
		closed[testnode] = true

		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in adjacentnodes do
			
			local newnode = adjacentNode[1]
			
			if closed[newnode] then
				continue
			end

			local testposition = LOUDCOPY(graph[newnode].position)
			

			if data.Testpath and DestinationBetweenPoints( data.Dest, position, testposition, data.Stepsize) then
				return queueitem.path, queueitem.length, true
			end

			local threat = GetThreatBetweenPositions( self, position, testposition, nil, data.ThreatLayer)

			
			if threat > (queueitem.threat) then
				continue
			end

			local fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }

			fork.cost = queueitem.cost + threat -- + adjacentNode[2]
			
			fork.goaldist = VDist2( data.Dest[1], data.Dest[3], testposition[1], testposition[3] )

			fork.length = queueitem.length + adjacentNode[2]

			fork.path[queueitem.pathcount + 1] = LOUDCOPY(graph[newnode].position)

			fork.pathcount = queueitem.pathcount + 1
			
			fork.threat = queueitem.threat - threat
			
			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)
		return false, 0, false
	end

	local data = {}
	local closed = {}
	local queue = {}

    local PathRequests = self.PathRequests.Water
	local PathReplies = self.PathRequests['Replies']

	while true do
		
		if PathRequests[1] then
		
			data = LOUDREMOVE(PathRequests, 1)
			closed = {}
			queue = { {cost = 0, goaldist = 0, length = 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight } }

			while LOUDGETN(queue) > 0 do

				local pathlist, pathlength, shortcut = AStarLoopBody( data, queue, closed )
        
				if pathlist then

					PathReplies[data.Platoon] = { length = pathlength, path = LOUDCOPY(pathlist) }
					
					break
					
				end
				
			end
			
			if not self.PathRequests['Replies'][data.Platoon] then
				PathReplies[data.Platoon] = { length = 0, path = 'NoPath' }
			end

		end
		
		WaitTicks(3)
	end
end

-- This routine purges the pathcache of any old entries
function PathCacheMonitor( aiBrain )

	LOG("*AI DEBUG "..aiBrain.Nickname.." starting PathCacheMonitor")
	
	-- setup the PathCache for this brain and the counters for hits and misses
	if not aiBrain.PathCache then
	
		aiBrain.PathCache = {}
		aiBrain.PathHits = 0
		aiBrain.PathMiss = 0
		
	end

	local cachecount = 0
	local cachetime = 1200	-- starting lifetime 1200 seconds = 2 minutes
	local looprate = cachetime * 0.1
	
	local maxcachetime = 1800
	
	if ScenarioInfo.size[1] < 2048 or ScenarioInfo.size[2] < 2048 then
	
		maxcachetime = 1200
		
	end
	
    local PathCache = aiBrain.PathCache
	local testtime
	local elementcount
	local k
	
	-- run this loop 10x as fast as the cache lifetime so that we reduce lifetime overages to no more than 110%
	while true do
	
		aiBrain.PathHits = 0
		aiBrain.PathMiss = 0
	
		WaitSeconds(looprate - math.floor(cachecount * 0.1) )
	
		cachecount = 0
	
		testtime = GetGameTimeSeconds()

		for k,v in PathCache do
			
			elementcount = 0

			for a,b in PathCache[k] do

				cachecount = cachecount + 1

				if (not PathCache[k][a].settime) or testtime > PathCache[k][a].settime + cachetime then
				
					PathCache[k][a] = nil
					
				else
				
					elementcount = elementcount + 1
					
				end
				
				WaitTicks(1)
				
			end

			if elementcount < 1 then
			
				PathCache[k] = nil
				
			end
			
		end

		-- dynamic adjustment of cachetime to achieve hitrate
		if (aiBrain.PathMiss + aiBrain.PathHits) > 0 then
		
			k = (aiBrain.PathHits/(aiBrain.PathMiss+aiBrain.PathHits))*100
			
			if k < 15 then
			
				if cachetime < maxcachetime then
				
					cachetime = cachetime + 100
					
				end
				
				looprate = cachetime * 0.1

			elseif k > 25 then 
			
				cachetime = cachetime - 50
				looprate = cachetime * 0.2
				
			end
			
		end
		
	end
	
end
	
function UpdatePathCache(self, startname, endname, pathlist, pathlength)
	
	if startname != endname then
		if not self.PathCache[startname][endname] then
			self.PathCache[startname] = {}
		end

		self.PathCache[startname][endname] = { length = pathlength, path = pathlist, settime = GetGameTimeSeconds() }
	end

	self.PathMiss = self.PathMiss + 1
end

--   Function: ParseIntelThread

-- NOTES:  The GetThreatsAroundPosition ALWAYS returns an IMAP point which are regularily spaced.
-- IMAP block size is related to map size and ranges from 16 to 256 Ogrids apart.
-- On large maps this is too coarse to be used for goal setting.  Therefore I have forced ALL
-- the parsing to locate exact target points -- that is what I will feed to the high priority list.
 
-- To accomplish that, I use GetUnitsAroundPoint with a radius of ogrids which will cover points
-- right to the junction of 4 IMAP points.  This of course overlaps somewhat with adjacent IMAP points
-- but alas..it must be done.  Rarely a unit may generate two high priority results when there are
-- large unit clusters.  Thats not necessarily a bad thing

-- I took the debatable step of checking the position of EVERY unit that is found using the above
-- rather than just the first unit.  In conjuction with the code used to merge nearby points within a
-- certain area, the result is several well spaced targets when parsing large bases.

-- This will give the AI several options to attack an enemy base as it will be able to make threat
-- assessments at several points that are actually valid with respect to the taarget rather than the
-- coarse results provided by the IMAP

-- NOTE also the inclusion of the NAVAL intelchecks which should be used to help guide AI naval
-- flotillas towards naval formations.

-- I have added a new table (EnemyData) which records total threat values, by threatType
-- The AI can make a judgement by comparing his strength to the enemys strength of a particular
-- threat.  I record 80 values (about 80 samples - 8 seconds apart) so that its fairly accurate
-- taking into account how much intel the AI is actually collecting - see the parseinterval value
-- to adjust the length of data collection period

-- KEEP IN MIND - all of this is based upon what the AI is actually seeing (radar, Omni or LOS) and revealed structures
function ParseIntelThread( aiBrain )

	LOG("*AI DEBUG "..aiBrain.Nickname.." Parse Intel Thread Starts")
	
	-- local this global function
	local GetUnitsInRect = GetUnitsInRect
	local IsEnemy = IsEnemy

	local LOUDFLOOR = math.floor
	local LOUDGETN = table.getn
	local LOUDINSERT = table.insert
	local LOUDSORT = table.sort
	local LOUDV2 = VDist2
	local VD2 = VDist2Sq
	local WaitTicks = coroutine.yield

    -- set the OgridRadius according to mapsize
    local OgridRadius, IMAPsize, ResolveBlocks, Rings, ThresholdMult

    if ScenarioInfo.size[1] == 256 then
        OgridRadius = 12.0
        IMAPSize = 16
        ResolveBlocks = 0
		ThresholdMult = .33
		Rings = 2
    elseif ScenarioInfo.size[1] == 512 then
        OgridRadius = 23.0
        IMAPSize = 32
        ResolveBlocks = 0
		ThresholdMult = .66
		Rings = 1
    elseif ScenarioInfo.size[1] == 1024 then
        OgridRadius = 45.0
        IMAPSize = 64
        ResolveBlocks = 0
		ThresholdMult = 1
		Rings = 0
    elseif ScenarioInfo.size[1] == 2048 then
        OgridRadius = 91.0
        IMAPSize = 128
        ResolveBlocks = 4
		ThresholdMult = 1
		Rings = 0
    else
        OgridRadius = 181.0
        IMAPSize = 256
        ResolveBlocks = 16
		ThresholdMult = 1.5
		Rings = 0
    end

	local IMAPRadius = IMAPSize * .5

	-- set the intel resolution according to the intelligence map size
	-- this controls how close intel points of the same type can be
	local resolution = (OgridRadius) 

	-- save the current resolution globally - it will be used by other routines to follow moving intel targets
	ScenarioInfo.IntelResolution = resolution

    --LOG("*AI DEBUG IMAP Size is " ..IMAPSize.. " and Parse will examine " ..ResolveBlocks.. " blocks per intel check")

	--[[
	local IntelTypes = {
        Overall,				-- reports everything - ALL threat values
        OverallNotAssigned,		-- hmm....
        StructuresNotMex,		-- any building except MEX - ALL threat values
        Structures,				-- ALL buildings - ALL threat values
		
        Naval,					-- reports ALL threat values but only of actual NAVAL units
        Air,					-- reports ALL threat values but only of actual AIR units			
        Land,					-- reports ALL threat values but only of actual LAND units
		
        Experimental,
        Commander,
        Artillery,
		
        AntiAir,				-- reports anti-air threat of ALL units		
        AntiSurface,			-- reports surface threat of ALL units
        AntiSub,				-- reports sub threat of ALL units
        Economy,				-- reports economic threat of ALL units
        Unknown,
	}
	--]]
	
	local intelChecks = {
		-- ThreatType	= {max dist to merge points, threat min, timeout (-1 = never), category for exact pos, parse every x iterations}
		-- notice the inclusions for Naval with matching exclusions for StructuresNotMex
		-- added in Economy 
		-- note that some categories dont have a dynamic threat threshold - just air,land,naval and structures - since you can only pack so many in a smaller IMAP block
		
		Air 			= { resolution, 20 * ThresholdMult, 10, (categories.MOBILE * categories.AIR) - categories.TRANSPORTFOCUS - categories.SATELLITE, 1},
		Land 			= { resolution, 15 * ThresholdMult, 45, (categories.MOBILE * categories.LAND) - categories.ANTIAIR, 1 },
		Naval 			= { resolution, 20 * ThresholdMult, 45, (categories.MOBILE * categories.NAVAL) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE), 1 },
		
		--AntiAir			= { resolution, 10, 90, (categories.ANTIAIR), 1},
		--AntiSub			= { resolution, 10, 90, (categories.NAVAL), 1},
		--AntiSurface		= { resolution, 10, 90, (categories.ALLUNITS), 1},
		
		Artillery 		= { resolution/2, 100, 120, (categories.ARTILLERY * categories.STRUCTURE * categories.TECH3) + (categories.EXPERIMENTAL * categories.ARTILLERY), 2 },
		Commander 		= { resolution, 20, 120, categories.COMMAND, 2 },
		Economy			= { resolution/2, 100, 120, ((categories.STRUCTURE * categories.ECONOMIC) + (categories.FACTORY * categories.STRUCTURE)), 3 },
		Experimental 	= { resolution, 50, 30, (categories.EXPERIMENTAL * categories.MOBILE), 2},
		
		--Structures		= { resolution, 10, 90, (categories.ALLUNITS), 1},
		
		StructuresNotMex = { resolution/2, 30, 120, categories.STRUCTURE - categories.WALL - categories.ECONOMIC - categories.FACTORY - (categories.NAVAL * categories.DEFENSE), 3 },
	}

	local numchecks = 0
	local usedticks = 0
	local checkspertick = 1		-- number of threat entries to be processed per tick - this really affects game performance if moved up 
	local parseinterval = 200 	-- the rate of this routine in ticks - essentially every 20 seconds
    local minimumcheck = 5      -- only check reports above this level

    local iterationcount = 0 

    -- Create EnemyData array - stores history of totalthreat by threattype over a period of time
	-- and the History value controls how much history is kept -- 60 is about 600 seconds of history
	aiBrain.EnemyData = { ['Count'] = 0, ['History'] = 60 }		
	
	
	-- Draw HiPri intel data on map - for visual aid - not required but useful for debugging threat assessment
	if ScenarioInfo.DisplayIntelPoints then
		if not aiBrain.IntelDebugThread then
			aiBrain.IntelDebugThread = aiBrain:ForkThread( import('/lua/loudutilities.lua').DrawIntel )
		end		
	end
	
	-- create the record for each type of intel within the array
	-- and initialize the element which will carry the running total
    for threatType, v in intelChecks do
        aiBrain.EnemyData[threatType] = { ['Total'] = 0}
	end

	-- the 3D location of the MAIN base for this AI
	local HomePosition = aiBrain.BuilderManagers.MAIN.Position

    -- local the repetitive functions		
	--local AssignThreatAtPosition = moho.aibrain_methods.AssignThreatAtPosition
	local EntityCategoryFilterDown = EntityCategoryFilterDown
	local GETTHREATATPOSITION = moho.aibrain_methods.GetThreatAtPosition
	local GetBlueprint = moho.entity_methods.GetBlueprint
	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	local GetPosition = moho.entity_methods.GetPosition
	local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
	local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition

	local import = import
	local LOUDMAX = math.max
	local LOUDMIN = math.min
	local LOUDMOD = math.mod
	local LOUDREMOVE = table.remove

    local EnemyData = aiBrain.EnemyData
    local EnemyDataCount = EnemyData.Count
    local EnemyDataHistory = EnemyData.History

    local NumOpponents = aiBrain.NumOpponents
	-- this moves all the local creation up front so NO locals need to be declared in
	-- the primary loop - probably doesn't mean much - but I did it anyway
	local totalThreat, threats, gametime, units, counter, x1,x2,x3, dupe, newpos, newthreat, newtime, myunits, myvalue, bp

	-- in a perfect world we would check all 8 threat types every parseinterval 
	-- however, only LAND, AIR and NAVAL will be checked every cycle -- the others will be checked every other cycle or on the 3rd or 4th
    while true do

		numchecks = 0
		usedticks = 0

		-- advance the iteration count
		-- the iteration count is used to process certain intel types at a different frequency than others
        iterationcount = iterationcount + 1

        -- roll the iteration count back to one if it exceeds the maximum number of iterations
        if iterationcount > 4 then
            iterationcount = 1

			-- if human ally has requested status updates
			if aiBrain.DeliverStatus then
			
				if not aiBrain.LastLandRatio or aiBrain.LastLandRatio != aiBrain.LandRatio then
				
					ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My present LAND ratio is '..aiBrain.LandRatio )
					
					aiBrain.LastLandRatio = aiBrain.LandRatio
				end
			end
        end

        -- advance the sample counter for the EnemyData array
        EnemyDataCount = EnemyDataCount + 1

		-- roll it back to one when the sample counter exceeds the number of samples we are keeping
        if EnemyDataCount > EnemyDataHistory then
            EnemyDataCount = 1
        end

		-- loop thru each of the threattypes
		for threatType, vx in intelChecks do

            totalThreat = 0
			local mergedistance = vx[1]*vx[1]

			if LOUDMOD(iterationcount, vx[5]) == 0 then

                -- get all threats of this type from the IMAP -- table format is as follows:  posx, posy, threatamount
				-- A note here - when you ask for 'Air' threat - you'll get ALL the threats that Air units can create for example
				-- 12 bombers have zero anti-air threat but they'll still generate threat because they threaten surface targets
				-- but to be clear 'Land' = Land Mobile units and does not include Land Structures
                threats = GetThreatsAroundPosition( aiBrain, HomePosition, 32, true, threatType)
                gametime = LOUDFLOOR(GetGameTimeSeconds())

                -- examine each threat and add those that are high enough to the InterestList if enemy units are found at that location
                for _,threat in threats do
					
                    -- add up the threat from each IMAP position - we'll use this as history even if it doesn't result in a InterestList entry
                    totalThreat = totalThreat + threat[3]

                    -- only check threats above minimumcheck otherwise break as rest will be below that
                    if threat[3] >= minimumcheck then
					
                        -- count the number of checks we've done and insert a wait to keep this routine from hogging the CPU 
                        numchecks = numchecks + 1

                        if numchecks > checkspertick then
                            WaitTicks(1)
							usedticks = usedticks + 1
                            numchecks = 0
                        end

						-- HERE IS THE BREAK POINT WHERE WE WOULD START A LOOP TO CHECK MULTIPLE BOXES FOR AN IMAP BOX LARGER THAN 64 OGRIDS
						-- using the syntax below, the threat[1] and threat[3] values would be offsets of the actual IMAP box -- ie. quadrants
						-- each quadrant could therefore have a much greater degree of detail than the IMAP itself would describe
						-- at the moment, the threat values are coming right off of the IMAP position - so they would have to be copied and
						-- used as two other values that would then be looped to cycle their values

                        -- collect all the enemy units within that IMAP grid
						units = GetEnemyUnitsInRect( aiBrain, threat[1]-IMAPRadius, threat[2]-IMAPRadius, threat[1]+IMAPRadius, threat[2]+IMAPRadius)
						
						counter = 0
						--local nearunits = {}
						
						-- these accumulate the postion values
                        x1 = 0
                        x2 = 0
                        x3 = 0
						
						-- loop thru only those that match the category filter
						for _,v in EntityCategoryFilterDown( vx[4], units ) do
						
							counter = counter + 1
							
							unitPos = GetPosition(v)
							if unitPos and not v.Dead then
								x1 = x1 + unitPos[1]
								x2 = x2 + unitPos[2]
								x3 = x3 + unitPos[3]
							end
						end

						-- if there are valid units then calc the average position and get the threat at that position
						-- either make a new IL entry for it or update an existing entry
						if counter > 0 then
						
							dupe = false

							-- divide the position values by the counter to get average position (gives you the heart of the cluster)
                            newPos = { x1/counter, x2/counter, x3/counter }

							units = GetUnitsAroundPoint( aiBrain, vx[4], newPos, vx[1], 'Enemy')
                            -- find the closest unit to that new position that is within the merge distance
							-- and use that unit as the position of the threat
                            for _, v in units do
                                if not v.Dead then
									-- first one will always be closest
                                    newPos = GetPosition(v)
                                    break
                                end
                            end

							-- get the current threat at this position - can differ from the IMAP value - unfortunately we have to use 'Rings' here
                            newthreat = GETTHREATATPOSITION( aiBrain, newPos, Rings, true, threatType )
							
							newtime = gametime

                            -- traverse the existing list until you find an entry within merge distance
							-- we'll update ALL entries that are within the merge distance meaning we may get duplicates
                            for k,loc in aiBrain.IL.HiPri do
								
								-- it's got to be of the same type
                                if loc.Type == threatType then

									-- and within the merge distance
									if VD2( newPos[1],newPos[3], loc.Position[1],loc.Position[3] ) <= mergedistance then
									
										if dupe then
										
											aiBrain.IL.HiPri[k] = nil
											
											continue
											
										end
									
										-- it might be a duplicate
										dupe = true
										
										-- so update the existing entry
										loc.Threat = newthreat
										loc.LastUpdate = newtime
										loc.Position = newPos

									end
									
                                end
								
                            end
						
                            -- if not a duplicate and it passes the threat threshold we'll add it - otherwise we ignore it
                            if (not dupe) and newthreat >= vx[2] then
							
								--LOG("*AI DEBUG Inserting new "..repr(threatType).." threat of "..newthreat.." at "..repr(newPos))
							
								-- insert this new entry
                                LOUDINSERT(aiBrain.IL.HiPri, { Position = newPos, Type = threatType, Threat = newthreat, LastUpdate = newtime, LastScouted = newtime } )
								
							end
							
                        end
						
                    else
					
						break -- rest of the threats will be below minimumcheck level and can be bypassed
						
					end
					
                end
				
				-- Update the EnemyData Array for this threattype -- Array element 'Total' carries a running total
                -- update the array using the current sample counter -- first remove what is there from total
				-- then update the current counter -- then add the current counter to the total
				EnemyData[threatType]['Total'] = EnemyData[threatType]['Total'] - (EnemyData[threatType][EnemyDataCount] or 0)
                EnemyData[threatType][EnemyDataCount] = totalThreat
				EnemyData[threatType]['Total'] = EnemyData[threatType]['Total'] + totalThreat
				
            end
			
			WaitTicks(1)
			
			usedticks = usedticks + 1
			
		end

		local timecheck = GetGameTimeSeconds()

		-- purge outdated, non-permanent intel if past the timeout period or below the threat threshold
		for s, t in aiBrain.IL.HiPri do
		
			-- if not permanent and has a timeout value
			if (not t.Permanent) and intelChecks[t.Type][3] > 0 then
			
				-- if the lastupdate was more than the timeout period or threat is less than the threshold
				if (t.LastUpdate + intelChecks[t.Type][3] < timecheck) or (t.Threat <= intelChecks[t.Type][2]) then
				
					-- clear the item
					aiBrain.IL.HiPri[s] = nil

				end
				
			end
			
		end
		
		-- rebuild to remove nil entries
		aiBrain.IL.HiPri = aiBrain:RebuildTable(aiBrain.IL.HiPri)

		-- sort it by distance from MAIN -- HOLD IT A SECOND - I know how important MAIN is - but what if we used PRIMARYATTACKBASE ?
		-- that would shift the HiPri table in a big way !  It would but it might impact a lot of other things like protecting the MAIN position
		LOUDSORT(aiBrain.IL.HiPri, function(a,b) 
		
			if a.LastScouted == b.LastScouted then
			
				return VD2(HomePosition[1], HomePosition[3], a.Position[1], a.Position[3]) < VD2(HomePosition[1], HomePosition[3], b.Position[1], b.Position[3])
				
			else
				
				return a.LastScouted < b.LastScouted
				
			end
			
		end)


		if parseinterval - usedticks >= 10 then
			
			WaitTicks(parseinterval - usedticks)

			if parseinterval - usedticks > 40 then
			
				if checkspertick > 1 then
				
					checkspertick = checkspertick - 1
					LOG("*AI DEBUG PARSE INTEL lowered CPT to "..checkspertick)
					
				end
				
			end
			
		else
		
			if checkspertick < 5 then
			
				checkspertick = checkspertick + 1
				
				LOG("*AI DEBUG PARSE INTEL increased CPT to "..checkspertick)
				
			end
			
		end

		-- recalc the strength ratios every loop ---
		-- get the full list of units
		-- syntax is --  Brain, Category, IsIdle, IncludeBeingBuilt
		myunits = GetListOfUnits( aiBrain, categories.MOBILE, false, false)

		--- AIR UNITS ---
		-----------------
		myvalue = 0
		
		-- calculate my present airvalue			
		for _,v in EntityCategoryFilterDown( (categories.AIR * categories.MOBILE) - categories.TRANSPORTFOCUS - categories.SATELLITE, myunits ) do
		
			bp = GetBlueprint(v).Defense

			myvalue = myvalue + bp.AirThreatLevel + bp.SubThreatLevel + bp.SurfaceThreatLevel

		end

		if EnemyData['Air']['Total'] > 0 then

			-- ratio will be total value divided by number of history points divided again by number of opponents
			-- we also cap the AIRRATIO at 10
			aiBrain.AirRatio = LOUDMIN( myvalue / ( (EnemyData['Air']['Total'] / EnemyDataHistory) / NumOpponents), 10 )
			
			if ScenarioInfo.ReportRatios then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Air Ratio is "..repr(aiBrain.AirRatio))
				
			end
			
		else
		
			aiBrain.AirRatio = 1
			
		end

		--- LAND UNITS ---
		------------------
		myvalue = 0

		-- calculate my present land value
		for _,v in EntityCategoryFilterDown( (categories.LAND * categories.MOBILE), myunits ) do
		
			bp = GetBlueprint(v).Defense
			
			myvalue = myvalue + bp.SurfaceThreatLevel + bp.SubThreatLevel + bp.AirThreatLevel
			
		end

		if EnemyData['Land']['Total'] > 0 then

			-- ratio will be total value divided by number of history points divided again by number of opponents
			-- we also cap the LANDRATIO at 10
			aiBrain.LandRatio = LOUDMIN( myvalue / ((EnemyData['Land']['Total'] / EnemyDataHistory) / NumOpponents), 10 )

			if ScenarioInfo.ReportRatios then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Land Ratio is "..repr(aiBrain.LandRatio))
			
			end

		else
		
			aiBrain.LandRatio = 1
			
		end

		--- NAVAL UNITS ---
		-------------------
		myvalue = 0

		-- calculate my present naval value
		for _,v in EntityCategoryFilterDown( (categories.MOBILE * categories.NAVAL) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE), myunits ) do
		
			bp = GetBlueprint(v).Defense
			
			myvalue = myvalue + bp.SubThreatLevel + bp.SurfaceThreatLevel + bp.AirThreatLevel
			
		end

		if EnemyData['Naval']['Total'] > 0 then

			-- ratio will be total value divided by number of history points divided again by number of opponents
			-- we cap the NAVALRATIO at 8
			aiBrain.NavalRatio = LOUDMIN( myvalue / ((EnemyData['Naval']['Total'] / EnemyDataHistory) / NumOpponents), 8 )

			if ScenarioInfo.ReportRatios then
			
				LOG("*AI DEBUG "..aiBrain.Nickname.." Naval Ratio is "..repr(aiBrain.NavalRatio))
				
			end
			
		else
		
			aiBrain.NavalRatio = 0.01
			
		end
		
--[[		
		for threatType, vx in intelChecks do
			
			LOG("*AI DEBUG "..threatType.." is "..repr(EnemyData[threatType][EnemyDataCount] ))
			
		end
--]]
		
    end
	
end


-- Sets up all the permanent scouting areas. If playing with fixed starting locations,
-- also sets up high-priority scouting areas. This function may be called multiple times, but only 
-- has an effect the first time it is called per brain.
-- Modified to eliminate any points which may be within 50 of an existing point to keep the list
-- to a more manageable size and prevent over-scouting any one area
function BuildScoutLocations( self )

	LOG("*AI DEBUG "..self.Nickname.." now BuildingScoutLocations ")
	
	local GetMarker = import('/lua/sim/scenarioutilities.lua').GetMarker
	local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
	
    local opponentStarts = {}
    local allyStarts = {}

	local function IntelPointNearby(intelpoint)
	
		local VDist2Sq = VDist2Sq
    
		for _,v in self.IL.LowPri do
		
			if VDist2Sq(v.Position[1],v.Position[3], intelpoint[1],intelpoint[3]) < 2500 then
			
				return true
				
			end
			
		end
		
		for _,v in self.IL.HiPri do
		
			if VDist2Sq(v.Position[1],v.Position[3], intelpoint[1],intelpoint[3]) < 2500 then
			
				return true
				
			end
			
		end
		
		return false
		
	end
	
    if not self.IL then

        self.IL = { ['HiPri'] = {}, ['LowPri'] = {}, ['LastScoutHi'] = false, ['LastScoutHiCount'] = 0, ['LastAirScoutHi'] = false, ['LastAirScoutHiCount'] = 0, ['LastAirScoutMust'] = false, ['MustScout'] = {} }

        local myArmy = ScenarioInfo.ArmySetup[self.Name]

        local numOpponents = 0

        if ScenarioInfo.Options.TeamSpawn == 'fixed' then
			
            for i=1,16 do
			
                local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
				local startPos = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[army.ArmyName].position

                if army and startPos then
				
					-- if position has enemy player put into high priority for 15 minutes with initial 200 threat
					if army.ArmyIndex != myArmy.ArmyIndex and ( not(army.Team == myArmy.Team) or army.Team == 1) then
					
                        opponentStarts['ARMY_' .. i] = startPos
                        numOpponents = numOpponents + 1
						
						-- assign initial threat of 200 at enemy position
						self:AssignThreatAtPosition( startPos, 200, 0.002, 'Economy' )
						
                        LOUDINSERT(self.IL.HiPri, { Position = startPos, Type = 'StructuresNotMex', LastScouted = 900, LastUpdate = 0, Threat = 200, Permanent = false } )
						
                    else
					
                        allyStarts['ARMY_' .. i] = startPos
						
                    end
					
                end
				
            end

			local positions = AIGetMarkerLocations('Start Location')

            for _,v in positions do
			
                -- if position is vacant add to low priority list permanently
                if not opponentStarts[v.Name] and not allyStarts[v.Name] then
				
                    LOUDINSERT(self.IL.LowPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
					
                end
				
            end
			

        else

			-- Spawn locations were random. We don't know where our opponents are. Add all non-ally start locations to the low priority list permanently
            for i=1, 16 do
			
                local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                local startPos = GetMarker('ARMY_' .. i).position

                if army and startPos then

                    if army.ArmyIndex == myArmy.ArmyIndex or (army.Team == myArmy.Team) then
					
                        allyStarts['ARMY_' .. i] = startPos
						
                    else
					
                        numOpponents = numOpponents + 1
						
                    end
					
                end
				
            end

            -- Add Start points not ours or allied and not already in one of the lists
			local positions = AIGetMarkerLocations('Start Location')

			for _,v in positions do

				if not allyStarts[v.Name] and not IntelPointNearby(v.Position) then
				
					LOUDINSERT(self.IL.LowPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
					
				end
				
			end
			
        end

        self.Players = ScenarioInfo.Options.PlayerCount
        self.NumOpponents = numOpponents
		
		local StartPosX, StartPosZ = self:GetArmyStartPos()
		
		self.StartPosX = StartPosX
		self.StartPosZ = StartPosZ
		
		-- store the number of mass points on the map
		ScenarioInfo.NumMassPoints = LOUDGETN(AIGetMarkerLocations('Mass'))
        
		LOG("*AI DEBUG Storing Mass Points = "..ScenarioInfo.NumMassPoints)
		LOG("*AI DEBUG Number of Players is "..self.Players)
		LOG("*AI DEBUG "..self.Nickname.." Opponent count is "..numOpponents)

		-- Having handled Starting Locations lets add others to the permanent list
        local PointTypes = { 'Large Expansion Area', 'Expansion Area', 'Naval Area', 'Combat Zone', 'Mass', 'Defensive Point', 'Naval Defensive Point' }

        for _, v in PointTypes do

            local positions = AIGetMarkerLocations( v )

            for _,v in positions do
			
                if not IntelPointNearby(v.Position) then
				
                    LOUDINSERT(self.IL.LowPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
					
                end
				
            end
			
        end

		PointTypes = nil
		opponentStarts = nil
		allyStarts = nil

		AISortScoutingAreas( self, self.IL.HiPri)

		AISortScoutingAreas( self, self.IL.LowPri)
		
    end
	
end

-- This one complements the previous function to remove visible markers from the map 
function RemoveBaseMarker( self, baseName, markerid )

	LOG("*AI DEBUG Removing Base Marker "..repr(markerid).." "..baseName.." from Owner "..repr(self.ArmyIndex - 1).." "..self.Nickname)
	
	import('/lua/simping.lua').UpdateMarker({Action = 'delete', ID = markerid, Owner = self.ArmyIndex - 1})
	
end


-- This continually running thread has the AI pick an enemy every 8 minutes
-- the index of the current enemy is kept on the brain
function PickEnemy( self )
	
	self.targetoveride = false

    while true do
	
        AIPickEnemyLogic( self, true)
		
        WaitTicks(4800)	-- every 8 minutes
		
    end
	
end

-- The ATTACK PLANNER - oh boy here we go
-- The purpose of this is to create a series of points (Stagepoints) that the AI will attempt
-- to seize control of - on his way to GOAL
function AttackPlanner(self, enemyPosition)

    if not self.AttackPlan then
	
        self.AttackPlan = {}
        self.AttackPlan.GoCheckInterval = 360   -- every 6 minutes
        self.AttackPlan.GoCheckRatio = 3        -- ratio for 100% Go signal
		
    end

    self.AttackPlan.Goal = nil
    self.AttackPlan.CurrentGoal = nil
    self.AttackPlan.StagePoints = {}
    self.AttackPlan.GoSignal = false

    CreateAttackPlan( self, enemyPosition )

    if self.AttackPlan.Goal then
	
        -- if monitoring an existing attack plan, kill it and start a new one
        if self.AttackPlanMonitorThread then
		
            KillThread(self.AttackPlanMonitorThread)
			
		end

        self.AttackPlanMonitorThread = self:ForkThread( AttackPlanMonitor )
		
    end
	
end

function CreateAttackPlan(self,enemyPosition)
    
	if self.DeliverStatus then
	
		ForkThread( AISendChat, 'allies', self.Nickname, 'Creating Attack Plan for '..ArmyBrains[self:GetCurrentEnemy().ArmyIndex].Nickname )
		
	end

	local mapsize = ScenarioInfo.size[1]
	local stagesize = math.floor(math.min(mapsize/2, 375)) #-- should give a range between 128 and 350 for the staging points

    local startx, startz = self:GetCurrentEnemy():GetArmyStartPos()

    local starty = GetSurfaceHeight( startx, startz )
    local Goal = {startx, starty, startz}
    local GoalReached = false

	-- this should probably get set to the current PrimaryLandAttackBase
    local StartPosition = self.BuilderManagers.MAIN.Position

    local markertypes = { 'Defensive Point','Naval Defensive Point', 'Blank Marker', 'Expansion Area', 'Large Expansion Area', 'Combat Zone' }
    local markerlist = {}
    local markers = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers

	-- checks if destination is somewhere between two points
	local DestinationBetweenPoints = function( Goal, start, finish )
	
		-- using the distance between two nodes -- using stepsize of 100
		-- calc how many steps there will be in the line
		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / 100 )
		
		if steps > 0 then
		
			-- and the size of each step
			local xstep = (start[1] - finish[1]) / steps
			local ystep = (start[3] - finish[3]) / steps
			
			-- check the steps from start to one less than then destination
			for i = 1, steps - 1 do
			
				-- if we're within the stepcheck ogrids of the destination then we found it
				if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), Goal[1], Goal[3]) < 10000 then
				
					return true
					
				end
				
			end	
			
		end
		
		return false
		
	end	
	
    -- first lets build a masterlist of all valid staging points between start and goal
    for k,v in markers do
	
        for _,t in markertypes do
		
            if v.type == t then
			
                local Position = {v.position[1], v.position[2], v.position[3]}
				
				-- only add markers that are at least 50% a stagesize away
                if VDist2Sq(Position[1],Position[3], StartPosition[1],StartPosition[3]) > ( (stagesize*0.5)*(stagesize*0.5))
					-- and at least 50% stagesize from goal
					and VDist2Sq(Position[1],Position[3], Goal[1],Goal[3]) > ((stagesize*0.5)*(stagesize*0.5))
					-- and closer to the goal than the startposition
					and VDist2Sq(Position[1],Position[3], Goal[1],Goal[3]) <= VDist2Sq(StartPosition[1],StartPosition[3], Goal[1],Goal[3])
					
					then
					
                    LOUDINSERT( markerlist, { Position = {v.position[1], v.position[2], v.position[3]}, Name = v.type } )
                    break
					
                end
				
            end
			
        end
		
    end

	if table.getn(markerlist) < 1 then
	
		LOG("*AI DEBUG "..self.Nickname.." No Markers meet AttackPlan requirements")
		
	end

    local CurrentPoint = StartPosition
    local StagePoints = {}
	local lastaddedposition = {}
    local StageCount = 0
    local looptest = 0
	local positions, pathvalue, path, reason, lastnode

    while not GoalReached do
        
		-- if current point is within stagesize of goal we're done
        if VDist2Sq(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3]) <= (stagesize*stagesize) then
		
            GoalReached = true
			
        else

            LOUDSORT( markerlist, function(a,b)	return VDist2Sq(a.Position[1],a.Position[3], CurrentPoint[1],CurrentPoint[3]) < VDist2Sq(b.Position[1],b.Position[3], CurrentPoint[1],CurrentPoint[3]) end )

            positions = {}

            -- Now we'll test each valid position and assign a value to it
            -- seek the position which has the lowest value

			-- Filter the list of markers
            for _,v in markerlist do
                
                -- if the position is at least half the stagesize away 
                if VDist2Sq( v.Position[1],v.Position[3], CurrentPoint[1],CurrentPoint[3]) >= ( (stagesize*0.5) * (stagesize*0.5) )
					-- and at least half a stagesize from the goal
					and VDist2Sq(v.Position[1],v.Position[3], Goal[1],Goal[3]) >= ( (stagesize*0.5) * (stagesize*0.5) )
					-- and 30% closer to the final goal than the last selected point 
					and (VDist2Sq(v.Position[1],v.Position[3], Goal[1],Goal[3]) < (VDist2Sq(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3]) * .70 ))
					-- and Goal is NOT between the current point and this point
					and not DestinationBetweenPoints( Goal, CurrentPoint, v.Position )	then
                    
                    pathvalue = 0
                    path, reason = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD(self, 'AttackPlanner', 'Land', CurrentPoint, v.Position, 250, 200)

                    -- calculate the distance of the path steps or distance + 300 if no path
                    if not path then
					
                        pathvalue = LOUDFLOOR(VDist2Sq( CurrentPoint[1],CurrentPoint[3], v.Position[1],v.Position[3] )) + (stagesize*stagesize)
						
                    else
					
                        pathvalue = 0
                        lastnode = CurrentPoint

                        for i, waypoint in path do
						
                            -- add the length of each step plus 10 for each step
                            pathvalue = pathvalue + LOUDFLOOR(VDist2Sq(lastnode[1],lastnode[3], waypoint[1],waypoint[3])) + (10*10)
                            lastnode = waypoint
							
                        end
						
                    end

                    if pathvalue > (VDist2Sq(CurrentPoint[1],CurrentPoint[3], v.Position[1],v.Position[3]) * 1.2) then
					
                        pathvalue = LOUDFLOOR(pathvalue * 1.2)
						
                    end

                    LOUDINSERT(positions, {Position = v.Position, Pathvalue = pathvalue, Type = 'Land', Path = path})
					
                end
				
				-- load balancing
				WaitTicks(1)
				
            end

            LOUDSORT(positions, function(a,b) return a.Pathvalue < b.Pathvalue end )

			-- if there are no positions found or the nearest is twice the stagesize
			-- then we'll have to create one out of a land node or water node (if land fails)
            if LOUDGETN(positions) < 1 or VDist2Sq(positions[1].Position[1],positions[1].Position[3], CurrentPoint[1],CurrentPoint[3]) > ((stagesize*2)*(stagesize*2)) then
                
                local a,b

                if LOUDGETN(positions) < 1 then
				
                    LOG("*AI DEBUG "..self.Nickname.." - There are no positions")
					
                    a = Goal[1] + CurrentPoint[1]
                    b = Goal[3] + CurrentPoint[3]
					
                else
				
                    --LOG("*AI DEBUG The nearest testposition is " .. VDist3(positions[1].Position, CurrentPoint) .. " away")
					
                    a = CurrentPoint[1] + positions[1].Position[1]
                    b = CurrentPoint[3] + positions[1].Position[3]
					
                end

                local result = { LOUDFLOOR(a* 0.5), 0, LOUDFLOOR(b* 0.5) }
                local landposition = false
                local fakeposition = false

                landposition = AIGetMarkersAroundLocation( self, 'Land Path Node', result, 200)

                if LOUDGETN(landposition) < 1 then
				
                    --LOG("*AI DEBUG Could not find Land Node with 200 of resultposition "..repr(result).." using Water at 300")
					
                    fakeposition = AIGetMarkersAroundLocation( self, 'Water Path Node', result, 300)
					
                else
				
                    LOUDINSERT(positions, {Position = landposition[1].Position, Pathvalue = LOUDFLOOR(VDist2Sq(CurrentPoint[1],CurrentPoint[3],landposition[1].Position[1],landposition[1].Position[3])), Type = 'Land', Path = false})
					
                end

                if fakeposition then
				
					--LOG("*AI DEBUG Fakeposition assign - working from CurrentPoint of "..repr(CurrentPoint))
					--LOG("*AI DEBUG Fakeposition assign - Fakepositions are "..repr(fakeposition))
					
                    LOUDINSERT(positions, {Position = fakeposition[1].Position, Pathvalue = LOUDFLOOR(VDist2Sq(CurrentPoint[1],CurrentPoint[3],fakeposition[1].Position[1],fakeposition[1].Position[3])), Type = 'Naval', Path = false})
					
                end
				
            end

            LOUDSORT(positions, function(a,b) return a.Pathvalue < b.Pathvalue end )
			
			-- make sure new point not same as previous - if it is - we're done
			if not table.equal( positions[1].Position, CurrentPoint ) then
			
				StageCount = StageCount + 1 
				
				LOUDINSERT(StagePoints, positions[1])
				
				lastaddedposition = table.copy(positions[1].Position)
				
				CurrentPoint = positions[1].Position
				
			else
			
				GoalReached = true
				
			end
			
        end 
		
    end
	
	--LOG("*AI DEBUG "..self.Nickname.." Goal reached ")
	
    if StageCount >= 0 then
	
        self.AttackPlan.Goal = Goal
        self.AttackPlan.CurrentGoal = 0
		self.AttackPlan.StageCount = StageCount
        self.AttackPlan.StagePoints = { [0] = StartPosition }
        self.AttackPlan.GoSignal = false
		
		-- record if attack plan can be land based or not
		if path then
			self.AttackPlan.Method = 'Land'
		else
			self.AttackPlan.Method = 'Amphibious'
		end

        --self.AttackPlan.StagePoints[0].Position = StartPosition
        local counter = 1

        for _,i in StagePoints do
		
            self.AttackPlan.StagePoints[counter] = i
            counter = counter + 1
			
        end

        self.AttackPlan.StagePoints[counter] = Goal
		
		LOG("*AI DEBUG "..self.Nickname.." Attack Plan Method is "..repr(self.AttackPlan.Method) )

		--LOG("*AI DEBUG "..self.Nickname.." Attack Plan is "..repr(self.AttackPlan))
		
    end
	
end

function AttackPlanMonitor(self)
	
	LOG("*AI DEBUG "..self.Nickname.." Attack Plan Monitor Launched for "..repr(self.AttackPlan.Goal))
	
    local GetThreatsAroundPosition = self.GetThreatsAroundPosition
    local CurrentEnemyIndex = self:GetCurrentEnemy():GetArmyIndex()

    while true do
	
        WaitTicks(self.AttackPlan.GoCheckInterval * 10)

		if self.AttackPlan.Goal then
		
			--LOG("*AI DEBUG " ..self.Nickname.." Assessing Attack Plan to " ..repr(self.AttackPlan.Goal))

			local threatTable = GetThreatsAroundPosition( self, self.AttackPlan.Goal, 64, true, 'Overall', CurrentEnemyIndex)
			
			--LOG("*AI DEBUG Overall Threat Table is " ..repr(threatTable))

			-- what I want to do is loop thru the stages - and evaluate if its complete (we own that stage)

			SetPrimaryLandAttackBase(self)
			
			SetPrimarySeaAttackBase(self)
			
		end
		
    end
	
end



-- this code is here to insure the base area is flat enough to allow 
-- the primary facilities to be built on most any map
function LevelStartBaseArea(position, rallypointradius)

	LOG("*AI DEBUG Flattening Map for AI at "..repr(position))
	
	local posX = position[1]
	local posY = position[3]

	local ht = GetTerrainHeight(posX, posY)

	local radius = math.floor(rallypointradius * .4)

	FlattenMapRect(posX-radius, posY-radius, radius*2, radius*2, ht)

	-- sometimes this can make some rather sharp terrain features - too bad we cant do smoothing at the edges

	local extra_area = 32	-- make additional adjustments this many o-grids beyond the radius value
	
	for a = 1, extra_area do
		
		local h,adjust
		local x1 = posX-(radius+a)
		local x2 = posX+(radius+a)

		-- two lines along the z axis
		for r= posY-(radius+a), posY+(radius+a) do
		
			h = GetTerrainHeight( x1, r )
			adjust = h - ht
			adjust = adjust * (a/extra_area)

			adjust = ht + adjust
			
			if x1 >= 0 and x1 <= ScenarioInfo.size[1] and r >= 0 and r <= ScenarioInfo.size[2] then
				FlattenMapRect( x1, r, 1, 1, adjust )
			end
	
			h = GetTerrainHeight( x2, r )
			adjust = h - ht
			adjust = adjust * (a/extra_area)
		
			adjust = ht + adjust	
		
			if x2 >= 0 and x2 <= ScenarioInfo.size[1] and r >= 0 and r <= ScenarioInfo.size[2] then
				FlattenMapRect( x2, r, 1, 1, adjust )
			end
			
		end
	
		x1 = posY-(radius+a)
		x2 = posY+(radius+a)
		
		-- and then along the x axis
		for r= posX-(radius+a), posX+(radius+a) do
	
			h = GetTerrainHeight( r, x1 )
			adjust = h - ht
			adjust = adjust * (a/extra_area)
			
			adjust = ht + adjust
			
			if x1 >= 0 and x1 <= ScenarioInfo.size[2] and r >= 0 and r <= ScenarioInfo.size[1] then
				FlattenMapRect( r, x1, 1, 1, adjust )
			end
		
			h = GetTerrainHeight( r, x2 )
			adjust = h - ht
			adjust = adjust * (a/extra_area)
			
			adjust = ht + adjust
		
			if x2 >= 0 and x2 <= ScenarioInfo.size[2] and r >= 0 and r <= ScenarioInfo.size[1] then
				FlattenMapRect( r, x2, 1, 1, adjust )
			end
		end
	end
	
end

-- function to draw HiPri Intel points on the map for debugging - all credit to Sorian
function DrawIntel( aiBrain )

    local WaitTicks = coroutine.yield
    local DrawC = DrawCircle
	
	local threatColor = {
		--ThreatType = { ARGB value }
		--StructuresNotMex = 'ff00ff00', #--Green
		--Commander = 'ff00ffff', #--Cyan
		--Economy = 'ddffffff', #--White
		--Experimental = 'ffff0000', #--Red
		--Artillery = 'ffffff00', #--Yellow
		Land = 'afff9600', #--Orange
		Naval = 'af0a0a0a', #--Black
		Air = 'ffff0096', #--Pink
		AntiAir = 'ff00ff00', #-- Green
	}
	
	local threatColor2 = {
		--ThreatType = { ARGB value }
		--StructuresNotMex = 'ff00ff00', #--Green
		--Commander = 'ff00ffff', #--Cyan
		--Economy = 'ddffffff', #--White
		--Experimental = 'ffff0000', #--Red
		--Artillery = 'ffffff00', #--Yellow
		Land = 'ffff9600', #--Orange
		Naval = 'ffff00ff', #--Purple
		Air = 'ffffd700', #--gold
		AntiAir = 'ffff0000', #-- red
	}	
	
	-- this will draw resolved intel data (specific points)
	local function DrawIntelPoint(position, color)
	
		for i = 0,5 do
			DrawC( position, 1, color )
			WaitTicks(1)
			DrawC( position, 3, color )
			WaitTicks(1)
			DrawC( position, 5, color )	
			WaitTicks(1)
			DrawC( position, 7, color )
			WaitTicks(1)
			DrawC( position, 9, color )	
			WaitTicks(1)
		end
		
	end

	-- this will draw 'raw' intel data (standard threat map points)
	local function DrawRawIntel(position, Type )
	
		local threats = aiBrain:GetThreatsAroundPosition( position, 1, true, Type)
		
		for _,v in threats do
		
			if v[3] > 10 then
			
				ForkThread( DrawIntelPoint, {v[1],0,v[2]}, threatColor2[Type] )
				
			end
			
		end
		
	end
	
	while true do
	
		if aiBrain.ArmyIndex == GetFocusArmy() then
		
            local inteldata = aiBrain.IL.HiPri
			
			for _,v in inteldata do
			
				if threatColor[v.Type] then
				
					ForkThread( DrawIntelPoint, v.Position, threatColor[v.Type] )
					
					--ForkThread( DrawRawIntel, v.Position, v.Type )
					
				end
				
				WaitTicks(1)
				
		    end
			
		end
		
		WaitTicks(50)
		
	end
	
end

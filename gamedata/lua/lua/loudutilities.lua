--  /lua/loudutilities.lua
--  LOUD specific things

-- You will find lots of useful notes in here 

local AIGetMarkersAroundLocation = import('/lua/ai/aiutilities.lua').AIGetMarkersAroundLocation
local AIPickEnemyLogic = import('/lua/ai/aiutilities.lua').AIPickEnemyLogic

--local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD

local RandomLocation = import('/lua/ai/aiutilities.lua').RandomLocation
local SetArmyPoolBuff = import('ai/aiutilities.lua').SetArmyPoolBuff

local AssignTransportToPool = import('/lua/ai/altaiutilities.lua').AssignTransportToPool

local AISendChat = import('/lua/ai/sorianutilities.lua').AISendChat
local AISendPing = import('/lua/ai/altaiutilities.lua').AISendPing

local Game = import('game.lua')

local LOUDCOPY = table.copy
local LOUDENTITY = EntityCategoryContains
local LOUDGETN = table.getn
local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove
local LOUDSORT = table.sort
local LOUDFLOOR = math.floor

local EntityCategoryCount = EntityCategoryCount
local ForkThread = ForkThread

local VectorCached = { 0, 0, 0 }

local WaitSeconds = WaitSeconds
local WaitTicks = coroutine.yield
local VDist2Sq = VDist2Sq
local VDist3 = VDist3

local GetAIBrain = moho.unit_methods.GetAIBrain

local GetCurrentUnits = moho.aibrain_methods.GetCurrentUnits
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome
local GetFuelRatio = moho.unit_methods.GetFuelRatio
local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
local GetNumUnitsAroundPoint = moho.aibrain_methods.GetNumUnitsAroundPoint
local GetPlatoonPosition = moho.platoon_methods.GetPlatoonPosition
local GetPosition = moho.entity_methods.GetPosition
local GetThreatAtPosition = moho.aibrain_methods.GetThreatAtPosition
local GetThreatsAroundPosition = moho.aibrain_methods.GetThreatsAroundPosition
local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint

local IsBeingBuilt = moho.unit_methods.IsBeingBuilt

local GetTerrainHeight = GetTerrainHeight
local GetUnitsInRect = GetUnitsInRect

local AssignUnitsToPlatoon = moho.aibrain_methods.AssignUnitsToPlatoon
local MakePlatoon = moho.aibrain_methods.MakePlatoon

local PlatoonCategoryCount = moho.platoon_methods.PlatoonCategoryCount
local PlatoonExists = moho.aibrain_methods.PlatoonExists

local EXTRACTORS = categories.MASSEXTRACTION - categories.TECH1
local FABRICATORS = categories.MASSFABRICATION * categories.TECH3
local PARAGONS = categories.MASSFABRICATION * categories.EXPERIMENTAL

local timeACTBrains = {}
local ratioACTBrains = {}

-- static version of function from EBC
function GreaterThanEnergyIncome(aiBrain, eIncome)
	return (GetEconomyIncome( aiBrain, 'ENERGY')*10) >= eIncome
end

-- static versions of functions from UCBC
function IsBaseExpansionUnderway(aiBrain, bool)
	return bool == aiBrain.BaseExpansionUnderway
end

function PoolLess( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) < unitCount
end

function PoolGreater( aiBrain, unitCount, testCat)
	return PlatoonCategoryCount( aiBrain.ArmyPool, testCat ) > unitCount
end

function FactoryGreaterAtLocation( aiBrain, locationType, unitCount, testCat)
	return EntityCategoryCount( testCat, aiBrain.BuilderManagers[locationType].FactoryManager.FactoryList ) > unitCount	
end

function FactoriesGreaterThan( aiBrain, unitCount, testCat )

	local result = 0
	
	for k,v in aiBrain.BuilderManagers do
		result = result + EntityCategoryCount( testCat, v.FactoryManager.FactoryList )
	end

	return result > unitCount
end

function UnitsLessAtLocation( aiBrain, locationType, unitCount, testCat )

    local BM = aiBrain.BuilderManagers[locationType]

	if BM.EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, BM.Position, BM.EngineerManager.Radius, 'Ally') < unitCount
	end
	
	return false
end

function UnitsGreaterAtLocation( aiBrain, locationType, unitCount, testCat )

    local BM = aiBrain.BuilderManagers[locationType]

	if BM.EngineerManager then
		return GetNumUnitsAroundPoint( aiBrain, testCat, BM.Position, BM.EngineerManager.Radius, 'Ally') > unitCount
	end
    
	return false
end

function HaveGreaterThanUnitsWithCategory(aiBrain, numReq, testCat, idleReq)
    return GetCurrentUnits(aiBrain,testCat) > numReq
end

function HaveGreaterThanUnitsWithCategoryAndAlliance(aiBrain, numReq, testCat, alliance)
	return GetNumUnitsAroundPoint( aiBrain, testCat, VectorCached, 999999, alliance ) > numReq
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

-- static version of function with specific location
function BaseInPlayableArea( aiBrain, managerposition )

    if ScenarioInfo.Playablearea then

        local PlayableArea = ScenarioInfo.Playablearea

        if managerposition[1] < PlayableArea[1] or managerposition[1] > PlayableArea[3] then
 
            return false
            
        end
        
        if managerposition[3] < PlayableArea[2] or managerposition[3] > PlayableArea[4] then

            return false
            
        end
        
    end
    
    return true
end

-- This routine returns the location of the closest base that has engineers or factories
function AIFindClosestBuilderManagerPosition( aiBrain, position)

    local distance = 9999999
	local closest = false
    
    local BM = aiBrain.BuilderManagers
    local VDist2Sq = VDist2Sq

    for k,v in BM do
	
		if v.EngineerManager.Active then
		
			if v.EngineerManager.EngineerList.Count > 0 or EntityCategoryCount( categories.FACTORY - categories.NAVAL, v.FactoryManager.FactoryList ) > 0 then
			
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
function FindClosestBaseName( aiBrain, position, allownavalbases, onlynavalbases)

    local distance = 99999999
	local closest = false
    
    local BM = aiBrain.BuilderManagers
    local VDist2 = VDist2
	
    for k,v in BM do
	
		if position and v.EngineerManager.Active then
		
			-- process all bases except 'Sea' unless allownavalbases is true and process only 'Sea' if onlynavalbases
			if (v.BaseType != 'Sea' and (not onlynavalbases)) or (v.BaseType == 'Sea' and allownavalbases) then
			
				if VDist2( position[1],position[3], v.Position[1],v.Position[3] ) < distance then
					distance = VDist2( position[1],position[3], v.Position[1],v.Position[3] )
					closest = v.BaseName
				end
			end
		end
    end

    return closest, distance
end


function GetBaseWithGreatestThreatAtDistance( aiBrain, threattype, threatcutoff, distance )

    local bestname = false
    local threatamount = 0
    local bestthreat = threatcutoff or 10
    
    local ringcheck = LOUDFLOOR(distance/ScenarioInfo.IMAPSize)
    
   	local GetThreatsAroundPosition = GetThreatsAroundPosition
    
    local BM = aiBrain.BuilderManagers
    
    local threattable

    for _, base in BM do

        if base.PlatoonFormManager.Active then

            threatTable = GetThreatsAroundPosition( aiBrain, base.Position, ringcheck, true, threattype)
            
            for _,v in threatTable do
            
                if v[3] > threatcutoff then
                
                    threatamount = threatamount + v[3]
                end
           
            end
            
            if threatamount > bestthreat then
            
                bestname = base.BaseName
                bestthreat = threatamount
            end
        end
    end
    
    return bestname, bestthreat
end

-- Sorts the list of scouting areas by time since scouted, and then distance from main base.
function AISortScoutingAreas( aiBrain, list )

    LOUDSORT( list, function(a,b)	
	
		if a.LastScouted and b.LastScouted then
		
			if a.LastScouted == b.LastScouted then
				return VDist2Sq(aiBrain.StartPosX, aiBrain.StartPosZ, a.Position[1], a.Position[3]) < VDist2Sq(aiBrain.StartPosX, aiBrain.StartPosZ, b.Position[1], b.Position[3])
			else
				return a.LastScouted < b.LastScouted
			end
			
		else
			return a.LastScouted
		end
    end)
	
end

-- if the AI has its share of mass points
function HasMassPointShare( aiBrain, multiple )

    local units = GetListOfUnits( aiBrain, categories.ECONOMIC, false)
    
    local extractorCount = 0
    
    if units[1] then
	
        extractorCount = EntityCategoryCount( EXTRACTORS, units)
    
        extractorCount = extractorCount + ( EntityCategoryCount( FABRICATORS, units) * .5)
    
        extractorCount = extractorCount + ( EntityCategoryCount( PARAGONS, units) * 4)

        -- The Extractor count is increased by the AIMult (which is carried in aiBrain.VeterancyMult)
        -- so an AI with a high cheat will consider itself to have it's share sooner
        extractorCount = extractorCount * aiBrain.VeterancyMult
    end

    -- the addition of the multiple allows us to test for an ownership % relationship
	return extractorCount >= ( aiBrain.MassPointShare * (multiple or 1))
end

-- a variant of the above
function NeedMassPointShare( aiBrain, multiple )

    local units = GetListOfUnits( aiBrain, categories.ECONOMIC, false)
    
    local extractorCount = 0
	
    if units[1] then

        extractorCount = EntityCategoryCount( EXTRACTORS, units)
    
        extractorCount = extractorCount + ( EntityCategoryCount( FABRICATORS, units) * .5)
    
        extractorCount = extractorCount + ( EntityCategoryCount( PARAGONS, units) * 4)

        -- The Extractor count is increased by the AIMult (which is carried in aiBrain.VeterancyMult)
        -- so an AI with a high cheat will consider itself to have it's share sooner
        extractorCount = extractorCount * aiBrain.VeterancyMult
    end

	return extractorCount < ( aiBrain.MassPointShare * (multiple or 1))
end

-- verifies if the TEAM has its share of mass points
function TeamMassPointShare( aiBrain, bool )

    -- the Extractor count is increased by the AIMult so we trigger this earlier than the count would indicate
	local TeamExtractors = LOUDGETN( GetUnitsAroundPoint( aiBrain, categories.MASSEXTRACTION, VectorCached, 9999, 'Ally' )) * aiBrain.VeterancyMult
    
	local TeamNeeded = aiBrain.MassPointShare * aiBrain.TeamSize
	
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

	local TeamExtractors = LOUDGETN( GetUnitsAroundPoint( aiBrain, EXTRACTORS, VectorCached, 9999, 'Ally' )) * aiBrain.VeterancyMult
    
	local TeamNeeded = aiBrain.MassPointShare * aiBrain.TeamSize

	return TeamExtractors < TeamNeeded
end

-- a land-based production centre can be in LandMode or not (== AmphibiousMode)
function BaseInLandMode( aiBrain, locType )

    return aiBrain.BuilderManagers[locType].LandMode
end

function BaseInAmphibiousMode( aiBrain, locType )

    return not aiBrain.BuilderManagers[locType].LandMode
end

-- if there is not a base alert at this location	
function NoBaseAlert( aiBrain, locType )

	if aiBrain.BuilderManagers[locType].EngineerManager.Active then
		return aiBrain.BuilderManagers[locType].EngineerManager.BaseMonitor.ActiveAlerts == 0
	end

	return true
end

function AirStrengthRatioGreaterThan( aiBrain, value )

    -- no AIR activity
    if aiBrain.AirRatio <= .01 then
        return true
    end

	return aiBrain.AirRatio >= value
end

function AirStrengthRatioLessThan ( aiBrain, value )

    -- no AIR activity
    if aiBrain.AirRatio <= .01 then
        return false
    end

	return aiBrain.AirRatio < value
end

function LandStrengthRatioGreaterThan( aiBrain, value )

    -- no LAND activity
    if aiBrain.LandRatio <= .01 or aiBrain.CycleTime < 300 then
        return true
    end

	return aiBrain.LandRatio >= value
end

function LandStrengthRatioLessThan ( aiBrain, value )

    -- no LAND activity
    if aiBrain.LandRatio <= .01 then
        return false
    end

	return aiBrain.LandRatio < value
end

function NavalStrengthRatioGreaterThan( aiBrain, value )

    -- no NAVAL activity
    if aiBrain.NavalRatio <= .01 then
        return true
    end

	return aiBrain.NavalRatio >= value
end

function NavalStrengthRatioLessThan ( aiBrain, value )

    -- no NAVAL activity
    if aiBrain.NavalRatio <= .01 then
        return false
    end

    return aiBrain.NavalRatio < value
end

function GetEnemyUnitsInRect( aiBrain, x1, z1, x2, z2 )
    
    local units = GetUnitsInRect(x1, z1, x2, z2)
    
    if units then
	
        local enemyunits = {}
		local counter = 1
		
        local IsEnemy = IsEnemy
		local GetAIBrain = GetAIBrain
		
        for _,v in units do
		
            if not v.Dead and IsEnemy( GetAIBrain(v).ArmyIndex, aiBrain.ArmyIndex) then
                enemyunits[counter] =  v
				counter = counter + 1
            end
        end 
		
        if counter > 1 then
            return enemyunits, counter-1
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
function GetFreeUnitsAroundPoint( aiBrain, category, location, radius, useRefuelPool, tmin, tmax, rings, tType )

    local units = aiBrain:GetUnitsAroundPoint( category, location, radius, 'Ally' )
    
    local GetThreatAtPosition = GetThreatAtPosition
	
    local retUnits = {}
	local counter = 1
	
    local checkThreat = true	-- default to true which means include all if no threat check 
	local threat = 0
    
    if tmin and tmax and rings then -- if threat parameters provided validate threat and set checkThreat
	
		threat = GetThreatAtPosition( aiBrain, location, rings, true, tType or 'Overall' )
		
		checkThreat = (threat >= tmin and threat <= tmax)
    end
	
	if checkThreat then
	
		for k,v in units do
		
			if not v.Dead and not IsBeingBuilt(v) and GetAIBrain(v).ArmyIndex == aiBrain.ArmyIndex then
			
				-- select only units in the Army pool or not attached
				if not v.PlatoonHandle or (v.PlatoonHandle == aiBrain.ArmyPool) or (useRefuelPool and v.PlatoonHandle == aiBrain.RefuelPool) then

					retUnits[counter] = v
					counter = counter + 1
				end
			end
        end
    end
	
    return retUnits,counter-1
end

-- this function will set a FACTORY builder priority to 0 permanently for later removal
function UseBuilderOnce( aiBrain, factory, builder)

    local manager = 'FactoryManager'

	local buildertable = aiBrain.BuilderManagers[factory.LocationType][manager]['BuilderData'][factory.BuilderType]

	for a,b in buildertable['Builders'] do
		
		if b.BuilderName == builder.BuilderName then
			b:SetPriority(0,false)
			break
		end
	end    

end

--	The SpawnWave is a bonus given only to the AIx
-- 	Essentially every spawndelay period, the AI will receive a few 'free' air units (based upon AIx cheat bonus.
--  The number gradually grows with each iteration over the course of the game and the period between
--  iterations gradually shrinks making the AIx an ever increasing threat.  Growth is capped at 10 iterations
--  The AIx unit cap (if not unlimited) is increased by the total number of units in the spawnwave
function SpawnWaveThread( aiBrain )

	local initialUnits = false
	
	local testUnits = {}
	local coreunits = {}
	local faction = aiBrain.FactionIndex
	local startx, startz = aiBrain:GetArmyStartPos()
	local wave = 1
	
	local spawndelay = 1200 * (1 / aiBrain.CheatValue)	-- every 20 minutes but reduced by cheat build multiplier
	
	local hold_wave = true
    
    if faction == 1 then
		testUnits = { 'uea0303', 'uea0304', 'uea0305', 'uea0104', 'uea0302' }
        
    elseif faction == 2 then
		testUnits = { 'uaa0303', 'uaa0304', 'xaa0305', 'uaa0104', 'uaa0302' }
		
    elseif faction == 3 then
		testUnits = { 'ura0303', 'ura0304', 'xra0305', 'ura0104', 'ura0302' }
		
	elseif faction == 4 then
		testUnits = { 'xsa0303', 'xsa0304', 'xsa0203', 'xsa0104', 'xsa0302' }
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
			LOUDINSERT(initialUnits, test_unit_id)
		else
		
			if not initialUnits then
				initialUnits = {}
			end
			
			LOUDINSERT(initialUnits, false)
		end
	end
	
	if initialUnits then
		--LOG("*AI DEBUG "..aiBrain.Nickname.." Spawnwave initialized")
	end
	
	local initialdelay = true

	-- IF there is an initial units list then
	-- spawnwave will begin once the first T3 Air Factory is online - check every 60 seconds until it does
	while initialdelay do
	
		WaitSeconds(60)
	
		local T3AirFacs = GetListOfUnits( aiBrain, categories.AIR * categories.FACTORY * categories.TECH3, false )
		
		if T3AirFacs[1] then
		
			for _,v in T3AirFacs do

				-- the factory must be fully built --
				if v:GetFractionComplete() == 1 then

					--LOG("*AI DEBUG "..aiBrain.Nickname.." Spawnwave timer launched")
					initialdelay = false
					break
				end
			end
		end
	end
	
	local ArmyPool = aiBrain.ArmyPool

	while initialUnits do
    
		local T3AirFacs = GetListOfUnits( aiBrain, categories.AIR * categories.FACTORY * categories.TECH3, false )
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." T3AirFacs is "..repr(T3AirFacs))
	
        -- the spawnwave cannot happen unless a T3 Air Factory is present
		if LOUDGETN(T3AirFacs) == 0 then
            LOG("*AI DEBUG "..aiBrain.Nickname.." spawnwave disabled - no factory")
            WaitSeconds(120)
			continue
		end    
		
		-- increase the size of the wave each time and vary it with the build cheat level
		local units = math.floor((wave * 1.5) * aiBrain:TotalCheat() )
        -- insure that there is always at least 1 unit (in case of negative multipliers)
        local units = math.max( units, 1 )
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Spawnwave will have "..units.." unit(s)")
		
		-- increase the unit cap by the number of units * 5 - accounting for the multiple types
		SetArmyUnitCap( aiBrain.ArmyIndex, GetArmyUnitCap( aiBrain.ArmyIndex) + (units * 5) )
		
		-- the unit we'll create
		local unit
		
		for spawn = 1, units do
		
			-- fighters --
			if initialUnits[1] then
				unit = aiBrain:CreateUnitNearSpot(initialUnits[1],startx,startz)
				SimulateFactoryBuilt( unit )
			end
			
			WaitTicks(1)

			-- bombers --
			if initialUnits[2] then
				unit = aiBrain:CreateUnitNearSpot(initialUnits[2],startx,startz)
				SimulateFactoryBuilt( unit )
			end
			
			WaitTicks(1)

			-- gunships --
			if initialUnits[3] then
				unit = aiBrain:CreateUnitNearSpot(initialUnits[3],startx,startz)
				SimulateFactoryBuilt( unit )
			end
			
			WaitTicks(1)

			-- transports -- but only if needed
			if aiBrain.NeedTransports then

				if initialUnits[4] then
					unit = aiBrain:CreateUnitNearSpot(initialUnits[4],startx,startz)
					SimulateFactoryBuilt( unit )
				end
				WaitTicks(1)
			end

			-- spy planes --
			if initialUnits[5] then
				unit = aiBrain:CreateUnitNearSpot(initialUnits[5],startx,startz)
				SimulateFactoryBuilt( unit )
			end
			
			WaitTicks(1)
		end
		
		wave = wave + 1

        -- cap out at 10 waves --
		if wave > 10 then
			wave = 10
		end
		
		-- send everything in the core to a disperse point --
		coreunits = GetFreeUnitsAroundPoint( aiBrain, categories.MOBILE - categories.ENGINEER, {startx, 0, startz}, 26 )
		
		DisperseUnitsToRallyPoints( aiBrain, coreunits, aiBrain.BuilderManagers['MAIN'].Position, aiBrain.BuilderManagers['MAIN'].RallyPoints )
		
		-- decrease the period until the next wave  -- modified by the cheat level
        -- each reduction will be smaller than the last until wave 10 when it becomes the same
        -- initial reduction is 30 seconds + cheat
        -- final   reduction is 12 seconds + cheat
		spawndelay = spawndelay - ( (30 - ((wave-1)*2) ) * aiBrain:TotalCheat() )
        
		--LOG("*AI DEBUG "..aiBrain.Nickname.." gets spawnwave of "..units.." at "..GetGameTimeSeconds().." seconds")
        --LOG("*AI DEBUG "..aiBrain.Nickname.." next spawnwave in "..spawndelay.." seconds")

		-- wait for the next spawn wave
		WaitTicks(math.floor(spawndelay * 10))
	end
	
	LOG("*AI DEBUG "..aiBrain.Nickname.." Spawnwave disabled")
	
	aiBrain.WaveThread = nil
	
end

function SubscribeToACT(aiBrain)

	-- Purge unneeded adaptive KVP once it's consumed
	if aiBrain.Adaptive == 2 or aiBrain.Adaptive == 4 then
		LOUDINSERT(ratioACTBrains, aiBrain)
	end
    
	if aiBrain.Adaptive == 3 or aiBrain.Adaptive == 4 then
		LOUDINSERT(timeACTBrains, aiBrain)
	end
    
	aiBrain.Adaptive = nil
end

function StartAdaptiveCheatThreads()

	if ratioACTBrains[1] then
    
		local str = ""
        
		for i, v in ratioACTBrains do
			str = str.."\t"..v.Nickname.."\n"
		end
        
		LOG("*AI DEBUG Forking ratio ACT for:\n"..str)
        
		ForkThread(RatioAdaptiveCheatThread)
	end
    
	if timeACTBrains[1] then
    
		local str = ""
        
		for i, v in timeACTBrains do
			str = str.."\t"..v.Nickname.."\n"
		end
        
		LOG("*AI DEBUG Forking time ACT for:\n"..str)
        
		ForkThread(TimeAdaptiveCheatThread)
	end
    
end

function StartSpeedProfile()

    --ForkThread (SpeedProfile)

end

function SpeedProfile()

    -- account for time expended prior to game time starting
    --local startvalue = GetSystemTimeSecondsOnlyForProfileUse()
    
    local GSO = GetSystemTimeSecondsOnlyForProfileUse
    --local GTS = GetGameTimeSeconds
    
--[[
    while true do
    
        local gamesecondsperactualseconds = ( GSO() - startvalue ) / GTS()
        local ax = GTS() / (GSO() - startvalue)
    
        LOG("*AI DEBUG Speed Profile at Gametime "..repr(GTS()).." is "..gamesecondsperactualseconds.." -- "..ax )
    
        -- this will actually be precisely 5 seconds -- at least according to GetGameTimeSeconds
        -- not quite sure where the extra tick is being lost
        WaitTicks(51)
        
    end
--]]

    local a
    
    local b = {}
    
    local total = 0
    
    local count = 1
    
    local avg = 0
    
    local period = 30
    
    while true do
    
        a = GSO()
       
        WaitTicks(11)
       
        a = GSO() - a
       
        total = total - ( b[count] or 0 )
       
        b[count] = a
       
        total = total + a
       
        avg = total/period
       
        count = count + 1
       
        if count > period then
       
            count = 1
            
        end

        LOG("*AI DEBUG Time per game second "..a.."  Avg over "..period.." seconds "..avg)
    
    end
end

-- The following 2 functions are courtesy of:
-- - Uveso (FAF); initial implementation
-- - Azraeelian Angel; adaptation for LOUD
-- - Sprouto; optimization
function RatioAdaptiveCheatThread()

	local interval = 10 * tonumber(ScenarioInfo.Options.ACTRatioInterval)
	local scale = tonumber(ScenarioInfo.Options.ACTRatioScale)

	LOG("*AI DEBUG Starting ACT FEEDBACK after 5 minutes. Interval: "..repr(interval).." ticks; scale: "..repr(scale))
    
	-- Wait 5 minutes first, else earliest land ratios skew results
	WaitTicks(10 * 60 * 5)
    
	LOG("*AI DEBUG Starting ACT FEEDBACK now")

	while true do
    
		if not ratioACTBrains[1] then
			break
		end

		WaitTicks(interval)

		-- If a brain gets unsubscribed during an update, the list of brains is
		-- compromised, and we must stop immediately and reiterate
		local broke = false

		local function Iterate()
        
			for i = 1, LOUDGETN(ratioACTBrains) do
            
				local aiBrain = ratioACTBrains[i]
                
				if aiBrain.Result == "defeat" then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT FEEDBACK unsubbed: defeated")
                    
					LOUDREMOVE(ratioACTBrains, i)
                    
					broke = true
                    
					break
				end

				local oldcheat = aiBrain:TotalCheat()

				local prev = aiBrain.FeedbackCheat

				-- RATODO: Discuss how to implement all ratios
				-- Need to consider how much water is on map
				if aiBrain.LandRatio <= 0.5 then
					aiBrain.FeedbackCheat = 0.5 * scale
				elseif aiBrain.LandRatio <= 0.6 then
					aiBrain.FeedbackCheat = 0.4 * scale
				elseif aiBrain.LandRatio <= 0.75 then
					aiBrain.FeedbackCheat = 0.3 * scale
				elseif aiBrain.LandRatio <= 0.9 then
					aiBrain.FeedbackCheat = 0.2 * scale
				elseif aiBrain.LandRatio <= 1 then
					aiBrain.FeedbackCheat = 0.1 * scale
				else
					aiBrain.FeedbackCheat = 0
				end

				-- Don't apply army pool buff if FeedbackCheat didn't change
				if prev ~= aiBrain.FeedbackCheat then
                
					SetArmyPoolBuff(aiBrain, aiBrain:TotalCheat())
                    
                    LOG("*AI DEBUG "..aiBrain.Nickname.." ACT FEEDBACK (Ratio = "..aiBrain.LandRatio..") from "..oldcheat.." to "..aiBrain:TotalCheat())
				end

			end
		end

		Iterate()
        
		if broke then
            Iterate()
        end
        
	end
    
	LOG("*AI DEBUG No more ACT FEEDBACK subscribers. Killing thread")
end

function TimeAdaptiveCheatThread()

	-- RATODO: Ideas by Uveso and Balthazar
	-- - Parabola
	-- - Logarithmic
	-- - Multiplicative
	-- - Use ratios to slow or speed time-based increase
    
	local startDelay = 10 * 60 * tonumber(ScenarioInfo.Options.ACTStartDelay)
    local interval = 10 * 60 * tonumber(ScenarioInfo.Options.ACTTimeDelay) + 1
    local cheatInc = tonumber(ScenarioInfo.Options.ACTTimeAmount)
	local cheatLimit = tonumber(ScenarioInfo.Options.ACTTimeCap)
    
	-- EXAMPLE: If 1.5 is the limit, -.05 is the change, and 1.1 is the base,
	-- this check prevents mult from getting math.maxed all the way up to 1.5
	for i = 1, LOUDGETN(timeACTBrains) do
    
		local aiBrain = timeACTBrains[i]
        
		if cheatInc < 0 and cheatLimit > aiBrain.CheatValue then
        
			LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED: base is below limit. Unsubscribing...")
            
			LOUDREMOVE(timeACTBrains, i)
		end
        
	end
	
	LOG("*AI DEBUG Starting ACT TIMED after "..startDelay.." ticks. Change: "..cheatInc.." per "..interval.." ticks. Limit: "..repr(cheatLimit))
    
	WaitTicks(startDelay)
	
	while true do
    
		if not timeACTBrains[1] then
			break
		end
        
		WaitTicks(interval)
        
		--LOG("*AI DEBUG ACT TIMED cycles at "..repr(GetGameTimeSeconds()).." secs")

		-- If a brain gets unsubscribed during an update, the list of brains is
		-- compromised, and we must stop immediately and reiterate
		local broke = false

		local function Iterate()
        
			for i = 1, LOUDGETN(timeACTBrains) do
            
				local aiBrain = timeACTBrains[i]
                
				-- Between this iteration and last, AI may have been defeated,
				-- or met/surpassed upper/lower limit. Deal with these cases
				if aiBrain.Result == "defeat" then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: defeated")
                    
					LOUDREMOVE(timeACTBrains, i)
                    
					broke = true
					break
                    
				elseif cheatInc < 0 and aiBrain:TotalCheat() <= cheatLimit then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: lower limit met")
                    
					SetArmyPoolBuff(aiBrain, math.max(cheatLimit, aiBrain:TotalCheat()))
                    
					LOUDREMOVE(timeACTBrains, i)
                    
					broke = true
					break
                    
				elseif cheatInc > 0 and aiBrain:TotalCheat() >= cheatLimit then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: upper limit met")
                    
					SetArmyPoolBuff(aiBrain, math.min(cheatLimit, aiBrain:TotalCheat()))
                    
					LOUDREMOVE(timeACTBrains, i)
                    
					broke = true
					break
                    
				end

				local oldcheat = aiBrain:TotalCheat()
				
				aiBrain.TimeCheat = aiBrain.TimeCheat + cheatInc
                
                -- adjust unit cap but only ever upwards - never down
                if cheatInc > 0 then
                
                    local c = aiBrain.StartingUnitCap 
                
                    local a = GetArmyUnitCap(aiBrain.ArmyIndex)
                    
                    local b = a + (c * cheatInc )
                    
                    SetArmyUnitCap(aiBrain.ArmyIndex, b)
                    
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED Unit Cap is now "..repr(b))
				end
                
				SetArmyPoolBuff(aiBrain, aiBrain:TotalCheat())
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED cheat goes from "..oldcheat.." to "..aiBrain:TotalCheat())
			end
		end

		Iterate()
        
		if broke then
            Iterate()
        end
        
	end
    
	LOG("*AI DEBUG No more ACT TIMED subscribers. Killing thread")
end

function SimulateFactoryBuilt (finishedUnit)

	-- this is a copy of what you'll find in the FactoryBuilderManager --
	if LOUDENTITY((categories.AIR * categories.MOBILE), finishedUnit) then
		
		-- all AIR units (except true Transports) will get these callbacks to assist with Airpad functions
		if not LOUDENTITY((categories.TRANSPORTFOCUS - categories.uea0203), finishedUnit) then

			local ProcessDamagedAirUnit = function( finishedUnit, newHP, oldHP )
            
                if not finishedUnit.InRefit then
	
                    -- added check for RTP callback (which is intended for transports but UEF gunships sometimes get it)
                    -- to bypass this is the unit is in the transport pool --
                    if (newHP < oldHP and newHP < 0.5) and not finishedUnit.ReturnToPoolCallbackSet then
					
                        --LOG("*AI DEBUG Callback OnHealthChanged running on "..finishedUnit:GetBlueprint().Description.." with New "..repr(newHP).." and Old "..repr(oldHP))

                        local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits

                        ProcessAirUnits( finishedUnit, GetAIBrain(finishedUnit) )
                    end
                end
			end

			finishedUnit:AddUnitCallback( ProcessDamagedAirUnit, 'OnHealthChanged')
			
			local ProcessFuelOutAirUnit = function( finishedUnit )
				
                if not finishedUnit.InRefit then
                
                    -- this flag only gets turned on after this executes
                    -- and is turned back on only when the unit gets fuel - so we avoid multiple executions
                    -- and we don't process this if it's a transport pool unit --
                    if finishedUnit.HasFuel and not finishedUnit.ReturnToPoolCallbackSet then
				
                        --LOG("*AI DEBUG Callback OutOfFuel running on "..finishedUnit:GetBlueprint().Description )
				
                        local ProcessAirUnits = import('/lua/loudutilities.lua').ProcessAirUnits
					
                        ProcessAirUnits( finishedUnit, GetAIBrain(finishedUnit) )
                    end
                end
			end
			
			finishedUnit:AddUnitCallback( ProcessFuelOutAirUnit, 'OnRunOutOfFuel')
		else
			
			-- transports get assigned to the Transport pool
			finishedUnit:ForkThread( AssignTransportToPool, GetAIBrain(finishedUnit) )
		end
	end
end
	
-- Maintains table of platoons issuing distress calls and what kind of help they are looking for
-- The thread executes every 8 seconds and simply purges any distress entry more than 30 seconds old
-- or where the platoon that issued it is no longer around
-- Lastly - it maintains a flag to signify if there are ANY platoon distress calls at all
function PlatoonDistressMonitor( aiBrain )

	-- create the data structure
    aiBrain.PlatoonDistress = { ['AlertSounded'] = false, ['Platoons'] = {} }

    local PlatoonExists = PlatoonExists
	local LOUDGETN = table.getn
    local RebuildTable = aiBrain.RebuildTable

    local change = false
    
    local PlatoonDistress = aiBrain.PlatoonDistress

	while true do

		WaitTicks(80)

		if PlatoonDistress.AlertSounded then
		
			change = false

			for k,v in PlatoonDistress.Platoons do
			
				if (not PlatoonExists(aiBrain, v.Platoon)) or (GetGameTimeSeconds() - v.CreationTime > 30) then

					PlatoonDistress.Platoons[k] = nil
					change = true

					if PlatoonExists(aiBrain, v.Platoon) then
						v.Platoon.DistressCall = nil
					end
				end
			end

			if change then
		
				PlatoonDistress.Platoons = RebuildTable( aiBrain, PlatoonDistress.Platoons)

				if not PlatoonDistress.Platoons[1] then
					PlatoonDistress.AlertSounded = false
                end
			end
		end
	end
end

-- feature request - have a flag which will disperse the units to X number of 
-- rallypoints closest to a given position -- would be used during threat conditions
-- to 'stage' units nearer to threat for better response
function DisperseUnitsToRallyPoints( aiBrain, units, position, rallypointtable, checkposition, checkcount )

	if not rallypointtable then

		local rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Rally Point', position, 90)
	
		if not rallypoints[1] then
			rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Naval Rally Point', position, 90)
		end
	
		rallypointtable = {}
        local count = 0
		
		for _,v in rallypoints do
            count = count + 1
			rallypointtable[count] = v.Position
		end
	end

    -- if checkposition is provided then sort the rallypoints by closest to checkposition
    if checkposition then
        LOUDSORT( rallypointtable, function(a,b) return VDist2Sq(a[1],a[3],checkposition[1],checkposition[3]) < VDist2Sq(b[1],b[3], checkposition[1],checkposition[3]) end )
    end

	if rallypointtable[1] then
	
		local rallycount = LOUDGETN(rallypointtable)

        -- if provided use only that number of points
        -- since the table should be sorted, we end up moving only to those
        -- number of points that are closest to checkposition
        if checkcount then
            if rallycount >= checkcount then
                rallycount = checkcount
            end
        end
		
		for _,u in units do
		
			local rp = rallypointtable[ Random( 1, rallycount) ]
			IssueMove( {u}, RandomLocation(rp[1],rp[3], 9))
		end
        
	else
    
		-- try and catch units being dispersed to what may now be a dead base --
		-- the idea is to drop them back into an RTB which should find another base

       	IssueClearCommands( units )

        local ident = Random(1,999999)

		returnpool = MakePlatoon( aiBrain, 'ReturnToBase '..tostring(ident), 'none' )

        returnpool.PlanName = 'ReturnToBaseAI'
        returnpool.BuilderName = 'DisperseFail'
		
        returnpool.BuilderLocation = false
		returnpool.RTBLocation = false

		import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer(returnpool) 

		for _,u in units do

			if not u.Dead then
				AssignUnitsToPlatoon( aiBrain, returnpool, {u}, 'Unassigned', 'None' )
				
				u.PlatoonHandle = {returnpool}
				u.PlatoonHandle.PlanName = 'ReturnToBaseAI'
			end
		end
		
		if returnpool.MovementLayer == "Land" then
			-- dont use naval bases for land --
			returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), false )
		else
			if returnpool.MovementLayer == "Air" or returnpool.PlatoonLayer == "Amphibious" then
				-- use any kind of base --
				returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), true, false )
			else
				-- use only naval bases --
				returnpool.BuilderLocation = FindClosestBaseName( aiBrain, GetPlatoonPosition(returnpool), true, true )
			end
		end

		returnpool.RTBLocation = returnpool.BuilderLocation	-- this should insure the RTB to that base

		-- send the new platoon off to RTB
		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)
	end

	return
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimaryLandAttackBase( aiBrain )

    -- clear existing base reference if it's no longer active
    if not aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].EngineerManager.Active then
        aiBrain.PrimaryLandAttackBase = false
        aiBrain.PrimaryLandAttackBaseDistance = 99999
    end
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD

    if aiBrain.AttackPlan.Goal then
    
        local goal = aiBrain.AttackPlan.Goal
    
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." setting Primary Land Attack Base for goal at "..repr(goal))
            LOG("*AI DEBUG "..aiBrain.Nickname.." Current Primary Land Attack Base is "..repr(aiBrain.PrimaryLandAttackBase))
            LOG("*AI DEBUG "..aiBrain.Nickname.." Previous Primary Land Attack Base is "..repr(aiBrain.LastPrimaryLandAttackBase))
        end
        
        local Bases = {}
		local counter = 0
        
        local path, reason, pathlength
        local Primary
        
        local currentgoaldistance = aiBrain.PrimaryLandAttackBaseDistance or 99999       -- default in case current primary doesn't exist --
        
        
        local currentlandbasemode = false   -- assume all bases are in amphibious mode
        
        if aiBrain.AttackPlan.Method == "Land" then
        
            currentlandbasemode = true      -- bases will be in land mode - rather than amphibious
            
        end
		
		-- make a table of all land bases
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Land" then

                path = false
                pathlength = 0
                
				-- here is the distance calculation 
                path,reason,pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, 'PrimaryLandBaseFinderfrom'..v.BaseName, 'Amphibious', v.Position, goal, 99999, 200)
                
                if path then

                    Bases[counter+1] = { BaseName = v.BaseName, Distance = pathlength, Position = v.Position, Reason = reason }
                    counter = counter + 1
          
                else
                
                    Bases[counter+1] = { BaseName = v.BaseName, Distance = VDist3(v.Position, goal) + 500, Position = v.Position, Reason = reason }
                    counter = counter + 1

                end
            
                -- record the current primary base distance
                if v.BaseName == aiBrain.PrimaryLandAttackBase then
                
                    currentgoaldistance = Bases[counter].Distance
                    
                end
            end
        end
        
        if counter == 0 then
            return
        end
        
		-- sort them by shortest path distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)

        -- a new base must be 10% closer than the existing one -- or don't change --
        if (currentgoaldistance and Bases[1].Distance < (currentgoaldistance * 0.9)) or LOUDGETN(Bases) == 1 then
        
            -- make this base the Primary
            Primary = Bases[1].BaseName
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(Primary).." is now the Primary Land Attack Base - mode LAND is "..repr(currentlandbasemode))
            
            -- set the distance trigger
            currentgoaldistance = Bases[1].Distance

            aiBrain.BuilderManagers[Primary].PrimaryLandAttackBase = true

            aiBrain.LastPrimaryLandAttackBase = aiBrain.PrimaryLandAttackBase or false
	
            -- store the current base selection and distance on the brain
            aiBrain.PrimaryLandAttackBase = Primary
            aiBrain.PrimaryLandAttackBaseDistance = currentgoaldistance
            
            local builderManager
        
            -- loop thru all the potential bases - set Primary, clear all others
            -- set the base mode according to the attack plan method
            for k,v in Bases do
			
                builderManager = aiBrain.BuilderManagers[v.BaseName].PlatoonFormManager

                -- save the primary base data, reset it's PFM and Base Monitor
                if v.BaseName == Primary and aiBrain.BuilderManagers[v.BaseName].EngineerManager.Active then

                    -- reset the Base Monitor 
            		aiBrain.BuilderManagers[v.BaseName].EngineerManager.BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())

                    -- if this is NOT already the current primary Land Attack Base
                    if not aiBrain.LastPrimaryLandAttackBase or aiBrain.LastPrimaryLandAttackBase != aiBrain.PrimaryLandAttackBase then

                        -- reset the tasks with Priority Functions at this PFM
                        builderManager:ForkThread( ResetPFMTasks, aiBrain )
			
                        -- if a human ally has requested status updates
                        if aiBrain.DeliverStatus then
                            ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My Primary LAND Base is now '..aiBrain.PrimaryLandAttackBase )
                        end
                        
                    end
                    
                -- otherwise trigger a clearing operation --                    
                else
                
                    aiBrain.BuilderManagers[v.BaseName].PrimaryLandAttackBase = false
                    builderManager:ForkThread( ClearOutBase, aiBrain )
                    
                end
                
                -- all bases will be set to the current attack plan mode (land or amphibious)
                -- this should enable LOUD to switch over to a pure LAND based attack when
                -- his primary base is connected, by land, to the current goal
                -- and revert to amphibious building otherwise
                if aiBrain.BuilderManagers[v.BaseName].LandMode != currentlandbasemode then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(v.BaseName).." switching Land mode to "..repr(currentlandbasemode) )
                end
                
                aiBrain.BuilderManagers[v.BaseName].LandMode = currentlandbasemode
            end
            
        else
        
            if aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].LandMode != currentlandbasemode then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(aiBrain.PrimaryLandAttackBase).." PRIMARY - switching Land mode to "..repr(currentlandbasemode) )
            end
            
            aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].LandMode = currentlandbasemode        

        end
    end
	
end

function GetPrimaryLandAttackBase( aiBrain )

	if aiBrain.PrimaryLandAttackBase and aiBrain.BuilderManagers[ aiBrain.PrimaryLandAttackBase ].Position then
		return aiBrain.PrimaryLandAttackBase, aiBrain.BuilderManagers[ aiBrain.PrimaryLandAttackBase ].Position
	end

    for k,v in aiBrain.BuilderManagers do
	
        if v.PrimaryLandAttackBase then

			--LOG("*AI DEBUG Returning search for PLAB "..repr(k) )
            return k, v.Position
        end
        
    end
    
	WARN("*AI DEBUG "..aiBrain.Nickname.." has no Primary Land Attack Base")
    return false, nil
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimarySeaAttackBase( aiBrain )

    -- clear existing base reference if it's no longer active
    if not aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].EngineerManager.Active then
        aiBrain.PrimarySeaAttackBase = false
        aiBrain.PrimarySeaAttackBaseDistance = 99999
    end
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD

    if aiBrain.AttackPlan.Goal then
    
        local goal = aiBrain.AttackPlan.Goal
    
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." setting Primary Sea Attack Base for goal at "..repr(goal))
            LOG("*AI DEBUG "..aiBrain.Nickname.." Current Primary Sea Attack Base is "..repr(aiBrain.PrimarySeaAttackBase))
            LOG("*AI DEBUG "..aiBrain.Nickname.." Previous Primary Sea Attack Base is "..repr(aiBrain.LastPrimarySeaAttackBase))
        end
        
        local Bases = {}
		local counter = 0
        
        local path, reason, pathlength
        local Primary
       
        local currentgoaldistance = aiBrain.PrimarySeaAttackBaseDistance or 99999       -- default in case current primary doesn't exist --

		-- make a table of all sea bases
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Sea" then
            
                path = false
                pathlength = 0
			
				-- here is the distance calculation
                path,reason,pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, 'PrimarySeaBaseFinderfrom'..v.BaseName, 'Amphibious', v.Position, goal, 99999, 200)
                
                if path then
                
                    Bases[counter+1] = { BaseName = v.BaseName, Distance = pathlength, Position = v.Position, Reason = reason }
                    counter = counter + 1

                else
                
                    Bases[counter+1] = { BaseName = v.BaseName, Distance = VDist3(v.Position, goal) + 500, Position = v.Position, Reason = reason }
                    counter = counter + 1
                    
                end

                if v.BaseName == aiBrain.PrimarySeaAttackBase then
                
                    currentgoaldistance = Bases[counter].Distance

                end
			end
        end
        
        if counter == 0 then
            return
        end
        
		-- sort them by shortest path distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)
		
        -- a new base must be 10% closer then the existing one -- or don't change --
        if (currentgoaldistance and Bases[1].Distance < (currentgoaldistance * 0.9)) or LOUDGETN(Bases) == 1 then
        
            -- make the closest one the Primary
            Primary = Bases[1].BaseName
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(Primary).." is now the Primary Sea Attack Base")
            
            -- set the distance trigger
            currentgoaldistance = Bases[1].Distance

            aiBrain.BuilderManagers[Primary].PrimarySeaAttackBase = true

            aiBrain.LastPrimarySeaAttackBase = aiBrain.PrimarySeaAttackBase or false

            aiBrain.PrimarySeaAttackBase = Primary
            aiBrain.PrimarySeaAttackBaseDistance = currentgoaldistance

            local builderManager
        
            -- iterate thru all existing SEA bases
            for k,v in Bases do 	

                builderManager = aiBrain.BuilderManagers[v.BaseName].PlatoonFormManager

                -- save the primary base data, reset the PFM and the Base Monitor
                if v.BaseName == Primary and aiBrain.BuilderManagers[v.BaseName].EngineerManager.Active then

                    -- reset the Base Monitor 
            		aiBrain.BuilderManagers[v.BaseName].EngineerManager.BaseMonitor.LastAlertTime = LOUDFLOOR(GetGameTimeSeconds())

                    -- if this is NOT already the current primary Sea Attack Base
                    if not aiBrain.LastPrimarySeaAttackBase or aiBrain.LastPrimarySeaAttackBase != aiBrain.PrimarySeaAttackBase then

                        -- reset the tasks with Priority Functions at this PFM
                        builderManager:ForkThread( ResetPFMTasks, aiBrain )
   
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
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(aiBrain.PrimarySeaAttackBase).." remains the Primary Sea Attack Base")            
        end
    end
    
end

function GetPrimarySeaAttackBase( aiBrain )

	if aiBrain.IsWaterMap then

		if aiBrain.PrimarySeaAttackBase and aiBrain.BuilderManagers[ aiBrain.PrimarySeaAttackBase ].Position then
			return aiBrain.PrimarySeaAttackBase, aiBrain.BuilderManagers[ aiBrain.PrimarySeaAttackBase ].Position
		end

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
    
    -- the base cannot have any active alerts --
    if aiBrain.BuilderManagers[basename].EngineerManager.BaseMonitor.ActiveAlerts == 0 then

        -- all standard land units but Not experimentals 
        local grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.AMPHIBIOUS - categories.COMMAND - categories.ENGINEER - categories.INSIGNIFICANTUNIT, Position, 100 )

        if grouplndcount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutLand'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Land'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in grouplnd do

                if counter < 60 then
                    AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')
                    counter = counter + 1
                else
                    break
                end
            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceLandAI', aiBrain )
            
        end
	
        -- all amphibious land units including experimentals
        local groupamphib, groupamphibcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.AMPHIBIOUS * categories.MOBILE) - categories.COMMAND - categories.ENGINEER - categories.INSIGNIFICANTUNIT, Position, 100 )

        if groupamphibcount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutAmphib'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Amphib'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in groupamphib do

                if counter < 60 then
                    AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')
                    counter = counter + 1
                else
                    break
                end
            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceAmphibAI', aiBrain )
            
        end
	
        -- all naval units including EXPERIMENTALS excluding MOBILESONAR
        local groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, (categories.NAVAL * categories.MOBILE) - categories.MOBILESONAR - categories.INSIGNIFICANTUNIT, Position, 100 )

        if groupseacount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutSea'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Sea'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in groupsea do

                if counter < 60 then
                    AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')
                    counter = counter + 1
                else
                    break
                end
            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceNavalAI', aiBrain )
            
        end

        -- all fighter units including air scouts
        local groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.MOBILE * (categories.ANTIAIR * categories.SCOUT)), Position, 100, true )

        if groupaircount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutFighters'..tostring(ident),'none')

            plat.BuilderName = 'ClearOut Fighters'
            plat.BuilderLocation = basename

            for _,unit in groupair do
                -- assign the units into 'Artillery' which will get an AttackMove order
                -- rather than typical attack - which forces an attack formation - but uses a simple move order
                AssignUnitsToPlatoon( aiBrain,plat, {unit},'Artillery','None')

            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceAmphibAI', aiBrain )	-- Land or Sea whichever is closest to GOAL
            
        end
	
        -- all gunship units including EXPERIMENTAL
        groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.AIR * categories.GROUNDATTACK ), Position, 100, true )

        if groupaircount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutGunships'..tostring(ident),'none')

            plat.BuilderName = 'ClearOut Gunships'
            plat.BuilderLocation = basename

            for _,unit in groupair do

                AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')

            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceAmphibAI', aiBrain )	-- Land or Sea whichever is closest
            
        end	

        -- all bomber units including torpedo bombers and EXPERIMENTALS
        groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.HIGHALTAIR * categories.BOMBER - categories.ANTINAVY), Position, 100, true )

        if groupaircount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutBombers'..tostring(ident),'none')

            plat.BuilderName = 'ClearOut Bombers'
            plat.BuilderLocation = basename

            for _,unit in groupair do

                AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')

            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceAirAI', aiBrain )	-- either Land or Sea
            
        end

        -- all bomber units including torpedo bombers and EXPERIMENTALS
        groupair, groupaircount = GetFreeUnitsAroundPoint( aiBrain, (categories.HIGHALTAIR * categories.ANTINAVY), Position, 100, true )

        if groupaircount > 0 then

            local ident = Random(1,999999)

            local plat = MakePlatoon( aiBrain,'ClearOutTorpedoBombers'..tostring(ident),'none')

            plat.BuilderName = 'ClearOut TorpedoBombers'
            plat.BuilderLocation = basename

            for _,unit in groupair do

                AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')

            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceNavalAI', aiBrain )	-- Sea only
            
        end
        

    end
    
	manager:ForkThread( ResetPFMTasks, aiBrain )
	
	return
	
end

function ResetPFMTasks (manager, aiBrain)
	
	-- Review ALL the PFM Builders for PriorityFunction task changes
	local tasksaltered = 0

    local newpri, temporary
	local newtasks = 0
    
    --if ScenarioInfo.PriorityDialog then
      --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..manager.ManagerType.." "..manager.LocationType.." Resets Any PFM Tasks")
    --end

	for _,b in manager.BuilderData['Any'].Builders do

		for c,d in b do

			if c == 'BuilderName' then

				newPri = false

				if Builders[d].PriorityFunction then
                
                    --if ScenarioInfo.PriorityDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." "..manager.ManagerType.." "..manager.LocationType.." PriorityFunction for "..b.BuilderName  )
                    --end

					temporary = true

					newPri, temporary = Builders[d]:PriorityFunction( aiBrain, manager)

					if newPri and newPri != b.Priority then

						tasksaltered = tasksaltered + 1
                        
                        if ScenarioInfo.PriorityDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..manager.ManagerType.." at "..manager.LocationType.." "..b.BuilderName.." is set to "..repr(newPri).." Temporary is "..repr(temporary))
                        end

						manager:SetBuilderPriority(b.BuilderName, newPri, temporary)
                        
                        manager.BuilderData['Any'].NeedSort = true
                        
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
    aiBrain.NeedTransports = nil
end

-- this function will direct all air units into the refit/refuel process if needed
-- this is fired off by the OnRunOutOfFuel event which triggers it as a callback -- only used by the AI --
-- or during the ReturnToBaseAI function 
function ProcessAirUnits( unit, aiBrain )

	if (not unit.Dead) and (not IsBeingBuilt(unit)) then

        local fuel = GetFuelRatio(unit)

		if ( fuel > -1 and fuel < .75 ) or unit:GetHealthPercent() < .80 then

            if not unit.InRefit then

                --if ScenarioInfo.TransportDialog then
                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." Air Unit "..unit.Sync.id.." assigned to AirUnitRefitThread ")
                --end
            
                -- and send it off to the refit thread --
                unit:ForkThread( AirUnitRefitThread, aiBrain )
                
                return true
                
            --else
              --  LOG("*AI DEBUG "..aiBrain.Nickname.." Air Unit "..unit.Sync.id.." "..unit:GetBlueprint().Description.." already in refit Thread")
            end
		end
	end
	
	return false    -- unit did not need processing
end

-- this function will attempt to get the air unit to a repair pad
-- and will wait until the unit is fueled and repaired
function AirUnitRefitThread( unit, aiBrain )
    
    if unit.Dead or unit.InRefit then
        return
    end

	-- if not dead 
	if (not unit.Dead) then
    
        unit.InRefit = true

        local ident = Random(100000,999999)
        local returnpool = MakePlatoon( aiBrain,'AirRefit'..tostring(ident), 'none')
        
        returnpool.BuilderName = 'AirRefit'..tostring(ident)
        returnpool.UsingTransport = true        -- never review this platoon as part of a merge
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." assigns unit "..unit.Sync.id.." to AirRefit"..tostring(ident).." Unit is "..repr(unit.Dead))

        if not unit.Dead then
        
            AssignUnitsToPlatoon( aiBrain, returnpool, {unit}, 'Unassigned', '')

            unit.PlatoonHandle = returnpool
            
        end

		local fuellimit = .75
		local healthlimit = .80

		local fuel, health, unitPos, plats, closestairpad, distance
		local platpos, tempDist

		local rtbissued = false

        local GetFuelRatio = GetFuelRatio
        local GetCurrentUnits = GetCurrentUnits
        
        local LOUDCOPY = table.copy
        local LOUDSORT = table.sort
        
        local VDist3Sq = VDist3Sq
        local WaitTicks = WaitTicks
        
        

		while (not unit.Dead) do
		
			fuel = GetFuelRatio(unit)
			health = unit:GetHealthPercent()
			
			if ( fuel > -1 and fuel < fuellimit ) or health < healthlimit then

				-- check for any airpads -- ignore mobile ones 
				if GetCurrentUnits( aiBrain, categories.AIRSTAGINGPLATFORM - categories.MOBILE) > 0 then
				
					unitPos = LOUDCOPY(GetPosition(unit))
					
					-- now limit to airpads within 30k
					plats = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint( aiBrain, categories.AIRSTAGINGPLATFORM - categories.MOBILE, unitPos, 1536 )
					
					-- Locate closest airpad
					if plats[1] then
                    
                        LOUDSORT( plats, function(a,b) return VDist3Sq(GetPosition(a),unitPos) < VDist3Sq(GetPosition(b),unitPos) end )
                        
                        closestairpad = plats[1]

						-- Begin loading/refit sequence
						if closestairpad then
							AirStagingThread( unit, closestairpad, aiBrain )
						end
                    end
                end
                
				-- no airpad - just send them home --
                if not rtbissued then
					
					rtbissued = true

					-- find closest base
					local baseposition = FindClosestBaseName( aiBrain, GetPosition(unit), true, false)

					if baseposition then

						IssueStop ( {unit} )
						IssueClearCommands( {unit} )

                        local safePath, reason = returnpool.PlatoonGenerateSafePathToLOUD(aiBrain, returnpool, 'Air', GetPosition(unit), aiBrain.BuilderManagers[baseposition].Position, 16, 256)
			
                        if safePath then

                            -- use path
                            for _,p in safePath do
                                IssueMove( {unit}, p )
                            end
                        else
                            -- go direct -- possibly bad
                            IssueMove( {unit}, aiBrain.BuilderManagers[baseposition].Position )
                        end
					end
				end
				
			-- otherwise we may have refueled/repaired ourselves or don't need it
			else
            
				break
                
			end
            
            if rtbissued then

                WaitTicks(21)
                
            else
            
                break
                
            end
		end

	end

	-- return repaired/refuelled unit to pool
	if not unit.Dead then
    
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." has refuelled or repaired - leaving AirUnitRefitThread - Dead is "..repr(unit.Dead))

        -- weapons turned back on (just in case)
        unit:MarkWeaponsOnTransport(unit, false)

        unit.InRefit = nil        

		-- all units except TRUE transports are returned to ArmyPool --
		if not LOUDENTITY( categories.TRANSPORTFOCUS, unit) or LOUDENTITY( categories.uea0203, unit ) then
	
			AssignUnitsToPlatoon( aiBrain, aiBrain.ArmyPool, {unit}, 'Unassigned', '' )
			
			unit.PlatoonHandle = aiBrain.ArmyPool
			
			DisperseUnitsToRallyPoints( aiBrain, {unit}, GetPosition(unit), false )
            
		else
        
            if ScenarioInfo.TransportDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..unit.Sync.id.." leaving Refit thread")
            end
            
			ForkThread( import('/lua/ai/altaiutilities.lua').ReturnTransportsToPool, aiBrain, {unit}, true )
            
		end
	end
end

-- this function will be called if an airunit finds an airstage to go to
function AirStagingThread( unit, airstage, aiBrain )

	local loadstatus = 0
	
	if not airstage.Dead then
		
		if not unit.Dead then

			IssueStop( {unit} )
			IssueClearCommands( {unit} )

            local safePath, reason = aiBrain.TransportPool.PlatoonGenerateSafePathToLOUD(aiBrain, unit.PlatoonHandle, 'Air', unit:GetPosition(), GetPosition(airstage), 20, 256)
            
            if not unit.Dead then
			
                if safePath then
                
                    --if ScenarioInfo.TransportDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." Transport "..unit.Sync.id.." gets RTB path of "..repr(safePath).." to airstaging - unit is "..repr(unit.Dead) )
                    --end

                    -- use path
                    for _,p in safePath do
                        IssueMove( {unit}, p )
                    end
                
                else
            
                    --if ScenarioInfo.TransportDialog then
                      --  LOG("*AI DEBUG "..aiBrain.Nickname.." Transport "..unit.Sync.id.." no safe path for RTB -- airstaging -- after drop")
                    --end

                    -- go direct -- possibly bad
                    IssueMove( {unit}, GetPosition(airstage))
                
                end
            
            end

			if not (unit.Dead or airstage.Dead) and (not unit:IsUnitState('Attached')) then

                safecall("Unable to IssueTransportLoad units are "..repr(unit), IssueTransportLoad, {unit}, airstage )

				unit:MarkWeaponsOnTransport(unit, true)		-- disable weapons so they wont seek targets -- I hope
			end
		end
	end

	local waitcount = 0
	
	-- loop until unit attached, idle, dead or it's fixed itself
	while (not unit.Dead) and (not airstage.Dead) do
		
		if (( GetFuelRatio(unit) < .75 and GetFuelRatio(unit) != -1) or unit:GetHealthPercent() < .80) and (not airstage.Dead) then
		
			WaitTicks(11)
            waitcount = waitcount + 1
        else
			break
		end
        
        if (not EntityCategoryContains( categories.CANNOTUSEAIRSTAGING, unit)) and waitcount > 90 then

            return AirStagingThread( unit, airstage, aiBrain )
        end
        
	end

	-- get it off the airpad
	if (not airstage.Dead) and (not unit.Dead) and unit:IsUnitState('Attached') then
	
		WaitTicks(11)
		
		-- we should be loaded onto airpad at this point
		-- some interesting behaviour here - usually when a unit is ready 
		-- it will lift off and exit by itself BUT
		-- sometimes we have to force it off -- when we do so we have
		-- to manually restore it's normal conditions (ie. - can take damage)
		if (not unit.Dead) and (not airstage.Dead) and unit:IsUnitState('Attached') then
		
			local ready = false
			
			while (not ready) and (not airstage.Dead) do
            
                local fuel = GetFuelRatio(unit)
			
				if (not unit.Dead) and ( fuel > -1 and fuel > .85 and unit:GetHealthPercent() > .85)  then
					ready = true
					break
				end
				
				WaitTicks(16)
			end
			
			if ready and unit:IsUnitState('Attached') and (not unit.Dead) and (not airstage.Dead) then
			
				if airstage.UnitStored[unit.Sync.id] then
					airstage.UnitStored[unit.Sync.id] = nil
				end
				
				unit:SetCanTakeDamage(true)
				unit:SetDoNotTarget(false)
				unit:SetReclaimable(true)
				unit:SetCapturable(true)
				unit:ShowBone(0, true)
				unit:OnRemoveFromStorage(airstage)
			end
		end
	end
	
	if not unit.Dead then
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." leaving AirStagingThread")
	
		unit:MarkWeaponsOnTransport(unit, false)
	end	
end

-- this will return true or false depending upon if an enemy ANTITELEPORT
-- unit is in range of the location
function TeleportLocationBlocked( self, location )

	local aiBrain = GetAIBrain(self)
    
    local BRAINS = ArmyBrains
    local VDist2 = VDist2
	
	for num, brain in BRAINS do
	
		if not IsAlly( aiBrain.ArmyIndex, brain.ArmyIndex ) and aiBrain.Armyindex != brain.ArmyIndex then
		
			local unitList = GetListOfUnits( brain, categories.ANTITELEPORT, false)
			
			for i, unit in unitList do
			
				local noTeleDistance = __blueprints[unit.BlueprintID].Defense.NoTeleDistance
				local atposition = unit:GetPosition()
				local targetdestdistance = VDist2(location[1], location[3], atposition[1], atposition[3])
				
				-- if the antiteleport range covers the targetlocation
				if noTeleDistance and noTeleDistance > targetdestdistance then
				
					--FloatingEntityText(self.Sync.id,'Teleportation Malfunction')
					
					-- play audio warning
					--if GetFocusArmy() == self:GetArmy() then
						--local Voice = Sound {Bank = 'LOUD', Cue = 'AttackRequestFailed',}

						--ForkThread(aiBrain.PlayVOSound, aiBrain, Voice, 'RemoteViewingFailed')
					--end
					
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

	local interExcludes = {}

	-- First check for inter-mod exclusions
	for i, m in __active_mods do
		local env = {}
		local eOk, eResult = pcall(doscript, m.location..'/excludes.lua', env)
		if eOk then
			for _, e in env do
				if e.mod then
					if not interExcludes[e.mod] then
						interExcludes[e.mod] = {}
					end
					e.always = true
					LOUDINSERT(interExcludes[e.mod], e)
				end
			end
		end
	end
	
	--Loop through active mods
	for i, m in __active_mods do

		local env = {}
		local excl = {}
		local eOk, eResult = pcall(doscript, m.location..'/excludes.lua', env)
		-- If there's an inter-mod exclusion set for this mod, add its blocks too
		if interExcludes[m.uid] then
			for _, v in interExcludes[m.uid] do
				LOUDINSERT(env, v)
			end
		end
		-- Check every exclusion block to see if modconfig activates it
		for _, e in env do
			if e.mod and e.mod ~= m.uid then
				continue -- Ignore exclusions bound for other mods
			end
			if e.key == m.config[e.combo] or e.always then
				for _, ex in e.values do
					excl[string.lower(ex)] = true
				end
			end
		end

        -- Some custom Scenario variables to support certain mods
	
		if m.name == 'BlackOps Adv Command Units for LOUD' then
			--LOG("*AI DEBUG BOACU installed")
			ScenarioInfo.BOACU_Checked = true
			ScenarioInfo.BOACU_Installed = true
		end

		if m.name == 'BlackOps Unleashed Units for LOUD' then
			--LOG("*AI DEBUG BOU installed")
			ScenarioInfo.BOU_Checked = true
			ScenarioInfo.BOU_Installed = true
		end
		
		if m.name == 'LOUD Integrated Storage' then
			--LOG("*AI DEBUG LOUD Integrated Storage installed")
			ScenarioInfo.LOUD_IS_Checked = true
			ScenarioInfo.LOUD_IS_Installed = true
		end
        
        if m.name == 'Metal World' then
            --LOG("*AI DEBUG METAL WORLD Installed")
            ScenarioInfo.MetalWorld = true
        end
        
        if m.name == 'Mass Point RNG' then
            --LOG("*AI DEBUG Mass Point RNG Installed")
            ScenarioInfo.MassPointRNG = true
        end
        
        if aiBrain.BrainType != 'AI' then
            continue
        end
		
		--If mod has a CustomUnits folder
		local CustomUnitFiles = DiskFindFiles(m.location..'/lua/CustomUnits', '*.lua')

		--Loop through files in CustomUnits folder
		for k, v in CustomUnitFiles do
		
			--LOG("*AI DEBUG: Adding Custom unit file "..repr(v))
		
			local tempfile = import(v).UnitList
			
			--Add each files entry into the appropriate table
			for plat, tbl in tempfile do
			
				for fac, entry in tbl do
				
					-- only add those that are same faction as the AI
					if fac == aiBrain.FactionName then
					
						if excl and entry[1] and excl[string.lower(entry[1])] then
							continue
						end
						
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

-- Records economy values every 3 ticks - builds array of 270 sample points
-- which covers the values of the last 90 seconds - used as trend analysis
-- added in average Mass and Energy Trends
-- added in average Mass and Energy Storage level
function EconomyMonitor( aiBrain )
	
    aiBrain.EcoData = { ['EnergyIncome'] = {}, ['EnergyRequested'] = {}, ['EnergyTrend'] = {}, ['MassIncome'] = {}, ['MassRequested'] = {}, ['MassTrend'] = {}, ['Period'] = 270, ['OverTime'] = { EnergyEfficiency = 0, EnergyIncome = 0, EnergyRequested = 0, EnergyTrend = 0, MassEfficiency = 0, MassIncome = 0, MassRequested = 0, MassTrend = 0} }

	-- number of sample points
	-- local point
	local samplerate = 3
	local samples = aiBrain.EcoData['Period'] / samplerate

	-- create the table to store the samples
	for point = 1, samples do
		aiBrain.EcoData['EnergyIncome'][point] = 0
		aiBrain.EcoData['MassIncome'][point] = 0
		aiBrain.EcoData['EnergyRequested'][point] = 0
		aiBrain.EcoData['MassRequested'][point] = 0
		aiBrain.EcoData['EnergyTrend'][point] = 0
		aiBrain.EcoData['MassTrend'][point] = 0
        --aiBrain.EcoData['EnergyStorage'][point] = 0        
        --aiBrain.EcoData['MassStorage'][point] = 0        
	end    

    local GetEconomyIncome = GetEconomyIncome
    local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
	local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
    --local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio

	local LOUDMIN = math.min

	local WaitTicks = coroutine.yield

	-- array totals
    local eIncome = 0
    local mIncome = 0
    local eRequested = 0
    local mRequested = 0
	local eTrend = 0
	local mTrend = 0
    --local eStorage = 0
    --local mStorage = 0
    
    -- this will be used to multiply the totals
    -- to arrive at the averages
	local samplefactor = 1/samples

    local EcoData = aiBrain.EcoData

    local EcoDataEnergyIncome = EcoData['EnergyIncome']
    local EcoDataMassIncome = EcoData['MassIncome']
    local EcoDataEnergyRequested = EcoData['EnergyRequested']
    local EcoDataMassRequested = EcoData['MassRequested']
    local EcoDataEnergyTrend = EcoData['EnergyTrend']
    local EcoDataMassTrend = EcoData['MassTrend']
    --local EcoDataEnergyStorage = EcoData['EnergyStorage']
    --local EcoDataMassStorage = EcoData['MassStorage']

    local EcoDataOverTime = EcoData['OverTime']

    -- Economy Monitor is delayed according to ArmyIndex
    -- between 0 and samplerate - 1 ticks, this way - they don't all fall
    -- on the same tick
    WaitTicks( math.mod( aiBrain.ArmyIndex, samplerate ) + 1)       -- we add one to avoid 0 --

    while true do

		for point = 1, samples do

            -- remove this point from the totals
			eIncome = eIncome - EcoDataEnergyIncome[point]
			mIncome = mIncome - EcoDataMassIncome[point]
			eRequested = eRequested - EcoDataEnergyRequested[point]
			mRequested = mRequested - EcoDataMassRequested[point]
			eTrend = eTrend - EcoDataEnergyTrend[point]
			mTrend = mTrend - EcoDataMassTrend[point]
            --eStorage = eStorage - EcoDataEnergyStorage[point]
            --mStorage = mStorage - EcoDataMassStorage[point]
            
            -- insert the new data --
			EcoDataEnergyIncome[point] = GetEconomyIncome( aiBrain, 'ENERGY')
			EcoDataMassIncome[point] = GetEconomyIncome( aiBrain, 'MASS')
			EcoDataEnergyRequested[point] = GetEconomyRequested( aiBrain, 'ENERGY')
			EcoDataMassRequested[point] = GetEconomyRequested( aiBrain, 'MASS')
			EcoDataEnergyTrend[point] = GetEconomyTrend( aiBrain, 'ENERGY')
			EcoDataMassTrend[point] = GetEconomyTrend( aiBrain, 'MASS')
            --EcoDataEnergyStorage[point] = GetEconomyStoredRatio( aiBrain, 'ENERGY')*100
            --EcoDataMassStorage[point] = GetEconomyStoredRatio( aiBrain, 'MASS')*100


            -- add the new data to totals
			eIncome = eIncome + EcoDataEnergyIncome[point]
			mIncome = mIncome + EcoDataMassIncome[point]
			eRequested = eRequested + EcoDataEnergyRequested[point]
			mRequested = mRequested + EcoDataMassRequested[point]
			eTrend = eTrend + EcoDataEnergyTrend[point]
			mTrend = mTrend + EcoDataMassTrend[point]
            --eStorage = eStorage + EcoDataEnergyStorage[point]
            --mStorage = mStorage + EcoDataMassStorage[point]

            
            -- calculate new OverTime values --
			EcoDataOverTime['EnergyIncome'] = eIncome * samplefactor
			EcoDataOverTime['MassIncome'] = mIncome * samplefactor
			EcoDataOverTime['EnergyRequested'] = eRequested * samplefactor
			EcoDataOverTime['MassRequested'] = mRequested * samplefactor
			EcoDataOverTime['EnergyTrend'] = eTrend * samplefactor
			EcoDataOverTime['MassTrend'] = mTrend * samplefactor
            --EcoDataOverTime['EnergyStorage'] = eStorage * samplefactor
            --EcoDataOverTime['MassStorage'] = mStorage * samplefactor
            
			EcoDataOverTime['EnergyEfficiency'] = LOUDMIN( (eIncome * samplefactor) / (eRequested * samplefactor), 2)
			EcoDataOverTime['MassEfficiency'] = LOUDMIN( (mIncome * samplefactor) / (mRequested * samplefactor), 2)


			WaitTicks(samplerate + 1)   -- account for lost tick

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
			location = LOUDCOPY(newloc)
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
			
			local threats = aiBrain:GetThreatsAroundPosition( location, 16, true, 'Economy' )
			
			LOUDSORT( threats, function(a,b) return VDist2(a[1],a[2],location[1],location[3]) + a[3] < VDist2(b[1],b[2],location[1],location[3]) + b[3] end )
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." Sorted threats are "..repr(threats))
			
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
		LOUDSORT(locList, function(a,b) return a[3] < b[3] end)
	elseif Orient == 'S' then
		LOUDSORT(locList, function(a,b) return a[3] > b[3] end)
	elseif Orient == 'E' then 
		LOUDSORT(locList, function(a,b) return a[1] > b[1] end)
	elseif Orient == 'W' then
		LOUDSORT(locList, function(a,b) return a[1] < b[1] end)
	end

	local sortedList = {}
	
	if not locList[1] then
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
			positionselection = Random( 1, counter )
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
    
	-- the intent of this function is to make sure that we don't try and respond over mountains
	-- and rivers and other serious terrain blockages -- these are generally identified by
    -- a rapid elevation change over a very short distance
	local function CheckBlockingTerrain( pos, targetPos )
	
		-- This gives us the number of approx. 6 ogrid steps in the distance
		local steps = math.floor( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 6 )
	
		local xstep = (pos[1] - targetPos[1]) / steps -- how much the X value will change from step to step
		local ystep = (pos[3] - targetPos[3]) / steps -- how much the Y value will change from step to step

		local lastpos = {pos[1], 0, pos[3]}
        
        local nextpos, lastposHeight, nextposHeight
        local LOUDABS = math.abs
	
		-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
		for i = 0, steps do
	
			if i > 0 then
		
				nextpos = { pos[1] - (xstep * i), 0, pos[3] - (ystep * i)}
			
				-- Get height for both points
				lastposHeight = GetTerrainHeight( lastpos[1], lastpos[3] )
				nextposHeight = GetTerrainHeight( nextpos[1], nextpos[3] )

				-- if more than 3.6 ogrids change in height over 6 ogrids distance
				if LOUDABS(lastposHeight - nextposHeight) > 3.6 then

					-- we are obstructed
					return true
				end
				
				lastpos = nextpos
            end
		end
	
		return false
	end
	
	if not ScenarioInfo[markertype] then
		ScenarioInfo[markertype] = {}
	end
	
	local rallypointtable = {}
    local baseposition = LOUDCOPY(aiBrain.BuilderManagers[basename].Position)
	
	for _,v in GetBasePerimeterPoints( aiBrain, basename, rallypointradius, orientation ) do

        if not CheckBlockingTerrain( baseposition, {v[1],v[2],v[3]} ) then
        
            LOUDINSERT(ScenarioInfo[markertype], { Name = markertype, Position = { v[1], v[2], v[3] } } )
            LOUDINSERT(rallypointtable, { v[1], v[2], v[3] }  )
            
        end
        
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
    
		for k,r in ScenarioInfo[markertype] do
        
			if v[1] == r.Position[1] and v[3] == r.Position[3] then
				LOUDREMOVE(ScenarioInfo[markertype], k )
			end
            
		end
        
	end
    
end

-- the DBM is designed to monitor the status of all Base Managers and shut them down if they are no longer valid
-- no longer valid means no engineers AND no factories 
-- This only applies to CountedBases -- non-counted bases are destroyed when all structures within 60 are dead
function DeadBaseMonitor( aiBrain )

    if ScenarioInfo.DeadBaseMonitorDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." DBM (Dead Base Monitor) begins")
    end
    
	WaitTicks(1800)	#-- dont start for 3 minutes

    local EntityCategoryCount = EntityCategoryCount
    
	local GetUnitsAroundPoint = GetUnitsAroundPoint
    local RebuildTable = aiBrain.RebuildTable
    
  	local GetOwnUnitsAroundPoint = import('/lua/ai/aiutilities.lua').GetOwnUnitsAroundPoint
	
	local changed, structurecount, platland, platair, platsea
	
	local grouplnd, grouplndcount, counter
	local groupair, groupaircount
	local groupsea, groupseacount
    
    local STRUCTURES = categories.STRUCTURE - categories.WALL
    local ALLUNITS = categories.ALLUNITS - categories.WALL
    
    local BM, EM, FM, PFM
    local DeadBaseMonitorDialog

	while true do
    
        -- learned something about local references with this and the importance of 'refreshing'
        -- the reference
        BM = aiBrain.BuilderManagers
        
        DeadBaseMonitorDialog = ScenarioInfo.DeadBaseMonitorDialog or false

		for k,v in BM do
			
			changed = false
			structurecount = 0

			platland = false
			platair = false
			platsea = false
            
            if DeadBaseMonitorDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(v.BaseName).." DBM processing - PrimaryLand "..repr(v.PrimaryLandAttackBase).." - PrimarySea "..repr(v.PrimarySeaAttackBase))
            end

			if not v.CountedBase then
				structurecount = LOUDGETN( GetOwnUnitsAroundPoint( aiBrain, STRUCTURES, v.Position, 60) )
			end
            
            EM = v.EngineerManager
            FM = v.FactoryManager
            PFM = v.PlatoonFormManager
            
            if DeadBaseMonitorDialog then
            
                if EM.BMDistressResponseThread then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(v.BaseName).." DBM - active base distress response")
                    continue
                end
            end

			-- if a base has no factories
			if (v.CountedBase and EntityCategoryCount( categories.FACTORY, FM.FactoryList ) <= 0) or
				(not v.CountedBase and structurecount < 1) then
                
                -- if the base has no engineers - increase the no factory count
                if EntityCategoryCount( ALLUNITS, EM.EngineerList ) <= 0 then 
                
                    if DeadBaseMonitorDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(v.BaseName).." DBM - no factories or Engineers "..repr(BM[k].nofactorycount + 1))
                    end
                    
                    aiBrain.BuilderManagers[k].nofactorycount = BM[k].nofactorycount + 1
                end

				-- if base has no engineers AND has had no factories for about 250 seconds
				if EntityCategoryCount( ALLUNITS, EM.EngineerList ) <= 0 and BM[k].nofactorycount >= 10 then
				
                    if DeadBaseMonitorDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(v.BaseName).." DBM - removing base" )
					end
                    
					-- handle the MAIN base
					if k == 'MAIN' then

						-- Kill WaveSpawn thread if exists
						if aiBrain.WaveThread then

							KillThread(aiBrain.WaveThread)
							
							aiBrain.WaveThread = nil
						end

						aiBrain.MainBaseDead = true
					end

					-- remove the dynamic rally points - using the basename (k) now instead of v.position
					RemoveBaseRallyPoints( aiBrain, k, v.BaseType, v.RallyPointRadius )
					
					-- disable and destroy the EM at this base (this will end BaseDistress and prevent the base from being re-selected as a Primary)
					if EM then
						EM:SetEnabled(aiBrain,false)
						EM:Destroy()
					end

					-- clear any Primary flags
   					-- and set new primary bases if needed
                    if v.PrimaryLandAttackBase then
                    
                        aiBrain.BuilderManagers[k].PrimaryLandAttackBase = false
                        
                        SetPrimaryLandAttackBase(aiBrain)
                    end
                    
                    if v.PrimarySeaAttackBase then
                    
                        aiBrain.BuilderManagers[k].PrimarySeaAttackBase = false
                        
                        SetPrimarySeaAttackBase(aiBrain)
                    end

					-- then clear it out
					ClearOutBase( PFM, aiBrain )

					-- disable and destroy the FBM and PFM now
					if FM then
						FM:SetEnabled(aiBrain,false)
						FM:Destroy()
					end

					if PFM then
						PFM:SetEnabled(aiBrain,false)
						PFM:Destroy()
					end

					-- update the base counter
					if v.CountedBase then
					
						if v.BaseType == 'Sea' then
							aiBrain.NumBasesNaval = aiBrain.NumBasesNaval - 1
						else
							aiBrain.NumBasesLand = aiBrain.NumBasesLand - 1
						end
					
					end
                    
					aiBrain.NumBases = aiBrain.NumBases - 1

					-- remove the visible marker from the map
					if ScenarioInfo.DisplayBaseNames or aiBrain.DisplayBaseNames or BM[k].MarkerID then
						ForkThread( RemoveBaseMarker, aiBrain, k, BM[k].MarkerID)
					end

					-- remove base from table
                    aiBrain.BuilderManagers[k] = nil
					
					-- rebuild the bases table
					aiBrain.BuilderManagers = RebuildTable(aiBrain, aiBrain.BuilderManagers)

                    changed = true

					break -- we changed -- start at the top again					
				end

			else
                if BM[k] then
                    aiBrain.BuilderManagers[k].nofactorycount = 0
                end
			end
            
            if changed then
                break
            end
			
			WaitTicks(21)   -- 2 second between bases
		end
		
		WaitTicks(201)	    -- check every 20 seconds
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
		aiBrain.dist_comp = math.sqrt( math.pow(ScenarioInfo.size[1],2) + math.pow(ScenarioInfo.size[2],2) )
	end

	WaitSeconds(20)

	aiBrain:ForkThread1( PathGeneratorAir )
	aiBrain:ForkThread1( PathGeneratorAmphibious )
	aiBrain:ForkThread1( PathGeneratorLand )

	if aiBrain.IsNavalMap then
    
        aiBrain.PathRequests['Water'] = {}
		aiBrain:ForkThread1( PathGeneratorWater )
	end
end	

-- This particular version of the pathgenerator takes into account casualties along the path
-- which makes path selections sensitive to threat that might prevent them from getting to a goal
function PathGeneratorAir( aiBrain )
	
    local GetThreatAtPosition = GetThreatAtPosition
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
    local PlatoonExists = PlatoonExists

	local LOUDCOPY = LOUDCOPY
    local LOUDEQUAL = table.equal
	local LOUDFLOOR = math.floor
    local MATHMAX = math.max
    local LOUDLOG10 = math.log10

	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local VDist2 = VDist2
    local VDist3 = VDist3

	local WaitTicks = WaitTicks

	local dist_comp = aiBrain.dist_comp
	
	-- get the table with all the nodes for this layer
	local graph = ScenarioInfo.PathGraphs['Air']
    local Rings = ScenarioInfo.RingSize or 0

	local data = false	
	local queue = {}
	local closed = {}
    
    local queueitem, Node, position, destination, stepsize, adjacentnodes, newnode, testposition, threat, fork, stepcostadjust
    local steps, checkrange, xstep, ystep


	local function DestinationBetweenPoints()

		steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize )
	
		if steps > 0 then
        
            local VDist2Sq = VDist2Sq
        
            checkrange = (stepsize * stepsize)
            
			xstep = ( position[1] - testposition[1]) / steps
			ystep = ( position[3] - testposition[3]) / steps
	
			for i = 1, steps do

				if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= checkrange then
					return true
				end
			end	
		end
	
		return false
	end

	local function AStarLoopBody()
    
        local VDist2 = VDist2
        local VDist3 = VDist3
		
		queueitem = LOUDREMOVE(queue, 1)

		if closed[queueitem.Node[1]] then
			return false, 0, false, 0
		end
        
        Node = queueitem.Node
	
		position = Node.position
		adjacentnodes = Node.adjacent

		if LOUDEQUAL(position, data.EndNode.position) or VDist3( destination, position) <= stepsize then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
	
		closed[Node[1]] = true

		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in adjacentnodes do
		
			newnode = adjacentNode[1]
			
			if closed[newnode] then
				continue
			end
			
			testposition = LOUDCOPY(graph[newnode].position)
		
			if data.Testpath and DestinationBetweenPoints() then

                queueitem.length = queueitem.length + VDist3(destination, position)
             
				return queueitem.path, queueitem.length, true, queueitem.cost
			end
			
			threat = GetThreatBetweenPositions( aiBrain, position, testposition, false, data.ThreatLayer)

			if threat > queueitem.threat then
				continue
			end
			
			threat = MATHMAX(0, GetThreatAtPosition( aiBrain, testposition, Rings, true, data.ThreatLayer ))
			
			if threat > queueitem.threat then
				continue
			end
			
			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }
            
            stepcostadjust = 0
            
            -- a step with ANY threat costs more than one without
            if threat > 0 then 
                stepcostadjust = stepsize
            end

			fork.cost = queueitem.cost + threat + stepcostadjust

			-- as we accrue more steps in a path - the value of being closer to the goal diminishes quickly in favor of being safe --
			fork.goaldist = VDist2( destination[1], destination[3], testposition[1], testposition[3] ) * ( LOUDLOG10(queueitem.pathcount + 1))

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = queueitem.pathcount + 1
	
			fork.path[fork.pathcount] = testposition
		
			fork.threat = queueitem.threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end		

    local PathRequests = aiBrain.PathRequests.Air
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
	
	-- OK - some notes about the path requests - here is the data layout of path request;
	--	Dest = destination,
	--	EndNode = endNode,
	--	Location = start,
	--	Platoon = platoon, 
	--	StartNode = startNode,
	--	Stepsize = stepsize,
	--	Testpath = testPath,
	--	ThreatLayer = threattype,
	--	ThreatWeight = threatallowed,	-- this is the maximum total threat this platoon is allowed to encounter
    
    local platoon, EndThreat, pathlist, pathlength, shortcut, pathcost

	-- i've come to a conclusion about how pathing can take casualties into account along the way -- in our case this
	-- would be represented by the platoon having a declining threat as it encounters enemy threat along its chosen path
	-- two outcomes become clear when you do this;
	--	 the platoon will chose a path that gets there with survivable losses that allow it to get to the final destination
	--	 the platoon will refuse the task	
	while true do
    
        if PathRequests[1] then
    
            data = LOUDREMOVE(PathRequests, 1) or false

            closed = {}
            
            destination = data.Dest
            stepsize = data.Stepsize
            
            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = GetThreatBetweenPositions( aiBrain, data.EndNode.position, destination, nil, data.ThreatLayer )
            
            -- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
            queue = { { cost = EndThreat, goaldist = 0, length = data.Startlength or 0, Node = data.StartNode, path = { data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight - EndThreat } }
            
            platoon = data.Platoon
    
            while queue[1] do
                
                pathlist, pathlength, shortcut, pathcost = AStarLoopBody()
        
                if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then

                    aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost }
                    break
                end
            end
			
            if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." no safe AIR path found to "..repr(data.Dest))
                end
                
                aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0 }

            end
            
        else
            WaitTicks(1)
        end
	end
end			

function PathGeneratorAmphibious(aiBrain)

    local GetThreatAtPosition = GetThreatAtPosition
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
    local PlatoonExists = PlatoonExists

	local LOUDCOPY = LOUDCOPY
    local LOUDEQUAL = table.equal
	local LOUDFLOOR = math.floor
    local MATHMAX = math.max
    local LOUDLOG10 = math.log10

	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

    local VDist2 = VDist2
	local VDist2Sq = VDist2Sq
    
	local WaitTicks = WaitTicks
	
	local dist_comp = aiBrain.dist_comp
	
	-- get the table with all the nodes for this layer
	local graph = ScenarioInfo.PathGraphs['Amphibious']
    local Rings = ScenarioInfo.RingSize or 0

	local data = false	
	local queue = {}
	local closed = {}
    
    local queueitem, Node, position, destination, stepsize, adjacentnodes, newnode, testposition, threat, fork, stepcostadjust
    local steps, xstep, ystep, dist


	local function DestinationBetweenPoints()

		steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize ) + 1
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." Amphib pathfinder finds "..repr(steps).." steps of "..repr(stepsize).." between "..repr(position).." and "..repr(testposition))

        xstep = ( position[1] - testposition[1]) / steps
		ystep = ( position[3] - testposition[3]) / steps

		for i = 0, steps - 1 do
        
            dist = VDist2( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3])

            if dist <= stepsize then
                --LOG("*AI DEBUG "..aiBrain.Nickname.." Amphib pathfinder finds destination "..repr(destination).." on step "..repr(i).." at "..repr(dist).." from "..repr( {position[1]-(xstep*i), position[3]-(ystep*i)} ) )
                return true
            else
                --LOG("*AI DEBUG Amphib pathfinder fails between points - distance is "..repr(dist).." on step "..repr(i) )
            end
		end	
	
		return false
	end
    
	local function AStarLoopBody()
    
        local VDist2 = VDist2
        local VDist3 = VDist3
	
		queueitem = LOUDREMOVE(queue, 1)
	
		if closed[queueitem.Node[1]] then
			return false, 0, false, 0
		end
        
        Node = queueitem.Node
	
		position = Node.position
		adjacentnodes = Node.adjacent
	
		if LOUDEQUAL( position, data.EndNode.position ) then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
		
		closed[Node[1]] = true
        
		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in adjacentnodes do 
        
            newnode = adjacentNode[1]
		
			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)
            
            --LOG("*AI DEBUG "..aiBrain.Nickname.." Amphib pathfinder evaluating from "..repr(position).." to node at "..repr(testposition))

			if data.Testpath and DestinationBetweenPoints() then
            
                queueitem.length = queueitem.length + VDist3(destination, position)
                
				return queueitem.path, queueitem.length, true, queueitem.cost
			end

            -- in the case of amphibious units - we'd like to discount movements thru the water - so either at the point of transition or 
            -- with each water-based point - we'd discount the cost just a bit - AND - we'd change the ThreatLayer.
            local ThreatLayerCheck = data.ThreatLayer
            
            -- right now we're just going to force the threat check to anti-sub - which is great
            -- for SUBMERSIBLE groups - but bad for hovercraft - ideally - we'd let the platoon
            -- pass an alternative threatlayer to be used in this situation - TODO
            if Node.InWater then
                ThreatLayerCheck = 'AntiSub'
            end

            threat = GetThreatBetweenPositions( aiBrain, position, testposition, nil, ThreatLayerCheck )

			if threat > (queueitem.threat) then
				continue
			end
            
			threat = MATHMAX(0, GetThreatAtPosition( aiBrain, testposition, Rings, true, ThreatLayerCheck ))
			
			if threat > queueitem.threat then
				continue
			end
			
			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }
            
            stepcostadjust = 10
            
            -- make water based movement cheaper
            if Node.InWater then
                stepcostadjust = 1
            end

            -- each step adds the stepcost
			fork.cost = queueitem.cost + threat + stepcostadjust

            -- as we accrue more steps in a path - the value of being closer to the goal diminishes quickly in favor of being safe --
            fork.goaldist = VDist2( destination[1], destination[3], testposition[1], testposition[3] ) * ( LOUDLOG10(queueitem.pathcount + 1))

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = queueitem.pathcount + 1
            
			fork.path[fork.pathcount] = testposition

			fork.threat = queueitem.threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)
		
		return false, 0, false, 0
	end

    local PathRequests = aiBrain.PathRequests.Amphibious
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
    
    local platoon,EndThreat, pathlist, pathlength, shortcut, pathcost
    
	while true do
		
		if PathRequests[1] then

			data = LOUDREMOVE(PathRequests, 1)
            
            destination = data.Dest
            stepsize = data.Stepsize
     
			closed = {}

            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = GetThreatBetweenPositions( aiBrain, data.EndNode.position, data.Dest, nil, data.ThreatLayer )
			
			-- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
			-- we also no longer need to pass it to the AStar function as it is part of the queue data
			queue = { { cost = EndThreat, goaldist = 0, length = data.Startlength or 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight - EndThreat } }
            
            platoon = data.Platoon
    
			while queue[1] do

				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()

				if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
					
					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost }
					break
				end
			end
			
			if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." no safe AMPHIB path found to "..repr(data.Dest))
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0 }
			end
		else
            WaitTicks(4)
        end
	end
	
end

function PathGeneratorLand(aiBrain)

    local GetThreatAtPosition = GetThreatAtPosition
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
    local PlatoonExists = PlatoonExists

	local LOUDCOPY = LOUDCOPY
    local LOUDEQUAL = table.equal
	local LOUDFLOOR = math.floor
    local MATHMAX = math.max

	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

    local VDist2 = VDist2
	local VDist2Sq = VDist2Sq
	local WaitTicks = WaitTicks
	
	local dist_comp = aiBrain.dist_comp
    
	local graph = ScenarioInfo.PathGraphs['Land']
    local Rings = ScenarioInfo.RingSize or 0

	local data = false	
	local queue = {}
	local closed = {}
    
    local maxthreat, minthreat
    
    local queueitem, Node, position, destination, stepsize, adjacentnodes, newnode, testposition, threat, fork, stepcostadjust
    local steps, checkrange, xstep, ystep


	local function DestinationBetweenPoints()

		steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize )
	
		if steps > 0 then
        
            local VDist2Sq = VDist2Sq
        
            checkrange = (stepsize * stepsize)
            
			xstep = ( position[1] - testposition[1]) / steps
			ystep = ( position[3] - testposition[3]) / steps
	
			for i = 1, steps do

				if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= checkrange then
					return true
				end
			end	
		end
	
		return false
	end
    
	local function AStarLoopBody()

        local VDist2 = VDist2
        local VDist3 = VDist3
	
		queueitem = LOUDREMOVE(queue, 1)

		if closed[queueitem.Node[1]] then
			return false, 0, false, 0
		end

        Node = queueitem.Node
	
		position = Node.position
		adjacentnodes = Node.adjacent
		
		if LOUDEQUAL( position, data.EndNode.position) or VDist3( destination, position) <= stepsize then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
	
		closed[Node[1]] = true

		for _, adjacentNode in adjacentnodes do
			
			newnode = adjacentNode[1]

			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)
		
			if data.Testpath and DestinationBetweenPoints() then
            
                queueitem.length = queueitem.length + VDist3(destination, position)

				return queueitem.path, queueitem.length, true, queueitem.cost
			end
			
			threat = MATHMAX(0, GetThreatAtPosition( aiBrain, testposition, Rings, true, data.ThreatLayer ))
			
			if threat > queueitem.threat then
				continue
			end
			
            -- if below min threat - devalue it even further - tiny threats should not impair pathing
			if threat <= data.ThreatWeight * minthreat then
				threat = threat * 0.5
                
            -- if above max threat - inflate by ratio - really stay away from big threats
			elseif threat > data.ThreatWeight then
				threat = (threat/maxthreat) * threat
			end

			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path), pathcount = 0 }

			fork.cost = queueitem.cost + threat + 10
			
			fork.goaldist = VDist2( destination[1], destination[3], testposition[1], testposition[3] )

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = queueitem.pathcount + 1
			
			fork.path[fork.pathcount] = testposition

			fork.threat = queueitem.threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end		


	local PathRequests = aiBrain.PathRequests.Land
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
    
    local platoon, EndThreat, pathlist, pathlength, shortcut, pathcost

	while true do
		
		if PathRequests[1] then
	
			data = LOUDREMOVE(PathRequests, 1)
            
            destination = data.Dest
            stepsize = data.Stepsize

			closed = {}
            
            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = GetThreatBetweenPositions( aiBrain, data.EndNode.position, destination, nil, data.ThreatLayer )
          
			queue = { { cost = EndThreat, goaldist = 0, length = data.Startlength or 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight - EndThreat } }
            
            platoon = data.Platoon

			while queue[1] do

				-- adjust these multipliers to make pathfinding more or less sensitive to threat
				maxthreat = data.ThreatWeight * 0.9
				minthreat = data.ThreatWeight * .3
                
				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()

				if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then

					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost }
					break
				end
				
			end

			if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then            
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." no safe LAND path found to "..repr(destination))
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0 }
			end
		else
            WaitTicks(3)
        end
	end
	
end

-- this pathgenerator also takes into account casualties along the route
function PathGeneratorWater(aiBrain)

    local GetThreatAtPosition = GetThreatAtPosition	
	local GetThreatBetweenPositions = moho.aibrain_methods.GetThreatBetweenPositions
    local PlatoonExists = moho.aibrain_methods.PlatoonExists

	local LOUDCOPY = LOUDCOPY
    local LOUDEQUAL = table.equal
	local LOUDFLOOR = math.floor

	local LOUDINSERT = table.insert
	local LOUDREMOVE = table.remove
	local LOUDSORT = table.sort
	local ForkThread = ForkThread

	local VDist2Sq = VDist2Sq
	local VDist2 = VDist2
	local WaitTicks = coroutine.yield

	local dist_comp = aiBrain.dist_comp
	
	local graph = ScenarioInfo.PathGraphs['Water']
    local Rings = ScenarioInfo.RingSize or 0

	local data = false	
	local queue = {}
	local closed = {}

    local queueitem, Node, position, destination, stepsize, adjacentnodes, testposition, threat, fork
    local steps, checkrange, xstep, ystep


	local function DestinationBetweenPoints()

		steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize )
	
		if steps > 0 then
        
            local VDist2Sq = VDist2Sq
        
            checkrange = (stepsize * stepsize)
            
			xstep = ( position[1] - testposition[1]) / steps
			ystep = ( position[3] - testposition[3]) / steps
	
			for i = 1, steps do

				if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= checkrange then
					return true
				end
			end	
		end
	
		return false
	end
    
	local AStarLoopBody = function()

        local VDist2 = VDist2
        local VDist3 = VDist3

		queueitem = LOUDREMOVE(queue, 1)

		if closed[queueitem.Node[1]] then
			return false, 0, false, 0
		end

        Node = queueitem.Node
	
		position = Node.position
		adjacentnodes = Node.adjacent

		if LOUDEQUAL(position, data.EndNode.position) or VDist3( destination, position) <= stepsize then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
		
		closed[Node[1]] = true

		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in adjacentnodes do
			
			newnode = adjacentNode[1]
			
			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)

			if data.Testpath and DestinationBetweenPoints() then
            
                queueitem.length = queueitem.length + VDist3(destination, position)

				return queueitem.path, queueitem.length, true, queueitem.cost
			end

			threat = GetThreatBetweenPositions( aiBrain, position, testposition, nil, data.ThreatLayer)
			
			if threat > queueitem.threat then
				continue
			end

			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }

			fork.cost = queueitem.cost + threat + 10
			
			fork.goaldist = VDist2( destination[1], destination[3], testposition[1], testposition[3] )

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = queueitem.pathcount + 1
			
			fork.path[fork.pathcount] = testposition

			fork.threat = queueitem.threat - threat
			
			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end


    local PathRequests = aiBrain.PathRequests.Water
	local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
    
    local platoon, pathlist, pathlength, shortcut, pathcost

	while true do
		
		if PathRequests[1] then
		
			data = LOUDREMOVE(PathRequests, 1)
            
			closed = {}
            
            destination = data.Dest
            stepsize = data.Stepsize

			queue = { {cost = 0, goaldist = 0, length = data.Startlength or 0, Node = data.StartNode, path = {data.StartNode.position, }, pathcount = 1, threat = data.ThreatWeight } }
            
            platoon = data.Platoon

			while queue[1] do

				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()
                
				if pathlist and platoon then

					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost }
					break
				end
			end
			
			if (not PathReplies[platoon]) and platoon then
            
                if PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(platoon.BuilderName or platoon).." no safe WATER path found to "..repr(destination))
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0 }
			end
        else
            WaitTicks(3)
        end
	end
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

-- I have added a new table (EnemyData) which records total threat values, by threatType
-- The AI can make a judgement by comparing his strength to the enemys strength of a particular
-- threat.  I record 80 values (about 80 samples - 8 seconds apart) so that its fairly accurate
-- taking into account how much intel the AI is actually collecting - see the parseinterval value
-- to adjust the length of data collection period
function ParseIntelThread( aiBrain )

	-- local this global function
	local IsEnemy = IsEnemy

	local LOUDFLOOR = LOUDFLOOR
	local LOUDGETN = LOUDGETN
	local LOUDINSERT = LOUDINSERT

	local LOUDMAX = math.max
	local LOUDMIN = math.min
	local LOUDMOD = math.mod
    
	local LOUDSORT = LOUDSORT
	local LOUDV2 = VDist2
	local VD2 = VDist2Sq
	local WaitTicks = WaitTicks

    -- local the repetitive functions		
	local EntityCategoryFilterDown = EntityCategoryFilterDown
    
	local GETTHREATATPOSITION = GetThreatAtPosition
	local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
	local GetPosition = moho.entity_methods.GetPosition
	local GetUnitsAroundPoint = GetUnitsAroundPoint
	local GetThreatsAroundPosition = GetThreatsAroundPosition
    
    local assign = moho.aibrain_methods.AssignThreatAtPosition
  
	ScenarioInfo.MaxMapDimension = LOUDMAX(ScenarioInfo.size[1],ScenarioInfo.size[2])
    
    if not ScenarioInfo.MapWaterRatio then
        
        ScenarioInfo.MapWaterRatio = aiBrain:GetMapWaterRatio()
        
        LOG("*AI DEBUG MapWaterRatio set to "..ScenarioInfo.MapWaterRatio)
        
    end

    -- set values according to mapsize
    -- it controls the size of the query when seeking the epicentre of a threat
    -- and the ability to 'merge' two points that might be in the same, or adjacent
    -- IMAP blocks
    local ResolveBlocks, Rings, ThresholdMult

    if ScenarioInfo.MaxMapDimension == 256 then
    
        ScenarioInfo.IntelResolution = 11.5
        ScenarioInfo.IMAPSize = 16
        ResolveBlocks = 0
		ThresholdMult = .45
		Rings = 5
        
    elseif ScenarioInfo.MaxMapDimension == 512 then
    
        ScenarioInfo.IntelResolution = 22.5
        ScenarioInfo.IMAPSize = 32
        ResolveBlocks = 0
		ThresholdMult = .7
		Rings = 3
        
    elseif ScenarioInfo.MaxMapDimension == 1024 then
    
        ScenarioInfo.IntelResolution = 45.0
        ScenarioInfo.IMAPSize = 64
        ResolveBlocks = 0
		ThresholdMult = 1
		Rings = 1
        
    elseif ScenarioInfo.MaxMapDimension == 2048 then
    
        ScenarioInfo.IntelResolution = 89.5
        ScenarioInfo.IMAPSize = 128
        ResolveBlocks = 4
		ThresholdMult = 1.1
		Rings = 0
        
    else
    
        ScenarioInfo.IntelResolution = 180.0
        ScenarioInfo.IMAPSize = 256
        ResolveBlocks = 16
		ThresholdMult = 1.66
		Rings = 0
        
    end

    -- the IMAP is always a rectangle so while OgridRadius is used for the distance
    -- to the corner of the block, IMAPRadius is the nearest distance to the sides
	local IMAPRadius = ScenarioInfo.IMAPSize * .5
    
    -- points of the same type - closer than this - will be merged
    local mergeradius = ((IMAPRadius/ThresholdMult)/2)

	-- save the current resolution globally - it will be used by other routines to follow moving intel targets
	ScenarioInfo.IMAPRadius = IMAPRadius
    ScenarioInfo.IMAPBlocks = Rings

	
    -- when turned on - this function will highlight the IMAP block 
    -- being checked by the loop when there is some threat in it
	local function DrawRectangle(aiBrain, threatblock, color)

		if aiBrain.ArmyIndex == GetFocusArmy() then
        
            --LOG("*AI DEBUG Drawing Rectangle at "..repr(threatblock))
        
            local surface = GetSurfaceHeight(threatblock[1],threatblock[2])
    
            local a = {threatblock[1]-IMAPRadius,surface,threatblock[2]-IMAPRadius}
            local b = {threatblock[1]+IMAPRadius,surface,threatblock[2]-IMAPRadius}
            local c = {threatblock[1]+IMAPRadius,surface,threatblock[2]+IMAPRadius}
            local d = {threatblock[1]-IMAPRadius,surface,threatblock[2]+IMAPRadius}
        
            for x = 1,22 do
            
                DrawLine( a, b, color)
                DrawLine( b, c, color)
                DrawLine( c, d, color)
                DrawLine( d, a, color)
                
                WaitTicks(2)
            end
        end
	end
	
    -- when turned on - this function will draw a circle around
    -- the epicentre of the area where an IMAP query found units
    -- which match the type required to generate the IMAP threat value
    -- and enough threat has been generated to trigger a closer look
	local function DrawCirc(aiBrain, position, color)

		if aiBrain.ArmyIndex == GetFocusArmy() then
        
            local surface = GetSurfaceHeight(position[1],position[3])
        
            for x = 1,22 do
            
                for y = 4, math.floor(IMAPRadius/ThresholdMult), 8 do
                
                    DrawCircle( {position[1],surface,position[3]}, y, color)
                    
                end
                
                WaitTicks(2)
            end
        end
	end	

    --LOG("*AI DEBUG IMAP Size is " ..IMAPSize.. " and Parse will examine " ..ResolveBlocks.. " blocks per intel check")

	--[[
	local IntelTypes = {
        Overall,				-- this one seems quite unreliable - not sure what it's doing
        OverallNotAssigned,		-- this one seems to report everything except threats that we directly assign....
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
	
	intelChecks = {
		-- ThreatType	= { threat min, timeout (-1 = never) in seconds, category for exact pos, parse every x iterations, color, AI Debug flag }
		-- note that some categories dont have a dynamic threat threshold - just air,land,naval and structures - since you can only pack so many in a smaller IMAP block
        
		Air 			    = { 15 * ThresholdMult, 4.5, categories.AIR - categories.SATELLITE - categories.SCOUT - categories.TRANSPORTFOCUS, 1,'ff76bdff', true},
		Land 			    = { 8 * ThresholdMult, 13.5, categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT, 3,'9000ff00', true },
		Naval 		    	= { 8 * ThresholdMult, 18, categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT, 4,'ff0060ff', true },
        AntiAir             = { 20 * ThresholdMult, 22.5, categories.ANTIAIR - categories.AIR, 5, 'e0ff0000', true},

		Economy	    		= { 50, 33.8, categories.ECONOMIC + categories.FACTORY, 7,'90ff7000', true },
		StructuresNotMex    = { 100, 67.5, categories.STRUCTURE - categories.WALL - categories.ECONOMIC - categories.CIVILIAN - categories.ANTIAIR, 11, '90ffff00', true },
		Commander 	    	= { 50, 67.5, categories.COMMAND, 13,'90ffffff', true },
        
		--Experimental  	= { 50, 26, (categories.EXPERIMENTAL * categories.MOBILE), 4,'ff00fec3', false },        
        --AntiSurface       = { 20 * ThresholdMult, 26, categories.STRUCTURE - categories.WALL, 4, 'ffaf00ff', true},
        --AntiSub           = { 15 * ThresholdMult, 52, categories.ALLUNITS - categories.WALL, 5, 'ff0000ff', false },
		--Artillery 	    = { 60, 52, (categories.ARTILLERY * categories.STRUCTURE - categories.TECH1) + (categories.EXPERIMENTAL * categories.ARTILLERY), 5,'60ffff00', false },
	}

	local numchecks = 0
	local usedticks = 0
	local checkspertick = 1		-- number of threat entries to be processed per tick - this really affects game performance if moved up
	
    -- this rate is important since it must be able to keep up with the shift in fast moving air units
	local parseinterval = 56    -- the rate of a single iteration in ticks - essentially every 5.5 seconds (which is relative to the IMAP update cycle which is 3 seconds)

    -- the current iteration value
    local iterationcount = LOUDFLOOR( Random() * 14) -- each AI will likely start on a different iteration - again, to prevent concentrated load 
    local iterationmax = 15

    -- Create EnemyData array - stores history of totalthreat by threattype over a period of time
	-- and the History value controls how much history is kept 
	aiBrain.EnemyData = { ['History'] = 100 }		

	-- create the record for each type of intel within the array
	-- and initialize the element which will carry the running total
	-- and the counter that tracks which element is current for this type
	-- since not all types are recorded every time
    for threatType, v in intelChecks do
        aiBrain.EnemyData[threatType] = { ['Count'] = 0, ['Total'] = 0}
	end

    -- take the whole array local 
    local EnemyData = aiBrain.EnemyData
    local EnemyDataCount
    local EnemyDataHistory = EnemyData.History

	-- the 3D location of the MAIN base for this AI
	local HomePosition = aiBrain.BuilderManagers.MAIN.Position

	-- this moves all the local creation up front so NO locals need to be declared in
	-- the primary loop - probably doesn't mean much - but I did it anyway
    -- it also lets me see all the variables I might be using and better re-use them 
	local totalThreat, threats, gametime, units, counter, x1,x2,x3, dupe, oldthreat, newthreat, newtime, bp, rebuild, newPos
	local DisplayIntelPoints, IntelDialog, ReportRatios
    local Type, Position, Threat, LastUpdate
    
	local ALLBPS = __blueprints
    local BRAINS = ArmyBrains
    
    local AIRUNITS = (categories.AIR * categories.MOBILE) - categories.TRANSPORTFOCUS - categories.SATELLITE - categories.SCOUT
    local LANDUNITS = (categories.LAND * categories.MOBILE) - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT
    local NAVALUNITS = (categories.NAVAL * categories.MOBILE) + (categories.NAVAL * categories.FACTORY) + (categories.NAVAL * categories.DEFENSE)

	WaitTicks( LOUDFLOOR(Random() * 25 + 1))	-- to avoid all the AI running at exactly the same tick
  
	-- in a perfect world we would check all 8 threat types every parseinterval 
	-- however, only AIR will be checked every cycle -- the others will be checked every other cycle or on the 3rd or 4th
    while true do

		numchecks = 0
		usedticks = 0
        
        DisplayIntelPoints = ScenarioInfo.DisplayIntelPoints or false
        IntelDialog = ScenarioInfo.IntelDialog or false
        ReportRatios = ScenarioInfo.ReportRatios or false

		-- advance the iteration count
		-- the iteration count is used to process certain intel types at a different frequency than others
        iterationcount = iterationcount + 1

        -- roll the iteration count back to one if it exceeds the maximum number of iterations
        if iterationcount > iterationmax then

            -- Draw HiPri intel data on map - for visual aid - not required but useful for debugging threat assessment
            if DisplayIntelPoints then
            
                if not aiBrain.IntelDebugThread then
                
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Starting Intel Debug Thread")
                    
                    aiBrain.IntelDebugThread = aiBrain:ForkThread( DrawIntel, parseinterval )
                end

            end

            iterationcount = 1

			-- if human ally has requested status updates
			if aiBrain.DeliverStatus then
			
				if not aiBrain.LastLandRatio or aiBrain.LastLandRatio != LandRatio then
				
					ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My present LAND ratio is '..LandRatio )
					aiBrain.LastLandRatio = LandRatio
				end
			
				if not aiBrain.LastAirRatio or aiBrain.LastAirRatio != AirRatio then
				
					ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My present AIR ratio is '..AirRatio )
					aiBrain.LastAirRatio = AirRatio
				end
			
				if not aiBrain.LastNavalRatio or aiBrain.LastNavalRatio != NavalRatio then
				
					ForkThread( AISendChat, 'allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'My present NAVAL ratio is '..NavalRatio )
					aiBrain.LastNavalRatio = NavalRatio
				end
			end
            
        end

		-- loop thru each of the threattypes
		-- processing only those types marked for this iteration
		for threatType, vx in intelChecks do

			if not vx[6] then
				continue
			end

			if LOUDMOD(iterationcount, vx[4]) == 0 then

				totalThreat = 0

				-- advance sample count for this type of threat
				EnemyDataCount = EnemyData[threatType]['Count'] + 1
			
				-- roll it back to one when the sample counter exceeds the number of samples we are keeping
				if EnemyDataCount > EnemyDataHistory then
					EnemyDataCount = 1
				end
			
				EnemyData[threatType]['Count'] = EnemyDataCount

                -- get all threats of this type from the IMAP -- table format is as follows:  posx, posy, threatamount
				-- A note here - when you ask for 'Air' threat - you'll get ALL the threats that Air units can create for example
				-- 12 bombers have zero anti-air threat but they'll still generate threat because they threaten surface targets
				-- but to be clear 'Land' = Land Mobile units and does not include Land Structures
                -- another quirk - when land units transition onto/into the water - they begin showing up as 'Naval' threats
                -- so far, this is the only type of unit which does this
                -- also Artillery does not seem to register at all - that I can see.
                threats = GetThreatsAroundPosition( aiBrain, HomePosition, 32, true, threatType)
			
                gametime = LOUDFLOOR(GetGameTimeSeconds())
				
				if IntelDialog then

                    if threats[1] then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." gets "..LOUDGETN(threats).." results on iteration "..repr(iterationcount).." at GameSecond "..gametime)
                    end
				end
	
                -- examine each threat and add those that are high enough to the InterestList if enemy units are found at that location
                -- but regardless - we add any threat amount to the total - even those we might ignore
                for _,threat in threats do

                    -- add up the threat from each IMAP position - we'll use this as history even if it doesn't result in a InterestList entry
                    totalThreat = totalThreat + threat[3]

                    -- only check threats above minimumcheck otherwise break as rest will be below that
                    if threat[3] > vx[1] then
					
						if IntelDialog then
							LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." processing threat of "..repr(threat[3]).." at "..repr( {threat[1],0,threat[2]} ))
						end

                        -- draw IMAP block if sufficient threat worth checking --
                        if DisplayIntelPoints then
							aiBrain:ForkThread(DrawRectangle,threat,vx[5])
						end                                        
	
                        -- count the number of checks we've done and insert a wait to keep this routine from hogging the CPU 
                        numchecks = numchecks + 1

                        if numchecks > checkspertick then
                            WaitTicks(2)    -- we always lose the first tick --
							usedticks = usedticks + 1
                            numchecks = 0
                        end

						-- HERE IS THE BREAK POINT WHERE WE WOULD START A LOOP TO CHECK MULTIPLE BOXES FOR AN IMAP BOX LARGER THAN 64 OGRIDS
						-- using the syntax below, the threat[1] and threat[3] values would be offsets of the actual IMAP box -- ie. quadrants
						-- each quadrant could therefore have a much greater degree of detail than the IMAP itself would describe
						-- at the moment, the threat values are coming right off of the IMAP position - so they would have to be copied and
						-- used as two other values that would then be looped to cycle their values
					
                        -- collect all the enemy units within that IMAP block
                        
						-- just NOTE - this will report ALL units - even those you don't see
						units = GetEnemyUnitsInRect( aiBrain, threat[1]-IMAPRadius, threat[2]-IMAPRadius, threat[1]+IMAPRadius, threat[2]+IMAPRadius)
						
						counter = 0
						
						-- these accumulate the position values
                        x1 = 0
                        x2 = 0
                        x3 = 0
						
						-- loop thru only those that match the category filter
						for _,v in EntityCategoryFilterDown( vx[3], units ) do
                        
                            if not v.Dead then

                                counter = counter + 1
                                unitPos = GetPosition(v)

                                if unitPos  then
                                    x1 = x1 + unitPos[1]
                                    x2 = x2 + unitPos[2]
                                    x3 = x3 + unitPos[3]
                                end
                            end
						end

						-- if there are valid units then calc the average position and get the threat at that position
						-- either make a new IL entry for it or update an existing entry
						-- otherwise just move onto the next threat and let this threat age
						if counter > 0 then

							dupe = false

							-- divide the position values by the counter to get average position (gives you the heart of the real cluster)
                            newPos = { x1/counter, x2/counter, x3/counter }

							if DisplayIntelPoints then
								aiBrain:ForkThread( DrawCirc, newPos, vx[5] )
							end

							-- get the current threat at this position - we have to use 'Rings' here
                            newthreat = GETTHREATATPOSITION( aiBrain, newPos, Rings, true, threatType )
                            
                            -- modify block threat by IMAP block size - 
                            newthreat = newthreat/ThresholdMult

                            oldthreat = 0

                            -- total up the ring values
                            for _,v in GetThreatsAroundPosition( aiBrain, newPos, Rings, true, threatType) do
                                oldthreat = oldthreat + v[3]
                            end
                            
                            if IntelDialog then

                                if newthreat != oldthreat then
                                    LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." reports IMAP threat of "..newthreat.." modifier "..repr(ThresholdMult).." using "..Rings.." rings old is "..repr(oldthreat))
                                end
                            end
                            
                            -- if the IMAP threat is less than half of the reported threat at that position reduce IMAP by 50%
							if newthreat < (threat[3]/2) then
                            
								if IntelDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." reports "..newthreat.." versus "..threat[3].." from IMAP - reducing by 50%")
								end

                                -- reduce the existing threat by 50% with a 5% decay - IMAP refreshes every 3 seconds
                                assign( aiBrain, {threat[1],0,threat[2]}, threat[3] * -0.5, 0.05, threatType)                                       
                                
								threat[3] = threat[3] * .5
                                
							end
                            
							-- NOTE: This command will only get those units that are detected --
							units = GetUnitsAroundPoint( aiBrain, vx[3], newPos, (IMAPRadius/ThresholdMult), 'Enemy')
						
                            -- and if we don't see anything - reduce it by 20%
							if not units[1] then
                            
								if IntelDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." shows "..threat[3].." but I find no units - reducing by 20%")
								end

                                -- reduce the existing threat by 25% with a 5% decay - IMAP refreshes every 3 seconds
                                assign( aiBrain, {threat[1],0,threat[2]}, threat[3] * -0.25, 0.05, threatType)                                       
                                
								newthreat = threat[3] * .75

							else
                            
                                --if IntelDialog then
                                  --  LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." found "..table.getn(units).." visible units at avg centre of threat "..repr(newPos))
                                --end
                                
                            end

							newtime = gametime

                            -- traverse the existing list until you find an entry within merge distance
							-- we'll update ALL entries that are within the merge distance meaning we may get duplicates
							-- umm...could I sort HiPri here for distance from newPos ? 
							-- then I could bypass all other HiPri entries
                            for k,loc in aiBrain.IL.HiPri do
                            
                                Type = loc.Type
                            
								-- it's got to be of the same type
                                if Type == threatType then
                                
                                    Position = loc.Position
                                    Threat = loc.Threat
                                    LastUpdate = loc.LastUpdate

									-- and within the merge distance
									if LOUDV2( newPos[1],newPos[3], Position[1],Position[3] ) <= mergeradius then
									
										if dupe then
										
											if IntelDialog then
												LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." Killing Duplicate at "..repr(Position) )
											end
										
											aiBrain.IL.HiPri[k] = nil
                                            rebuild = true
											
											continue
										end
									
										-- it might be a duplicate
										dupe = true
										
										if newthreat > vx[1] then
										
											if IntelDialog then
												LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." Updating Existing threat of "..repr(Threat).." to "..repr(newthreat).." from "..repr(Position).." to "..repr(newPos) )
											end
										
											-- so update the existing entry
											loc.Threat = newthreat
										
											if LastUpdate < newtime then
												loc.LastUpdate = newtime
											end
										
											loc.Position = newPos
										end
                                    
                                    end
                                    
                                    if Threat <= vx[1] and not loc.Permanent then
                                        
										if IntelDialog then
                                            LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL data is "..repr(loc))
											LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." Removing Existing "..repr(Threat).." too low at "..repr(Position))
										end

										-- newthreat is too low 
										aiBrain.IL.HiPri[k] = nil
                                        rebuild = true
									end
                                    
                                end
                                
                            end
						
                            -- if not a duplicate and it passes the threat threshold we'll add it - otherwise we ignore it
                            if (not dupe) and newthreat > vx[1] then
							
								if IntelDialog then
									LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL "..threatType.." Inserting new threat of "..newthreat.." at "..repr(newPos))
								end

                                LOUDINSERT(aiBrain.IL.HiPri, { Position = newPos, Type = threatType, Threat = newthreat, LastUpdate = newtime, LastScouted = newtime } )
							end
                            
						else

                            -- reduce the existing threat by 75% with a 5% decay - IMAP refreshes every 3 seconds
                            assign( aiBrain, {threat[1],0,threat[2]}, threat[3] * -0.75, 0.05, threatType)                                       
   
                            -- remove or reduce HiPri targets in range --
                            for k,loc in aiBrain.IL.HiPri do
                            
                                if loc.Type == threatType then
                                
                                    if LOUDV2( threat[1],threat[2], loc.Position[1],loc.Position[3] ) <= IMAPRadius then
                                    
                                        if not loc.Permanent then
                                            rebuild = true
                                            aiBrain.IL.HiPri[k] = nil
                                        else
                                            loc.Threat = loc.Threat * .5
                                        end

                                    end
                                    
                                end
                                
                            end
                 
                        end
                        
                        if rebuild then
                            aiBrain.IL.HiPri = aiBrain:RebuildTable(aiBrain.IL.HiPri)
                            rebuild = false
                        end
                        
                        WaitTicks(2)    -- again - the first tick is lost
                        
                        usedticks = usedticks + 1
					end
                    
                    WaitTicks(2)
                    
                    usedticks = usedticks + 1
                    
                end

				-- Update the EnemyData Array for this threattype -- Array element 'Total' carries a running total
                -- update the array using the current sample counter -- first remove what is there from total
				-- then update the current counter -- then add the current counter to the total
				EnemyData[threatType]['Total'] = EnemyData[threatType]['Total'] - (EnemyData[threatType][EnemyDataCount] or 0)
                EnemyData[threatType][EnemyDataCount] = totalThreat
				EnemyData[threatType]['Total'] = EnemyData[threatType]['Total'] + totalThreat

                -- purge outdated, non-permanent intel if past the timeout period or below the threat threshold
                for s, t in aiBrain.IL.HiPri do
		
                    -- if this type of threat has a timeout value
                    if threatType == t.Type and intelChecks[t.Type][2] > 0 then

                        -- if the lastupdate was more than the timeout period or threat is less than the threshold
                        if ( (t.LastUpdate + intelChecks[t.Type][2] < gametime) or (t.Threat <= intelChecks[t.Type][1]) ) then

                            if IntelDialog then
                            
                                if t.LastUpdate + intelChecks[t.Type][2] < gametime then
                                    if not t.Permanent then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL Removing Existing HiPri "..t.Type.." at "..repr(t.Position).." due to timeout")
                                    end
                                else
                                    if not t.Permanent then
                                        LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL Removing Existing HiPri "..t.Type.." at "..repr(t.Position).." threat too low at "..repr(t.Threat))
                                    end
                                end
                                
                            end

                            if (not t.Permanent) then
                                -- clear the item
                                aiBrain.IL.HiPri[s] = nil
                                rebuild = true
                            else
                                -- reduce the threat by 50%
                                t.Threat = t.Threat * .5
                            end

                        end
                        
                    end
                    
                end
                
                if rebuild then
                    aiBrain.IL.HiPri = aiBrain:RebuildTable(aiBrain.IL.HiPri)
                    rebuild = false
                end
                
                WaitTicks(2)    -- again - we lose the first tick
                
                usedticks = usedticks + 1
            end
            
		end

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
		
			if IntelDialog then
				LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL On Wait for ".. parseinterval - usedticks .. " ticks")	
			end
			
			WaitTicks((parseinterval+1) - usedticks)

			if parseinterval - usedticks > 36 then
			
				if checkspertick > 1 then
                
					checkspertick = checkspertick - 1
					--LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL lowered CPT to "..checkspertick)
				end
			end
            
		else
        
			if checkspertick < 15 then
            
				checkspertick = checkspertick + 3
            
                --if checkspertick > 7 then
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL increased CPT to "..checkspertick)
                --end

			else
            
                checkspertick = checkspertick + 1
            
                --if checkspertick > 7 then
                    --LOG("*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL increased CPT to "..checkspertick)
                --end
                
            end
            
		end

		-- recalc the strength ratios 
		-- syntax is --  Brain, Category, IsIdle, IncludeBeingBuilt
        if (iterationcount == 5) or (iterationcount == 10) or (iterationcount == 15) then
        
            --- AIR UNITS ---
            -----------------
            totalThreat = 0
            oldthreat = 0

            if EnemyData['Air']['Total'] > 0 then
            
                for v, brain in BRAINS do
            
                    if IsEnemy( aiBrain.ArmyIndex, v ) then
                
                        units = GetListOfUnits( brain, AIRUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            oldthreat = oldthreat + bp.AirThreatLevel + bp.SurfaceThreatLevel

                        end
                        
                    else
                    
                        units = GetListOfUnits( brain, AIRUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            totalThreat = totalThreat + bp.AirThreatLevel + (bp.SurfaceThreatLevel * .5)
                        end                    
                    end
                end

                if oldthreat > 0 then
                    aiBrain.AirRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)
                else
                    aiBrain.AirRatio = .011
                end
                
            else
                aiBrain.AirRatio = 0.01
            end

            --- LAND UNITS ---
            ------------------
            totalThreat = 0
            oldthreat = 0

            if EnemyData['Land']['Total'] > 0 then

                for v, brain in BRAINS do
            
                    if IsEnemy( aiBrain.ArmyIndex, v ) then
                
                        units = GetListOfUnits( brain, LANDUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            oldthreat = oldthreat + bp.SurfaceThreatLevel

                        end
                        
                    else
                
                        local units = GetListOfUnits( brain, LANDUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            totalThreat = totalThreat + bp.SurfaceThreatLevel
                        end
                    end
                end
            
                if oldthreat > 0 then
                    aiBrain.LandRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)
                else
                    aiBrain.LandRatio = .011
                end
                
            else
                aiBrain.LandRatio = 0.01
            end

            --- NAVAL UNITS ---
            -------------------
            totalThreat = 0
            oldthreat = 0

            if EnemyData['Naval']['Total'] > 0 then

                for v, brain in BRAINS do
            
                    if IsEnemy( aiBrain.ArmyIndex, v ) then
                
                        units = GetListOfUnits( brain, NAVALUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            oldthreat = oldthreat + bp.SurfaceThreatLevel + bp.SubThreatLevel

                        end
                        
                    else

                        units = GetListOfUnits( brain, NAVALUNITS, false, false)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            totalThreat = totalThreat + bp.SurfaceThreatLevel + bp.SubThreatLevel
                        end                
                    end
                end
            
                if oldthreat > 0 then
                    aiBrain.NavalRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)
                else
                    aiBrain.NavalRatio = 0.11
                end
                
            else
                aiBrain.NavalRatio = 0.01
            end

            if ReportRatios then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Air Ratio is "..repr(aiBrain.AirRatio).." Land Ratio is "..repr(aiBrain.LandRatio).." Naval Ratio is "..repr(aiBrain.NavalRatio))
            end
        
        end
        
    end
end

-- Sets up all the permanent scouting areas. If playing with fixed starting locations,
-- also sets up high-priority scouting areas. This function may be called multiple times, but only 
-- has an effect the first time it is called per brain.
-- Modified to eliminate any points which may be within 55 of an existing point to keep the list
-- to a more manageable size and prevent over-scouting any one area
-- added dynamic ratio between Hi and Low scouting based upon number of points
function BuildScoutLocations( self )

	LOG("*AI DEBUG "..self.Nickname.." now BuildingScoutLocations ")

    LOG("*AI DEBUG playable map area is "..repr(ScenarioInfo.Playablearea))
	
	local GetMarker = import('/lua/sim/scenarioutilities.lua').GetMarker
	local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
	
    local opponentStarts = {}
    local allyStarts = {}

	local function IntelPointNearby(intelpoint)
	
		local VDist2Sq = VDist2Sq
    
		for _,v in self.IL.LowPri do
			if VDist2Sq(v.Position[1],v.Position[3], intelpoint[1],intelpoint[3]) < 3000 then
				return true
			end
		end
		
		for _,v in self.IL.HiPri do
			if VDist2Sq(v.Position[1],v.Position[3], intelpoint[1],intelpoint[3]) < 3000 then
				return true
			end
		end
		
		return false
	end
    
    local function PositionInPlayableArea(intelpoint)
    
        if ScenarioInfo.Playablearea then
        
            local PlayableArea = ScenarioInfo.Playablearea
            
            if intelpoint[1] < PlayableArea[1] or intelpoint[1] > PlayableArea[3] then
                return false
            end
            
            if intelpoint[3] < PlayableArea[2] or intelpoint[3] > PlayableArea[4] then
                return false
            end

        end
        
        return true
    end
	
    if not self.IL then

        self.IL = { ['HiPri'] = {}, ['LowPri'] = {}, ['LastScoutHi'] = false, ['LastScoutHiCount'] = 0, ['LastAirScoutHi'] = false, ['LastAirScoutHiCount'] = 0, ['LastAirScoutMust'] = false, ['MustScout'] = {} }

        local myArmy = ScenarioInfo.ArmySetup[self.Name]

        local numOpponents = 0
        local numAllies = 0

        if ScenarioInfo.Options.TeamSpawn == 'fixed' then
			
            for i=1,16 do
			
                local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
				local startPos = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers[army.ArmyName].position

                -- if occupied and in playable area --
                if army and startPos and PositionInPlayableArea(startPos) then
				
					-- if position has enemy player put into high priority for 20 minutes with initial 500 threat
					if army.ArmyIndex != myArmy.ArmyIndex and ( not(army.Team == myArmy.Team) or army.Team == 1) then
					
                        opponentStarts['ARMY_' .. i] = startPos
                        numOpponents = numOpponents + 1

                        -- add it to the Hi Priority list --
                        LOUDINSERT(self.IL.HiPri, { Position = startPos, Type = 'Economy', LastScouted = 1200, LastUpdate = 1200, Threat = 5000, Permanent = true } )
                        
                        -- add it to the MustScout list --
                        LOUDINSERT(self.IL.MustScout, { Created = GetGameTimeSeconds(), Position = startPos, TaggedBy = false } )
                    else
                        allyStarts['ARMY_' .. i] = startPos
                        numAllies = numAllies + 1
                    end
                end
            end

			local positions = AIGetMarkerLocations('Start Location')

            for _,v in positions do
                -- if position is vacant add to hi priority list permanently
                if (not opponentStarts[v.Name] and not allyStarts[v.Name]) and PositionInPlayableArea(v.Position) then
                    LOUDINSERT(self.IL.HiPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, Type = 'Economy', LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
                end
            end

        else

			-- Spawn locations were random. We don't know where our opponents are. Add all non-ally start locations to the low priority list permanently
            for i=1, 16 do
			
                local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                local startPos = GetMarker('ARMY_' .. i).position

                if army and startPos and PositionInPlayableArea(startPos) then
				
					-- if position has enemy player put into high priority for 15 minutes with initial 300 threat
					if army.ArmyIndex != myArmy.ArmyIndex and ( not(army.Team == myArmy.Team) or army.Team == 1) then
					
                        opponentStarts['ARMY_' .. i] = startPos
                        numOpponents = numOpponents + 1

                        LOUDINSERT(self.IL.HiPri, { Position = startPos, Type = 'Economy', LastScouted = 1200, LastUpdate = 0, Threat = 5000, Permanent = false } )
                        
                        -- add it to the MustScout list --
                        LOUDINSERT(self.IL.MustScout, { Created = GetGameTimeSeconds(), Position = startPos, TaggedBy = false } )                        
                        
                    else
                        allyStarts['ARMY_' .. i] = startPos
                        numAllies = numAllies + 1
                    end				
                end
            end

            -- Add Start points not ours or allied and not already in one of the lists
			local positions = AIGetMarkerLocations('Start Location')

			for _,v in positions do

				if (not allyStarts[v.Name] and not IntelPointNearby(v.Position)) and PositionInPlayableArea(v.Position) then
				
					LOUDINSERT(self.IL.LowPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, Type = 'Economy', LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
				end
			end
        end

        self.Players = ScenarioInfo.Options.PlayerCount
        
        self.NumOpponents = numOpponents

		
		local StartPosX, StartPosZ = self:GetArmyStartPos()
		
		self.StartPosX = StartPosX
		self.StartPosZ = StartPosZ

		-- Having handled Starting Locations lets add others to the permanent list
        -- for HiPri
        local PointTypes = { 'Large Expansion Area', 'Expansion Area', 'Naval Area', 'Naval Defensive Point' }

        for _, v in PointTypes do

            local positions = AIGetMarkerLocations( v )

            for _,v in positions do
			
                if (not IntelPointNearby(v.Position)) and PositionInPlayableArea(v.Position) then
                    LOUDINSERT(self.IL.HiPri, { Position = {LOUDFLOOR(v.Position[1]), LOUDFLOOR(v.Position[2]), LOUDFLOOR(v.Position[3])}, LastScouted = 0, LastUpdate = 0, Threat = 0, Permanent = true } )
                end
            end
        end

		-- Having handled Starting Locations lets add others to the permanent list
        -- for LowPri
        local PointTypes = { 'Combat Zone', 'Mass', 'Hydrocarbon', 'Defensive Point' }

        for _, v in PointTypes do

            local positions = AIGetMarkerLocations( v )

            for _,v in positions do
			
                if (not IntelPointNearby(v.Position)) and PositionInPlayableArea(v.Position) then
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
    
    -- use the ratio between low and hi priority scout positions to determine how many
    -- low priority missions must be taken before another hi priority
    -- this value can range from 1 to 8
    self.AILowHiScoutRatio =  math.max( 1, math.min( math.floor(LOUDGETN(self.IL.LowPri) / LOUDGETN(self.IL.HiPri)), 8) )
    
    --LOG("*AI DEBUG "..self.Nickname.." Low to Hi scout ratio set to "..self.AILowHiScoutRatio)
end

-- This one complements the previous function to remove visible markers from the map 
function RemoveBaseMarker( self, baseName, markerid )

	import('/lua/simping.lua').UpdateMarker({Action = 'delete', ID = markerid, Owner = self.ArmyIndex - 1})
end

-- This continually running thread has the AI pick an enemy every 8 minutes
-- the index of the current enemy is kept on the brain
function PickEnemy( self )
	
	self.targetoveride = nil

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
        self.AttackPlan.GoCheckInterval = 120   -- every 2 minutes
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
            
            if self.DrawPlanThread then
                KillThread(self.DrawPlanThread)
                self.DrawPlanThread = nil
            end
            
            KillThread(self.AttackPlanMonitorThread)
            self.AttackPlanMonitorThread = nil
		end

        self.AttackPlanMonitorThread = self:ForkThread( AttackPlanMonitor )
    end
	
end

function CreateAttackPlan( self, enemyPosition )

    local GetSurfaceHeight = GetSurfaceHeight
    local GetTerrainHeight = GetTerrainHeight

    local LOUDCOPY = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local VDist2 = VDist2
    local VDist2Sq = VDist2Sq
    local WaitTicks = WaitTicks
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD
    
	if self.DeliverStatus then
		ForkThread( AISendChat, 'allies', self.Nickname, 'Creating Attack Plan for '..ArmyBrains[self:GetCurrentEnemy().ArmyIndex].Nickname )
	end

	local stagesize = 300
	local minstagesize = 125 * 125
	local maxstagesize = 350 * 350

    local startx, startz = self:GetCurrentEnemy():GetArmyStartPos()
    
    startx = enemyPosition[1]
    startz = enemyPosition[3]

    if ScenarioInfo.AttackPlanDialog then
        LOG("*AI DEBUG "..self.Nickname.." Creating attack plan to "..repr(enemyPosition))
    end
  
    local starty = GetSurfaceHeight( startx, startz )
    local Goal = {startx, starty, startz}
    local GoalReached = false

	-- this should probably get set to the current PrimaryLandAttackBase
	-- but we use the MAIN base for now 
    local StartPosition = self.BuilderManagers.MAIN.Position
    
    if ScenarioInfo.AttackPlanDialog then
        LOG("*AI DEBUG "..self.Nickname.." Creating attack plan FROM "..repr(StartPosition))
    end
  
    local markertypes = { 'Defensive Point','Naval Area','Naval Defensive Point','Blank Marker','Expansion Area','Large Expansion Area','Small Expansion Area' }
    local markerlist = {}
    local counter = 0
    
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
    
    local LocationInWaterCheck = function(position)
        return GetTerrainHeight(position[1], position[3]) < GetSurfaceHeight(position[1], position[3])
    end    
	
    -- first lets build a masterlist of all valid staging points between start and goal
    for k,v in markers do
	
        for _,t in markertypes do
		
            if v.type == t then
			
                local Position = {v.position[1], v.position[2], v.position[3]}
				
				-- only add markers that are at least minstagesize away
                if VDist2Sq(Position[1],Position[3], StartPosition[1],StartPosition[3]) > minstagesize
				
					-- and at least minstagesize from the final goal
					and VDist2Sq(Position[1],Position[3], Goal[1],Goal[3]) > minstagesize
					
					-- and closer to the goal than the startposition
					and VDist2Sq(Position[1],Position[3], Goal[1],Goal[3]) <= VDist2Sq(StartPosition[1],StartPosition[3], Goal[1],Goal[3])
					
					then
	
                    counter = counter + 1
                    markerlist[counter] = { Position = {v.position[1], v.position[2], v.position[3]}, Name = v.type } 
                    break
                end
            end
        end
    end

	if counter < 1 then
    
        if ScenarioInfo.AttackPlanDialog then
            WARN("*AI DEBUG "..self.Nickname.." No Markers meet AttackPlan requirements - Cannot solve tactical challenge")
        end
        
		GoalReached = true
	end

    -- we always start checking from here --
    local CurrentPoint = LOUDCOPY(StartPosition)
    
    local CurrentPointDistance = VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3])
    
    local StagePoints = {}

    local StageCount = 0
    local looptest = 0
	local positions, path, reason, pathlength, pathtype, CurrentBestPathLength
    
    path = false
    pathlength = 0
    
    -- FIRST - see if we can path from start to the goal using LAND --
    pathtype = 'Land'
    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand', 'Land', CurrentPoint, Goal, 99999, 160)
    
    -- if not - try AMPHIB --
    if not path then
        pathtype = 'Amphibious'
        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib', 'Amphibious', CurrentPoint, Goal, 99999, 250)
    end
    
    if not path then
    
        pathtype = 'Unknown'
        
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..self.Nickname.." Attack Planner finds no path to Goal "..repr(Goal).." from StartPosition of "..repr(CurrentPoint))
        end
        
        GoalReached = true
        
    else
    
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..self.Nickname.." finds "..pathtype.." path from "..repr(CurrentPoint).." to "..repr(Goal).." pathlength is "..pathlength.." path is "..repr(path) )
        end
        
        CurrentBestPathLength = pathlength
        
    end

    
	-- record if attack plan can be land based or not - start with land - but fail over to amphibious if no path --
    self.AttackPlan.Method = pathtype

    -- performance throttle
    local cyclecount = 0

    while not GoalReached do
    
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..self.Nickname.." Current distance to goal is "..VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3]).." stagesize is "..stagesize)
            LOG("*AI DEBUG "..self.Nickname.." Next position will need to be less than "..(CurrentPointDistance * .7).." and have a path of less than "..CurrentBestPathLength )
        end
    
    	-- if current point is within stagesize of goal we're done
        if VDist2Sq(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3]) <= maxstagesize then
		
            GoalReached = true
			
        else
       
            -- sort the markerlist for closest to the current point --
            LOUDSORT( markerlist, function(a,b)	return VDist2Sq(a.Position[1],a.Position[3], CurrentPoint[1],CurrentPoint[3]) < VDist2Sq(b.Position[1],b.Position[3], CurrentPoint[1],CurrentPoint[3]) end )

            positions = {}
            counter = 0

            -- Now we'll test each valid position and assign a value to it
            -- seek the position which has the lowest path value between our minimum(100) and maximum(300) stage size distance
            -- note that the path value might exceed these limits - but the crow flies distance cannot

			-- Filter the list of markers
            for _,v in markerlist do
        
                -- distance from the Current Point
                local testdistance = VDist2Sq( v.Position[1],v.Position[3], CurrentPoint[1],CurrentPoint[3])
                -- distance to the Goal
                local goaldistance = VDist2( v.Position[1],v.Position[3], Goal[1],Goal[3])
                
                if ScenarioInfo.AttackPlanDialog then
                    LOG("*AI DEBUG "..self.Nickname.." reviewing point "..repr(v.Name).." from Current Point is "..math.sqrt(testdistance).." to goal is "..goaldistance)
                end
                
                -- check all points that are at least minimum distance from current point, minimum distance from Goal, within maximum stage size from current point, closer to the goal than current point
                if testdistance >= minstagesize and VDist2Sq(v.Position[1],v.Position[3], Goal[1],Goal[3]) >= minstagesize and testdistance <= maxstagesize and goaldistance < (CurrentPointDistance * .7) then
        
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." examines "..repr(v).." distance is "..math.sqrt(testdistance).." from current point "..repr(CurrentPoint) )
                        LOG("*AI DEBUG "..self.Nickname.." examines "..repr(v).." distance is "..goaldistance.." to the goal "..repr(Goal) )
                    end 
                    
                    cyclecount = cyclecount + 1
                    
                    path = false
                    pathlength = 0

                    -- get the pathlength of this position to the Goal position -- using LAND
                    if (not LocationInWaterCheck(Goal)) and (not LocationInWaterCheck(v.Position)) then
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand2', 'Land', Goal, v.Position, 99999, 160)
                    end
                
                    -- then try AMPHIB --
                    if not path then
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib2', 'Amphibious', Goal, v.Position, 99999, 250)
                    end
 
                    -- if we have a path and its closer to goal than the best so far
                    if path and ( pathlength < CurrentBestPathLength ) and not DestinationBetweenPoints( Goal, CurrentPoint, v.Position ) then
                        
                        -- try to make a LAND path first 
                        path = false
                        
                        local holdpathlength = pathlength
                        
                        if (not LocationInWaterCheck(CurrentPoint)) and (not LocationInWaterCheck(v.Position)) then
                        
                            pathtype = "Land"
                            path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand3', 'Land', CurrentPoint, v.Position, 99999, 160)
                            
                        end
					
                        -- if not try an AMPHIB path --
                        if not path then
                        
                            pathtype = "Amphibious"
                            path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib3', 'Amphibious', CurrentPoint, v.Position, 99999, 250)
                            
                        end

                        if path then
                        
                            if ScenarioInfo.AttackPlanDialog then
                                LOG("*AI DEBUG "..self.Nickname.." adding "..repr(v.Name).." at "..repr(v.Position).." w "..pathtype.." path to goal of "..repr(holdpathlength))
                            end
                            
                            counter = counter + 1
                            positions[counter] = {Name = v.Name, Position = v.Position, Pathvalue = holdpathlength, Type = pathtype, Path = path}
                            
                            CurrentBestPathLength = holdpathlength
                            
                            self.AttackPlan.Method = pathtype

                        end

                    else
                    
                        if ScenarioInfo.AttackPlanDialog then
                    
                            if path and pathlength >= CurrentBestPathLength then
                                LOG("*AI DEBUG "..self.Nickname.." "..pathtype.." path from "..repr(v.Name).." at "..repr(v.Position).." to goal was "..pathlength)
                            end
                            
                        end
                        
                    end
                    
                    -- load balancing --
                    if cyclecount > 2 then
                        WaitTicks(1)
                        cyclecount = 0
                    end

                else
                
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." Min Stage size = "..repr(testdistance >= minstagesize).." to Goal Stage Size = "..repr(VDist2Sq(v.Position[1],v.Position[3], Goal[1],Goal[3]) >= minstagesize).." Max Stage Size = "..repr(testdistance <= maxstagesize).." Goal Distance = "..repr(goaldistance < (CurrentPointDistance * .7)) )
                    end
                
                end
                
            end
            
            LOUDSORT(positions, function(a,b) return a.Pathvalue < b.Pathvalue end )
            
            if ScenarioInfo.AttackPlanDialog then
                LOG("*AI DEBUG "..self.Nickname.." Sorted "..repr(LOUDGETN(positions)).." possible positions are "..repr(positions))
            end
            
			-- if there are no positions we'll have to create one out of a movement node
            if not positions[1] then
                
                local a,b

                if not positions[1] then
				
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." could find no marker positions from "..repr(CurrentPoint))
					end
                    
                    a = Goal[1] + CurrentPoint[1]
                    b = Goal[3] + CurrentPoint[3]
                    
                else
				
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." could only find a marker at " .. VDist3(positions[1].Position, CurrentPoint) .. " from "..repr(CurrentPoint).." Max Distance is "..stagesize)
                    end
					
                    a = CurrentPoint[1] + positions[1].Position[1]
                    b = CurrentPoint[3] + positions[1].Position[3]
                    
                end

                local result = { LOUDFLOOR(a* 0.5), 0, LOUDFLOOR(b* 0.5) }
                local landposition = false
                local fakeposition = false

                landposition = AIGetMarkersAroundLocation( self, 'Land Path Node', result, 200)

				-- try and use a land marker when no other can be found
                if not landposition[1] then
				
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." Could not find a Land Node with 200 of resultposition "..repr(result).." using Water at 300")
                    end
					
                    fakeposition = AIGetMarkersAroundLocation( self, 'Water Path Node', result, 300)
                else
                
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand4', 'Land', CurrentPoint, landposition[1].Position, 99999, 160)
                    
                    if not path then
                    
                        pathtype = "Amphibious"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib4', 'Amphibious', CurrentPoint, landposition[1].Position, 99999, 250)
                    end
				
                    LOUDINSERT(positions, { Name = "FakeLAND", Position = landposition[1].Position, Pathvalue = pathlength, Type = pathtype, Path = path})
                end

				-- if no land marker could be found - try using a Naval marker
                if fakeposition[1].Position then
				
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." using Fakeposition assign - working from CurrentPoint of "..repr(CurrentPoint))
                        LOG("*AI DEBUG "..self.Nickname.." Fakeposition is "..repr(fakeposition))
                    end
                    
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand5', 'Land', CurrentPoint, fakeposition[1].Position, 99999, 160)
                    
                    if not path then
                    
                        pathtype = "Amphibious"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib5', 'Amphibious', CurrentPoint, fakeposition[1].Position, 99999, 250)
                    end

                    LOUDINSERT(positions, {Name = "FakeNAVAL", Position = fakeposition[1].Position, Pathvalue = pathlength, Type = pathtype, Path = path})
                end
            end

            LOUDSORT(positions, function(a,b) return a.Pathvalue < b.Pathvalue end )
			
			-- make sure new point not same as previous - if it is - we're done
			if positions[1] and (not table.equal( positions[1].Position, CurrentPoint )) then
			
				StageCount = StageCount + 1 
				
				LOUDINSERT(StagePoints, positions[1])

				CurrentPoint = LOUDCOPY(positions[1].Position)
                CurrentPointDistance = VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3])
                
                pathtype = "Land"
                path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand6', 'Land', CurrentPoint, Goal, 99999, 160 )
                
                if not path then
                    pathtype = "Amphibious"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib6', 'Amphibious', CurrentPoint, Goal, 99999, 250 )
                end
                
                if path then
                    CurrentPointDistance = pathlength
                    self.AttackPlan.Method = pathtype
                    
                else
                
                    if ScenarioInfo.AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." finds no path from "..repr(CurrentPoint).." to goal position "..repr(Goal))
                    end
                    
                end
				
			else
				GoalReached = true
			end
            
        end 
    end

	
    if StageCount >= 0 then
	
        self.AttackPlan.Goal = Goal
        self.AttackPlan.CurrentGoal = 0
		self.AttackPlan.StageCount = StageCount
        self.AttackPlan.StagePoints = { [0] = StartPosition }
        self.AttackPlan.GoSignal = false

        local counter = 1

        if StageCount > 0 then
        
            for _,i in StagePoints do
		
                self.AttackPlan.StagePoints[counter] = i
                counter = counter + 1
			
            end
        end

        self.AttackPlan.StagePoints[counter] = Goal
		
        if ScenarioInfo.AttackPlanDialog then
            LOG("*AI DEBUG "..self.Nickname.." Attack Plan Method is "..repr(self.AttackPlan.Method) )
            LOG("*AI DEBUG "..self.Nickname.." Attack Plan is "..repr(self.AttackPlan))
        end
    else
		LOG("*AI DEBUG "..self.Nickname.." fails Attack Planning for "..repr(Goal) )
	end
    
end

function DrawPlanNodes(self)

	local DC = DrawCircle
	local DLP = DrawLinePop
	
	--LOG("*AI DEBUG "..self.Nickname.." Drawing Plan "..repr(self.AttackPlan))
	
	while self.AttackPlan.Goal do
	
		if ( self.ArmyIndex == GetFocusArmy() or ( GetFocusArmy() != -1 and self.ArmyIndex and IsAlly(GetFocusArmy(), self.ArmyIndex)) ) and self.AttackPlan.StagePoints[0] then
		
			DC(self.AttackPlan.StagePoints[0], 1, '00ff00')
			DC(self.AttackPlan.StagePoints[0], 3, '00ff00')

			local lastpoint = self.AttackPlan.StagePoints[0]				
				local lastpoint = self.AttackPlan.StagePoints[0]				
			local lastpoint = self.AttackPlan.StagePoints[0]				
			local lastdraw = lastpoint
			
			if self.AttackPlan.StagePoints[0].Path then
			
				-- draw the movement path --
				for _,v in self.AttackPlan.StagePoints[0].Path do
				
					DLP( lastdraw, v, '0303ff' )
					lastdraw = v
				
				end
			end
			
			for i = 1, self.AttackPlan.StageCount do
			
				DLP( lastpoint, self.AttackPlan.StagePoints[i].Position, 'ffffff')
				
				DC( self.AttackPlan.StagePoints[i].Position, 1, 'ff0000')
				DC( self.AttackPlan.StagePoints[i].Position, 3, 'ff0000')
				DC( self.AttackPlan.StagePoints[i].Position, 5, 'ffffff')

				lastdraw = lastpoint
				
				if self.AttackPlan.StagePoints[i].Path then
				
					for _,v in self.AttackPlan.StagePoints[i].Path do
				
						DLP( lastdraw,v, '0303ff' )
						lastdraw = v
				
					end
				end
				
				lastpoint = self.AttackPlan.StagePoints[i].Position
			end
			
			DLP( lastpoint, self.AttackPlan.Goal, 'ffffff')
			
			lastdraw = lastpoint
			
			DC( self.AttackPlan.Goal, 1, 'ff00ff')
			DC( self.AttackPlan.Goal, 3, '00ff00')
			DC( self.AttackPlan.Goal, 5, 'ff00ff')
		end
		
		WaitTicks(6)
	end
	
	self.DrawPlanThread = nil
end

function AttackPlanMonitor(self)

    --LOG("*AI DEBUG "..self.Nickname.." starting AttackPlanMonitor to "..repr(self.AttackPlan.Goal))
    
    local GetThreatsAroundPosition = GetThreatsAroundPosition
    local CurrentEnemyIndex = self:GetCurrentEnemy():GetArmyIndex()
    
    local WaitTicks = WaitTicks

    while self.AttackPlan.Goal do
    
		-- Draw Attack Plans onscreen (set in InitializeSkirmishSystems or by chat to the AI)
		if self.AttackPlan and (ScenarioInfo.DisplayAttackPlans or self.DisplayAttackPlans) then
        
            if not self.DrawPlanThread then
                self.DrawPlanThread = ForkThread( DrawPlanNodes, self )
            end
		end         

		if self.AttackPlan.Goal then
        
		    if ScenarioInfo.AttackPlanDialog then   
            
                LOG("*AI DEBUG " ..self.Nickname.." Assessing Attack Plan to " ..repr(self.AttackPlan.Goal))
            
                local threatTable = GetThreatsAroundPosition( self, self.AttackPlan.Goal, 64, true, 'Overall', CurrentEnemyIndex)
            
                LOG("*AI DEBUG "..self.Nickname.." Overall Threat Table is " ..repr(threatTable))
                
                LOG("*AI DEBUG "..self.Nickname.." Starting Point "..repr(self.AttackPlan.StagePoints[0]))
            

                -- what I want to do is loop thru the stages - and evaluate if its complete (we own that stage)
                -- essentially - is there still enemy threat at the goal point ?
                -- if not, the plan is complete ?   -- ABORT -- MAKE A NEW PLAN
            
                -- of do we go thru each stagepoint - check threat at each position -
                -- and if threat at THAT position is higher than the GOAL threat
                -- ABORT -- MAKE NEW PLAN
            
                for k = 1,self.AttackPlan.StageCount do
            
                    LOG("*AI DEBUG "..self.Nickname.." Stagepoint "..repr(self.AttackPlan.StagePoints[k]))

                end
            
                LOG("*AI DEBUG "..self.Nickname.." Goal Point "..repr(self.AttackPlan.StagePoints[self.AttackPlan.StageCount+1]))
            
            end
            
            -- otherwise just check primary bases 
			SetPrimaryLandAttackBase(self)
			SetPrimarySeaAttackBase(self)
            
            -- and wait for next cycle (GoCheckInterval)            
            WaitTicks(self.AttackPlan.GoCheckInterval * 10)
		end
    end
    
    self.AttackPlanMonitorThread = nil
end

function DrawPath ( origin, path, destination )
 
    for i = 0, 250 do
    
        local lastpoint = LOUDCOPY(origin)
        
        for _, v in path do
            DrawLinePop( lastpoint, v, 'ffffff' )
            lastpoint = LOUDCOPY(v)
        end
        
        DrawLinePop( lastpoint, destination, 'ff0000' )
        
        WaitTicks(2)
    end
end

-- function to draw HiPri Intel points on the map for debugging - all credit to Sorian
function DrawIntel( aiBrain, parseinterval)

    LOG("*AI DEBUG "..aiBrain.Nickname.." starts DrawIntel with parseinterval of "..repr(parseinterval))

    local WaitTicks = coroutine.yield
    local DrawC = DrawCircle
	
	local threatColor = {
		--ThreatType = { ARGB value }
		Air = 'ff76bdff',
		Land = '9000ff00',
		Naval = 'ff0060ff',
		Commander = '90ffffff',
		Economy = '90ff7000',
		StructuresNotMex = '90ffff00',
		AntiAir = 'e0ff0000',
        
		--Experimental = 'ff00fec3',  #-- Cyan        
        --AntiSurface = 'ffaf00ff',   #-- Bright Pink
        --AntiSub = 'ff0000ff',   #-- Light Blue
		--Artillery = 'ffffff00',   #--Yellow        
	}
	
	local threatColor2 = {
		--ThreatType = { ARGB value }
		Air = 'ff76bdff',
		Land = '9000ff00',
		Naval = 'ff0060ff',
		Commander = '90ffffff',
		Economy = '90ff7000',
		StructuresNotMex = '90ffff00',
		AntiAir = 'e0ff0000',
        
		--Experimental = 'ff00fec3', #--Red
		--Artillery = 'ffffff00', #--Yellow
	}	
	
	-- this will draw resolved intel data (specific points)
	local function DrawIntelPoint(position, color, threatamount)
    
        local distmax = math.log10( math.sqrt( threatamount ))
        local surface = GetSurfaceHeight(position[1],position[3])

        -- controls display length
		for i = 0,parseinterval do
        
            -- radiate out from point according to threat intensity
            for distance = .3, distmax, .3 do
                DrawC( {position[1],surface,position[3]}, distance * 1.1, color )
            end
            
            WaitTicks(1)
		end
	end

	-- this will draw 'raw' intel data (standard threat map points)
	local function DrawRawIntel(position, Type )
	
		local threats = aiBrain:GetThreatsAroundPosition( position, 1, true, Type)

		for _,v in threats do
		
			if v[3] > 5 then
				ForkThread( DrawIntelPoint, {v[1],0,v[2]}, threatColor2[Type], v[3] )
			end
		end
	end

	while true do
	
		if aiBrain.ArmyIndex == GetFocusArmy() then

            --local inteldata = aiBrain.IL.HiPri
            -- inteldata.LastScouted
            -- inteldata.LastUpdate
            -- inteldata.Position
            -- inteldata.Threat
            -- inteldata.Type
            
            -- display the HiPri positions
			for _,v in aiBrain.IL.HiPri do
	
                -- for any active types in the threatColor table --
				if threatColor[v.Type] and v.Threat > 0 then
				
					ForkThread( DrawIntelPoint, v.Position, threatColor[v.Type], v.Threat )
					
					--ForkThread( DrawRawIntel, v.Position, v.Type )
				end
		    end
		end
		
		WaitTicks(parseinterval)
		
	end
	
end

--[[

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

-- This routine purges the pathcache of any old entries
-- at present we are no longer caching paths
function PathCacheMonitor( aiBrain )

	LOG("*AI DEBUG "..aiBrain.Nickname.." starting PathCacheMonitor")
	
	-- setup the PathCache for this brain and the counters for hits and misses
	if not aiBrain.PathCache then
	
		aiBrain.PathCache = {}
		aiBrain.PathHits = 0
		aiBrain.PathMiss = 0
		
	end

	local cachecount = 0
	local cachetime = 900	-- starting lifetime 1200 seconds = 2 minutes
	local looprate = cachetime * 0.1
	
	local maxcachetime = 1500
	
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
                
                    LOG("*AI DEBUG "..aiBrain.Nickname.." removing path cache "..repr(k).." "..repr(a))
				
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
            
            LOG("*AI DEBUG "..aiBrain.Nickname.." path cache hit/miss ratio is "..repr(k))
			
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

--]]

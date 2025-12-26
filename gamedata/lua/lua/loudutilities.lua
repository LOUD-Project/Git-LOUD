--  /lua/loudutilities.lua
--  LOUD specific things

-- You will find lots of useful notes in here 
local Game      = import('game.lua')

local AIGetMarkersAroundLocation    = import('ai/aiutilities.lua').AIGetMarkersAroundLocation
local GetOwnUnitsAroundPoint        = import('ai/aiutilities.lua').GetOwnUnitsAroundPoint
local RandomLocation                = import('ai/aiutilities.lua').RandomLocation
local SetArmyPoolBuff               = import('ai/aiutilities.lua').SetArmyPoolBuff
local ApplyBuff                     = import('/lua/sim/buff.lua').ApplyBuff
local HasBuff                       = import('/lua/sim/buff.lua').HasBuff
local RemoveBuff                    = import('/lua/sim/buff.lua').RemoveBuff
local AISendChat                    = import('/lua/ai/sorianutilities.lua').AISendChat
local AssignTransportToPool         = import('/lua/ai/transportutilities.lua').AssignTransportToPool
local ReturnTransportsToPool        = import('/lua/ai/transportutilities.lua').ReturnTransportsToPool


local EntityCategoryCount   = EntityCategoryCount
local ForkThread            = ForkThread
local GetArmyUnitCap        = GetArmyUnitCap
local GetArmyUnitCostTotal  = GetArmyUnitCostTotal
local GetTerrainHeight      = GetTerrainHeight
local GetUnitsInRect        = GetUnitsInRect
local LOUDCOPY              = table.copy
local LOUDEQUAL             = table.equal
local LOUDENTITY            = EntityCategoryContains
local LOUDGETN              = table.getn
local LOUDINSERT            = table.insert
local LOUDREMOVE            = table.remove
local LOUDSORT              = table.sort
local LOUDFLOOR             = math.floor
local LOUDMAX               = math.max
local LOUDMOD               = math.mod
local LOUDSQRT              = math.sqrt
local tostring              = tostring
local VDist2Sq              = VDist2Sq
local VDist3                = VDist3
local WaitTicks             = coroutine.yield

local AIBrainMethods = moho.aibrain_methods

local AssignThreatAtPosition        = AIBrainMethods.AssignThreatAtPosition
local AssignUnitsToPlatoon          = AIBrainMethods.AssignUnitsToPlatoon
local GetCurrentUnits               = AIBrainMethods.GetCurrentUnits
local GetEconomyIncome              = AIBrainMethods.GetEconomyIncome
local GetEconomyRequested           = AIBrainMethods.GetEconomyRequested
local GetEconomyTrend               = AIBrainMethods.GetEconomyTrend
local GetListOfUnits                = AIBrainMethods.GetListOfUnits
local GetNumUnitsAroundPoint        = AIBrainMethods.GetNumUnitsAroundPoint
local GetThreatAtPosition           = AIBrainMethods.GetThreatAtPosition
local GetThreatBetweenPositions     = AIBrainMethods.GetThreatBetweenPositions
local GetThreatsAroundPosition      = AIBrainMethods.GetThreatsAroundPosition
local GetUnitsAroundPoint           = AIBrainMethods.GetUnitsAroundPoint
local MakePlatoon                   = AIBrainMethods.MakePlatoon
local PlatoonExists                 = AIBrainMethods.PlatoonExists

aiBrainMethods = nil

local GetPosition           = moho.entity_methods.GetPosition

local GetPlatoonPosition    = moho.platoon_methods.GetPlatoonPosition
local PlatoonCategoryCount  = moho.platoon_methods.PlatoonCategoryCount

local GetAIBrain            = moho.unit_methods.GetAIBrain
local GetFuelRatio          = moho.unit_methods.GetFuelRatio
local IsBeingBuilt          = moho.unit_methods.IsBeingBuilt
local IsIdleState           = moho.unit_methods.IsIdleState
local IsPaused              = moho.unit_methods.IsPaused
local IsUnitState           = moho.unit_methods.IsUnitState

local VectorCached = { 0, 0, 0 }

local AIRFACT3      = categories.FACTORY * categories.AIR * categories.TECH3
local AIRPADS       = categories.AIRSTAGINGPLATFORM - categories.MOBILE
local EXTRACTORS    = categories.MASSEXTRACTION - categories.TECH1
local FABRICATORS   = categories.MASSFABRICATION * categories.TECH3
local NAVALFAC      = categories.NAVAL * categories.FACTORY 
local NAVALMOBILE   = categories.NAVAL * categories.MOBILE
local PARAGONS      = categories.MASSFABRICATION * categories.EXPERIMENTAL

local timeACTBrains = {}
local ratioACTBrains = {}

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

-- this is a custom condition
function HaveGreaterThanT3AirFactories(aiBrain, numReq)
    return GetCurrentUnits(aiBrain, AIRFACT3) > numReq
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
    
    local ArmyIndex = aiBrain.ArmyIndex
    local result    = GetArmyUnitCostTotal(ArmyIndex) / GetArmyUnitCap(ArmyIndex)
 	
    return result > percent 
end

function UnitCapCheckLess(aiBrain, percent)

	if aiBrain.IgnoreArmyCaps then
		return true
	end
    
    local ArmyIndex = aiBrain.ArmyIndex
    local result    = GetArmyUnitCostTotal(ArmyIndex) / GetArmyUnitCap(ArmyIndex)
    
    return result < percent

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

-- This routine returns the location of the closest base that has engineers or NON-NAVAL factories
function AIFindClosestBuilderManagerPosition( aiBrain, position, requiredcat)

    local BM = aiBrain.BuilderManagers or false
    
    if not BM then
        return position
    end
    
    local distance = 9999999
	local closest = false

    local VDist2Sq = VDist2Sq

    for k,v in BM do
	
		if v.EngineerManager.Active then
        
            if not requiredcat then
		
                if v.EngineerManager.EngineerList.Count > 0 or EntityCategoryCount( NAVALFAC, v.FactoryManager.FactoryList ) > 0 then
			
                    if VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] ) <= distance then
                        distance = VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] )
                        closest = v.Position
                    end
                end
                
            else

                -- ignore bases with active alerts
                if v.EngineerManager.BaseMonitor.ActiveAlerts < 1 then
            
                    if LOUDGETN( GetUnitsAroundPoint( aiBrain, requiredcat, v.Position, v.Radius, 'Ally' )) > 0 then

                        if VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] ) <= distance then
                            distance = VDist2Sq( position[1],position[3], v.Position[1],v.Position[3] )
                            closest = v.Position
                        end
                    end
                end
            end
        end
    end
    
    -- if there was a category requirement and we could not locate it - just use closest
    if requiredcat and not closest then
    
        return AIFindClosestBuilderManagerPosition( aiBrain, position)
        
    end
    
    if not closest then
        LOG("*AI DEBUG "..aiBrain.Nickname.." cant find closest base from "..repr(position) )
        return position
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
    local bestposition = false
    
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
                bestposition = base.Position
            end
        end
    end
    
    return bestname, bestposition, bestthreat
end

-- Sorts the list of scouting areas by time since scouted, and then distance from main base.
function AISortScoutingAreas( aiBrain, list )

    local StartPosX = aiBrain.StartPosX
    local StartPosZ = aiBrain.StartPosZ
    local VDist2Sq = VDist2Sq
    
    LOUDSORT( list, function(a,b)
	
		if a.LastScouted and b.LastScouted then
		
			if a.LastScouted == b.LastScouted then
				return VDist2Sq( StartPosX, StartPosZ, a.Position[1], a.Position[3]) < VDist2Sq( StartPosX, StartPosZ, b.Position[1], b.Position[3])
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

    local units = GetListOfUnits( aiBrain, categories.ECONOMIC, false, true)
    
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

    local units = GetListOfUnits( aiBrain, categories.ECONOMIC, false, true)
    
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
        
        --LOG("*AI DEBUG "..aiBrain.Nickname.." "..locType.." has "..aiBrain.BuilderManagers[locType].EngineerManager.BaseMonitor.ActiveAlerts.." alerts" )

		return aiBrain.BuilderManagers[locType].EngineerManager.BaseMonitor.ActiveAlerts == 0
	end

	return true
end

function AirProductionRatioGreaterThan( aiBrain, value )
	return aiBrain.AirProdRatio >= value
end

function AirProductionRatioLessThan( aiBrain, value )
	return aiBrain.AirProdRatio < value
end

function AirStrengthRatioGreaterThan( aiBrain, value )
	return aiBrain.AirRatio >= value
end

function AirStrengthRatioLessThan ( aiBrain, value )
	return aiBrain.AirRatio < value
end

--- the air bias indicates the composition of the enemy air strength
--- higher values reflect an emphasis towards bombers/gunships/torps
function AirToGroundBiasGreaterThan( aiBrain, value )
    return aiBrain.AirBias >= value
end

function LandProductionRatioGreaterThan( aiBrain, value )
	return aiBrain.LandProdRatio >= value
end

function LandProductionRatioLessThan( aiBrain, value )
	return aiBrain.LandProdRatio < value
end

function LandStrengthRatioGreaterThan( aiBrain, value )

    -- no LAND activity
    if aiBrain.LandRatio <= .01 or aiBrain.CycleTime < 240 then

        -- this better recognizes 'Ground & Pound' scenarios and prevents
        -- early overbuild of air factories
        if ScenarioInfo.Options.RestrictedCategories then

            for k,v in ScenarioInfo.Options.RestrictedCategories do

                if v == 'AIRFIGHTERS' then
                    return aiBrain.LandRatio >= value
                end
            end
        end
        
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

function NavalProductionRatioGreaterThan( aiBrain, value )
	return aiBrain.NavalProdRatio >= value
end

function NavalProductionRatioLessThan( aiBrain, value )
	return aiBrain.NavalProdRatio < value
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
    local ArmyIndex = aiBrain.ArmyIndex
    
    if units then
	
        local enemyunits = {}
		local counter = 0
		
        local IsEnemy = IsEnemy
		
        for _,v in units do
		
            if (not v.Dead) and v.ArmyIndex then

                if IsEnemy( v.ArmyIndex, ArmyIndex) then
                    counter = counter + 1
                    enemyunits[counter] =  v
                end

            end

        end 
		
        if counter > 0 then
            return enemyunits, counter
        end
    end
    
    return false, 0
end

function GreaterThanEnemyUnitsAroundBase( aiBrain, locationtype, numUnits, unitCat, radius )

    if aiBrain.BuilderManagers[locationtype] then
		return GetNumUnitsAroundPoint(aiBrain, unitCat, aiBrain.BuilderManagers[locationtype].Position, radius, 'Enemy') > numUnits
	end
	
	return false
end

-- gets units that are NOT in a platoon around a point
function GetFreeUnitsAroundPoint( aiBrain, category, location, radius, useRefuelPool, tmin, tmax, rings, tType )

    local ArmyIndex     = aiBrain.ArmyIndex
    local ArmyPool      = aiBrain.ArmyPool
    local RefuelPool    = aiBrain.RefuelPool or false
    
    local units = GetUnitsAroundPoint( aiBrain, category, location, radius, 'Ally' )
	
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
		
			if not v.Dead and (not IsBeingBuilt(v)) and v.ArmyIndex == ArmyIndex then
			
				-- select only units in the Army pool or not attached
				if (not v.Attached) and (not v.PlatoonHandle or (v.PlatoonHandle == ArmyPool)) or (useRefuelPool and v.PlatoonHandle == RefuelPool) then

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

--	The SpawnWave
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
	
	local initialdelay = true
    local T3AIRFACS = categories.AIR * categories.FACTORY * categories.TECH3

	-- IF there is an initial units list then
	-- spawnwave will begin once the first T3 Air Factory is online - check every 60 seconds until it does
	while initialdelay do
	
		WaitTicks(601)
	
		local T3AirFacs = GetListOfUnits( aiBrain, T3AIRFACS, false, true )
		
		if T3AirFacs[1] then
		
			for _,v in T3AirFacs do

				-- the factory must be fully built --
				if v:GetFractionComplete() == 1 then

					initialdelay = false
					break
				end
			end
		end
	end
	
	local ArmyPool = aiBrain.ArmyPool

	while initialUnits do
    
		local T3AirFacs = GetListOfUnits( aiBrain, T3AIRFACS, false, true )
	
        -- the spawnwave cannot happen unless a T3 Air Factory is present
		if LOUDGETN(T3AirFacs) == 0 then
            LOG("*AI DEBUG "..aiBrain.Nickname.." spawnwave disabled - no factory")

            WaitTicks(1201)
			continue
		end    
		
		-- increase the size of the wave each time and vary it with the MajorCheatModifier (about 66% of the nominal cheat)
		local units = LOUDFLOOR((wave * 1.2) * aiBrain.MajorCheatModifier )

        -- insure that there is always at least 1 unit (in case of negative multipliers)
        local units = LOUDMAX( units, 1 )
		
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
        
        -- we provided so clear the need flag
        if aiBrain.NeedTransports then
            aiBrain.NeedTransports = nil
        end

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
		spawndelay = spawndelay - ( (30 - ((wave-1)*2) ) * aiBrain.MajorCheatModifier )
        
		--LOG("*AI DEBUG "..aiBrain.Nickname.." gets spawnwave of "..units.." at "..GetGameTimeSeconds().." seconds")
        --LOG("*AI DEBUG "..aiBrain.Nickname.." next spawnwave in "..spawndelay.." seconds")

		-- wait for the next spawn wave
		WaitTicks(LOUDFLOOR(spawndelay * 10))
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
    
	LOG("*AI DEBUG Starting ACT FEEDBACK on tick "..GetGameTick())

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
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT FEEDBACK unsubbed: defeated on tick "..GetGameTick())
                    
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
                    
                    LOG("*AI DEBUG "..aiBrain.Nickname.." ACT FEEDBACK (Ratio = "..aiBrain.LandRatio..") from "..oldcheat.." to "..aiBrain:TotalCheat().." on tick "..GetGameTick())
				end

			end
		end

		Iterate()
        
		if broke then
            Iterate()
        end
        
	end
    
	LOG("*AI DEBUG No more ACT FEEDBACK subscribers. Killing thread on tick "..GetGameTick())
end

function TimeAdaptiveCheatThread()

	-- RATODO: Ideas by Uveso and Balthazar
	-- - Parabola
	-- - Logarithmic
	-- - Multiplicative
	-- - Use ratios to slow or speed time-based increase
    
	local startDelay = 10 * 60 * (tonumber(ScenarioInfo.Options.ACTStartDelay) + 1)
    local interval = 10 * 60 * (tonumber(ScenarioInfo.Options.ACTTimeDelay) + 1)
    local cheatInc = tonumber(ScenarioInfo.Options.ACTTimeAmount)
	local cheatLimit = tonumber(ScenarioInfo.Options.ACTTimeCap)
    
	-- EXAMPLE: If 1.5 is the limit, -.05 is the change, and 1.1 is the base,
	-- this check prevents mult from getting math.maxed all the way up to 1.5
	for i = 1, LOUDGETN(timeACTBrains) do
    
		local aiBrain = timeACTBrains[i]
        
		if cheatInc < 0 and cheatLimit > aiBrain.CheatValue then
        
			LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED: base is below limit. Unsubscribing on tick "..GetGameTick())
            
			LOUDREMOVE(timeACTBrains, i)
		end
        
	end
	
	LOG("*AI DEBUG Starting ACT TIMED after "..startDelay.." ticks. Change: "..cheatInc.." per "..interval.." ticks. Limit: "..repr(cheatLimit).." on tick "..GetGameTick())
    
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
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: defeated on tick "..GetGameTick())
                    
					LOUDREMOVE(timeACTBrains, i)
                    
					broke = true
					break
                    
				elseif cheatInc < 0 and aiBrain:TotalCheat() <= cheatLimit then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: lower limit met on tick "..GetGameTick())
                    
					SetArmyPoolBuff(aiBrain, LOUDMAX(cheatLimit, aiBrain:TotalCheat()))
                    
					LOUDREMOVE(timeACTBrains, i)
                    
					broke = true
					break
                    
				elseif cheatInc > 0 and aiBrain:TotalCheat() >= cheatLimit then
                
					LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED unsubbed: upper limit met on tick "..GetGameTick())
                    
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
				end
                
				SetArmyPoolBuff(aiBrain, aiBrain:TotalCheat())
				
				LOG("*AI DEBUG "..aiBrain.Nickname.." ACT TIMED cheat goes from "..oldcheat.." to "..aiBrain:TotalCheat().." on tick "..GetGameTick())
			end
		end

		Iterate()
        
		if broke then
            Iterate()
        end
        
	end
    
	LOG("*AI DEBUG No more ACT TIMED subscribers. Killing thread on tick "..GetGameTick())
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
                    if (newHP < oldHP and newHP < 0.5) and not finishedUnit.EventCallbacks['OnTransportDetach'] then
					
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
                    if finishedUnit.HasFuel and not finishedUnit.EventCallbacks['OnTransportDetach'] then
				
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

	local LOUDGETN      = LOUDGETN
    local PlatoonExists = PlatoonExists
    local RebuildTable  = aiBrain.RebuildTable
    local WaitTicks     = WaitTicks

    local change = false
    
    local PlatoonDistress   = aiBrain.PlatoonDistress

    local AlertSounded      = PlatoonDistress.AlertSounded
    local Platoons          = PlatoonDistress.Platoons

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

    local RandomLocation = RandomLocation

	if position and not rallypointtable then

		local rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Rally Point', position, 65)
	
		if not rallypoints[1] then
			rallypoints = AIGetMarkersAroundLocation(aiBrain, 'Naval Rally Point', position, 65)
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
        LOUDSORT( rallypointtable, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a[1],a[3],checkposition[1],checkposition[3]) < VDist2Sq(b[1],b[3], checkposition[1],checkposition[3]) end )
    end

	if rallypointtable[1] then
	
		local rallycount = LOUDGETN(rallypointtable)
        
        local rp
        
        local unitcount = 0

        -- if provided use only that number of points
        -- since the table should be sorted, we end up moving only to those
        -- number of points that are closest to checkposition
        if checkcount then
            if rallycount >= checkcount then
                rallycount = checkcount
            end
        end
		
		for _,u in units do
        
            if not u.Dead then
        
                -- healthy units will be sent to closest threat rally points
                -- damaged units will be sent to the rally point furthest 
                -- from the checkposition (usually safest)
                if u:GetHealthPercent() > .5 then
		
                    rp = rallypointtable[ Random( 1, rallycount) ]
                
                else
            
                    rp = rallypointtable[ Random( rallycount, checkcount) ]
                
                end
            
                IssueStop( {u} )
                IssueMove( {u}, RandomLocation( rp[1], rp[3], 9 ) )
            
                unitcount = unitcount + 1

                -- throttling of commands
                if unitcount > 15 then
                    unitcount = 0
                    
                    WaitTicks(2)
                end
            end
		end
        
	else
    
		-- try and catch units being dispersed to what may now be a dead base --
		-- the idea is to drop them back into an RTB which should find another base

       	IssueStop( units )

        local ident = Random(4000001,9999999)

		returnpool = MakePlatoon( aiBrain, 'ReturnToBase '..tostring(ident), 'none' )

        returnpool.PlanName = 'ReturnToBaseAI'
        returnpool.BuilderName = 'DisperseFail'
		
        returnpool.BuilderLocation = false
		returnpool.RTBLocation = false

		import('/lua/ai/aiattackutilities.lua').GetMostRestrictiveLayer(returnpool) 

		for _,u in units do

			if not u.Dead then
				AssignUnitsToPlatoon( aiBrain, returnpool, {u}, 'Unassigned', 'None' )
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

		returnpool.RTBLocation = returnpool.BuilderLocation

		-- send the new platoon off to RTB
		returnpool:SetAIPlan('ReturnToBaseAI', aiBrain)
	end

	return
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimaryLandAttackBase( aiBrain )

    while aiBrain.AttackPlan.Pending do
        WaitTicks(21)
    end
    
    local AttackPlanDialog = ScenarioInfo.AttackPlanDialog or false

    -- clear existing base reference if it's no longer active
    if not aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].EngineerManager.Active then
        aiBrain.PrimaryLandAttackBase = false
        aiBrain.PrimaryLandAttackBaseDistance = 99999
    end
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD

    if aiBrain.AttackPlan.Goal then
    
        local goal = aiBrain.AttackPlan.Goal
        
        local Bases = {}
		local counter = 0
        
        local path, reason, pathlength
        local Primary
        
        local currentgoaldistance = aiBrain.PrimaryLandAttackBaseDistance or 99999       -- default in case current primary doesn't exist --
        
        local currentlandbasemode = false   -- assume all bases are amphibious mode
        
        if aiBrain.AttackPlan.Method == "Land" then
            currentlandbasemode = true      -- bases will be in land mode
        end
		
		-- make a table of all land bases
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Land" then

                path = false
                pathlength = 0
                
				-- here is the distance calculation 
                path,reason,pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, 'FindPrimaryLandAttackPlanner'..v.BaseName, 'Amphibious', v.Position, goal, 99999, 200)
                
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
    
        if AttackPlanDialog then
        
            LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan reviews Primary Land Attack Base for goal at "..repr(goal))
            LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan Current Primary Land Attack Base is "..repr(aiBrain.PrimaryLandAttackBase).." - LAND mode "..repr(aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].LandMode))

            if aiBrain.LastPrimaryLandAttackBase and aiBrain.LastPrimaryLandAttackBase != aiBrain.PrimaryLandAttackBase then
                LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan Previous Primary Land Attack Base is "..repr(aiBrain.LastPrimaryLandAttackBase))
            end
        end
        
		-- sort them by shortest path distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)

        -- a new primary base must be 10% closer than the existing one -- or don't change --
        if (currentgoaldistance and Bases[1].Distance < (currentgoaldistance * 0.9)) or LOUDGETN(Bases) == 1 then
        
            -- make this base the Primary
            Primary = Bases[1].BaseName
            
            if AttackPlanDialog then
            
                if aiBrain.PrimaryLandAttackBase != Primary then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan setting "..repr(Primary).." as Primary Land Attack Base - mode LAND is "..repr(currentlandbasemode))
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan records "..repr(aiBrain.PrimaryLandAttackBase).." as previous" )
                end
                
            end
            
            -- set the goal distance of the new base
            currentgoaldistance = Bases[1].Distance

            -- mark the base as being Primary --
            aiBrain.BuilderManagers[Primary].PrimaryLandAttackBase = true
            -- record what the previous primary base was
            aiBrain.LastPrimaryLandAttackBase = aiBrain.PrimaryLandAttackBase or false
            -- store the current base selection and the goal distance on the brain
            aiBrain.PrimaryLandAttackBase = Primary
            aiBrain.PrimaryLandAttackBaseDistance = currentgoaldistance
            
        
            local builderManager
        
            -- loop thru all the bases - set Primary, clear all others
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
 
                aiBrain.BuilderManagers[v.BaseName].LandMode = currentlandbasemode
            end
            
        else
        
            if aiBrain.PrimaryLandAttackBase then
            
                if aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].LandMode != currentlandbasemode then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan "..repr(aiBrain.PrimaryLandAttackBase).." PRIMARY - switching Land mode to "..repr(currentlandbasemode) )
                end
            
                aiBrain.BuilderManagers[aiBrain.PrimaryLandAttackBase].LandMode = currentlandbasemode
            end

        end
    end
    
    if AttackPlanDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." Set Primary Land Attack Base "..repr(aiBrain.PrimaryLandAttackBase).." complete on tick "..GetGameTick() )
    end
	
end

function GetPrimaryLandAttackBase( aiBrain )

	if aiBrain.PrimaryLandAttackBase and aiBrain.BuilderManagers[ aiBrain.PrimaryLandAttackBase ].Position then
		return aiBrain.PrimaryLandAttackBase, aiBrain.BuilderManagers[ aiBrain.PrimaryLandAttackBase ].Position
	end

    for k,v in aiBrain.BuilderManagers do
	
        if v.PrimaryLandAttackBase then
            return k, v.Position
        end
        
    end
    
	WARN("*AI DEBUG "..aiBrain.Nickname.." has no Primary Land Attack Base")
    return false, nil
end

-- This function determines which base is closest to the primary
-- attack planner goal and sets the flag on that base
function SetPrimarySeaAttackBase( aiBrain )
    
    if aiBrain.NumBasesNaval < 1 then

        aiBrain.PrimarySeaAttackBase = false
        
        return
    end
 
    local AttackPlanDialog      = ScenarioInfo.AttackPlanDialog or false
    local dialog = "*AI DEBUG "..aiBrain.Nickname.." SetPrimarySeaAttackBase"

    while aiBrain.AttackPlan.Pending do
    
        if AttackPlanDialog then
            LOG( dialog.." waiting for 21 ticks on tick "..GetGameTick())
        end

        WaitTicks(21)
    end
    
    if AttackPlanDialog then
        LOG( dialog.." begins on tick "..GetGameTick())
    end
   
    local GetClosestPathNode    = import('/lua/ai/aiattackutilities.lua').GetClosestPathNodeInRadiusByLayer

    -- clear existing base reference if it's no longer active
    if not aiBrain.BuilderManagers[aiBrain.PrimarySeaAttackBase].EngineerManager.Active then
        aiBrain.PrimarySeaAttackBase = false
        aiBrain.PrimarySeaAttackBaseDistance = 99999
    end
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD

    if aiBrain.AttackPlan.Goal then

        -- this is almost always a land position so it's not really valid for the sea attack base
        -- perhaps we should locate the closest naval path marker to this position
        local reason, goal, distance = GetClosestPathNode( aiBrain.AttackPlan.Goal,'Water' )
        
        if not goal then
        
            if AttackPlanDialog then
                LOG( dialog.." fails to find WATER node at "..distance.." trying AMPHIBIOUS")
            end
            
            reason, goal, distance = GetClosestPathNode( aiBrain.AttackPlan.Goal,'Amphibious')
        end

        if AttackPlanDialog then    
            LOG( dialog.." Goal is "..repr(goal).." on tick "..GetGameTick())
        end
        
        local Bases = {}
		local counter = 0
        
        local path, pathlength
        local Primary
       
        local currentgoaldistance = aiBrain.PrimarySeaAttackBaseDistance or 99999       -- default in case current primary doesn't exist --

		-- make a table of all sea bases
        for k,v in aiBrain.BuilderManagers do

            if AttackPlanDialog and v.BaseType == "Sea" then
                LOG( dialog.." assessing "..repr(v.BaseName).." on tick "..GetGameTick())
            end
		
			if v.EngineerManager.Active and v.BaseType == "Sea" then
            
                path = false
                pathlength = 0
                
                if AttackPlanDialog then
                    LOG( dialog.." checking path from "..repr(v.Position).." to "..repr(goal).." on tick "..GetGameTick())
                end
			
				-- here is the distance calculation based on Water movement
                path,reason,pathlength = PlatoonGenerateSafePathToLOUD( aiBrain, 'FindPrimarySeaAttackPlanner'..v.BaseName, 'Water', v.Position, goal, 99999, 200)

                if AttackPlanDialog then
                    LOG( dialog.." using path "..repr(path).." on tick "..GetGameTick())
                end

                if path then

                    if ScenarioInfo.DisplayAttackPlans and GetFocusArmy() == aiBrain.ArmyIndex then
                        ForkThread( DrawPath, v.Position, path, goal, '0099dd' )
                    end
                
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

            aiBrain.PrimarySeaAttackBase = false
            aiBrain.PrimarySeaAttackBaseDistance = 99999        

            LOG( dialog.." has NO CHOICES for Primary Sea Attack Base")

            return
        end
    
        if AttackPlanDialog then

            LOG( dialog.." reviews Primary Sea Attack Base for goal at "..repr(goal))

            if aiBrain.PrimarySeaAttackBase then
                LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan Current Primary Sea Attack Base is "..repr(aiBrain.PrimarySeaAttackBase))
            end
            if aiBrain.LastPrimarySeaAttackBase then
                LOG("*AI DEBUG "..aiBrain.Nickname.." AttackPlan Previous Primary Sea Attack Base is "..repr(aiBrain.LastPrimarySeaAttackBase))
            end
        end

		-- sort them by shortest path distance to goal
        LOUDSORT(Bases, function(a,b) return a.Distance < b.Distance end)
        
        if AttackPlanDialog then
            LOG( dialog.." Current goal distance is "..repr(currentgoaldistance).." to "..repr(goal) )
            LOG( dialog.." Sea Bases are "..repr(Bases) )
        end
		
        -- a new base must be 10% closer then the existing one -- or don't change --
        if (currentgoaldistance and Bases[1].Distance < (currentgoaldistance * 0.9)) or LOUDGETN(Bases) == 1 then
        
            -- make the closest one the Primary
            Primary = Bases[1].BaseName
            
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

                -- if the location is not the primary -- check for any units that need to be moved up 
                else
            
                    aiBrain.BuilderManagers[v.BaseName].PrimarySeaAttackBase = false
                    builderManager:ForkThread( ClearOutBase, aiBrain )
                end
            end
           
        else
            --LOG("*AI DEBUG "..aiBrain.Nickname.." "..repr(aiBrain.PrimarySeaAttackBase).." remains the Primary Sea Attack Base")            
        end

    else
        -- no attack plan - pick the first Sea base you find
        for k,v in aiBrain.BuilderManagers do
		
			if v.EngineerManager.Active and v.BaseType == "Sea" then

                aiBrain.BuilderManagers[v.BaseName].PrimarySeaAttackBase = true

                aiBrain.LastPrimarySeaAttackBase = aiBrain.PrimarySeaAttackBase or false

                aiBrain.PrimarySeaAttackBase = v.BaseName
                aiBrain.PrimarySeaAttackBaseDistance = 99999
                
                break
			end
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
				return k, v.Position
			end
		end
    
		WARN("*AI DEBUG "..aiBrain.Nickname.." has no Primary Sea Attack Base")
        
        SetPrimarySeaAttackBase( aiBrain )
	end
	
    return false, nil
end

function ClearOutBase( manager, aiBrain )

    local PlatoonDialog = ScenarioInfo.PlatoonDialog

	local basename = manager.LocationType
	local Position = aiBrain.BuilderManagers[basename].Position
    local tostring = tostring
    
    -- the base cannot have any active alerts --
    if aiBrain.BuilderManagers[basename].EngineerManager.BaseMonitor.ActiveAlerts == 0 then

        -- all standard land units but Not experimentals 
        local grouplnd, grouplndcount = GetFreeUnitsAroundPoint( aiBrain, (categories.LAND * categories.MOBILE) - categories.AMPHIBIOUS - categories.COMMAND - categories.ENGINEER - categories.INSIGNIFICANTUNIT, Position, 100 )

        if grouplndcount > 0 then

            local ident = Random(1,999999)
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutLand"..tostring(ident).." at "..basename )
            end

            local plat = MakePlatoon( aiBrain,'ClearOutLand'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Land'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in grouplnd do

                if counter < 50 then
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
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutAmphib"..tostring(ident).." at "..basename )
            end

            local plat = MakePlatoon( aiBrain,'ClearOutAmphib'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Amphib'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in groupamphib do

                if counter < 50 then
                    AssignUnitsToPlatoon( aiBrain,plat, {unit},'Attack','None')
                    counter = counter + 1
                else
                    break
                end
            end

            plat:ForkThread( import('/lua/ai/aibehaviors.lua')['BroadcastPlatoonPlan'], aiBrain )

            plat:SetAIPlan( 'ReinforceAmphibAI', aiBrain )
            
        end

        local groupsea, groupseacount = GetFreeUnitsAroundPoint( aiBrain, NAVALMOBILE - categories.INSIGNIFICANTUNIT, Position, 100 )

        if groupseacount > 0 then

            local ident = Random(1,999999)
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutSea"..tostring(ident).." at "..basename )
            end

            local plat = MakePlatoon( aiBrain,'ClearOutSea'..tostring(ident),'none')

            plat.BuilderName = 'ClearOutPrimary Sea'
            plat.BulderLocation = basename

            local counter = 0

            for _,unit in groupsea do

                if counter < 50 then
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
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutFighters"..tostring(ident).." at "..basename )
            end

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
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..basename.." Creates ClearOutGunships"..tostring(ident) )
            end

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
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutBombers"..tostring(ident).." at "..basename )
            end

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
            
            if PlatoonDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates ClearOutTorpedoBombers"..tostring(ident).." at "..basename )
            end

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

function ResetPFMTasks (PFM, aiBrain)

    local PriorityDialog = ScenarioInfo.PriorityDialog
    local header = "*AI DEBUG "..aiBrain.Nickname.." "..PFM.LocationType.." "..PFM.ManagerType
	
	-- Review ALL the PFM Builders for PriorityFunction task changes
    local NewPriority, temporary
	local newtasks = 0
    
    if PriorityDialog then
        LOG( header.." Resets Any PFM Tasks on tick "..GetGameTick() )
    end

	for _,BuilderTask in PFM.BuilderData['Any'].Builders do

        if BuilderTask.PriorityFunction then

            NewPriority, temporary = BuilderTask:PriorityFunction( aiBrain, PFM )

            if NewPriority and NewPriority != BuilderTask.Priority then

                if PriorityDialog then
                    LOG( header.." resets "..BuilderTask.BuilderName.." to "..repr(NewPriority))
                end

                PFM:SetBuilderPriority(BuilderTask.BuilderName, NewPriority, temporary)

                -- signal a resort of the PFM Builders
                PFM.BuilderData['Any'].NeedSort = true
            end
        end

		if (not NewPriority and BuilderTask.Priority > 99) or (NewPriority and NewPriority > 99) then

			newtasks = newtasks + 1
		end

	end

	PFM.NumBuilders = newtasks	
end

-- this function will direct all air units into the refit/refuel process if needed
-- this is fired off by the OnRunOutOfFuel event which triggers it as a callback -- only used by the AI --
-- or during the ReturnToBaseAI function 
function ProcessAirUnits( unit, aiBrain )

	if (not unit.Dead) and (not IsBeingBuilt(unit)) then
    
        --LOG("*AI DEBUG Unit is "..repr(unit.BlueprintID).." GetFuel is "..GetFuelRatio(unit) )

		if ( GetFuelRatio(unit) > -1 and GetFuelRatio(unit) < .75 ) or unit:GetHealthPercent() < .80 then

            if not unit.InRefit then
            
                if unit.RefitThread then
                
                    LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." killing existing refit thread")
                    
                    KillThread(unit.RefitThread)
                    
                    unit.RefitThread = nil

                end
                
                --LOG("*AI DEBUG "..aiBrain.Nickname.." Unit "..unit.Sync.id.." assigned to refit thread from "..repr(unit.PlatoonHandle.BuilderName).." "..repr(unit.PlatoonHandle.BuilderInstance) )

                unit.InRefit = true
                
                -- and send it off to the refit thread --
                unit.RefitThread = unit:ForkThread( AirUnitRefitThread, aiBrain )
                
                return true
            end
		end
	end
	
	return false    -- unit did not need processing
end

-- this function will attempt to get the air unit to a repair pad or base
-- and then turn them over to the RefuelPool
function AirUnitRefitThread( unit, aiBrain )

    local PlatoonDialog = ScenarioInfo.PlatoonDialog
    local RefitDialog   = false

    if unit.Dead then
        return
    end

    local GetFuelRatio      = GetFuelRatio
    local GetHealthPercent  = unit.GetHealthPercent
    local GetCurrentUnits   = GetCurrentUnits

    local LOUDCOPY  = LOUDCOPY
    local LOUDSORT  = LOUDSORT
    local VDist3Sq  = VDist3Sq
    local WaitTicks = WaitTicks

    --- these values set the point at which a unit can leave the refit thread
	local fuellimit     = 1.0
	local healthlimit   = 1.0
   
    while (not unit.Dead) and unit.IgnoreRefit do
        WaitTicks(9)
    end

	local ident, returnpool, unitPos
	local airpad, closestairpad, reason, safePath
 
    local function GetClosestAirpad( aiBrain, unitPos )

        --- limit to airpads within 40k
        local plats = GetOwnUnitsAroundPoint( aiBrain, AIRPADS, unitPos, 2048 )

        --- if transport - filter out the T1 airpads
        if LOUDENTITY( categories.TRANSPORTFOCUS, unit) then
            plats = EntityCategoryFilterDown(AIRPADS - categories.TECH1, plats )
        end

		if plats[1] then

            LOUDSORT( plats, function(a,b) local VDist3Sq = VDist3Sq return VDist3Sq(GetPosition(a),unitPos) < VDist3Sq(GetPosition(b),unitPos) end )

            return GetPosition(plats[1]), plats[1]
        else
        
            return false, false
        end
    end

	-- if not dead 
	if not unit.Dead then

        ident = tostring(unit.Sync.id)

        returnpool                  = MakePlatoon( aiBrain,'AirRefit'..ident, 'none')
        returnpool.BuilderName      = 'AirRefit'..ident
        returnpool.UsingTransport   = true        -- never review this platoon as part of a merge

        if PlatoonDialog or RefitDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." Platoon Creates "..returnpool.BuilderName.." on tick "..GetGameTick() )
        end

        if not unit.Dead then

            if RefitDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." assigned to "..returnpool.BuilderName.." at tick "..GetGameTick() )
            end

            AssignUnitsToPlatoon( aiBrain, returnpool, {unit}, 'Support', '')

            unit:MarkWeaponsOnTransport(unit, true)     --- prevent targetlock, dr and merge
        end

		if not unit.Dead then

            unitPos = LOUDCOPY(GetPosition(unit))
            
            -- closest base with an airpad
            closestairpad, airpad = import('/lua/loudutilities.lua').AIFindClosestBuilderManagerPosition( aiBrain, unitPos, categories.AIRSTAGINGPLATFORM )

            -- otherwise just closest base
            if not closestairpad then
                closestairpad = FindClosestBaseName( aiBrain, unitPos, true, false)
                closestairpad = aiBrain.BuilderManagers[closestairpad].Position
            end

			if closestairpad then

                safePath = false

                IssueClearCommands( {unit} )

                if GetThreatBetweenPositions( aiBrain, unitPos, closestairpad, nil, 'AntiAir' ) < 16 then

                    safePath = { closestairpad }
                    reason = 'Direct'

                else
                    safePath, reason = returnpool.PlatoonGenerateSafePathToLOUD(aiBrain, returnpool, 'Air', unitPos, closestairpad, 16, 256)
                end

                if not safePath then

                    safePath = { closestairpad }
                    reason = 'Direct'

                end

                --- move the platoon 
                returnpool.MoveThread = returnpool:ForkThread( returnpool.MovePlatoon, safePath, 'AttackFormation', false, 31)

                if RefitDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." moving to "..repr(closestairpad).." with path "..repr(safePath).." on tick "..GetGameTick() )
                end

                -- wait for the movement orders to execute --
                while PlatoonExists(aiBrain, returnpool) and returnpool.MoveThread and ( (GetFuelRatio(unit) < fuellimit and GetFuelRatio(unit) != -1) or GetHealthPercent(unit) < healthlimit ) do
                    WaitTicks(2)
                end

                if returnpool.MoveThread then
                    returnpool:KillMoveThread()
                end
                
                --- assign unit to RefuelPool (if it exists)
                if PlatoonExists(aiBrain, returnpool ) and aiBrain.RefuelPool then

                    if RefitDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." "..returnpool.BuilderName.." arrives at airpad - Assigned to RefuelPool on tick "..GetGameTick() )
                    end

                    AssignUnitsToPlatoon( aiBrain, aiBrain.RefuelPool, {unit}, 'Support', '')

                    if airpad then
                        AirStagingThread( unit, airpad, aiBrain, RefitDialog )
                    end

                end

            end

        end
    end

    WaitTicks(2)
    
    --- this will trap units that didn't get to an airpad (ie. - transports, or no airpad)
    --- and if an airpad appears during that, it will send them to it
    while (not unit.Dead) and ( ( GetFuelRatio(unit) < fuellimit and GetFuelRatio(unit) != -1) or GetHealthPercent(unit) < healthlimit ) do
        
        airpad          = false
        closestairpad   = false

        closestairpad, airpad = GetClosestAirpad( aiBrain, GetPosition(unit) )

        if closestairpad then
            AirStagingThread( unit, airpad, aiBrain, RefitDialog )
        else
            WaitTicks(11)
        end

    end

	--- return repaired/refuelled unit to pool
	if not unit.Dead then

        if RefitDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." leaves RefitThread on tick "..GetGameTick() )
        end

        unit.InRefit = nil

        --- weapons turned back on
        unit:MarkWeaponsOnTransport(unit, false)

		--- all air units except TRUE transports are returned to ArmyPool --
		if not LOUDENTITY( categories.TRANSPORTFOCUS, unit) or LOUDENTITY( categories.uea0203, unit ) then

            if RefitDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." returns to Army Pool at tick "..GetGameTick() )
            end

			AssignUnitsToPlatoon( aiBrain, aiBrain.ArmyPool, {unit}, 'Unassigned', '' )
			
			DisperseUnitsToRallyPoints( aiBrain, {unit}, GetPosition(unit), false )
            
		else
        
            if ScenarioInfo.TransportDialog or RefitDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." transport "..unit.EntityID.." leaving Refit thread")
            end
            
			ForkThread( ReturnTransportsToPool, aiBrain, {unit}, true )
            
		end

        unit.InRefit = nil
        unit.RefitThread = nil
	end

end

--- this function is called when an airunit finds an airstage to go to
function AirStagingThread( unit, airstage, aiBrain, RefitDialog )

    if RefitDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." begins AirStagingThread at "..GetGameTick() )
    end

    local EntityCategoryContains    = EntityCategoryContains
    local GetFuelRatio              = GetFuelRatio
    local GetHealthPercent          = unit.GetHealthPercent
    local IsUnitState               = IsUnitState
    local WaitTicks                 = WaitTicks

    local stage = GetPosition(airstage)
    
    local unitpos, reason, safePath

	if (not airstage.Dead) and aiBrain.PathRequests then
		
		if not unit.Dead then

            safePath    = false
            unitpos     = GetPosition(unit)
            
            --- path move to the airpad
            if VDist3( unitpos, stage ) > 40 then

                if aiBrain.TransportPool.PlatoonGenerateSafePathToLOUD then

                    safePath, reason = aiBrain.TransportPool.PlatoonGenerateSafePathToLOUD(aiBrain, unit.PlatoonHandle, 'Air', unitpos, stage, 20, 256)

                end

            else
                safePath = { stage }
            end

            IssueClearCommands( {unit} )

            if safePath and not unit.Dead then

                if RefitDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." paths to airpad" )
                end

                --- use path
                for _,p in safePath do
                    IssueMove( {unit}, p )
                end
                
            else

                if RefitDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." goes direct to airpad" )
                end

                --- go direct -- possibly bad
                IssueMove( {unit}, stage )
                
            end

            -- while underway to airstaging --
            while not (unit.Dead or airstage.Dead) and VDist2(unitpos[1],unitpos[3], stage[1],stage[3]) > 20 and (( GetFuelRatio(unit) < .85 and GetFuelRatio(unit) != -1) or GetHealthPercent(unit) < .85 ) do
                WaitTicks(6)
            end

			IssueClearCommands( {unit} )

			if not (unit.Dead or airstage.Dead) and (not unit:IsUnitState('Attached')) then

                if RefitDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." ordered to attach to airpad "..airstage.Sync.id.." on tick "..GetGameTick() )
                end

                safecall("Unable to IssueTransportLoad units are "..unit.Sync.id, IssueTransportLoad, {unit}, airstage )

            end

		end

	end

	local waitcount = 0
	
	--- loop until unit attached, idle, dead or it's fixed itself
	while (not unit.Dead) and (not airstage.Dead) do
     
        if unit.Attached then

            if RefitDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." AirStaging reports ATTACHED on tick "..GetGameTick() )
            end
        
            break
        end
		
		if (( GetFuelRatio(unit) < 1.0 and GetFuelRatio(unit) != -1) or GetHealthPercent(unit) < 1.0) then

            if RefitDialog then
                --ForkThread( FloatingEntityText, unit.EntityID, 'Cyc '..waitcount )
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." AirStaging loading cycle "..waitcount.." at tick "..GetGameTick() )
            end

        else

            if RefitDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." AirStaging reports REPAIRED NO ATTACH - aborting pad load on tick "..GetGameTick() )
            end
  
			break
		end
        
        if (not unit.Attached) and (not unit.Dead) then

            --- taking a long time to get loaded -- try and reload again - or force unit into landing
            if waitcount == 21 and (not EntityCategoryContains( categories.CANNOTUSEAIRSTAGING, unit)) then

                --- then re-order it to load onto airpad if airpad has space
                if (not airstage.Dead) and (not unit.Dead) and (not unit.Attached) then

                    if airstage:TransportHasSpaceFor( unit ) then

                        waitcount = 22

                        if RefitDialog then
                            LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." ordered 2ND attach to "..airstage.Sync.id.." on tick "..GetGameTick() )
                        end
                
                        safecall("Unable to IssueTransportLoad units are "..unit.Sync.id, IssueTransportLoad, {unit}, airstage )

                    end

                else --- otherwise force the unit to land
                    waitcount = 41
                end
            end

            --- land nearby and wait for natural refuel/heal
            if waitcount == 41 then  --- but stay within this loop until repair & refuel
        
                IssueClearCommands( {unit} )

                if RefitDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." AirStaging load TIMEOUT "..waitcount.." - will land instead on tick "..GetGameTick() )
                end
            end
            
        end

		WaitTicks( 15 )
        waitcount = waitcount + 1
        
	end

	--- get it off the airpad
	if (not airstage.Dead) and (not unit.Dead) then
        
        waitcount = GetGameTick()

		-- we should be loaded onto airpad at this point
		-- some interesting behaviour here - usually when a unit is ready it will lift off and exit by itself BUT
		-- sometimes we have to force it off -- when we do we have to manually restore it's normal conditions (ie. - can take damage)
		while (( GetFuelRatio(unit) < 1.0 and GetFuelRatio(unit) != -1) or GetHealthPercent(unit) < 1.0) do
            WaitTicks(3)
        end

        if RefitDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." AirStaging complete after "..(GetGameTick() - waitcount).." ticks - on tick "..GetGameTick() )
        end 

        --- the unload is usually automatic so this is just a guard
        --IssueTransportUnloadSpecific( unit, unit:GetPosition(), airstage )

        --airstage:OnTransportDetach( nil, unit)

		unit:SetReclaimable(true)
		unit:SetCapturable(true)
		unit:ShowBone(0, true)            

	end
	
	if not unit.Dead then
    
        unit:OnGotFuel()

        while (not unit.Dead) and unit.Attached do
            WaitTicks(3)
        end

        if RefitDialog then
            LOG("*AI DEBUG "..aiBrain.Nickname.." "..unit.Sync.id.." leaves AirStaging on tick "..GetGameTick() )
        end
  
	end	

end

-- this will return true or false depending upon if an enemy ANTITELEPORT
-- unit is in range of the location
-- will now check for blockage on a line to the destination
function TeleportLocationBlocked( self, targetPos )

	local aiBrain = GetAIBrain(self)
    
    local BRAINS = ArmyBrains
    local unitList = {}
    local VDist2 = VDist2

	local function CheckBlockingAntiTeleport( position, targetPos )  

        local lastpos, steps, xstep, ystep
        local noTeleDistance, atposition, targetdist

		-- This gives us the number of approx. 50 ogrid steps in the distance
		steps = LOUDFLOOR( VDist3( position, targetPos ) / 50 ) + 1
	
		xstep = (position[1] - targetPos[1]) / steps -- how much the X value will change from step to step
		ystep = (position[3] - targetPos[3]) / steps -- how much the Y value will change from step to step

        nextpos = { 0, 0, 0 }
	
		-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
		for i = 1, steps do

            nextpos[1] = position[1] - (xstep * i)
            nextpos[3] = position[3] - (ystep * i)
            
            for u, unit in unitList do
            
                noTeleDistance  = __blueprints[unit.BlueprintID].Defense.NoTeleDistance
                atposition      = GetPosition(unit)
                targetdist      = VDist2(nextpos[1], nextpos[3], atposition[1], atposition[3])
                
                if targetdist < noTeleDistance then
                    LOG("*AI DEBUG OnTeleportUnit blocked around "..repr(nextpos))
                    return true
                end
            end

		end
	
		return false    -- not blocked
	end
	
	for num, brain in BRAINS do
	
		if not IsAlly( aiBrain.ArmyIndex, brain.ArmyIndex ) and aiBrain.Armyindex != brain.ArmyIndex then
		
			unitList = GetListOfUnits( brain, categories.ANTITELEPORT, false, true)
			
            if CheckBlockingAntiTeleport( self:GetPosition(), targetPos ) then
                return true
			end
		end
	end
	
	return false
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
			ScenarioInfo.BOACU_Checked = true
		end

		if m.name == 'BlackOps Unleashed Units for LOUD' then
			ScenarioInfo.BOU_Checked = true
		end
		
		if m.name == 'LOUD Integrated Storage' then
			ScenarioInfo.LOUD_IS_Checked = true
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

				eng:SetCustomName("Eng " .. eng.EntityID .. ": " .. eng.PlatoonHandle.BuilderName)

			elseif LOUDENTITY( categories.SUBCOMMANDER, eng) and eng.PlatoonHandle.BuilderName then

				eng:SetCustomName("SCU " .. eng.EntityID .. ": " .. eng.PlatoonHandle.BuilderName)

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

    local GetEconomyIncome      = GetEconomyIncome
    local GetEconomyRequested   = GetEconomyRequested
	local GetEconomyTrend       = GetEconomyTrend

	local LOUDMIN = math.min

	local WaitTicks = WaitTicks

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
    WaitTicks( LOUDMOD( aiBrain.ArmyIndex, samplerate ) + 1)       -- we add one to avoid 0 --

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
            
            if (eRequested * samplefactor) != 0 then
                EcoDataOverTime['EnergyEfficiency'] = LOUDMIN( (eIncome * samplefactor) / (eRequested * samplefactor), 2)
            end
            if (mRequested * samplefactor) != 0 then
                EcoDataOverTime['MassEfficiency'] = LOUDMIN( (mIncome * samplefactor) / (mRequested * samplefactor), 2)
            end


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

	local GetDirectionInDegrees = import('/lua/utilities.lua').GetDirectionInDegrees
	local LOUDCEIL              = math.ceil
    local VDist2Sq              = VDist2Sq
    
	local newloc    = false
	local Orient    = false
	local Basename  = false
	
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
            
            --LOG("*AI DEBUG Getting Orientation for location "..repr(location).." on tick "..GetGameTick() )
			
			local threats = aiBrain:GetThreatsAroundPosition( location, 16, true, 'Overall' )

			LOUDSORT( threats, function(a,b) local VDist2Sq = VDist2Sq return VDist2(a[1],a[2],location[1],location[3]) + a[3] < VDist2(b[1],b[2],location[1],location[3]) + b[3] end )
		
            local counter = 0
            local avgposition = { 0,0,0 }
            
			for _,v in threats do
			
                avgposition[1] = avgposition[1] + v[1]
                avgposition[3] = avgposition[3] + v[2]
                
                counter = counter + 1
				
			end
            
            --- if there are no threats on the map - then orient towards middle of the map
            if counter == 0 then
            
                --LOG("*AI DEBUG No threats were found for location "..repr(location) )

                avgposition[1] = Mx/2
                avgposition[3] = Mz/2
                counter = 1
            end
            
			Direction = GetDirectionInDegrees( {avgposition[1]/counter, location[2], avgposition[3]/counter}, location )

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
			if not (x == 0 and y == 0)	and	(x == lowlimit or y == lowlimit or x == highlimit or y == highlimit)
			and not ((x == lowlimit and y == lowlimit) or (x == lowlimit and y == highlimit)
			or ( x == highlimit and y == highlimit) or ( x == highlimit and y == lowlimit)) then
            
                if layer == "Water" and ( GetTerrainHeight(location[1] + x, location[3] + y) + 1 ) > GetSurfaceHeight(location[1] + x, location[3] + y) then

                    continue
                    
                elseif layer == "Land" and ( GetTerrainHeight(location[1] + x, location[3] + y) + 1 ) < GetSurfaceHeight(location[1] + x, location[3] + y) then

                    continue

                end
			
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

	local markertype = "Rally Point"
	local orientation = orientation or 'ALL'
	
	if basetype == "Sea" then
		markertype = "Naval Rally Point"
	end
    
	-- the intent of this function is to make sure that we don't try and respond over mountains
	-- and rivers and other serious terrain blockages -- these are generally identified by
    -- a rapid elevation change over a very short distance
	local function CheckBlockingTerrain( pos, targetPos )

        local GetSurfaceHeight = GetSurfaceHeight 
        local LOUDABS = math.abs

        local deviation, nextpos, nextposHeight    

        if basetype == "Sea" then
            deviation = 0.2
        else
            deviation = 2.5
        end
	
		-- This gives us the number of approx. 8 ogrid steps in the distance
		local steps = LOUDFLOOR( VDist2(pos[1], pos[3], targetPos[1], targetPos[3]) / 8 ) + 1
	
		local xstep = (pos[1] - targetPos[1]) / steps
		local ystep = (pos[3] - targetPos[3]) / steps

		local lastpos = {pos[1], 0, pos[3]}
        local lastposHeight = GetSurfaceHeight( lastpos[1], lastpos[3] )
        
        nextpos = { 0, 0, 0 }

		-- Iterate thru the number of steps - starting at the pos and adding xstep and ystep to each point
		for i = 1, steps do
		
            nextpos[1] = pos[1] - (xstep * i)
            nextpos[3] = pos[3] - (ystep * i)

			nextposHeight = GetSurfaceHeight( nextpos[1], nextpos[3] )

			-- if more than deviation ogrids change in height over 8 ogrids distance
			if LOUDABS(lastposHeight - nextposHeight) > deviation then
				return true
			end

			lastpos[1] = nextpos[1]
            lastpos[3] = nextpos[3]
            lastposHeight = nextposHeight

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

	--LOG("*AI DEBUG "..aiBrain.Nickname.." sets Base Rally points for "..basename.." "..repr(rallypointtable))	

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
    
	WaitTicks(1801)     -- dont start for three minutes

    if ScenarioInfo.DeadBaseMonitorDialog then
        LOG("*AI DEBUG "..aiBrain.Nickname.." DBM (Dead Base Monitor) begins")
    end

    local EntityCategoryCount = EntityCategoryCount
    
	local GetUnitsAroundPoint = GetUnitsAroundPoint
    local RebuildTable = aiBrain.RebuildTable
    
  	local GetOwnUnitsAroundPoint = GetOwnUnitsAroundPoint
	
	local changed, structurecount, platland, platair, platsea
	
	local grouplnd, grouplndcount, counter
	local groupair, groupaircount
	local groupsea, groupseacount
    
    local FACTORIES     = categories.FACTORY
    local STRUCTURES    = categories.STRUCTURE - categories.WALL
    local ALLUNITS      = categories.ALLUNITS - categories.WALL
    
    local BM, EM, FM, PFM
    local CountedBase
    local DeadBaseMonitorDialog

	while true do
    
        -- learned something about local references with this and the importance of 'refreshing'
        -- the reference
        BM = aiBrain.BuilderManagers
        
        DeadBaseMonitorDialog = ScenarioInfo.DeadBaseMonitorDialog or false

		for k,v in BM do
			
			changed = false
			structurecount = 0

			platland    = false
			platair     = false
			platsea     = false
--[[            
            if DeadBaseMonitorDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." DBM "..v.BaseName.." processing - PrimaryLand "..repr(v.PrimaryLandAttackBase).." - PrimarySea "..repr(v.PrimarySeaAttackBase))
            end
--]]            
            CountedBase = v.CountedBase

			if not CountedBase then
				structurecount = LOUDGETN( GetOwnUnitsAroundPoint( aiBrain, STRUCTURES, v.Position, 72) )
			end
            
            EM  = v.EngineerManager
            FM  = v.FactoryManager
            PFM = v.PlatoonFormManager

			-- if a base has no factories
			if (CountedBase and EntityCategoryCount( FACTORIES, FM.FactoryList ) <= 0) or
				(not CountedBase and structurecount < 1) then
                
                -- if the base has no engineers - increase the no factory count
                if EntityCategoryCount( ALLUNITS, EM.EngineerList ) <= 0 then 
                
                    if DeadBaseMonitorDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." DBM "..v.BaseName.." - no ENG count "..repr(BM[k].nofactorycount + 1))
                    end
                    
                    aiBrain.BuilderManagers[k].nofactorycount = BM[k].nofactorycount + 1
                end

				-- if base has no engineers, no factories for 120 seconds AND no other structures
				if EntityCategoryCount( ALLUNITS, EM.EngineerList ) <= 0 and BM[k].nofactorycount >= 6 and structurecount < 1 then
				
                    if DeadBaseMonitorDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." DBM "..v.BaseName.." - removing base on tick "..GetGameTick() )
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
					if CountedBase then
					
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
		aiBrain.dist_comp = LOUDSQRT( math.pow(ScenarioInfo.size[1],2) + math.pow(ScenarioInfo.size[2],2) )
	end

	WaitTicks(201)

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
	
	local GetThreatBetweenPositions = GetThreatBetweenPositions
    local PlatoonExists             = PlatoonExists

	local LOUDCOPY      = LOUDCOPY
    local LOUDEQUAL     = LOUDEQUAL
    local LOUDLOG10     = math.log10
	local LOUDREMOVE    = table.remove
	local LOUDSORT      = LOUDSORT
	local ForkThread    = ForkThread
    local type          = type
    local VDist2        = VDist2
	local VDist2Sq      = VDist2Sq
    local VDist3        = VDist3
	local WaitTicks     = WaitTicks
	
	-- get the table with all the nodes for this layer
	local graph         = ScenarioInfo.PathGraphs['Air']
    local Rings         = ScenarioInfo.RingSize or 0
	local IMAPRadius    = ScenarioInfo.IMAPSize * .5
    local IMAPSize      = ScenarioInfo.IMAPSize

	local data      = false
    local calctable = {}    -- this table memoizes the distance modifier result 
	local queue     = {}
	local closed    = {}
    
    local checkrange, destination, fork, platoon, shortcut, stepcostadjust, stepsize, threat, ThreatLayer
    local EndPosition, EndThreat, pathcost, pathlength, pathlist, StartLength, StartNode, StartPosition, ThreatWeight  

	local function DestinationBetweenPoints(position,testposition)

        local VDist2Sq = VDist2Sq

		local steps = LOUDFLOOR( VDist3(position, testposition) / stepsize )
        
        if steps == 0 then
            return false
        end

        local xstep = ( position[1] - testposition[1]) / steps
		local ystep = ( position[3] - testposition[3]) / steps
	
		for i = 1, steps do

			if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= (checkrange*.6) then
				return true
			end
		end	
	
		return false
	end

	local function AStarLoopBody()

        local GetThreatBetweenPositions = GetThreatBetweenPositions
        local GetThreatAtPosition       = GetThreatAtPosition
        
        local LOUDCOPY = LOUDCOPY
        local LOUDEQUAL = LOUDEQUAL
        local LOUDINSERT = LOUDINSERT
        local LOUDLOG10 = LOUDLOG10
        local LOUDSORT = LOUDSORT
        local VDist3 = VDist3

        local Cost, newnode, Node, Pathcount, position, queueitem, testposition, testpositionlength, Threat		

		queueitem = LOUDREMOVE(queue, 1)
        
        Cost        = queueitem.cost
        Node        = queueitem.Node
        Pathcount   = queueitem.pathcount
		position    = Node.position
        Threat      = queueitem.threat

		if closed[Node[1]] then
			return false, 0, false, 0
		end

		if LOUDEQUAL(position, EndPosition) or VDist3( destination, position) <= stepsize then
			return queueitem.path, queueitem.length, false, Cost
		end
	
		closed[Node[1]] = true

		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in Node.adjacent do
		
			newnode = adjacentNode[1]
			
			if closed[newnode] then
				continue
			end
			
			testposition = LOUDCOPY(graph[newnode].position)
		
			if data.Testpath and DestinationBetweenPoints( position, testposition ) then

                queueitem.length = queueitem.length + VDist3( destination, position)
             
				return queueitem.path, queueitem.length, true, Cost
			end

            testpositionlength = LOUDFLOOR(VDist3( position, testposition ))
            
            threat = 0
            
            -- Threat is how much threat this test is allowed to absorb
            -- each time we accept a step in the path, it's value may be reduced by what we already absorbed
            if Threat < 99999 then
			
                threat = LOUDMAX( 0, GetThreatBetweenPositions( aiBrain, position, testposition, true, ThreatLayer))

                -- the the perceived threat is greater than we allow - ignore this step
                if threat > Threat then
                    continue
                    
                -- otherwise, value it according to how long this step is - compared to the size of the IMAP block
                -- if we're going to travel the full length of the block - threat is valued at full - shorter or longer is adjusted
                else

                    if not calctable[testpositionlength] then 
                        calctable[testpositionlength] = LOUDSQRT(testpositionlength/IMAPSize)
                    end
                    
                    stepcostadjust = calctable[testpositionlength]
                    
                    threat = threat * stepcostadjust
                end

            end
			
			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }
            
            stepcostadjust = 0
            
            -- a step with ANY threat costs more than one without
            if threat > 0 then 
                stepcostadjust = 20
                
                -- if it's more then half our allowed then do this again
                if threat > (Threat*.5) then
                    stepcostadjust = stepcostadjust + 40
                end
            end

			fork.cost = Cost + threat + stepcostadjust

			-- as we accrue more steps in a path - the value of being closer to the goal diminishes quickly in favor of being safe --
			fork.goaldist = VDist3( destination, testposition ) * ( LOUDLOG10( Pathcount + 1))

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = Pathcount + 1
	
			fork.path[fork.pathcount] = testposition
		
			fork.threat = Threat - threat   --- we capture the declining amount of threat we can absorb

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end		

    local PathRequests = aiBrain.PathRequests.Air
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
	
	-- OK - some notes about the path requests - here is the data layout of a path request;
	--	Dest = destination,
	--	EndNode = endNode,
	--	Location = start,
	--	Platoon = platoon, 
	--	StartNode = startNode,
	--	Stepsize = stepsize,
	--	Testpath = testPath,
	--	ThreatLayer = threattype,
	--	ThreatWeight = threatallowed,	-- this is the maximum total threat this platoon is allowed to encounter

	-- i've come to a conclusion about how pathing can take casualties into account along the way -- in our case this
	-- would be represented by the platoon having a declining threat as it encounters enemy threat along its chosen path
	-- some outcomes become clear when you do this;
	--	 the platoon will chose a path that gets there with survivable losses that allow it to get to the final destination
	--	 the platoon will refuse a task at some point along the way as it's allowed threat is consumed by smaller threats along the way	
	while true do
    
        if PathRequests[1] then
    
            data = LOUDREMOVE(PathRequests, 1) or false

            closed = {}
            
            destination     = data.Dest
            EndPosition     = data.EndNode.position
            StartLength     = data.Startlength or 0
            StartNode       = data.StartNode
            StartPosition   = StartNode.position
            stepsize        = data.Stepsize
          
            checkrange      = stepsize*stepsize

            ThreatLayer     = data.ThreatLayer
            ThreatWeight    = data.ThreatWeight
            
            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind AIR starts find from "..repr(StartNode[1]).." "..repr(StartPosition).." to "..repr(data.EndNode[1]).." "..repr(EndPosition) )
            end
            
            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = 0
            
            if ThreatWeight < 99999 then
                EndThreat = LOUDMAX( 0, GetThreatBetweenPositions( aiBrain, EndPosition, destination, nil, ThreatLayer )) / LOUDMAX(1,(VDist3( EndPosition, destination )/IMAPRadius ))
            end
            
            -- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
            queue = { { cost = EndThreat, goaldist = 0, length = StartLength, Node = StartNode, path = { StartPosition, }, pathcount = 1, threat = ThreatWeight - EndThreat } }
            
            platoon = data.Platoon
    
            while queue[1] do
                
                pathlist, pathlength, shortcut, pathcost = AStarLoopBody()
        
                if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then

                    aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost, SubmitTime = GetGameTick() }
            
                    if PathFindingDialog then
                        LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." reply submitted on tick "..GetGameTick())
                    end
     
                    break
                end
            end
			
            if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
                
                aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0, SubmitTime = GetGameTick() }
            
                if PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." no safe AIR path found to "..repr(destination))
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." reply submitted on tick "..GetGameTick())
                end

            end
            
        else
            WaitTicks(1)
        end
	end
end			

function PathGeneratorAmphibious(aiBrain)

	local GetThreatBetweenPositions = GetThreatBetweenPositions
    local PlatoonExists             = PlatoonExists

	local LOUDCOPY = LOUDCOPY
    local LOUDEQUAL = LOUDEQUAL
    local LOUDLOG10 = math.log10

	local LOUDREMOVE = table.remove
	local LOUDSORT = LOUDSORT
	local ForkThread = ForkThread
    local type = type

    local VDist2 = VDist2
    local VDist3 = VDist3
    
	local WaitTicks = WaitTicks
	
	-- get the table with all the nodes for this layer
	local graph         = ScenarioInfo.PathGraphs['Amphibious']
    local Rings         = ScenarioInfo.RingSize or 0
	local IMAPRadius    = ScenarioInfo.IMAPSize * .5
    local IMAPSize      = ScenarioInfo.IMAPSize

	local data      = false
    local calctable = {}
	local queue     = {}
	local closed    = {}
    
    local checkrange, destination, fork, stepcostadjust, stepsize, Testpath, threat, ThreatLayer, ThreatLayerCheck
    local EndPosition, EndThreat,  pathcost, pathlength, pathlist, platoon,shortcut, StartLength, StartNode, StartPosition, ThreatWeight 

	local function DestinationBetweenPoints( position, testposition )

        local VDist2 = VDist2
        
		local steps = LOUDFLOOR( VDist2( position[1],position[3], testposition[1],testposition[3] ) / stepsize )
        
        if steps == 0 then
            return false
        end

        local xstep = ( position[1] - testposition[1]) / steps
		local ystep = ( position[3] - testposition[3]) / steps
 
		for i = 1, steps do

            if VDist2( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= (stepsize*.6) then
            
                if ScenarioInfo.PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." found destination "..repr(destination).." on step "..i.." within stepsize "..(stepsize*.6).." range of "..repr({position[1] - (xstep * i), position[3] - (ystep * i)}).." while examining "..repr(testposition) )
                end
     
                return true
            end
		end	
	
		return false
	end
    
	local function AStarLoopBody()

        local GetThreatBetweenPositions = GetThreatBetweenPositions
        local GetThreatAtPosition       = GetThreatAtPosition
        
        local LOUDCOPY = LOUDCOPY
        local LOUDEQUAL = LOUDEQUAL
        local LOUDINSERT = LOUDINSERT
        local LOUDLOG10 = LOUDLOG10
        local LOUDSORT = LOUDSORT
        local VDist3 = VDist3

        local Cost, newnode, Node, Pathcount, position, queueitem, testposition, testpositionlength, Threat	

		queueitem = LOUDREMOVE(queue, 1)
        
        Cost = queueitem.cost
        Node = queueitem.Node
        Pathcount = queueitem.pathcount
		position = Node.position
        Threat = queueitem.threat
	
		if closed[Node[1]] then
			return false, 0, false, 0
		end

		if LOUDEQUAL( position, EndPosition ) then
			return queueitem.path, queueitem.length, false, Cost
		end

		closed[Node[1]] = true
        
		-- loop thru all the nodes which are adjacent to this one and create a fork entry for each adjacent node
		-- adjacentnode data format is nodename, distance to node
		for _, adjacentNode in Node.adjacent do 
        
            newnode = adjacentNode[1]
		
			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)

			if Testpath and DestinationBetweenPoints( position, testposition ) then
            
                queueitem.length = queueitem.length + VDist3(destination, position)
                
				return queueitem.path, queueitem.length, true, Cost
			end

            testpositionlength = LOUDFLOOR(VDist3( position, testposition ))

            -- in the case of amphibious units - we'd like to discount movements thru the water - so either at the point of transition or 
            -- with each water-based point - we'd discount the cost just a bit - AND - we'd change the ThreatLayer.
            ThreatLayerCheck = ThreatLayer
            
            -- right now we're just going to force the threat check to anti-sub - which is great
            -- for SUBMERSIBLE groups - but bad for hovercraft - ideally - we'd let the platoon
            -- pass an alternative threatlayer to be used in this situation - TODO
            if Node.InWater then
                ThreatLayerCheck = 'AntiSub'
            end
            
            threat = 0
            
            if Threat < 99999 then

                threat = LOUDMAX( 0, GetThreatBetweenPositions( aiBrain, position, testposition, true, ThreatLayerCheck ))

                if threat > Threat then
                    continue

                else

                    -- testpositionlength less than the IMAPSize decreases the cost - greater increases it
                    -- the more distance you're covering in an IMAP block - the more dangerous that block can be
                    if not calctable[testpositionlength] then
                        calctable[testpositionlength] = LOUDSQRT( testpositionlength/IMAPSize )
                    end
                    
                    stepcostadjust = calctable[testpositionlength]
                    
                    threat = threat * stepcostadjust
                end

            end
			
			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path) }
            
            stepcostadjust = 25     --- land nodes per step cost
            
            -- make water based movement cheaper
            if Node.InWater then
                stepcostadjust = 1
            end
            
            if threat > 0 then
                stepcostadjust = stepcostadjust + 10
                
                if threat > (Threat*.5) then
                    stepcostadjust = stepcostadjust + 20
                end
            end

            -- each step adds the stepcost
			fork.cost = Cost + threat + stepcostadjust

            -- as we accrue more steps in a path - the value of being closer to the goal diminishes quickly in favor of being safe --
            fork.goaldist = VDist3( destination, testposition ) * ( LOUDLOG10(Pathcount + 1))

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = Pathcount + 1
            
			fork.path[fork.pathcount] = testposition

			fork.threat = Threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)
		
		return false, 0, false, 0
	end

    local PathRequests = aiBrain.PathRequests.Amphibious
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false
    
	while true do
		
		if PathRequests[1] then

			data = LOUDREMOVE(PathRequests, 1)

            destination     = data.Dest
            EndPosition     = data.EndNode.position
            StartLength     = data.Startlength or 0
            StartNode       = data.StartNode
            StartPosition   = StartNode.position
            stepsize        = data.Stepsize

            checkrange      = stepsize * stepsize

            Testpath        = data.Testpath
            ThreatLayer     = data.ThreatLayer
            ThreatWeight    = data.ThreatWeight
            
            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." starts AMPHIB pathfind from "..repr(StartPosition).." to "..repr(EndPosition).." maxthreat is "..repr(ThreatWeight) )
            end

			closed = {}

            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = 0
            
            if ThreatWeight < 99999 then
                EndThreat = GetThreatBetweenPositions( aiBrain, EndPosition, destination, nil, ThreatLayer ) / LOUDMAX(1,(VDist3( EndPosition, destination )/IMAPRadius ))
            end
			
			-- NOTE: We insert the ThreatWeight into the data we carry in the queue now - which will allow us to decrease it with each step we take that has threat
			-- we also no longer need to pass it to the AStar function as it is part of the queue data
			queue = { { cost = EndThreat, goaldist = 0, length = StartLength, Node = StartNode, path = { StartPosition, }, pathcount = 1, threat = ThreatWeight - EndThreat } }
            
            platoon = data.Platoon
    
			while queue[1] do

				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()

				if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
					
					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost, SubmitTime = GetGameTick() }
					break
				end
			end
			
			if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." no safe AMPHIB path found to "..repr(data.Dest))
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0, SubmitTime = GetGameTick() }
			end
		else
            WaitTicks(4)
        end
	end
	
end

function PathGeneratorLand(aiBrain)

    local GetThreatBetweenPositions = GetThreatBetweenPositions
    local PlatoonExists             = PlatoonExists
    
	local LOUDCOPY      = LOUDCOPY
    local LOUDEQUAL     = LOUDEQUAL
	local LOUDREMOVE    = table.remove
	local LOUDSORT      = LOUDSORT
	local ForkThread    = ForkThread
    local type          = type
    local VDist2        = VDist2
	local WaitTicks     = WaitTicks
	
	local dist_comp = aiBrain.dist_comp
    
	local graph         = ScenarioInfo.PathGraphs['Land']
    local Rings         = ScenarioInfo.RingSize or 0
	local IMAPRadius    = ScenarioInfo.IMAPSize * .5
    local IMAPSize      = ScenarioInfo.IMAPSize

	local data      = false
    local calctable = {}
	local queue     = {}
	local closed    = {}
    
    local maxthreat, minthreat
    
    local checkrange, destination, fork, platoon, stepcostadjust, stepsize,  TestPath, testposition, threat, ThreatLayer
    local EndPosition, EndThreat, pathcost, pathlength, pathlist, shortcut, StartNode, StartPosition, ThreatWeight

	local function DestinationBetweenPoints( position, testposition )

        local VDist2Sq = VDist2Sq

        local steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize )

        if steps == 0 then
            return false
        end
       
        local xstep = ( position[1] - testposition[1]) / steps
		local ystep = ( position[3] - testposition[3]) / steps
	
		for i = 1, steps do

			if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= (checkrange*.6) then
				return true
			end
		end	
	
		return false
	end
    
	local function AStarLoopBody()

        local GetThreatAtPosition       = GetThreatAtPosition
        local GetThreatBetweenPositions = GetThreatBetweenPositions

        local LOUDCOPY      = LOUDCOPY
        local LOUDEQUAL     = LOUDEQUAL
        local LOUDINSERT    = LOUDINSERT
        local LOUDSORT      = LOUDSORT
        local VDist3        = VDist3

        local Cost, newnode, Node, Pathcount, position, queueitem, testposition, testpositionlength, Threat	

		queueitem = LOUDREMOVE(queue, 1)

        Cost        = queueitem.cost
        Node        = queueitem.Node
        Pathcount   = queueitem.pathcount
		position    = Node.position
        Threat      = queueitem.threat

		if closed[Node[1]] then
			return false, 0, false, 0
		end
		
		if LOUDEQUAL( position, EndPosition ) or VDist3( destination, position ) <= stepsize then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
	
		closed[Node[1]] = true

		for _, adjacentNode in Node.adjacent do
			
			newnode = adjacentNode[1]

			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)
		
			if Testpath and DestinationBetweenPoints( position, testposition ) then
            
                queueitem.length = queueitem.length + VDist3(destination, position)

				return queueitem.path, queueitem.length, true, queueitem.cost
			end
            
            testpositionlength = LOUDFLOOR(VDist3( position, testposition ))
            
            threat = 0
            
            if Threat < 99999 then
			
                threat = LOUDMAX(0, GetThreatAtPosition( aiBrain, testposition, Rings, true, ThreatLayer ))
			
                if threat > Threat then
                    continue
                end
			
                -- if below min threat - devalue it - tiny threats should not impair pathing
                if threat <= minthreat then
                    threat = threat * 0.7
                
                -- if above max threat - inflate by ratio - really stay away from big threats
                elseif threat > maxthreat then
                    threat = (threat/maxthreat)
                end

                -- adjust threat for the length of the step compared to size of the IMAP block
                if not calctable[testpositionlength] then 
                    calctable[testpositionlength] = LOUDSQRT(testpositionlength/IMAPSize)
                end

                stepcostadjust = calctable[testpositionlength]
                
                threat = threat * stepcostadjust
                
            end

			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path), pathcount = 0 }
            
            stepcostadjust = 5
            
            if threat > 0 then 
                stepcostadjust = stepcostadjust + 10
                
                if threat > (Threat*.5) then
                    stepcostadjust = stepcostadjust + 10
                end
            end

			fork.cost = Cost + threat + stepcostadjust
			
			fork.goaldist = VDist3( destination, testposition )

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = Pathcount + 1
			
			fork.path[fork.pathcount] = testposition

			fork.threat = Threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end		

	local PathRequests = aiBrain.PathRequests.Land
    local PathReplies = aiBrain.PathRequests['Replies']
    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false

	while true do
		
		if PathRequests[1] then
	
			data = LOUDREMOVE(PathRequests, 1)

			closed = {}
            
            destination     = data.Dest
            EndPosition     = data.EndNode.position
            StartNode       = data.StartNode
            StartPosition   = StartNode.position
            stepsize        = data.Stepsize

            checkrange      = stepsize*stepsize

            Testpath        = data.Testpath
            ThreatLayer     = data.ThreatLayer
            ThreatWeight    = data.ThreatWeight
            
            if PathFindingDialog then
                LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." starts LAND pathfind from "..repr(StartPosition).." to "..repr(EndPosition) )
            end
            
            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = 0
            
            if ThreatWeight < 99999 then
                EndThreat = LOUDMAX(0, GetThreatBetweenPositions( aiBrain, EndPosition, destination, nil, ThreatLayer ))
            end
          
			queue = { { cost = EndThreat, goaldist = 0, length = data.Startlength or 0, Node = StartNode, path = { StartPosition, }, pathcount = 1, threat = ThreatWeight - EndThreat } }
            
            platoon = data.Platoon

			while queue[1] do

				-- adjust these multipliers to make pathfinding more or less sensitive to threat
				maxthreat = ThreatWeight * 0.9
				minthreat = ThreatWeight * .3
                
				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()

				if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then

					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost, SubmitTime = GetGameTick() }
					break
				end
				
			end

			if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then            
                    LOG("*AI DEBUG "..aiBrain.Nickname.." PathFind "..repr(platoon.BuilderName or platoon).." "..repr(platoon.BuilderInstance).." no safe LAND path found to "..repr(destination))
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0, SubmitTime = GetGameTick() }
			end
		else
            WaitTicks(3)
        end
	end
	
end

-- this pathgenerator also takes into account casualties along the route
function PathGeneratorWater(aiBrain)

    local PathFindingDialog = ScenarioInfo.PathFindingDialog or false

    local GetThreatBetweenPositions = GetThreatBetweenPositions
    local PlatoonExists             = PlatoonExists
    
	local LOUDCOPY      = LOUDCOPY
    local LOUDEQUAL     = LOUDEQUAL
	local LOUDREMOVE    = table.remove
	local LOUDSORT      = LOUDSORT
	local ForkThread    = ForkThread
    local type          = type
    local VDist2        = VDist2
	local WaitTicks     = WaitTicks
	
	local dist_comp = aiBrain.dist_comp
    
	local graph         = ScenarioInfo.PathGraphs['Water']
    local Rings         = ScenarioInfo.RingSize or 0
	local IMAPRadius    = ScenarioInfo.IMAPSize * .5
    local IMAPSize      = ScenarioInfo.IMAPSize

	local data      = false
    local calctable = {}
	local queue     = {}
	local closed    = {}
    
    local maxthreat, minthreat
    
    local checkrange, destination, fork, platoon, stepcostadjust, stepsize,  TestPath, testposition, threat, ThreatLayer
    local EndPosition, EndThreat, pathcost, pathlength, pathlist, shortcut, StartNode, StartPosition, ThreatWeight

	local function DestinationBetweenPoints(position,testposition)

        local VDist2Sq = VDist2Sq

		local steps = LOUDFLOOR( VDist2( position[1], position[3], testposition[1], testposition[3]) / stepsize )
        
        if steps == 0 then
            return false
        end

		local xstep = ( position[1] - testposition[1]) / steps
		local ystep = ( position[3] - testposition[3]) / steps
	
		for i = 1, steps do

			if VDist2Sq( position[1] - (xstep * i), position[3] - (ystep * i), destination[1], destination[3]) <= (checkrange*.6) then
				return true
			end
		end	
	
		return false
	end
    
	local function AStarLoopBody()

        local GetThreatAtPosition       = GetThreatAtPosition
        local GetThreatBetweenPositions = GetThreatBetweenPositions

        local LOUDCOPY      = LOUDCOPY
        local LOUDEQUAL     = LOUDEQUAL
        local LOUDINSERT    = LOUDINSERT
        local LOUDSORT      = LOUDSORT
        local VDist3        = VDist3

        local Cost, newnode, Node, Pathcount, position, queueitem, testposition, testpositionlength, Threat	

		queueitem = LOUDREMOVE(queue, 1)

        Cost        = queueitem.cost
        Node        = queueitem.Node
        Pathcount   = queueitem.pathcount
		position    = Node.position
        Threat      = queueitem.threat

		if closed[Node[1]] then
			return false, 0, false, 0
		end
		
		if LOUDEQUAL( position, EndPosition ) or VDist3( destination, position ) <= stepsize then
			return queueitem.path, queueitem.length, false, queueitem.cost
		end
	
		closed[Node[1]] = true

		for _, adjacentNode in Node.adjacent do
			
			newnode = adjacentNode[1]

			if closed[newnode] then
				continue
			end

			testposition = LOUDCOPY(graph[newnode].position)
		
			if Testpath and DestinationBetweenPoints( position, testposition ) then
            
                queueitem.length = queueitem.length + VDist3(destination, position)

				return queueitem.path, queueitem.length, true, queueitem.cost
			end
            
            testpositionlength = LOUDFLOOR(VDist3( position, testposition ))
            
            threat = 0
            
            if Threat < 99999 then
			
                threat = LOUDMAX(0, GetThreatAtPosition( aiBrain, testposition, Rings, true, ThreatLayer ))
			
                if threat > Threat then
                    continue
                end
			
                -- if below min threat - devalue it - tiny threats should not impair pathing
                if threat <= minthreat then
                    threat = threat * 0.7
                
                -- if above max threat - inflate by ratio - really stay away from big threats
                elseif threat > maxthreat then
                    threat = (threat/maxthreat)
                end

                -- adjust threat for the length of the step compared to size of the IMAP block
                if not calctable[testpositionlength] then 
                    calctable[testpositionlength] = LOUDSQRT(testpositionlength/IMAPSize)
                end

                stepcostadjust = calctable[testpositionlength]
                
                threat = threat * stepcostadjust
                
            end

			fork = { cost = 0, goaldist = 0, length = 0, Node = graph[newnode], path = LOUDCOPY(queueitem.path), pathcount = 0 }
            
            stepcostadjust = 5
            
            if threat > 0 then 
                stepcostadjust = stepcostadjust + 10
                
                if threat > (Threat*.5) then
                    stepcostadjust = stepcostadjust + 10
                end
            end

			fork.cost = Cost + threat + stepcostadjust
			
			fork.goaldist = VDist3( destination, testposition )

			fork.length = queueitem.length + adjacentNode[2]

			fork.pathcount = Pathcount + 1
			
			fork.path[fork.pathcount] = testposition

			fork.threat = Threat - threat

			LOUDINSERT(queue,fork)
		end

		LOUDSORT(queue, function(a,b) return (a.cost + a.goaldist) < (b.cost + b.goaldist) end)

		return false, 0, false, 0
	end		

    local PathRequests = aiBrain.PathRequests.Water
	local PathReplies = aiBrain.PathRequests['Replies']
    
    local dialog = "*AI DEBUG "..aiBrain.Nickname.." PathGen WATER "

	while true do
		
		if PathRequests[1] then
		
			data = LOUDREMOVE(PathRequests, 1)
            
            if PathFindingDialog then
                LOG( dialog..repr(platoon.BuilderName or platoon).." processing request "..repr(data).." on tick "..GetGameTick())
            end
            
			closed = {}
            
            destination     = data.Dest
            EndPosition     = data.EndNode.position
            StartNode       = data.StartNode
            StartPosition   = StartNode.position
            stepsize        = data.Stepsize

            checkrange      = stepsize*stepsize

            Testpath        = data.Testpath
            ThreatLayer     = data.ThreatLayer
            ThreatWeight    = data.ThreatWeight
            
            if PathFindingDialog then
                LOG( dialog.."starts find from "..repr(StartNode[1]).." to "..repr(EndPosition).." on tick "..GetGameTick() )
            end
            
            -- we must take into account the threat between the EndNode and the destination - they are rarely the same point
            -- we add this threat to the cost value to start with since the final step is just added to the path after the
            -- path has been decided
            EndThreat = 0
            
            if ThreatWeight < 99999 then
                EndThreat = LOUDMAX( 0, GetThreatBetweenPositions( aiBrain, EndPosition, destination, nil, ThreatLayer )) / LOUDMAX(1,(VDist3( EndPosition, destination )/IMAPRadius ))
            end
  
			queue = { {cost = EndThreat, goaldist = 0, length = data.Startlength or 0, Node = StartNode, path = { StartPosition, }, pathcount = 1, threat = ThreatWeight } }
            
            platoon = data.Platoon

			while queue[1] do
            
                if PathFindingDialog then
                    LOG( dialog..repr(platoon.BuilderName or platoon).." processing queue on tick "..GetGameTick())
                end

				-- adjust these multipliers to make pathfinding more or less sensitive to threat
				maxthreat = ThreatWeight * 0.9
				minthreat = ThreatWeight * .3

				pathlist, pathlength, shortcut, pathcost = AStarLoopBody()

				if pathlist and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then

					aiBrain.PathRequests['Replies'][platoon] = { length = pathlength, path = LOUDCOPY(pathlist), cost = pathcost, SubmitTime = GetGameTick() }
					break
				end

			end

			if (not PathReplies[platoon]) and (type(platoon) == 'string' or PlatoonExists(aiBrain, platoon)) then
            
                if PathFindingDialog then            
                    LOG( dialog..repr(platoon.BuilderName or platoon).." no safe WATER path found to "..repr(destination).." on tick "..GetGameTick())
                end
                
				aiBrain.PathRequests['Replies'][platoon] = { length = 0, path = 'NoPath', cost = 0, SubmitTime = GetGameTick() }
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

	local IsEnemy = IsEnemy

	local LOUDFLOOR     = LOUDFLOOR
	local LOUDGETN      = LOUDGETN
	local LOUDINSERT    = LOUDINSERT
	local LOUDMIN       = math.min
	local LOUDMOD       = LOUDMOD
	local LOUDSORT      = LOUDSORT
	local LOUDV2        = VDist2
	local VD2           = VDist2Sq
	local WaitTicks     = WaitTicks

    local ASSIGN                    = AssignThreatAtPosition
	local EntityCategoryFilterDown  = EntityCategoryFilterDown
	local GetListOfUnits            = GetListOfUnits
	local GetPosition               = GetPosition
	local GetThreatsAroundPosition  = GetThreatsAroundPosition
	local GETTHREATATPOSITION       = GetThreatAtPosition
	local GetUnitsAroundPoint       = GetUnitsAroundPoint
    
    local IsIdleState = IsIdleState
  
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

    if ScenarioInfo.MaxMapDimension <= 512 then

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
    local unitgetrange = IMAPRadius/ThresholdMult

	-- save the current resolution globally - it will be used by other routines to follow moving intel targets
	ScenarioInfo.IMAPRadius = IMAPRadius
    ScenarioInfo.IMAPBlocks = Rings
    
    ScenarioInfo.ThreatTypes = {}

	
    -- when turned on - this function will highlight the IMAP block 
    -- being checked by the loop when there is some threat in it
	local function DrawRectangle(aiBrain, threatblock, color)

		if aiBrain.ArmyIndex == GetFocusArmy() then
        
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
            
                for y = 4, LOUDFLOOR(IMAPRadius/ThresholdMult), 8 do
                
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
		
        Naval,					-- reports ALL threat values but only of actual NAVAL units and AMPHIB units in the water
        Air,					-- reports ALL threat values but only of actual AIR units			
        Land,					-- reports ALL threat values but only of actual LAND units and AMPHIB units on the land
		
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
		-- ThreatType	= { threat min, timeout (-1 = never) in seconds, category for exact pos, parse every x iterations }
		-- note that some categories dont have a dynamic threat threshold - just air,land,naval and structures - since you can only pack so many in a smaller IMAP block
        
		Air 			    = { 15 * ThresholdMult, 4.5, categories.AIR - categories.SATELLITE - categories.SCOUT - categories.TRANSPORTFOCUS, 1 },
        AntiAir             = { 20 * ThresholdMult, 22.5, categories.ANTIAIR - categories.AIR, 5 },
        AntiSub             = { 8 * ThresholdMult, 26, categories.ALLUNITS - categories.WALL, 3 },
		Commander 	    	= { 50, 67.5, categories.COMMAND, 13 },
		Economy	    		= { 50, 33.8, categories.ECONOMIC + categories.FACTORY, 7 },
		Land 			    = { 8 * ThresholdMult, 13.5, categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT, 3 },
		Naval 		    	= { 8 * ThresholdMult, 9, categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT, 2 },
		StructuresNotMex    = { 100, 67.5, categories.STRUCTURE - categories.WALL - categories.ECONOMIC - categories.ANTIAIR, 11 },
        
		--Experimental  	= { 50, 26, (categories.EXPERIMENTAL * categories.MOBILE), 4,'ff00fec3', false },        
        --AntiSurface       = { 20 * ThresholdMult, 26, categories.STRUCTURE - categories.WALL, 4, 'ffaf00ff', true},
		--Artillery 	    = { 60, 52, (categories.ARTILLERY * categories.STRUCTURE - categories.TECH1) + (categories.EXPERIMENTAL * categories.ARTILLERY), 5,'60ffff00', false },
	}


    -- Create EnemyData array - stores history of totalthreat by threattype over a period of time
	-- History value controls how much history is kept 
	aiBrain.EnemyData = { ['History'] = 100 }		

	-- create a record for each type of intel & initialize the running total element & the counter that tracks which element is current for this type
    for threatType, v in intelChecks do
        aiBrain.EnemyData[threatType] = { ['Count'] = 0, ['Total'] = 0}

        if not ScenarioInfo.ThreatTypes[threatType] then

            local __INTEL_CHECKS = {
                'Air',
                'AntiAir',
                'Commander',
                'Economy',
                'Land',
                'Naval',
                'StructuresNotMex',
            }
    
            local __INTEL_CHECKS_COLORS = {
                'ff76bdff',
                'e0ff0000',
                '90ffffff',
                '90ff7000',
                '9000ff00',
                'ff0060ff',
                '90ffff00',
            }
    
            local counter = 1
    
            for _,v in __INTEL_CHECKS do
                ScenarioInfo.ThreatTypes[v] = { Active = true, Color = __INTEL_CHECKS_COLORS[counter] }
                counter = counter + 1
            end
            
        end
	end

    -- take the whole array local 
    local EnemyData = aiBrain.EnemyData
    local EnemyDataCount
    local EnemyDataHistory = EnemyData.History

	local checkspertick = 1		-- number of threat entries to be processed per tick - this really affects game performance if moved up

    -- the current iteration value
    local iterationcount = LOUDFLOOR( Random() * 14) -- each AI can start on a different iteration - to prevent concentrated load 
    local iterationmax = 15         -- the number of iterations we'll make in a complete cycle
	
    -- this rate is important since it must be able to keep up with the shift in fast moving air units -- this is the primary performance value -
	local parseinterval = 58    -- the rate of a single iteration in ticks - every 5.7 seconds (relative to the IMAP update cycle which is 3 seconds)
    
    local threatcount
    
    if ScenarioInfo.Options.FogOfWar == 'none' then
        parseinterval = parseinterval + 30      -- when FOW is turned off, we'll add 50% to the amount of time a cycle will take (8.7 seconds)
    end

	-- this moves all the local creation up front so NO locals need to be declared in the primary loop
	local bp, counter, dupe, gametime, newthreat, newtime, oldthreat, threatamounttrigger, threatcategories, threatreport, threats, totalThreat, totalThreatAir, totalThreatSurface
	local DisplayIntelPoints, IntelDialog, LastUpdate, numchecks, Permanent, Position, rebuild, ReportRatios, Threat, Type, units, usedticks, x1,x2,x3
    local aircount, airidle, landcount, landidle, navcount, navidle, myaircount, myairidle, mylandcount, mylandidle, mynavalcount, mynavalidle
    
    local airtot = 0
    local landtot = 0
    local navaltot = 0
    local myairtot = 0
    local mylandtot = 0
    local mynavaltot = 0
    local grandairtot = 0
    local grandlandtot = 0
    local grandnavaltot = 0
   
	local ALLBPS = __blueprints
    local BRAINS = ArmyBrains
    
    local newPos = { 0,0,0 }

    local AIR       = categories.AIR
    local LAND      = categories.LAND
    local NAVAL     = categories.NAVAL
    
    local AIRUNITS  = (AIR * categories.MOBILE) - categories.TRANSPORTFOCUS - categories.SATELLITE - categories.SCOUT + categories.uea0203
    local LANDUNITS = (LAND * categories.MOBILE) - categories.ANTIAIR - categories.ENGINEER - categories.SCOUT
    local NAVALUNITS = NAVALMOBILE + NAVALFAC + (NAVAL * categories.DEFENSE)
    local TECH1     = categories.TECH1
    local TECH2     = categories.TECH2
    local TECH3     = categories.TECH3

	WaitTicks( LOUDFLOOR(Random() * 25 + 1))	-- to avoid all the AI running at exactly the same tick

	-- the location of the MAIN base for this AI
	local HomePosition      = aiBrain.BuilderManagers.MAIN.Position
    local MyArmyIndex       = aiBrain.ArmyIndex
    local NumOpponents      = aiBrain.NumOpponents
    local OutnumberedFactor = LOUDSQRT(aiBrain.OutnumberedRatio)
  
	-- in a perfect world we would check all 8 threat types every parseinterval 
	-- however, only AIR will be checked every cycle -- the others will be checked every other cycle or on the 3rd or 4th
    while true do

		numchecks = 0
		usedticks = 0
        
        DisplayIntelPoints  = ScenarioInfo.DisplayIntelPoints or false   -- we put these in the loop so we can toggle them on/off in the game
        IntelDialog         = ScenarioInfo.IntelDialog or false
        local dialog = "*AI DEBUG "..aiBrain.Nickname.." PARSEINTEL"

        ReportRatios        = ScenarioInfo.ReportRatios or false

		-- advance the iteration count -- used to process certain intel types at a different frequency than others
        iterationcount = iterationcount + 1

        -- roll the iteration count back to one if it exceeds the maximum number of iterations
        if iterationcount > iterationmax then

            -- Draw HiPri intel data on map - for visual aid - not required but useful for debugging threat assessment
            if DisplayIntelPoints and not aiBrain.IntelDebugThread then
                
                LOG( dialog.." begins")

                aiBrain.IntelDebugThread = aiBrain:ForkThread( DrawIntel, parseinterval )

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

		if IntelDialog then
            LOG( dialog.." begins iteration "..repr(iterationcount).." on tick "..GetGameTick() )
        end
	
		-- loop thru each of the threattypes
		-- processing only those types marked for this iteration
		for ThreatTypeName, vx in intelChecks do

            threatamounttrigger = vx[1]
            threatcategories = vx[3]

			if LOUDMOD(iterationcount, vx[4]) == 0 then

				totalThreat = 0

				-- advance sample count for this type of threat
				EnemyDataCount = EnemyData[ThreatTypeName]['Count'] + 1
			
				-- roll it back to one when the sample counter exceeds the number of samples we are keeping
				if EnemyDataCount > EnemyDataHistory then
					EnemyDataCount = 1
				end
			
				EnemyData[ThreatTypeName]['Count'] = EnemyDataCount

                -- get all threats of this type from the IMAP -- table format is as follows:  posx, posy, threatamount
				-- A note here - when you ask for 'Air' threat - you'll get ALL the threats that Air units can create for example
				-- 12 bombers have zero anti-air threat but they'll still generate threat because they threaten surface targets
				-- but to be clear 'Land' = Land Mobile units and does not include Land Structures
                -- another quirk - when land units transition onto/into the water - they begin showing up as 'Naval' threats
                -- so far, this is the only type of unit which does this
                -- also Artillery does not seem to register at all - that I can see.
                threats = GetThreatsAroundPosition( aiBrain, HomePosition, 32, true, ThreatTypeName)
			
                gametime = LOUDFLOOR(GetGameTimeSeconds())
                
                threatcount = 0
				
				if IntelDialog then

                    if threats[1] then
                        LOG( dialog.." "..ThreatTypeName.." gets "..LOUDGETN(threats).." results on tick "..GetGameTick())
                    end
				end
                
                threatcount = 0
	
                -- examine each threat and add those that are high enough to the InterestList if enemy units are found at that location
                -- but regardless - we add any threat amount to the total - even those we might ignore
                for _,threat in threats do
                
                    threatcount = threatcount + 1
                
                    threatreport = threat[3]

                    -- add up the threat from each IMAP position - we'll use this as history even if it doesn't result in a InterestList entry
                    totalThreat = totalThreat + threatreport

                    -- draw IMAP block if there is any threat and that threat is turned on in the DEBUG panel --
                    if DisplayIntelPoints and ScenarioInfo.ThreatTypes[ThreatTypeName].Active and threatreport > 2 then
                    
						aiBrain:ForkThread( DrawRectangle, threat, ScenarioInfo.ThreatTypes[ThreatTypeName].Color )

					end                                        

                    -- only check threats above minimumcheck otherwise break as rest will be below that
                    if threatreport > threatamounttrigger then
					
						if IntelDialog then
							LOG( dialog.." "..ThreatTypeName.." processing result "..threatcount.." of "..repr(threatreport).." at "..repr( {threat[1],0,threat[2]} ).." on tick "..GetGameTick())
						end
	
                        -- count the number of checks we've done and insert a wait to keep this routine from hogging the CPU 
                        numchecks = numchecks + 1

                        if numchecks > checkspertick then

                            if IntelDialog then
                                LOG( dialog.." "..ThreatTypeName.." delays for 2 ticks on tick "..GetGameTick() )
                            end
                        
                            WaitTicks(2)
							usedticks = usedticks + 1
                            numchecks = 0
                        end

						-- HERE IS THE BREAK POINT WHERE WE WOULD START A LOOP TO CHECK MULTIPLE BOXES FOR AN IMAP BOX LARGER THAN 64 OGRIDS
						-- using the syntax below, the threat[1] and threatreport values would be offsets of the actual IMAP box -- ie. quadrants
						-- each quadrant could therefore have a much greater degree of detail than the IMAP itself would describe
						-- at the moment, the threat values are coming right off of the IMAP position - so they would have to be copied and
						-- used as two other values that would then be looped to cycle their values
					
                        -- collect all the enemy units within that IMAP block
                    
						-- just NOTE - this will report ALL units - even those you don't see
						units, counter = GetEnemyUnitsInRect( aiBrain, threat[1]-IMAPRadius, threat[2]-IMAPRadius, threat[1]+IMAPRadius, threat[2]+IMAPRadius)
						
						-- these accumulate the position values
                        x1 = 0
                        x2 = 0
                        x3 = 0
					
                        if units then
                        
                            counter = 0

                            -- loop thru only those that match the category filter
                            for _,v in EntityCategoryFilterDown( threatcategories, units ) do

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

							dupe = false
                            newthreat = 0
                            oldthreat = 0

                            newPos[1] = threat[1]
                            newPos[2] = 0
                            newPos[3] = threat[2]
 
                            if counter > 0 then

                                -- divide the position values by the counter to get average position (gives you the heart of the real cluster)
                                newPos[1] = LOUDFLOOR(x1/counter)
                                newPos[2] = LOUDFLOOR(x2/counter)
                                newPos[3] = LOUDFLOOR(x3/counter)
   
                                if IntelDialog then
                                    LOG( dialog.." "..ThreatTypeName.." finds "..counter.." units at avg. Position "..repr(newPos).." on tick "..GetGameTick())
                                end
	
                                if DisplayIntelPoints and ScenarioInfo.ThreatTypes[ThreatTypeName].Active then
                                    ForkThread( DrawCirc, aiBrain, LOUDCOPY(newPos), ScenarioInfo.ThreatTypes[ThreatTypeName].Color )
                                end
                                
                            else

                                if IntelDialog then
                                    LOG( dialog.." "..ThreatTypeName.." found NO units at "..repr(newPos).." on tick "..GetGameTick() )
                                end
                            
                            end

                            -- get the current threat at this position - we have to use 'Rings' here
                            newthreat = LOUDFLOOR(LOUDMAX( 0, GETTHREATATPOSITION( aiBrain, newPos, Rings, true, ThreatTypeName )))
                            
                            if IntelDialog then
                                LOG( dialog.." "..ThreatTypeName.." gets IMAP threat from "..repr(newPos).." of "..newthreat.." using "..Rings.." rings on tick "..GetGameTick() )
                            end

                            -- total up the ring values just to verify that total matches 
                            for _,v in GetThreatsAroundPosition( aiBrain, newPos, Rings, true, ThreatTypeName) do
                                oldthreat = oldthreat + v[3]
                            end
                            
                            oldthreat = LOUDFLOOR(oldthreat)
                            
                            if IntelDialog then
                                if newthreat != oldthreat then
                                    WARN( dialog.." "..ThreatTypeName.." IMAP threat of "..newthreat.." modifier "..repr(ThresholdMult).." using "..Rings.." rings NO MATCH old is "..repr(oldthreat).." there are "..counter.." units involved")
                                end
                            end
                            
                            -- modify block threat with ThresholdMult (based on IMAP block size) 
                            newthreat = newthreat/ThresholdMult
                            
                            if IntelDialog then
                                LOG( dialog.." "..ThreatTypeName.." results in threat of "..newthreat.." modifier "..repr(ThresholdMult).." on tick "..GetGameTick() )
                            end
                            
                            -- if the IMAP threat is less than half of the reported threat at that position reduce IMAP by 50%
							if newthreat < (threatreport * .5) and GetGameTick() > 5400 then
                            
								if IntelDialog then
									LOG( dialog.." "..ThreatTypeName.." reports "..newthreat.." versus "..threatreport.." from IMAP - assigning 50% reduction")
								end
 
                                -- reduce the existing threat by 50% with a 5% decay - IMAP refreshes every 3 seconds 
                                ASSIGN( aiBrain, {threat[1],0,threat[2]}, threatreport * -0.5, 0.05, ThreatTypeName)

                                threatreport = threatreport * .5
                            end

                            -- NOTE: This command will only get those units that are detected --
                            units = GetUnitsAroundPoint( aiBrain, threatcategories, newPos, unitgetrange, 'Enemy')
						
                            -- and if we don't see anything - reduce it by 20%
                            if (not units[1]) and GetGameTick() > 5400 then
                            
                                if IntelDialog then
                                    LOG( dialog.." "..ThreatTypeName.." shows "..threatreport.." but I SEE no units - assigning 20% reduction")
                                end
 
                                -- reduce the existing threat by 50% with a 5% decay - IMAP refreshes every 3 seconds 
                                ASSIGN( aiBrain, {threat[1],0,threat[2]}, threatreport * -0.2, 0.05, ThreatTypeName)                                        
 
                                threatreport = threatreport * .8
                            end

                            -- if the values don't match - write the new value
                            if newthreat < threatreport then
                            
                                if IntelDialog then
                                    LOG( dialog.." "..ThreatTypeName.." updated result "..threatcount.." at "..repr({threat[1],0,threat[2]}).." to "..threatreport.." on tick "..GetGameTick() )
                                end

                                newthreat = threatreport
                            end

							newtime = LOUDFLOOR(gametime)

                            -- traverse the existing list until you find an entry within merge distance
							-- we'll update ALL entries that are within the merge distance meaning we may get duplicates
							-- umm...could I sort HiPri here for distance from newPos ? 
							-- then I could bypass all other HiPri entries
                            for k,loc in aiBrain.IL.HiPri do
                            
                                Type = loc.Type
                            
								-- it's got to be of the same type
                                if Type == ThreatTypeName then
                                
                                    LastUpdate  = loc.LastUpdate
                                    Permanent   = loc.Permanent
                                    Position    = loc.Position
                                    Threat      = loc.Threat

									-- and within the merge distance
									if LOUDV2( newPos[1],newPos[3], Position[1],Position[3] ) <= mergeradius then
									
										if dupe then
										
											if IntelDialog then
												LOG( dialog.." "..ThreatTypeName.." Killing Duplicate at "..repr(Position) )
											end
										
											aiBrain.IL.HiPri[k] = nil
                                            rebuild = true
											
											continue
										end
									
										-- it might be a duplicate
										dupe = true
										
										if newthreat > threatamounttrigger then
                                        
                                            if Threat != newthreat or (Position[1] != newPos[1] or Position[3] != newPos[3]) then
										
                                                if IntelDialog then
                                                    LOG( dialog.." "..ThreatTypeName.." Updating Existing HiPri threat of "..repr(Threat).." to "..repr(newthreat).." from "..repr(Position).." to "..repr(newPos) )
                                                end
										
                                                -- so update the existing entry
                                                loc.Threat = newthreat
								
                                                loc.Position[1] = newPos[1]
                                                loc.Position[2] = newPos[2]
                                                loc.Position[3] = newPos[3]
                                            end
										
                                            if LastUpdate < newtime then
                                                loc.LastUpdate = newtime
                                            end
		
										end
                                    
                                    end
                                    
                                    if Threat <= threatamounttrigger and not Permanent then
                                        
										if IntelDialog then
                                            LOG( dialog.." PARSEINTEL data is "..repr(loc))
											LOG( dialog.." "..ThreatTypeName.." Removing Existing HiPri threat of "..repr(Threat).." too low at "..repr(Position))
										end

										-- newthreat is too low 
										aiBrain.IL.HiPri[k] = nil
                                        rebuild = true
									end
                                    
                                end
                                
                            end
						
                            -- if not a duplicate and it passes the threat threshold we'll add it - otherwise we ignore it
                            if (not dupe) and newthreat > threatamounttrigger then
							
								if IntelDialog then
									LOG( dialog.." "..ThreatTypeName.." Inserting new HiPri threat of "..newthreat.." at "..repr(newPos))
								end

                                LOUDINSERT(aiBrain.IL.HiPri, { Position = { newPos[1],newPos[2],newPos[3] }, Type = ThreatTypeName, Threat = newthreat, LastUpdate = newtime, LastScouted = newtime } )
							end
                            
						else

							if IntelDialog then
								LOG( dialog.." "..ThreatTypeName.." reduce Existing HiPri threat "..repr(threatreport).." to "..repr(threatreport * -0.75).." at "..repr(threat) )
							end

                            -- reduce the existing threat by 75% with a 5% decay - IMAP refreshes every 3 seconds
                            ASSIGN( aiBrain, {threat[1],0,threat[2]}, threatreport * -0.75, 0.05, ThreatTypeName)                                       
   
                            -- remove or reduce HiPri targets in range --
                            for k,loc in aiBrain.IL.HiPri do
                            
                                Permanent   = loc.Permanent
                                Position    = loc.Position
                                Threat      = loc.Threat
                                Type        = loc.Type
                            
                                if Type == ThreatTypeName then
                                
                                    if LOUDV2( threat[1],threat[2], Position[1],Position[3] ) <= IMAPRadius then
                                    
                                        if IntelDialog then
                                            LOG( dialog.." altering "..Type.." HiPri entry at "..repr(Position).." for no units found" )	
                                        end
                                    
                                        if not Permanent then
                                            rebuild = true
                                            aiBrain.IL.HiPri[k] = nil
                                        else
                                            loc.Threat = Threat * .5
                                        end

                                    end
                                    
                                end
                                
                            end
                 
                        end
                        
                        if rebuild then

							if IntelDialog then
								LOG( dialog.." rebuilding HiPri table on tick "..GetGameTick() )
							end
                        
                            aiBrain.IL.HiPri = aiBrain:RebuildTable(aiBrain.IL.HiPri)
                            rebuild = false
                        end

					else
					
						if IntelDialog then
							LOG( dialog.." "..ThreatTypeName.." result "..threatcount.." of "..repr(LOUDFLOOR(threatreport)).." ignored on tick "..GetGameTick())
						end

                    end
                    
                    WaitTicks(3)
                    
                    usedticks = usedticks + 2
                    
                end

				-- Update the EnemyData Array for this threattype -- Array element 'Total' carries a running total
                -- update the array using the current sample counter -- first remove what is there from total
				-- then update the current counter -- then add the current counter to the total
				EnemyData[ThreatTypeName]['Total'] = EnemyData[ThreatTypeName]['Total'] - (EnemyData[ThreatTypeName][EnemyDataCount] or 0)
                EnemyData[ThreatTypeName][EnemyDataCount] = totalThreat
				EnemyData[ThreatTypeName]['Total'] = EnemyData[ThreatTypeName]['Total'] + totalThreat

                -- purge outdated, non-permanent intel if past the timeout period or below the threat threshold
                for s, t in aiBrain.IL.HiPri do
                
                    LastUpdate  = t.LastUpdate
                    Permanent   = t.Permanent
                    Threat      = t.Threat
                    Type        = t.Type
                    
                    -- if this type of threat has a timeout value
                    if ThreatTypeName == Type and intelChecks[Type][2] > 0 then

                        -- if the lastupdate was more than the timeout period or threat is less than the threshold
                        if ( (LastUpdate + intelChecks[Type][2] < gametime) or (Threat <= intelChecks[Type][1]) ) then

                            if IntelDialog then
                            
                                if LastUpdate + intelChecks[Type][2] < gametime then
                                    if not Permanent then
                                        LOG( dialog.." Removing Existing HiPri "..Type.." at "..repr(t.Position).." due to timeout")
                                    end
                                else
                                    if not Permanent then
                                        LOG( dialog.." Removing Existing HiPri "..Type.." at "..repr(t.Position).." threat too low at "..repr(t.Threat))
                                    end
                                end
                                
                            end

                            if (not Permanent) then
                                -- clear the item
                                aiBrain.IL.HiPri[s] = nil
                                rebuild = true
                            else
                                -- reduce the threat by 50%
                                t.Threat = Threat * .5
                            end

                        end
                        
                    end
                    
                end
                
                if rebuild then

                    if IntelDialog then
						LOG( dialog.." rebuilding HiPri table (after purge) on tick "..GetGameTick() )
					end

                    aiBrain.IL.HiPri = aiBrain:RebuildTable(aiBrain.IL.HiPri)
                    rebuild = false
                end
                
                WaitTicks(2)    -- again - we lose the first tick
                
                usedticks = usedticks + 1
            end
            
		end

		if IntelDialog then
			LOG( dialog.." resorting HiPri table on tick "..GetGameTick() )
		end

		-- sort it by distance from MAIN -- HOLD IT A SECOND - I know how important MAIN is - but what if we used PRIMARYATTACKBASE ?
		-- that would shift the HiPri table in a big way !  It would but it might impact a lot of other things like protecting the MAIN position
		LOUDSORT(aiBrain.IL.HiPri, function(a,b)

            local VD2 = VD2 
		
			if a.LastScouted == b.LastScouted then
				return VD2(HomePosition[1], HomePosition[3], a.Position[1], a.Position[3]) < VD2(HomePosition[1], HomePosition[3], b.Position[1], b.Position[3])
			else
				return a.LastScouted < b.LastScouted
			end
			
		end)
        
		
		if IntelDialog then
			--LOG( dialog.." HiPri list is "..repr(aiBrain.IL.HiPri))	
		end

		if parseinterval - usedticks >= 10 then
		
			if IntelDialog then
				LOG( dialog.." On Wait for ".. parseinterval - usedticks .. " ticks on tick "..GetGameTick() )	
			end
			
			WaitTicks((parseinterval+1) - usedticks)

			if parseinterval - usedticks > 36 then
			
				if checkspertick > 1 then
					checkspertick = checkspertick - 1
				end
			end
            
		else
        
			if checkspertick < 15 then
            
				checkspertick = checkspertick + 3

			else
            
                checkspertick = checkspertick + 1
                
            end
            
		end

		-- recalc the strength ratios every 5 cycles 
        -- strength ratio is (myvalue versus enemyvalue)
		-- syntax is --  Brain, Category, IsIdle, IncludeBeingBuilt
        if LOUDMOD(iterationcount,5) == 0 then
        
            if IntelDialog then
                LOG( dialog.." Recalc AIR Strength Ratios on tick "..GetGameTick())
            end
        
            --- AIR UNITS ---
            -----------------
            totalThreat = 0
            totalThreatAir = 0
            totalThreatSurface = 0

            oldthreat = 0

            if EnemyData['Air']['Total'] > 0 or airtot > 0 then

                for v, brain in BRAINS do

                    if IsEnemy( MyArmyIndex, v ) then

                        -- don't include civilians
                        if brain.Nickname != 'civilian' then

                            units = GetListOfUnits( brain, AIRUNITS, false, true)

                            for _,v in units do

                                bp = ALLBPS[v.BlueprintID].Defense

                                totalThreatAir      = totalThreatAir + bp.AirThreatLevel
                                totalThreatSurface  = totalThreatSurface + bp.SurfaceThreatLevel

                                oldthreat = oldthreat + bp.AirThreatLevel + bp.SurfaceThreatLevel
                            end

                        end

                    end

                    -- my strength
                    if MyArmyIndex == v then

                        units = GetListOfUnits( brain, AIRUNITS, false, true)

                        for _,v in units do

                            bp = ALLBPS[v.BlueprintID].Defense

                            -- note how the A2G value of my air units is discounted quite a bit
                            totalThreat = totalThreat + bp.AirThreatLevel + (bp.SurfaceThreatLevel * .35)
                        end

                    end

                end


                if oldthreat > 0 then
                    -- the relationship of A2A and A2G in the enemy threat
                    -- higher values signify a greater composition of bombers/gunships, low values mean it's mostly A2A
                    -- a value of 1 indicates a fairly even split in firepower (not necessarily units)
                    aiBrain.AirBias = LOUDMIN( 2, LOUDMAX( 0.02, (totalThreatSurface/totalThreatAir) ) )
                    
                    -- multiply my strength by size of my team
                    totalThreat = totalThreat * aiBrain.TeamSize

                    aiBrain.AirRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)
                    
                    -- inflate the Air Ratio by the root of the Outnumbered Ratio
                    aiBrain.AirRatio = aiBrain.AirRatio * OutnumberedFactor
                    
                    -- if enemy air strength is comprised dominantly of surface threat
                    -- let it upvalue our air ratio to encourage more aggressive air actions
                    if aiBrain.AirBias > 1 and aiBrain.AirRatio > 1 then
                        aiBrain.AirRatio = aiBrain.AirRatio + (aiBrain.AirBias/2)
                    end
                    
                else
                
                    if aiBrain.CycleTime < 600 then
                    
                        aiBrain.AirRatio = .011
                        aiBrain.AirBias = 1
                        
                    else
                    
                        aiBrain.AirRatio = 10
                        aiBrain.AirBias = 1
                    end
                end
                
            else
                if aiBrain.CycleTime < 600 then
                    
                    aiBrain.AirRatio = 0.01
                    aiBrain.AirBias = 1
                    
                else
                
                    aiBrain.AirRatio = 10
                    aiBrain.AirBias = 1
                end
            end

            --- LAND UNITS ---
            ------------------
            totalThreat = 0
            oldthreat = 0
        
            if IntelDialog then
                LOG( dialog.." Recalc LAND Strength Ratios on tick "..GetGameTick())
            end

            if EnemyData['Land']['Total'] > 0 then

                for v, brain in BRAINS do
            
                    if IsEnemy( MyArmyIndex, v ) then

                        if brain.Nickname != 'civilian' then

                            units = GetListOfUnits( brain, LANDUNITS, false, true)

                            for _,v in units do

                                bp = ALLBPS[v.BlueprintID].Defense

                                oldthreat = oldthreat + bp.SurfaceThreatLevel

                            end

                        end

                    end
                    
                    if MyArmyIndex == v then
                
                        units = GetListOfUnits( brain, LANDUNITS, false, true)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            totalThreat = totalThreat + bp.SurfaceThreatLevel
                        end

                    end

                end
            
                if oldthreat > 0 then
                
                    -- multiply my strength * size of my team
                    totalThreat = totalThreat * aiBrain.TeamSize
                
                    aiBrain.LandRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)

                    -- inflate the Land Ratio by the root of the Outnumbered Ratio
                    aiBrain.LandRatio = aiBrain.LandRatio * OutnumberedFactor

                else
                
                    if aiBrain.CycleTime < 600 then
                    
                        aiBrain.LandRatio = .011
                        
                    else
                    
                        aiBrain.LandRatio = 10
                    end
                    
                end
                
            else
                
                if aiBrain.CycleTime < 600 then

                    aiBrain.LandRatio = .011

                else

                    aiBrain.LandRatio = 10
                end

            end

            --- NAVAL UNITS ---
            -------------------
            totalThreat = 0
            oldthreat = 0
        
            if IntelDialog then
                LOG( dialog.." Recalc NAVAL Strength Ratios on tick "..GetGameTick())
            end

            if EnemyData['Naval']['Total'] > 0 then

                for v, brain in BRAINS do
            
                    if IsEnemy( MyArmyIndex, v ) then
                
                        units = GetListOfUnits( brain, NAVALUNITS, false, true)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            oldthreat = oldthreat + bp.SurfaceThreatLevel + bp.SubThreatLevel

                        end
                        
                    end
                    
                    if MyArmyIndex == v then

                        units = GetListOfUnits( brain, NAVALUNITS, false, true)
                    
                        for _,v in units do
                    
                            bp = ALLBPS[v.BlueprintID].Defense
                        
                            totalThreat = totalThreat + bp.SurfaceThreatLevel + bp.SubThreatLevel
                        end                

                    end

                end
            
                if oldthreat > 0 then

                    totalThreat = totalThreat * aiBrain.TeamSize
                    
                    aiBrain.NavalRatio = LOUDMAX( LOUDMIN( (totalThreat / oldthreat), 10 ), 0.011)

                    aiBrain.NavalRatio = aiBrain.NavalRatio * OutnumberedFactor

                else
                
                    if aiBrain.CycleTime < 600 then
                    
                        aiBrain.NavalRatio = .011
                        
                    else
                    
                        aiBrain.NavalRatio = 10
                    end                

                end
                
            else
                
                if aiBrain.CycleTime < 600 then
                    
                    aiBrain.NavalRatio = .011

                else

                    aiBrain.NavalRatio = 10

                end            

            end

            if IntelDialog then
                LOG( dialog.." Collect Enemy PRODUCTION values on tick "..GetGameTick())
            end
            
            grandairtot     = 0
            grandlandtot    = 0
            grandnavaltot   = 0

            -- ENEMY PRODUCTION FOCUS --
            -- accumulate the value of all enemy owned factories -- divide by number of opponents
            -- compare against my factory values to determine need for more factories and of what type
            -- account for the cheat value (buildratemodifier) increasing the output of my factories
            for v, brain in BRAINS do
            
                if IsEnemy( MyArmyIndex, v ) and not ArmyIsCivilian( v ) then
                
                    units = GetListOfUnits( brain, categories.FACTORY, false, true)
                    
                    aircount = 0
                    airidle = 0
                    airtot = 0
                    
                    for _,u in EntityCategoryFilterDown( AIR, units) do
                    
                        aircount = aircount + 1
                    
                        if u:GetFractionComplete() == 1 and not u.Dead then

                            if IsIdleState(u) or IsPaused(u) then 
                                airidle = airidle + 1
                                airtot = airtot + .3
                            else
                                if EntityCategoryContains( TECH1, u) then
                                    airtot = airtot + 1
                                elseif EntityCategoryContains( TECH2, u) then
                                    airtot = airtot + 4
                                elseif EntityCategoryContains( TECH3, u) then
                                    airtot = airtot + 10
                                end
                            end
                        end

                    end
                    
                    grandairtot = grandairtot + airtot

                    landcount   = 0
                    landidle    = 0
                    landtot     = 0
                    
                    for _,u in EntityCategoryFilterDown( LAND, units) do
                    
                        landcount = landcount + 1
                        
                        if u:GetFractionComplete() == 1 and not u.Dead then

                            if IsIdleState(u) or IsPaused(u) then 
                                landidle = landidle + 1
                                landtot = landtot + .3
                            else
                                if EntityCategoryContains( TECH1, u) then
                                    landtot = landtot + 1
                                elseif EntityCategoryContains( TECH2, u) then
                                    landtot = landtot + 4
                                elseif EntityCategoryContains( TECH3, u) then
                                    landtot = landtot + 10
                                end
                            end
                        end

                    end
                    
                    grandlandtot = grandlandtot + landtot
            
                    navcount    = 0
                    navidle     = 0
                    navaltot    = 0
                    
                    for _,u in EntityCategoryFilterDown( NAVALFAC, units) do
                    
                        navcount = navcount + 1
                        
                        if u:GetFractionComplete() == 1 and not u.Dead then

                            if IsIdleState(u) or IsPaused(u) then 
                                navidle = navidle + 1
                                navaltot = navaltot + .3
                            else
                                if EntityCategoryContains( TECH1, u) then
                                    navaltot = navaltot + 1
                                elseif EntityCategoryContains( TECH2, u) then
                                    navaltot = navaltot + 4
                                elseif EntityCategoryContains( TECH3, u) then
                                    navaltot = navaltot + 10
                                end
                            end
                        end

                    end
                    
                    grandnavaltot = grandnavaltot + navaltot
                end

            end
            
            units = GetListOfUnits( aiBrain, categories.FACTORY, false, true )
            
            myaircount  = 0
            myairidle   = 0
            myairtot    = 0

            if IntelDialog then
                LOG( dialog.." Calculate AIR PRODUCTION values on tick "..GetGameTick())
            end

            for _,u in EntityCategoryFilterDown( AIR, units) do

                myaircount = myaircount + 1

                if u:GetFractionComplete() == 1 and not u.Dead then

                    if IsIdleState(u) then 
                        myairidle = myairidle + 1
                        myairtot = myairtot + .3
                    else
                        if EntityCategoryContains( TECH1, u) then
                            myairtot = myairtot + 1
                        elseif EntityCategoryContains( TECH2, u) then
                            myairtot = myairtot + 4
                        elseif EntityCategoryContains( TECH3, u) then
                            myairtot = myairtot + 10
                        end
                    end
                end

            end
            
            -- my total is increased by my cheat value (I'm more productive)
            myairtot = myairtot * aiBrain.BuildRateModifier

            -- my air production value divided by (enemy air production value/Number of Opponents)
            aiBrain.AirProdRatio = myairtot/(LOUDMAX(NumOpponents,grandairtot)/NumOpponents)
            
            mylandcount = 0
            mylandidle  = 0
            mylandtot   = 0

            if IntelDialog then
                LOG( dialog.." Calculate LAND PRODUCTION values on tick "..GetGameTick())
            end

            for _,u in EntityCategoryFilterDown( LAND, units) do

                mylandcount = mylandcount + 1

                if u:GetFractionComplete() == 1 and not u.Dead then

                    if IsIdleState(u) then 
                        mylandidle = mylandidle + 1
                        mylandtot = mylandtot + .3
                    else
                        if EntityCategoryContains( TECH1, u) then
                            mylandtot = mylandtot + 1
                        elseif EntityCategoryContains( TECH2, u) then
                            mylandtot = mylandtot + 4
                        elseif EntityCategoryContains( TECH3, u) then
                            mylandtot = mylandtot + 10
                        end
                    end
                end
            end
            
            mylandtot = mylandtot * aiBrain.BuildRateModifier

            aiBrain.LandProdRatio = mylandtot/(LOUDMAX(NumOpponents,grandlandtot)/NumOpponents)

            mynavalcount    = 0
            mynavalidle     = 0
            mynavaltot      = 0

            if IntelDialog then
                LOG( dialog.." Calculate NAVAL PRODUCTION values on tick "..GetGameTick())
            end

            for _,u in EntityCategoryFilterDown( NAVALFAC, units) do

                mynavalcount = mynavalcount + 1

                if u:GetFractionComplete() == 1 and not u.Dead then

                    if IsIdleState(u) then 
                        mynavalidle = mynavalidle + 1
                        mynavaltot = mynavaltot + .3
                    else
                        if EntityCategoryContains( TECH1, u) then
                            mynavaltot = mynavaltot + 1
                        elseif EntityCategoryContains( TECH2, u) then
                            mynavaltot = mynavaltot + 4
                        elseif EntityCategoryContains( TECH3, u) then
                            mynavaltot = mynavaltot + 10
                        end
                    end
                end
            end
            
            mynavaltot = mynavaltot * aiBrain.BuildRateModifier

            aiBrain.NavalProdRatio = mynavaltot/(LOUDMAX(NumOpponents,grandnavaltot)/NumOpponents)

            -- I have navy production but the enemy is undetected
            if grandnavaltot > 0 and aiBrain.NavalRatio < 0.02 then
                aiBrain.NavalRatio = 0.2
            end
            
            -- I have air production but the enemy is undetected
            if grandairtot > 0 and aiBrain.AirRatio < 0.02 then
                aiBrain.AirRatio = (0.25 * aiBrain.AirProdRatio)
            end

            if ReportRatios then
                LOG("*AI DEBUG ===============================")
                --LOG("*AI DEBUG "..aiBrain.Nickname.." I have "..NumOpponents.." Opponents")
                LOG("*AI DEBUG "..aiBrain.Nickname.." My factories Totals -- AIR "..string.format("%.2f", myairtot).." -- LAND "..string.format("%.2f",mylandtot).." -- NAVAL "..string.format("%.2f",mynavaltot) )
                LOG("*AI DEBUG "..aiBrain.Nickname.." Enemy factory Avg -- AIR "..string.format("%.2f", grandairtot/NumOpponents ).." -- LAND "..string.format("%.2f", grandlandtot/NumOpponents).." -- NAVAL "..string.format("%.2f",grandnavaltot/NumOpponents) )
                LOG("*AI DEBUG "..aiBrain.Nickname.."   Production Ratios -- AIR "..string.format("%.2f", aiBrain.AirProdRatio).." - LAND "..string.format("%.2f", aiBrain.LandProdRatio).." -- NAVAL "..string.format("%.2f", aiBrain.NavalProdRatio) ) 
                LOG("*AI DEBUG "..aiBrain.Nickname.."      Strength Ratios -- AIR "..string.format("%.2f", aiBrain.AirRatio).." -- LAND "..string.format("%.2f", aiBrain.LandRatio).." -- NAVAL "..string.format("%.2f", aiBrain.NavalRatio).."  at tick "..GetGameTick() )
                LOG("*AI DEBUG "..aiBrain.Nickname.."      A2G bias is "..aiBrain.AirBias  )
                LOG("*AI DEBUG ===============================")
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
	
	local GetMarker             = import('/lua/sim/scenarioutilities.lua').GetMarker
	local AIGetMarkerLocations  = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
	
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
    self.AILowHiScoutRatio =  LOUDMAX( 1, math.min( LOUDFLOOR(LOUDGETN(self.IL.LowPri) / LOUDGETN(self.IL.HiPri)), 8) )

end

-- This one complements the previous function to remove visible markers from the map 
function RemoveBaseMarker( self, baseName, markerid )

	import('/lua/simping.lua').UpdateMarker({Action = 'delete', ID = markerid, Owner = self.ArmyIndex - 1})
end


-- This thread has the AI pick an enemy every 8 minutes
-- if an AttackPlan is aborted it will be terminated and restarted
-- to plan another
function PickEnemy( self )
	
	self.targetoveride = nil

    while true do

        AIPickEnemyLogic( self, true)

        WaitTicks(4801 + (self.ArmyIndex * 60) )	-- every 8 minutes
        
    end
end

-- In this function we build a table of enemies and allies and insert their 'strength' value.
-- The aim is to identify the enemy with the most 'value'
function AIPickEnemyLogic( self, brainbool )
    
	-- Just a note here - the position used when finding an enemy should likely
    -- be based on his CURRENT PRIMARY position - and not always the starting position
    -- this will help keep him focused upon what he's already achieved
    -- rather than just switching to a stronger opponent
    
    local AttackPlanDialog = ScenarioInfo.AttackPlanDialog or false

    local testposition = self.BuilderManagers['MAIN'].Position or self:GetStartVector3f()

  	local GetThreatsAroundPosition  = GetThreatsAroundPosition
    local GetPosition               = GetPosition	
    local IsAlly                    = IsAlly
	local IsEnemy                   = IsEnemy
   
    local LOUDSORT  = LOUDSORT
    local MATHEXP   = math.exp
    local VDist3    = VDist3

	local allyEnemy         = false
    local armyStrengthTable = {}
    local Brains            = ArmyBrains
    local findEnemy         = false
    local IMAPRadius        = ScenarioInfo.IMAPRadius
    local selfIndex         = self.ArmyIndex

    --- we now watch for Commander threat
    local threattypes = {'StructuresNotMex','Land','Commander'}
    
    if self.IsNavalMap then
        threattypes = {'StructuresNotMex','Land','Naval','Commander'}
    end
    
    local armyindex, counter, currenemy, distance, insertTable, key, threats, threatWeight, unitPos, units, x1, x2, x3

    -- this table will hold the summed threat for specific positions
    insertTable = {}

    if AttackPlanDialog then
        LOG("*AI DEBUG "..self.Nickname.." AttackPlan selecting enemies at "..GetGameTick() )
    end

    -- loop thru all the brains and insert positional values for each enemy
    -- we'll end up with two tables, one with discrete positions
    -- the second with the total strength of each enemy
    for k,v in Brains do
	
        armyindex = v.ArmyIndex
		
        if (not v:IsDefeated()) and selfIndex != armyindex and not IsAlly( selfIndex, armyindex) then
		
			if IsEnemy(selfIndex, armyindex) then

                for _,threattype in threattypes do

                    threats = GetThreatsAroundPosition( self, testposition, 32, true, threattype, armyindex)
                
                    -- sort the threats for closest
                    LOUDSORT( threats, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a[1],a[2],testposition[1],testposition[3]) < VDist2Sq(b[1],b[2],testposition[1],testposition[3]) end )

                    for _,data in threats do

                        if data[3] > 20 then
                        
                            -- closer targets are worth more
                            distance = VDist3( testposition, {data[1],0,data[2]} )
                
                            -- adjust result against maximum possible distance on this map
                            threatWeight = (self.dist_comp / distance ) - 1

                            threatWeight = LOUDFLOOR(threatWeight * data[3])

                            key = tostring(data[1])..","..tostring(data[2].."-"..tostring(k))

                            if not insertTable[key] then
                                insertTable[key] = { Brain = k, Position = { data[1],0,data[2] }, Strength = 0 }
                            end

                            insertTable[key].Strength = insertTable[key].Strength + threatWeight
                            
                            if not armyStrengthTable[armyindex] then
                                armyStrengthTable[armyindex] = { Alias = v.Nickname, Brain = armyindex, Enemy = true, Position = false, TotalStrength = 0 }
                            end
                            
                            armyStrengthTable[armyindex].TotalStrength = armyStrengthTable[armyindex].TotalStrength + threatWeight
                        end
                    end
                end
			end
        end
    end

    -- we'll now use the two tables to arrive at a third table
    -- where we identify the highest concentration for each enemy
    local maxthreat = {}

    --if AttackPlanDialog then
      --  LOG("*AI DEBUG "..self.Nickname.." AttackPlan insertTable is "..repr(insertTable) )
    --end
    
    for k,v in insertTable do
        
        if not maxthreat[v.Brain] then
            maxthreat[v.Brain] = 0
        end
    
        if v.Strength >= maxthreat[v.Brain] then
        
            armyStrengthTable[v.Brain].Position = v.Position
            
            maxthreat[v.Brain] = v.Strength
        end
    end

    --if AttackPlanDialog then
      --  LOG("*AI DEBUG "..self.Nickname.." AttackPlan armyStrengthTable is "..repr(armyStrengthTable) )
    --end
	
    -- if targetoveride is true then allow target switching
    -- the only place I see that happening is with the Sorian
    -- AI Chat functions - otherwise default is false and 
    -- allied targets don't override this one
    if allyEnemy then
		
        self:SetCurrentEnemy( allyEnemy )
		
		self.CurrentEnemyIndex = self:GetCurrentEnemy().ArmyIndex
		
    else

        currenemy = self:GetCurrentEnemy()
		
        -- if there is no current enemy - or the current enemy is not generating any threat - and we are not target overridden --
        if (not currenemy or brainbool) or (currenemy and not armyStrengthTable[currenemy:GetArmyIndex()]) and not self.targetoveride then
		
            findEnemy = true
			
        elseif currenemy then
			
            -- If our current enemy has been defeated or has less than 35 strength, we need a new enemy
            if currenemy:IsDefeated() or armyStrengthTable[currenemy:GetArmyIndex()].Strength < 35 then
			
                findEnemy = true
            end
        end
		
		if self.DrawPlanThread then 
		
			KillThread(self.DrawPlanThread)
            self.DrawPlanThread = nil
		end	

        if findEnemy then
		
            local enemyPosition = false
            local enemyStrength = 0
            local enemy = false
            local newPosition = false
			
            for k,v in armyStrengthTable do
			
                -- Ignore allies 
                if not v.Enemy then
                    continue
                end

                -- store the highest value so far -- we'll pick this as the
                -- enemy once we've checked all the enemies
                if not enemy or v.TotalStrength > enemyStrength then
                    
                    enemyPosition = v.Position
					enemyStrength = v.TotalStrength
                    
                    enemy = ArmyBrains[v.Brain]
                end
            end

            -- if we've picked an enemy and have a position for them
            if enemy and enemyPosition then
                
                -- collect all the enemy units within that IMAP grid -- NOTE - this will report all units - even those you don't see
				units, counter = GetEnemyUnitsInRect( self, enemyPosition[1] - IMAPRadius, enemyPosition[3] - IMAPRadius, enemyPosition[1] + IMAPRadius, enemyPosition[3] + IMAPRadius)

                if units then

                    -- these accumulate the position values
                    x1 = 0
                    x3 = 0

                    for _,v in units do

                        if not v.Dead then

                            unitPos = GetPosition(v) or false
                    
                            if unitPos then
                                x1 = x1 + unitPos[1]
                                x3 = x3 + unitPos[3]
                            end
                        end
                    end

                    x1 = LOUDFLOOR(x1/counter)
                    x3 = LOUDFLOOR(x3/counter)

                    -- the averaged centre
                    newPosition = { x1,0,x3 }

                    if AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." AttackPlan armyStrengthTable Position "..repr(enemyPosition).." averaged "..repr(newPosition) )                
                    end

                    -- If we don't have an enemy or it's different than the one we already have
                    if not self:GetCurrentEnemy() or self:GetCurrentEnemy() != enemy then
				
                        -- set this as our current enemy
                        self:SetCurrentEnemy( enemy )
					
                        -- remember this enemy index on the brain
                        self.CurrentEnemyIndex = self:GetCurrentEnemy().ArmyIndex
					
                        -- AI will announce the current target to allies
                        AISendChat('allies', ArmyBrains[self:GetArmyIndex()].Nickname, 'targetchat', ArmyBrains[enemy:GetArmyIndex()].Nickname)
                    end
                    
                    -- if we have an enemy and we dont have an attack goal or the goal is quite different from the one we already have
                    if self.CurrentEnemyIndex and ( (not self.AttackPlanGoal) or VDist3(self.AttackPlan.Goal, newPosition) > 100 ) then

                        -- create a new attack plan
                        self:ForkThread( CreateAttackPlan, newPosition)
                    end
                end
			end
        end
    end
	
end

function GetAlliedBases(self)

    -- make a list of all existing ALLIED bases
    local usedmarkerlist = {}
    local usedmarkercounter = 0
    
    for _,brain in ArmyBrains do
        
        if brain.ArmyIndex != self.ArmyIndex and IsAlly( self.ArmyIndex, brain.ArmyIndex) then
        
            for _,base in brain.BuilderManagers do
            
                if base.EngineerManager.Active then
                    usedmarkercounter = usedmarkercounter + 1
                    usedmarkerlist[base.BaseName] = { Position = { base.Position[1], base.Position[3] } }
                end
            end
        end
    end
    
    return usedmarkerlist, usedmarkercounter
end

-- The ATTACK PLANNER - oh boy here we go
-- The purpose of this is to create a series of points (Stagepoints) that the AI will attempt
-- to seize control of - on his way to GOAL
function CreateAttackPlan( self, enemyPosition )

    local GetSurfaceHeight = GetSurfaceHeight
    local GetTerrainHeight = GetTerrainHeight

    local LOUDCOPY  = LOUDCOPY
    local LOUDFLOOR = LOUDFLOOR
    local VDist2    = VDist2
    local VDist2Sq  = VDist2Sq
    local WaitTicks = WaitTicks
    
    local AttackPlanDialog = ScenarioInfo.AttackPlanDialog or false
    local dialog = "*AI DEBUG "..self.Nickname.." CreateAttackPlan"
    
    local PlatoonGenerateSafePathToLOUD = import('/lua/platoon.lua').Platoon.PlatoonGenerateSafePathToLOUD
    
	if self.DeliverStatus then
		ForkThread( AISendChat, 'allies', self.Nickname, 'Creating Attack Plan for '..ArmyBrains[self:GetCurrentEnemy().ArmyIndex].Nickname )
	end

	local stagesize     = 300
	local minstagesize  = 125 * 125
	local maxstagesize  = 350 * 350

    local startx, startz = self:GetCurrentEnemy():GetArmyStartPos()
    
    startx = enemyPosition[1]
    startz = enemyPosition[3]
  
    local starty        = GetSurfaceHeight( startx, startz )
    local Goal          = {startx, starty, startz}
    local GoalReached   = false

	-- this should probably get set to the current PrimaryLandAttackBase -- but we use the MAIN base for now 
    local StartPosition = self.BuilderManagers.MAIN.Position
    
    if AttackPlanDialog then
        LOG( dialog.." FROM "..repr(StartPosition).." TO "..repr(enemyPosition).." at tick "..GetGameTick() )
    end

	-- checks if destination is somewhere between two points
	local DestinationBetweenPoints = function( Goal, start, finish )
    
        local VDist2Sq = VDist2Sq

		local steps = LOUDFLOOR( VDist2(start[1], start[3], finish[1], finish[3]) / 100 ) + 1
		
		-- and the size of each step
		local xstep = (start[1] - finish[1]) / steps
		local ystep = (start[3] - finish[3]) / steps
			
		-- check the steps from start to one less than then destination
		for i = 1, steps do
			
			-- if we're within the stepcheck ogrids of the destination then we found it
			if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), Goal[1], Goal[3]) < 10000 then
				return true
			end
		end	
		
		return false
	end	
    
    local LocationInWaterCheck = function(position)
        return GetTerrainHeight(position[1], position[3]) < GetSurfaceHeight(position[1], position[3])
    end    

    -- build a list of all current allied positions
    local usedmarkerlist, usedmarkercounter = GetAlliedBases(self)

    local CDistance,GDistance,SDistance
    local counter = 0
    local throttle = 0

    if not StartPosition then
        return
    end
    
    -- distance from start to goal
    CDistance = VDist2Sq(StartPosition[1],StartPosition[3], Goal[1],Goal[3])
  
    local markerlist    = {}
    local markers       = ScenarioInfo.Env.Scenario.MasterChain._MASTERCHAIN_.Markers
    local markertypes   = {'Defensive Point','Naval Area','Naval Defensive Point','Blank Marker','Expansion Area','Large Expansion Area','Small Expansion Area'}
	
    -- build masterlist of ALL valid staging points between start and goal
    for k,v in markers do

        -- ignore any marker already in use by an ALLIED AI
        if usedmarkercounter > 0 and usedmarkerlist[k] then
            continue
        end

        -- distance from this marker to the goal
        GDistance = VDist2Sq(v.position[1],v.position[3], Goal[1],Goal[3])
        -- distance from this marker to the start
        SDistance = VDist2Sq(v.position[1],v.position[3], StartPosition[1],StartPosition[3])

        for _,t in markertypes do
        
            throttle = throttle + 1
		
            if v.type == t then

				-- only add markers that are at least minstagesize away from the start
                if SDistance > minstagesize
				
					-- and at least minstagesize from the final goal
					and GDistance > minstagesize
					
					-- and 1/2 of the minstagesize closer, to the goal, than the startposition
					and GDistance <= (CDistance - (minstagesize/2) )
					
					then
	
                    counter = counter + 1
                    markerlist[counter] = { Position = {v.position[1],v.position[2],v.position[3]}, Name = k } 
                    break
                end
            end

            if LOUDMOD(throttle, 15) == 1 then
                WaitTicks(1)
            end

        end
    end

	if counter < 1 then
    
        if AttackPlanDialog then
            WARN( dialog.." No Markers meet AttackPlan requirements - Cannot solve tactical challenge")
        end
        
		GoalReached = true

    else

        if AttackPlanDialog then
            LOG( dialog.." collected "..throttle.." markers at tick "..GetGameTick() )
        end
    end

    if not self.AttackPlan then
	
        self.AttackPlan = {}
        self.AttackPlan.GoCheckInterval = 120   -- every 2 minutes
        self.AttackPlan.GoCheckRatio = 3        -- ratio for 100% Go signal
    end

    self.AttackPlan.Goal = nil
    self.AttackPlan.CurrentGoal = nil
    self.AttackPlan.GoSignal = false
    self.AttackPlan.Pending = true
    
    local StagePoints = {}

    local StageCount = 0
    local looptest = 0
    
	local CurrentBestPathLength, CurrentPoint, CurrentPointDistance, cyclecount, goaldistance, holdpathlength
    local position, positions, path, pathlength, pathtype, reasontestdistance
    
    path = false
    pathlength = 0

    -- we always start checking from here --
    CurrentPoint = LOUDCOPY(StartPosition)
    CurrentPointDistance = VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3])

    -- FIRST - see if we can path from start to the goal using LAND --
    pathtype = 'Land'
    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerLand', 'Land', CurrentPoint, Goal, 99999, 160)
    
    -- if not - try AMPHIB --
    if not path then
        
        if AttackPlanDialog then
            LOG( dialog.." finds no LAND path to Goal "..repr(Goal).." from StartPosition of "..repr(CurrentPoint).." reason is "..repr(reason) )
        end

        pathtype = 'Amphibious'
        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerAmphib', 'Amphibious', CurrentPoint, Goal, 99999, 250)
    end
    
    if not path then
    
        pathtype = 'Unknown'
        
        if AttackPlanDialog then
            LOG( dialog.." finds no viable LAND or AMPHIB path to Goal "..repr(Goal).." from StartPosition of "..repr(CurrentPoint).." reason is "..repr(reason) )
        end
        
        GoalReached = true
        
    else
    
        if AttackPlanDialog then
            LOG( dialog.." finds "..pathtype.." path from Start to goal - pathlength is "..math.floor(pathlength) )
        end
        
        CurrentBestPathLength = pathlength

        if AttackPlanDialog then
            LOG( dialog.." Method set to "..repr(pathtype) )
        end

        -- record if attack plan can be land based or not - start with land - but fail over to amphibious if no path --
        self.AttackPlan.Method = pathtype
        
    end

    cyclecount = 0

    while not GoalReached do
 
    	-- if current point is within stagesize of goal we're done
        if VDist2Sq(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3]) <= maxstagesize then
		
            GoalReached = true
			
        else

            if AttackPlanDialog then
                LOG( dialog.." Stagecount ".. StageCount+1 .." BEGINS - stage distance to goal is "..math.floor(VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3])).." stagesize is "..stagesize)
                LOG( dialog.." Stagecount ".. StageCount+1 .." needs to be less than "..math.floor((CurrentPointDistance - 100)).." from the goal and have a path length of less than "..math.floor(CurrentBestPathLength) )
            end
          
            -- sort the markerlist for closest to the current point --
            LOUDSORT( markerlist, function(a,b) local VDist2Sq = VDist2Sq return VDist2Sq(a.Position[1],a.Position[3], CurrentPoint[1],CurrentPoint[3]) < VDist2Sq(b.Position[1],b.Position[3], CurrentPoint[1],CurrentPoint[3]) end )

            positions = {}
            counter = 0

            -- Now we'll test each valid position and assign a value to it
            -- seek the position which has the lowest path value between our minimum(100) and maximum(300) stage size distance
            -- note that the path value might exceed these limits - but the crow flies distance cannot

			-- Filter the list of markers
            for _,v in markerlist do
            
                position = v.Position

                -- load balancing --
                if cyclecount > 2 then
                    WaitTicks(1)
                    cyclecount = 0
                end

                -- distance from CurrentPoint
                testdistance = VDist2Sq( position[1],position[3], CurrentPoint[1],CurrentPoint[3])

                if testdistance > maxstagesize then
                    break -- the remainder will fail --
                end

                if AttackPlanDialog then
                    LOG( dialog.." Stagecount ".. StageCount+1 .." reviewing "..repr(v.Name).." distance is "..math.floor(LOUDSQRT(testdistance)).." to goal" )
                end
                
                if testdistance < minstagesize then
                    if AttackPlanDialog then
                        LOG( dialog.." point too close to current point "..testdistance.." < "..minstagesize )
                    end

                    continue
                end

                -- distance to the Goal
                goaldistance = VDist2( position[1],position[3], Goal[1],Goal[3])
                
                if goaldistance >= (CurrentPointDistance - 125) then
                    if AttackPlanDialog then
                        LOG( dialog.." point is not 125 closer to goal "..goaldistance.." >= "..(CurrentPointDistance -125) )
                    end

                    continue
                end
                
                if goaldistance < LOUDSQRT(minstagesize) then
                    if AttackPlanDialog then
                        LOG( dialog.." point too close to goal "..goaldistance.." < "..LOUDSQRT(minstagesize) )
                    end

                    continue
                end

                cyclecount = cyclecount + 1

                path = false
                pathlength = 0

                -- get the pathlength of this position to the Goal position -- using LAND
                if (not LocationInWaterCheck(Goal)) and (not LocationInWaterCheck(position)) then
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountAttackPlannerToGoalLand', 'Land', position, Goal, 99999, 160)
                end
                
                -- then try AMPHIB --
                if not path then

                    WaitTicks(1)
                    
                    pathtype = "Amphibious"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountAttackPlannerToGoalAmphib', 'Amphibious', position, Goal, 99999, 250)
                end
 
                -- if we have a path and its closer to goal than the best so far
                if path and ( pathlength < CurrentBestPathLength ) and not DestinationBetweenPoints( Goal, CurrentPoint, position ) then

                    -- try to make a LAND path first 
                    path = false

                    holdpathlength = pathlength

                    if (not LocationInWaterCheck(CurrentPoint)) and (not LocationInWaterCheck(position)) then
                        pathtype = "Land"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountCurrentToPositionLand', 'Land', CurrentPoint, position, 99999, 160)
                    end

                    -- if not try an AMPHIB path --
                    if not path then
                        pathtype = "Amphibious"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountCurrentToPositionAmphib', 'Amphibious', CurrentPoint, position, 99999, 250)
                    end

                    if path then

                        if AttackPlanDialog then
                            LOG( dialog.." Stagecount ".. StageCount+1 .." adding "..repr(v.Name).." at "..repr(position).." - "..pathtype.." path length "..repr(holdpathlength) )
                        end

                        counter = counter + 1
                        positions[counter] = {Name = v.Name, Position = position, Pathvalue = holdpathlength, PathvalueCurrent = pathlength, Type = pathtype, Path = path}

                        CurrentBestPathLength = holdpathlength
                    end

                else
--[[                    
                    if AttackPlanDialog then
                    
                        if path and pathlength >= CurrentBestPathLength then
                            LOG( dialog.." Stagecount ".. StageCount+1 .." "..pathtype.." path from "..repr(v.Name).." at "..repr(position).." to goal was "..pathlength)
                        end

                    end
--]]
                end

            end
            
            LOUDSORT(positions, function(a,b) return a.Pathvalue + a.PathvalueCurrent < b.Pathvalue + b.PathvalueCurrent end )
            
            --if AttackPlanDialog then
              --  LOG( dialog.." Stagecount ".. StageCount+1 .." Sorted "..repr(LOUDGETN(positions)).." possible positions are "..repr(positions))
            --end
            
			-- if there are no positions we'll have to create one out of a movement node
            if not positions[1] then
                
                local a,b

                if not positions[1] then
				
                    if AttackPlanDialog then
                        LOG( dialog.." Stagecount ".. StageCount+1 .." finds no positions from "..repr(CurrentPoint))
					end
                    
                    a = Goal[1] + CurrentPoint[1]
                    b = Goal[3] + CurrentPoint[3]
                    
                else
				
                    if AttackPlanDialog then
                        LOG( dialog.." Stagecount ".. StageCount+1 .." could only find a marker at " .. math.floor(VDist3(positions[1].Position, CurrentPoint)) .. " from "..repr(CurrentPoint).." Max Distance is "..stagesize)
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
				
                    if AttackPlanDialog then
                        LOG( dialog.." Stagecount ".. StageCount+1 .." Could not find a Land Node within 200 of resultposition "..repr(result).." using Water at 300")
                    end
					
                    fakeposition = AIGetMarkersAroundLocation( self, 'Water Path Node', result, 300)
                else
                
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountFindFakeLand', 'Land', CurrentPoint, landposition[1].Position, 99999, 160)
                    
                    if not path then
                    
                        WaitTicks(1)
                    
                        pathtype = "Amphibious"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountFindFakeAmphib', 'Amphibious', CurrentPoint, landposition[1].Position, 99999, 250)
                    end
				
                    LOUDINSERT(positions, { Name = "FakeLAND", Position = landposition[1].Position, Pathvalue = pathlength, Type = pathtype, Path = path})
                end

				-- if no land marker could be found - try using a Naval marker
                if fakeposition[1].Position then
				
                    if AttackPlanDialog then
                        LOG( dialog.." Stagecount ".. StageCount+1 .." using Fakeposition assign - working from CurrentPoint of "..repr(CurrentPoint).." Fake Position is "..repr(fakeposition) )
                    end
                    
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountFindFakeNavalLand', 'Land', CurrentPoint, fakeposition[1].Position, 99999, 160)
                    
                    if not path then
                    
                        WaitTicks(1)
                    
                        pathtype = "Amphibious"
                        path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'StageCountFindFakeNavalAmphib', 'Amphibious', CurrentPoint, fakeposition[1].Position, 99999, 250)
                    end

                    LOUDINSERT(positions, {Name = "FakeNAVAL", Position = fakeposition[1].Position, Pathvalue = pathlength, Type = pathtype, Path = path})
                end
            end

            LOUDSORT(positions, function(a,b) return a.Pathvalue < b.Pathvalue end )
			
			-- make sure new point not same as previous - if it is - we're done
			if positions[1] and (not table.equal( positions[1].Position, CurrentPoint )) then
			
				StageCount = StageCount + 1 

                StagePoints[StageCount] = positions[1]

				CurrentPoint = LOUDCOPY(positions[1].Position)
                CurrentPointDistance = VDist2(CurrentPoint[1],CurrentPoint[3], Goal[1],Goal[3])

                if positions[1].Type == 'Land' then
                
                    pathtype = "Land"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerToGoalLand', 'Land', CurrentPoint, Goal, 99999, 160 )
                else
                    pathtype = "Amphibious"
                    path, reason, pathlength = PlatoonGenerateSafePathToLOUD( self, 'AttackPlannerToGoalAmphib', 'Amphibious', CurrentPoint, Goal, 99999, 250 )
                end
                
                if path then
                    CurrentPointDistance = pathlength
            
                    if AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." AttackPlan Stagecount ".. StageCount .." selects "..positions[1].Name.." at "..repr(positions[1].Position).." type is "..repr(positions[1].Type) )
                        LOG("*AI DEBUG "..self.Nickname.." AttackPlan Stagecount ".. StageCount .." ENDS ")
                    end
                    
                else
                    if AttackPlanDialog then
                        LOG("*AI DEBUG "..self.Nickname.." AttackPlan Stagecount ".. StageCount .." finds no path from "..repr(CurrentPoint).." to goal position "..repr(Goal))
                    end
                end

                if self.AttackPlan.Method != "Amphibious" then
                    
                    if AttackPlanDialog and pathtype != self.AttackPlan.Method then
                        LOG("*AI DEBUG "..self.Nickname.." AttackPlan Method changes from "..self.AttackPlan.Method.." to "..repr(pathtype) )                    
                    end

                    self.AttackPlan.Method = pathtype
                end
				
			else
				GoalReached = true
			end
            
        end 
    end

	
    if StageCount >= 0 then
	
        -- if monitoring an existing attack plan, kill it and start a new one
        if self.AttackPlanMonitorThread then
            
            if self.DrawPlanThread then
                KillThread(self.DrawPlanThread)
                self.DrawPlanThread = nil
            end
            
            KillThread(self.AttackPlanMonitorThread)
            self.AttackPlanMonitorThread = nil
        end
	
        self.AttackPlan.CurrentGoal = 1
        self.AttackPlan.Goal = Goal
        self.AttackPlan.GoSignal = false
        self.AttackPlan.Pending = false
		self.AttackPlan.StageCount = StageCount
        
        self.AttackPlan.StagePoints = table.copy(StagePoints)
        
        self.AttackPlan.StagePoints[0] = { Name = "Startpoint", Position = StartPosition }

        self.AttackPlan.StagePoints[StageCount + 1] = { Name = "Goal", Path = path, Position = Goal, Type = pathtype }

        self.AttackPlanMonitorThread = self:ForkThread( AttackPlanMonitor )

    else
		LOG("*AI DEBUG "..self.Nickname.." AttackPlan fails for "..repr(Goal) )
	end
    
end

function DrawAttackPlanNodes(self)

	local DC = DrawCircle
	local DLP = DrawLinePop
	
	while self.AttackPlan.Goal do
	
		if (not self.AttackPlan.Pending) and ( self.ArmyIndex == GetFocusArmy() or ( GetFocusArmy() != -1 and self.ArmyIndex and IsAlly(GetFocusArmy(), self.ArmyIndex)) ) and self.AttackPlan.StagePoints[0] then
		
			DC(self.AttackPlan.StagePoints[0].Position, 1, '00ff00')
			DC(self.AttackPlan.StagePoints[0].Position, 3, '00ff00')

			local lastpoint = self.AttackPlan.StagePoints[0].Position				
			local lastdraw = lastpoint
			
			if self.AttackPlan.StagePoints[0].Path then
			
				-- draw the movement path --
				for _,v in self.AttackPlan.StagePoints[0].Path do
				
					DLP( lastdraw, v, '00cc33' )
					lastdraw = v
				
				end
			end
			
			for i = 1, self.AttackPlan.StageCount + 1 do
			
				DLP( lastpoint, self.AttackPlan.StagePoints[i].Position, 'ffffff')
				
				DC( self.AttackPlan.StagePoints[i].Position, 1, 'ff0000')
				DC( self.AttackPlan.StagePoints[i].Position, 3, 'ff0000')
				DC( self.AttackPlan.StagePoints[i].Position, 5, 'ffffff')

				lastdraw = lastpoint
				
				if self.AttackPlan.StagePoints[i].Path then
				
					for _,v in self.AttackPlan.StagePoints[i].Path do
				
						DLP( lastdraw,v, '00cc33' )
						lastdraw = v
				
					end
				end
				
				lastpoint = self.AttackPlan.StagePoints[i].Position
			end

		end
		
		WaitTicks(6)
	end
	
	self.DrawPlanThread = nil
end

function AttackPlanMonitor(self)
    
    local GetThreatsAroundPosition = GetThreatsAroundPosition
    local CurrentEnemyIndex = self:GetCurrentEnemy():GetArmyIndex()
    
    local WaitTicks = WaitTicks

    while self.AttackPlan.Goal do
    
        local AttackPlanDialog = ScenarioInfo.AttackPlanDialog or false
        local dialog = "*AI DEBUG "..self.Nickname.." AttackPlanMonitor"

		-- Draw Attack Plans onscreen (set in InitializeSkirmishSystems or by chat to the AI)
		if self.AttackPlan and (ScenarioInfo.DisplayAttackPlans or self.DisplayAttackPlans) then
        
            if not self.DrawPlanThread then
                self.DrawPlanThread = ForkThread( DrawAttackPlanNodes, self )
            end
		end         

		if self.AttackPlan.Goal and (not self.AttackPlan.Pending) then
        
		    if AttackPlanDialog then   
                LOG( dialog.." assessing goal " ..repr(self.AttackPlan.Goal).." on tick "..GetGameTick() )
                LOG( dialog.." Start Point is "..repr(self.AttackPlan.StagePoints[0]))
            end

            -- what I want to do is loop thru the stages - and evaluate if its complete (we own that stage)
            -- essentially - is there still enemy threat at the goal point ?
            -- if not, the plan is complete ?   -- ABORT -- MAKE A NEW PLAN
            
            -- of do we go thru each stagepoint - check threat at each position -
            -- and if threat at THAT position is higher than the GOAL threat
            -- ABORT -- MAKE NEW PLAN
            
            self.AttackPlan.CurrentGoal = 1
            self.AttackPlan.Method = "Land"     -- default to Land

            local usedmarkerlist, usedmarkercounter = GetAlliedBases(self)
            
            for k = 1, self.AttackPlan.StageCount + 1 do
            
                local markername = self.AttackPlan.StagePoints[k].Name
 
                -- if there are usedmarkers and one of our markers is in use by an ally
                -- then we must abort the current plan and build a new one
                if usedmarkercounter > 0 and usedmarkerlist[markername] then

                    self.AttackPlan = false
                    self.AttackPlanMonitorThread = nil
                    
                    if self.EnemyPickerThread then

                        if AttackPlanDialog then
                            LOG( dialog.." ABORTED at "..GetGameTick() )
                        end

                        KillThread(self.EnemyPickerThread)
                    end
            
                    if self.DrawPlanThread then
                        KillThread(self.DrawPlanThread)
                        self.DrawPlanThread = nil
                    end

                    self.EnemyPickerThread = self:ForkThread1( PickEnemy )
                    
                    return
                end

                if AttackPlanDialog then
                    LOG( dialog.." Stagepoint "..repr(k).." "..markername.." at "..repr(self.AttackPlan.StagePoints[k].Position ) )
                end

                -- if any stage is Amphibious - the overall Method will be set to Amphibious
                if self.AttackPlan.StagePoints[k].Type and self.AttackPlan.StagePoints[k].Type != "Land" then
                    self.AttackPlan.Method = "Amphibious"
                end
                
                if k>0 then 
                
                    local testname = self.AttackPlan.StagePoints[k].Name
                
                    if not self.BuilderManagers[testname] and self.AttackPlan.CurrentGoal == 0  then 
                        self.AttackPlan.CurrentGoal = k
                    end
                    
                end

            end
            
            -- set primary bases 
			SetPrimaryLandAttackBase(self)
			SetPrimarySeaAttackBase(self)
            
            -- and wait for next cycle (GoCheckInterval)            
            WaitTicks( (self.AttackPlan.GoCheckInterval or 60) * 10)
		else
            if AttackPlanDialog then
                LOG( dialog.." AttackPlan pending")
            end
            
            WaitTicks(21)
        end

    end
    
    self.AttackPlanMonitorThread = nil
end


--	This function will return threat and distance data from entries in the HighPriorityList
--	Returns:
--		A list of data with the following elements
--			Position	- a 3D position vector
--			Threats		- four of them: AirThreat, EcoThreat, SubThreat & SurThreat
--			Distance	- # of ogrids to the position based upon location
--			Type		- the class of threat (StructuresNotMex, Experimental, Commander, Air, Land, etc.)
--			LastScouted - gametime when position was last scouted

-- We are basically re-checking the work that was done to put this data into the HiPri list to get
-- refreshed position and strength values - May 2019
-- added threat type, range and Entity filtering options
function GetHiPriTargetList(aiBrain, location, threattypes, maxrange, EntityControl)

    if not location then
        return {}
    end
	
	local intelChecks = {
		Air 			    = categories.AIR - categories.SATELLITE - categories.SCOUT - categories.TRANSPORTFOCUS,
		Land 			    = categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT,
		Naval 		    	= categories.MOBILE - categories.AIR - categories.ANTIAIR - categories.SCOUT,
        AntiAir             = categories.ANTIAIR - categories.AIR,
		Economy	    		= categories.ECONOMIC + categories.FACTORY,
		StructuresNotMex    = categories.STRUCTURE - categories.WALL - categories.ECONOMIC - categories.ANTIAIR,
		Commander 	    	= categories.COMMAND,
	}

	local EntityCategoryFilterDown  = EntityCategoryFilterDown
	local LOUDCOPY                  = LOUDCOPY
    local LOUDFLOOR                 = LOUDFLOOR
    local VDist3                    = VDist3
	local WaitTicks                 = WaitTicks

    local threatlist = LOUDCOPY(aiBrain.IL.HiPri)
	
	-- this defines the 'box' that we'll use around the threat position to find enemy units
	-- it varies with the map size and is set in the PARSEINTEL thread
	local IMAPRadius = ScenarioInfo.IMAPRadius
	
	local ALLBPS = __blueprints
    local checks = 0
	local counter = 0
	local targetlist = {}	

	local allthreat, airthreat, bp, ecothreat, newPos, subthreat, surthreat, targets, targetcount, unitcount, unitPos, x1, x2, x3
    local EntityCheck, TPosition, TType

	LOUDSORT( threatlist, function(a,b) local VDist3 = VDist3 return VDist3(a.Position,location) < VDist3(b.Position,location) end )

    for _,threat in threatlist do
    
        TType = threat.Type

        if not TType then
            continue
        end
        
        if threattypes and not threattypes[TType] then
            continue
        end
        
        TPosition = threat.Position
        
        if maxrange and VDist3(location, TPosition) > maxrange then
            break
        end

        if EntityControl then
            EntityCheck = false
        else
            EntityCheck = intelChecks[TType] or false
        end
   
        -- ok - this result is going to differ from the one in PARSEINTEL because of the position - at this point it's already offset from the IMAP block
        -- so it can move in relation to what the HiPri list actually has
		targets, targetcount = GetEnemyUnitsInRect( aiBrain, TPosition[1]-IMAPRadius, TPosition[3]-IMAPRadius, TPosition[1]+IMAPRadius, TPosition[3]+IMAPRadius)

        if targetcount == 0 then
            continue
        end

        if EntityCheck then
            targets = EntityCategoryFilterDown( EntityCheck, targets )
        end
		
		airthreat = 0.0
		ecothreat = 0.0
		subthreat = 0.0
		surthreat = 0.0
		
		unitPos = false
		x1 = 0
		x2 = 0
		x3 = 0
		unitcount = 0
		newPos = false
		
		if targets then

			checks = checks + 1

			for _, target in targets do
			
				if not target.Dead then
				
					unitPos = target:GetCachePosition()
					
					if unitPos then
                    
                        unitcount = unitcount + 1
                        
						x1 = x1 + unitPos[1]
						x2 = x2 + unitPos[2]
						x3 = x3 + unitPos[3]
					
                        bp = ALLBPS[target.BlueprintID].Defense
					
                        airthreat = airthreat + bp.AirThreatLevel
                        ecothreat = ecothreat + bp.EconomyThreatLevel
                        subthreat = subthreat + bp.SubThreatLevel
                        surthreat = surthreat + bp.SurfaceThreatLevel
                    end
				end
			end

			allthreat = LOUDFLOOR(ecothreat + subthreat + surthreat + airthreat)

            if allthreat > 0 then
            
                -- if we parsed the targets by Entity - use the average position - otherwise use the original position
                if EntityCheck then
                    newPos = { LOUDFLOOR(x1/unitcount), LOUDFLOOR(x2/unitcount), LOUDFLOOR(x3/unitcount) }
                else
                    newPos = TPosition
                end
			
                counter = counter + 1		
                targetlist[counter] = { Distance = LOUDFLOOR(VDist3(location, newPos)), LastScouted = threat.LastScouted, Position = newPos, Threats = { Air = airthreat, Eco = ecothreat, Sub = subthreat, Sur = surthreat, All = allthreat}, Type = TType, }

            end

            if checks > 2 then
                WaitTicks(1)
                checks = 0
            end

		end

    end
	
	return targetlist, counter
end


	-- checks if a targetposition is still on the hipri intel list and return true or false
	-- If true, the threat levels will also be returned which can then be used by the platoon to do further evaluation
	-- NOTE the use of intelresolution which is set by the ParseIntel thread.  This value changes according to
	-- map size and should allow this routine to keep up with moving intel targets - at least those within the IMAP block
	-- It's always a larger value than the IMAPRadius that was used to find targets originally and allows this
	-- routine to return TRUE on moving HiPri targets
function RecheckHiPriTarget( aiBrain, targetlocation, targetclass, nulrange, EntityControl )
    
    local testtypes = {}
    
    testtypes[targetclass] = true

	local targetlist, targetlistcount = GetHiPriTargetList( aiBrain, targetlocation, testtypes, ScenarioInfo.IntelResolution, EntityControl or false )

    if targetlistcount > 0 then
    
        Target = targetlist[1]

		-- return true and table of different threat values (Air,Eco,Sub,Sur,All) and potentially new location
        return true, Target.Threats, Target.Position
	end

	-- current target is no longer HiPri
	return false, 0
end


function DrawPath ( origin, path, destination, overridecolor )

    if not path then
        return
    end
 
    for i = 0, 300 do
    
        local lastpoint = LOUDCOPY(origin)
        
        for _, v in path do
            DrawLinePop( lastpoint, v, overridecolor or 'ffffff' )
            lastpoint = LOUDCOPY(v)
        end
        
        DrawLinePop( lastpoint, destination, 'ff0000' )
        
        WaitTicks(2)
    end
end

-- function to draw HiPri Intel points on the map for debugging - all credit to Sorian
function DrawIntel( aiBrain, parseinterval)

    LOG("*AI DEBUG "..aiBrain.Nickname.." DrawIntel Thread starts")

    local WaitTicks = WaitTicks
    local DrawC = DrawCircle
    
    local ArmyIndex = aiBrain.ArmyIndex

	-- this will draw resolved intel data (specific points)
	local function DrawIntelPoint(position, color, threatamount)
    
        local DrawC = DrawC
    
        local distmax = math.log10( LOUDSQRT( threatamount ))
        local surface = GetSurfaceHeight(position[1],position[3])

        -- controls display length
		for i = 0, parseinterval do
        
            -- radiate out from point according to threat intensity
            for distance = .3, distmax, .3 do
                DrawC( {position[1],surface,position[3]}, distance * 1.1, color )
            end
            
            WaitTicks(1)
		end
	end

	-- this will draw 'raw' intel data (standard threat map points)
	local function DrawRawIntel( position, Type )
	
		local threats = aiBrain:GetThreatsAroundPosition( position, 1, true, Type)

		for _,v in threats do
		
			if v[3] > 5 then
				ForkThread( DrawIntelPoint, {v[1],0,v[2]}, threatColor2[Type], v[3] )
			end
		end
	end

    local ThreatTypes = ScenarioInfo.ThreatTypes
    
	while true do
	
		if ArmyIndex == GetFocusArmy() then
        

            --local inteldata = aiBrain.IL.HiPri
            -- inteldata.LastScouted
            -- inteldata.LastUpdate
            -- inteldata.Position
            -- inteldata.Threat
            -- inteldata.Type
            
            -- display the HiPri positions
			for _,v in aiBrain.IL.HiPri do
            
                local Type = v.Type
                local Threat = v.Threat
	
                -- for any active types in the threatColor table --
				if ThreatTypes[Type].Active and Threat > 0 then

                    --LOG("*AI DEBUG "..aiBrain.Nickname.." Intel Thread "..Type.." value is "..Threat.." at "..repr(v.Position) )
    
					ForkThread( DrawIntelPoint, v.Position, ThreatTypes[Type].Color, Threat )
				end
		    end
		end
		
		WaitTicks(parseinterval)
	end
	
end

--- the intent of this function is quite clear, it's a counter specifically to so called 'micro' ability
--- being that the 'micro' is based upon tracking both units and events, that no human player has access to, it's only fitting to 
--- infer that it's also okay for LOUD to engage tracking of AI which engage in this behavior, consider this a limited 'micro' for
--- LOUD, which has no impact on human players - nulling this function would be a clear indication of bias

--- now that we've identified this kind of bias we can take other measures - I knew you couldn't resist and 
--- would not bother to examine how the Miasma projectile functions, and as you said YDGAF - lol
function TrackSpoon(projectitem, self)

    local unit = self:GetCurrentTarget()
 
    if not unit or not LOUDENTITY(categories.MOBILE,unit) then
        return
    end

    if unit:BeenDestroyed() or projectitem:BeenDestroyed() then
        return
    end

    local brain = GetAIBrain(unit)

    --if brain.BrainType == "AI" and string.sub( brain.Personality, 1, 1) == 'm' then

        local bp = projectitem:GetBlueprint().Physics

        if (bp.DetonateAboveHeight and bp.DetonateAboveHeight > 0) then
            return
        end
        
        if (bp.DetonateBelowHeight and bp.DetonateBelowHeight > 0) then

            WaitTicks(2)

            if unit:BeenDestroyed() or projectitem:BeenDestroyed() then
                return
            end

            local tpos = projectitem:GetCurrentTargetPosition()
            local mpos = projectitem:GetPosition()
            local theight = GetSurfaceHeight(mpos[1],mpos[3])
            local dist = VDist2( mpos[1],mpos[3], tpos[1],tpos[3] )
            
            local prevelev = mpos[2] - theight
            local prevdist = dist

            while not projectitem:BeenDestroyed() do
        
                tpos = projectitem:GetCurrentTargetPosition()
                mpos = projectitem:GetPosition()
                theight = GetSurfaceHeight(mpos[1],mpos[3])

                dist = VDist2( mpos[1],mpos[3], tpos[1],tpos[3] )
                
                WaitTicks(1)

                if prevdist < 20 then

                    --self:CheckBallisticAcceleration( projectitem )

                    break

                else

                    prevdist = dist
                    prevelev = mpos[2] - theight

                    WaitTicks(1)
                end

            end
        
        elseif projectitem.Distance then

            while (not projectitem:BeenDestroyed()) and projectitem.Distance > 10 do
                WaitTicks(2)
            end

        end

    --end

end

function LogGamePerformanceData()

    local iTimeAtMainTickStart = 0
    local iIntervalInTicks = 100 --Every 10s
    local iCurUnitCount = 0

    local iCurTickCycle = iIntervalInTicks

    local iFreeze1Count = 0
    local iFreeze1Threshold = 0.1
    local iTimeAtSingleTickStart = 0

    while ArmyBrains do

        iTimeAtSingleTickStart = GetSystemTimeSecondsOnlyForProfileUse()

        WaitTicks(1)

        iCurTickCycle = iCurTickCycle - 1

        if GetSystemTimeSecondsOnlyForProfileUse() - iTimeAtSingleTickStart > iFreeze1Threshold then
            iFreeze1Count = iFreeze1Count + 1
        end

        if iCurTickCycle <= 0 then

            iCurUnitCount = 0

            for iBrain, oBrain in ArmyBrains do
                iCurUnitCount = iCurUnitCount + oBrain:GetCurrentUnits(categories.ALLUNITS - categories.BENIGN)
            end

            LOG('LogGamePerformanceData: GameTime='..LOUDFLOOR(GetGameTimeSeconds())..' Time taken='..GetSystemTimeSecondsOnlyForProfileUse() - iTimeAtMainTickStart..'; Unit Count='..iCurUnitCount..'; iFreeze1Count='..iFreeze1Count)

            iCurTickCycle = iIntervalInTicks
            iTimeAtMainTickStart = GetSystemTimeSecondsOnlyForProfileUse()
            iFreeze1Count = 0
        end
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

	local radius = LOUDFLOOR(rallypointradius * .4)

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

function StartSpeedProfile()

    --ForkThread (SpeedProfile)

end

function SpeedProfile()

    -- account for time expended prior to game time starting
    --local startvalue = GetSystemTimeSecondsOnlyForProfileUse()
    
    local GSO = GetSystemTimeSecondsOnlyForProfileUse
    --local GTS = GetGameTimeSeconds()
    
    while true do
    
        local gamesecondsperactualseconds = ( GSO() - startvalue ) / GTS()
        local ax = GTS() / (GSO() - startvalue)
    
        LOG("*AI DEBUG Speed Profile at Gametime "..repr(GTS()).." is "..gamesecondsperactualseconds.." -- "..ax )
    
        -- this will actually be precisely 5 seconds -- at least according to GetGameTimeSeconds
        -- not quite sure where the extra tick is being lost
        WaitTicks(51)
        
    end

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

--]]

-- 	/lua/editor/EconomyBuildConditions.lua
-- a set of functions used to measure Economic conditions

local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
local AIGetReclaimablesAroundLocation = import('/lua/ai/aiutilities.lua').AIGetReclaimablesAroundLocation
local AISortMarkersFromLastPosWithThreatCheck = import('/lua/ai/aiutilities.lua').AISortMarkersFromLastPosWithThreatCheck

local BrainMethods = moho.aibrain_methods

local CanBuildStructureAt   = BrainMethods.CanBuildStructureAt
local GetCurrentUnits       = BrainMethods.GetCurrentUnits
local GetEconomyTrend       = BrainMethods.GetEconomyTrend
local GetEconomyStoredRatio = BrainMethods.GetEconomyStoredRatio
local GetEconomyIncome      = BrainMethods.GetEconomyIncome
local GetEconomyRequested   = BrainMethods.GetEconomyRequested
local GetEconomyStored      = BrainMethods.GetEconomyStored

local GetThreatsAroundPosition = BrainMethods.GetThreatsAroundPosition

BrainMethods = nil

local VDist3 = VDist3

local LOUDENTITY                = EntityCategoryContains
local EntityCategoryCount       = EntityCategoryCount
local EntityCategoryFilterDown  = EntityCategoryFilterDown

local IsUnitState = moho.unit_methods.IsUnitState

local LOUDLOG10 = math.log10
local LOUDMAX   = math.max
local LOUDSORT  = table.sort

local T1FACTORIES = categories.STRUCTURE * categories.TECH1 * categories.FACTORY
local T2FACTORIES = categories.STRUCTURE * categories.TECH2 * categories.FACTORY
local T3FACTORIES = categories.STRUCTURE * categories.TECH3 * categories.FACTORY + categories.GATE
    
local function GetNumCategoryBeingBuiltByEngineers( EM, category, engCategory )

	local counter = 0
    local beingBuiltUnit
    local IsUnitState = IsUnitState
    local LOUDENTITY = LOUDENTITY

    for _,v in EntityCategoryFilterDown( engCategory, EM.EngineerList ) do
		
        if not v.Dead and IsUnitState( v, 'Building' ) then
            
            beingBuiltUnit = v.UnitBeingBuilt
			
			if beingBuiltUnit and not beingBuiltUnit.Dead then
            
				if LOUDENTITY( category, beingBuiltUnit ) then
					counter = counter + 1
				end
			end
		end
    end

    return counter
end

local function GetNumCategoryBeingBuiltByFactories( FBM, category, facCategory )

	local counter = 0
    local beingBuiltUnit
    local IsUnitState = IsUnitState
    local LOUDENTITY = LOUDENTITY

	for _,v in EntityCategoryFilterDown( facCategory, FBM.FactoryList ) do
		
		if v.Dead then
		
			continue
		end

		if not IsUnitState( v, 'Upgrading' ) and not IsUnitState( v, 'Building' ) then
		
			continue
		end

		beingBuiltUnit = v.UnitBeingBuilt	
		
		if not beingBuiltUnit or beingBuiltUnit.Dead then
		
			continue
		end

		if not LOUDENTITY( category, beingBuiltUnit ) then
		
			continue
		end

		counter = counter + 1
	end
	
	return counter    
end

-- this function used to be part of aibrain.lua
-- brought it in here and I now use it to get values from both engineers and factories
local function GetManagerUnitsBeingBuilt( aiBrain, category )
	
	local unitcount = 0
		
    for k,v in aiBrain.BuilderManagers do
		unitcount = unitcount + GetNumCategoryBeingBuiltByEngineers( v.EngineerManager, category, categories.ENGINEER )
		unitcount = unitcount + GetNumCategoryBeingBuiltByFactories( v.FactoryManager, category, categories.FACTORY )
	end	
	return unitcount
end

--- this is here to provide an instant build condition version (used by the ACU builders)
function ThreatCloserThan( aiBrain, locationType, distance, threatcutoff, threattype)

    local position = aiBrain.BuilderManagers[locationType].Position
	
	if position[1] then

        local threatTable = GetThreatsAroundPosition( aiBrain, position, 12, true, threattype)

        local adjustment = 0

        if threatTable[1] then

            if threattype == 'Land' or threattype == 'AntiSurface' and aiBrain.LandRatio > 1 then

                adjustment = LOUDLOG10( aiBrain.VeterancyMult ) + LOUDLOG10( aiBrain.LandRatio )

                distance = distance * ( 1 / (1 + adjustment))    -- don't look as far

                threatcutoff = threatcutoff * (1 + adjustment)   -- and require greater threat to trigger        

            end

            for _,v in threatTable do

                if v[3] > threatcutoff then

                    if VDist2( v[1], v[2], position[1], position[3] ) <= distance then

                        return true
                    end
                    
                end
            end
        end
        
        LOG("*AI DEBUG "..aiBrain.Nickname.." at "..repr(locationType).." fails ThreatCloserThan (EBC) "..distance.." for greater than "..threatcutoff.." "..threattype.." threat  Adjustment "..adjustment )        

	end
	
    return false

end
	
function ReclaimablesInAreaMass(aiBrain, locType, range)

    local ents = AIGetReclaimablesAroundLocation( aiBrain, locType, range )
	
    if ents[1] then
	
		if not aiBrain.BadReclaimables then
			aiBrain.BadReclaimables = {}
		end	
		
		for _,v in ents do
			if (v.MassReclaim and v.MassReclaim > 1) and ((not aiBrain.BadReclaimables[v]) and (not v.BeingReclaimed)) then
				return true
			end
		end
    end
    
    return false
end

function CanBuildOnMassAtRange(aiBrain, locationType, mindistance, maxdistance, tMin, tMax, tRings, tType, maxNum )

    if aiBrain.BuilderManagers[locationType] then
		
		local markerlist = ScenarioInfo['Mass']

		local mlist = {}
		local counter = 0
        local distance, position
        
        local baseposition = aiBrain.BuilderManagers[locationType].Position
        
        local VDist3 = VDist3

        local a,b
        
        local function DOSORT(a,b)
            local VDist3 = VDist3
            return VDist3( a.Position, baseposition) < VDist3( b.Position, baseposition)
        end
        
        LOUDSORT( markerlist, DOSORT )

		local CanBuildStructureAt = CanBuildStructureAt
    
		for _,v in markerlist do
            
            position = v.Position
            distance = VDist3( position, baseposition )
            
            if distance >= mindistance then
            
                if distance <= maxdistance then
                
                    if CanBuildStructureAt( aiBrain, 'ueb1103', position ) then
                        counter = counter + 1
                        mlist[counter] = v
                    end
                end
            end
		end
		
		if counter > 0 then

			markerlist = AISortMarkersFromLastPosWithThreatCheck(aiBrain, mlist, maxNum, tMin, tMax, tRings, tType, baseposition)

			if markerlist then
				return true
			end
		end		
	end
	
    return false
end

function CanBuildOnHydroLessThanDistance(aiBrain, locationType, distance, tMin, tMax, tRings, tType, maxNum )

	if aiBrain.BuilderManagers[locationType] then
		
		local markerlist = ScenarioInfo['Hydrocarbon'] or AIGetMarkerLocations('Hydrocarbon')
		
		local mlist = {}
		local counter = 0
	
		local CanBuildStructureAt = CanBuildStructureAt
        local VDist2Sq = VDist2Sq
    
		for _,v in markerlist do
			if CanBuildStructureAt( aiBrain, 'ueb1102', v.Position ) then
				counter = counter + 1
				mlist[counter] = v
			end
		end
	
		if counter > 0 then
        
			local position = aiBrain.BuilderManagers[locationType].Position

			markerlist = AISortMarkersFromLastPosWithThreatCheck(aiBrain, mlist, maxNum, tMin, tMax, tRings, tType, position)
	    
			if markerlist and VDist2Sq( markerlist[1][1],markerlist[1][3], position[1],position[3] ) < (distance*distance) then
				return true
			end
		end		
	end
	
    return false
end

function GreaterThanEconStorageCurrent(aiBrain, mStorage, eStorage)
	
    if GetEconomyStored( aiBrain, 'MASS') >= mStorage then
		return GetEconomyStored( aiBrain, 'ENERGY') >= eStorage
	end
    return false
end

----------------------
-- ENERGY FUNCTIONS --
----------------------

-- modified to be altered by AI Cheat --
function LessThanEconEnergyStorageCurrent(aiBrain, eStorage)
	return GetEconomyStored( aiBrain, 'ENERGY') < (eStorage * (1/LOUDMAX( 1, aiBrain.CheatValue)))
end

function LessThanEconEnergyStorageRatio(aiBrain, eStorageRatio)
	return (GetEconomyStoredRatio( aiBrain, 'ENERGY') *100) < eStorageRatio
end

function GreaterThanEconEnergyStorageCurrent(aiBrain, eStorage)
    return GetEconomyStored( aiBrain, 'ENERGY') >= (eStorage * (1/LOUDMAX( 1, aiBrain.CheatValue)))
end

function GreaterThanEconEnergyStorageRatio(aiBrain, eStorageRatio)
	return (GetEconomyStoredRatio( aiBrain, 'ENERGY') *100) >= eStorageRatio
end


function LessThanEnergyTrend(aiBrain, eTrend)
	return GetEconomyTrend( aiBrain, 'ENERGY' ) < eTrend
end

function LessThanEnergyTrendOverTime(aiBrain, eTrend)
    return aiBrain.EcoData['OverTime']['EnergyTrend'] < eTrend
end

function GreaterThanEnergyTrend(aiBrain, eTrend)
    return (GetEconomyTrend( aiBrain, 'ENERGY' ) *10) >= eTrend
end

function GreaterThanEnergyTrendOverTime(aiBrain, eTrend)
    return aiBrain.EcoData['OverTime']['EnergyTrend'] >= eTrend
end

function GreaterThanEnergyIncome(aiBrain, eIncome)
	return (GetEconomyIncome( aiBrain, 'ENERGY') *10) >= eIncome
end

--------------------
-- MASS FUNCTIONS --
--------------------

-- modified to be altered by AI Cheat --
function LessThanEconMassStorageCurrent(aiBrain, mStorage)
	return GetEconomyStored( aiBrain, 'MASS' ) < (mStorage * (1/LOUDMAX( 1, aiBrain.CheatValue)))
end

function LessThanEconMassStorageRatio(aiBrain, mStorageRatio)
	return (GetEconomyStoredRatio( aiBrain, 'MASS' ) *100) < mStorageRatio
end

function GreaterThanEconMassStorageRatio(aiBrain, mStorageRatio)
	return (GetEconomyStoredRatio( aiBrain, 'MASS' ) *100) >= mStorageRatio
end

function LessThanMassTrend(aiBrain, mTrend)
	return GetEconomyTrend( aiBrain, 'MASS' ) < mTrend
end

function LessThanMassTrendOverTime(aiBrain, mTrend)
    return aiBrain.EcoData['OverTime']['MassTrend'] <= mTrend
end

function GreaterThanMassTrend(aiBrain, mTrend)
    return (GetEconomyTrend( aiBrain, 'MASS' ) *10) >= mTrend
end

function GreaterThanMassIncome(aiBrain, mIncome)
	return (GetEconomyIncome( aiBrain, 'MASS' ) *10) >= mIncome
end


--------------------------
-- EFFICIENCY FUNCTIONS --
--------------------------

-- combo function combines M/E OverTime Trends with Overtime Efficiency
function GreaterThanEconTrendEfficiencyOverTime(aiBrain, mTrend, eTrend, massefficiency,energyefficiency)

	if GreaterThanEconEfficiencyOverTime(aiBrain, massefficiency or 1, energyefficiency or 1) then

		if aiBrain.EcoData['OverTime']['MassTrend'] >= mTrend then
			return aiBrain.EcoData['OverTime']['EnergyTrend'] >= eTrend
		end
        
	end
    return false
end


function GreaterThanEconEfficiency(aiBrain, mEfficiency, eEfficiency)
    return ((GetEconomyIncome( aiBrain, 'MASS') / GetEconomyRequested( aiBrain, 'MASS')) >= mEfficiency and (GetEconomyIncome( aiBrain, 'ENERGY') / GetEconomyRequested( aiBrain, 'ENERGY')) >= eEfficiency)
end

function LessThanEconEfficiency(aiBrain, mEfficiency, eEfficiency)
    return ((GetEconomyIncome( aiBrain, 'MASS') / GetEconomyRequested( aiBrain, 'MASS')) <= mEfficiency and (GetEconomyIncome( aiBrain, 'ENERGY') / GetEconomyRequested( aiBrain, 'ENERGY')) <= eEfficiency)
end

function GreaterThanEconEfficiencyOverTime(aiBrain, mEfficiency, eEfficiency)
    return (aiBrain.EcoData['OverTime']['MassEfficiency'] >= mEfficiency and aiBrain.EcoData['OverTime']['EnergyEfficiency'] >= eEfficiency)
end

function LessThanEconEfficiencyOverTime(aiBrain, mEfficiency, eEfficiency)
    return (aiBrain.EcoData['OverTime']['MassEfficiency'] <= mEfficiency and aiBrain.EcoData['OverTime']['EnergyEfficiency'] <= eEfficiency)
end


-- this now includes a basic eco check to insure we are positive flow
-- allows us to remove other eco checks in the builder conditions
function MassToFactoryRatioBaseCheck( aiBrain, locationType, massefficiency, energyefficiency )

    local EcoData       = aiBrain.EcoData['OverTime']
    
	local MassIncome    = EcoData.MassIncome
	local EnergyIncome  = EcoData.EnergyIncome
    
    local CheatAdjust = aiBrain.CheatValue or 1

	if ( EcoData.MassRequested > MassIncome) and ( EcoData.EnergyRequested > EnergyIncome) then
    
		if not GreaterThanEconEfficiencyOverTime(aiBrain, massefficiency or 1, energyefficiency or 1) then
			return false
		end
        
	end

	-- mult by 10 to save mult each time during check
	MassIncome = MassIncome * 10
	
    -- ALL Drain values are modified by the cheat level - ie. - cheaters need less to upgrade -
    local cheatmod = 1/CheatAdjust
    
    local t1Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T1Value or 7.5)
    local t2Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T2Value or 14)
    local t3Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T3Value or 20)
	
	local GetCurrentUnits = GetCurrentUnits

    -- T3 Test
	-- get a list of all the T3 factories built plus those about to be built and multiply by the T3 drain
	local factorycount = (GetCurrentUnits( aiBrain, T3FACTORIES ) + GetManagerUnitsBeingBuilt( aiBrain, T3FACTORIES ))
    local massTotal = factorycount * t3Drain
	
	-- compare the drain to the income
    if massTotal > MassIncome then
        return false
    end

    -- T2 Test
	-- add in the consumption of the T2 factories plus those about to be built
    massTotal = massTotal + ((GetCurrentUnits( aiBrain, T2FACTORIES ) + GetManagerUnitsBeingBuilt( aiBrain, T2FACTORIES )) * t2Drain)
	
	-- compare the drain to the income
    if massTotal >  MassIncome then
        return false
    end
	
    -- T1 Test
	-- add in the consumption of the T1 factories plus those about to be built
    massTotal = massTotal + ((GetCurrentUnits( aiBrain, T1FACTORIES ) + GetManagerUnitsBeingBuilt( aiBrain, T1FACTORIES )) * t1Drain)
    
	-- compare the drain to the income
	-- and add in consumption of the new factory
    if (massTotal + t1Drain) >  MassIncome then
        return false
    end
    
    return true    
end

-- 	/lua/editor/EconomyBuildConditions.lua
-- a set of functions used to measure Economic conditions

local AIGetMarkerLocations = import('/lua/ai/aiutilities.lua').AIGetMarkerLocations
local AIGetReclaimablesAroundLocation = import('/lua/ai/aiutilities.lua').AIGetReclaimablesAroundLocation
local AISortMarkersFromLastPosWithThreatCheck = import('/lua/ai/aiutilities.lua').AISortMarkersFromLastPosWithThreatCheck

local LOUDGETN = table.getn

local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio
local GetEconomyIncome = moho.aibrain_methods.GetEconomyIncome

local GetEconomyRequested = moho.aibrain_methods.GetEconomyRequested
local GetEconomyStored = moho.aibrain_methods.GetEconomyStored


function ReclaimablesInAreaMass(aiBrain, locType, range)

    local ents = AIGetReclaimablesAroundLocation( aiBrain, locType, range )
	
    if ents and LOUDGETN(ents) > 0 then
	
		if not aiBrain.BadReclaimables then
			aiBrain.BadReclaimables = {}
		end	
		
		for _,v in ents do
			if (v.MassReclaim and v.MassReclaim > 0) and ((not aiBrain.BadReclaimables[v]) and (not v.BeingReclaimed)) then
				return true
			end
		end
    end
    return false
end

function CanBuildOnMassAtRange(aiBrain, locationType, mindistance, maxdistance, tMin, tMax, tRings, tType, maxNum )

    if aiBrain.BuilderManagers[locationType] then
		
		local markerlist = ScenarioInfo.Env.Scenario.MasterChain['Mass']

		local mlist = {}
		local counter = 0
        local position = aiBrain.BuilderManagers[locationType].Position
        
        table.sort( markerlist, function (a,b) return VDist3( a.Position, position ) < VDist3( b.Position, position ) end )

		local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
    
		for _,v in markerlist do
            
            if VDist3( v.Position, position ) >= mindistance then
            
                if VDist3( v.Position, position ) <= maxdistance then
                
                    if CanBuildStructureAt( aiBrain, 'ueb1103', v.Position ) then
                        counter = counter + 1
                        mlist[counter] = v
                    end
                end
            end
		end
		
		if counter > 0 then

			local markerTable = AISortMarkersFromLastPosWithThreatCheck(aiBrain, mlist, maxNum, tMin, tMax, tRings, tType, position)

			if markerTable then
				return true
			end
		end		
	end
	
    return false
end

function CanBuildOnHydroLessThanDistance(aiBrain, locationType, distance, tMin, tMax, tRings, tType, maxNum )

	if aiBrain.BuilderManagers[locationType] then
		
		local markerlist = ScenarioInfo.Env.Scenario.MasterChain['Hydrocarbon'] or AIGetMarkerLocations('Hydrocarbon')
		
		local mlist = {}
		local counter = 0
	
		local CanBuildStructureAt = moho.aibrain_methods.CanBuildStructureAt
    
		for _,v in markerlist do
			if CanBuildStructureAt( aiBrain, 'ueb1102', v.Position ) then
				counter = counter + 1
				mlist[counter] = v
			end
		end
	
		if counter > 0 then
			local position = aiBrain.BuilderManagers[locationType].Position
			local markerTable = AISortMarkersFromLastPosWithThreatCheck(aiBrain, mlist, maxNum, tMin, tMax, tRings, tType, position)
	    
			if markerTable and VDist2Sq( markerTable[1][1],markerTable[1][3], position[1],position[3] ) < (distance*distance) then
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

-- modified to be altered by AI Cheat --
function LessEconEnergyStorageCurrent(aiBrain, eStorage)
	return GetEconomyStored( aiBrain, 'ENERGY') < (eStorage * (1/math.max( 1, aiBrain.CheatValue)))
end

function LessThanEconEnergyStorageRatio(aiBrain, eStorageRatio)
	return (GetEconomyStoredRatio( aiBrain, 'ENERGY')*100) < eStorageRatio
end

function LessThanEconMassStorageRatio(aiBrain, mStorageRatio)
	return (GetEconomyStoredRatio(aiBrain,'MASS')*100) < mStorageRatio
end

function GreaterThanEconMassStorageRatio(aiBrain, mStorageRatio)
	return (GetEconomyStoredRatio(aiBrain,'MASS')*100) >= mStorageRatio
end

-- I built the EconEfficiencyCheck into this function since Trend is current
-- and not averaged as I thought it was -- this allows us to do two things at once
-- insure that we have the extra mass and energy AND that we are positive overall
-- so we can remove the extra conditions in the builders -- less conditions is good
function GreaterThanEconTrendEfficiencyOverTime(aiBrain, mTrend, eTrend, massefficiency,energyefficiency)

	if GreaterThanEconEfficiencyOverTime(aiBrain, massefficiency or 1, energyefficiency or 1) then
    
        --LOG("*AI DEBUG "..aiBrain.Nickname.." EconTrend Mass "..repr(aiBrain.EcoData['OverTime'].MassTrend).." Energy "..repr(aiBrain.EcoData['OverTime'].EnergyTrend))
		
		if aiBrain.EcoData['OverTime'].MassTrend >= mTrend then
			return aiBrain.EcoData['OverTime'].EnergyTrend >= eTrend
		end
	end
    return false
end

function LessThanEnergyTrend(aiBrain, eTrend)
	return GetEconomyTrend( aiBrain, 'ENERGY' ) < eTrend
end

function GreaterThanEnergyTrend(aiBrain, eTrend)
    return GetEconomyTrend( aiBrain, 'ENERGY' ) >= eTrend
end

function GreaterThanEnergyIncome(aiBrain, eIncome)
	return (GetEconomyIncome( aiBrain, 'ENERGY')*10) >= eIncome
end

function GreaterThanEconEfficiency(aiBrain, mEfficiency, eEfficiency)
    return ((GetEconomyIncome( aiBrain, 'MASS') / GetEconomyRequested( aiBrain, 'MASS')) >= mEfficiency and (GetEconomyIncome( aiBrain, 'ENERGY') / GetEconomyRequested( aiBrain, 'ENERGY')) >= eEfficiency)
end

function LessThanEconEfficiency(aiBrain, mEfficiency, eEfficiency)
    return ((GetEconomyIncome( aiBrain, 'MASS') / GetEconomyRequested( aiBrain, 'MASS')) <= mEfficiency and (GetEconomyIncome( aiBrain, 'ENERGY') / GetEconomyRequested( aiBrain, 'ENERGY')) <= eEfficiency)
end

function GreaterThanEconEfficiencyOverTime(aiBrain, mEfficiency, eEfficiency)

    --LOG("*AI DEBUG "..aiBrain.Nickname.." Econ Efficiency M "..aiBrain.EcoData['OverTime'].MassEfficiency.."  E "..aiBrain.EcoData['OverTime'].EnergyEfficiency )

    return (aiBrain.EcoData['OverTime'].MassEfficiency >= mEfficiency and aiBrain.EcoData['OverTime'].EnergyEfficiency >= eEfficiency)
end

function LessThanEconEfficiencyOverTime(aiBrain, mEfficiency, eEfficiency)
    return (aiBrain.EcoData['OverTime'].MassEfficiency <= mEfficiency and aiBrain.EcoData['OverTime'].EnergyEfficiency <= eEfficiency)
end

-- this now includes a basic eco check to insure we are positive flow
-- allows us to remove other eco checks in the builder conditions
function MassToFactoryRatioBaseCheck( aiBrain, locationType, massefficiency, energyefficiency )

	local MassIncome = aiBrain.EcoData['OverTime'].MassIncome
	local EnergyIncome = aiBrain.EcoData['OverTime'].EnergyIncome
    
    local CheatAdjust = aiBrain.CheatValue or 1

	if (aiBrain.EcoData['OverTime'].MassRequested > MassIncome) and (aiBrain.EcoData['OverTime'].EnergyRequested > EnergyIncome) then
		if not GreaterThanEconEfficiencyOverTime(aiBrain, massefficiency or 1, energyefficiency or 1) then
			return false
		end
	end
	
	-- this function used to be part of aibrain.lua
	-- brought it in here and I now use it to get values from both engineers and factories
	local function GetManagerUnitsBeingBuilt( category )
	
		local unitcount = 0
		
	    for k,v in aiBrain.BuilderManagers do
			unitcount = unitcount + v.EngineerManager:GetNumCategoryBeingBuilt( category, categories.ENGINEER )
			unitcount = unitcount + v.FactoryManager:GetNumCategoryBeingBuilt( category, categories.FACTORY )
		end	
		return unitcount
	end
	
	-- mult by 10 to save mult each time during check
	MassIncome = MassIncome * 10
	
    -- ALL Drain values are modified by the cheat level - ie. - cheaters need less to upgrade -
    local cheatmod = 1/CheatAdjust
    
    local t1Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T1Value or 8)
    local t2Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T2Value or 13)
    local t3Drain = cheatmod * (aiBrain.BuilderManagers[locationType].BaseSettings.MassToFactoryValues.T3Value or 18)
	
	local GetCurrentUnits = moho.aibrain_methods.GetCurrentUnits

    -- T3 Test
	-- get a list of all the T3 factories built plus those about to be built and multiply by the T3 drain
	local factorycount = (GetCurrentUnits( aiBrain, categories.TECH3 * categories.FACTORY + categories.GATE ) + GetManagerUnitsBeingBuilt(categories.TECH3 * categories.FACTORY + categories.GATE))
    local massTotal = factorycount * t3Drain
	
	-- compare the drain to the income
    if massTotal > MassIncome then
        return false
    end

    -- T2 Test
	-- add in the consumption of the T2 factories plus those about to be built
    massTotal = massTotal + ((GetCurrentUnits( aiBrain, categories.TECH2 * categories.FACTORY) + GetManagerUnitsBeingBuilt(categories.TECH2 * categories.FACTORY)) * t2Drain)
	
	-- compare the drain to the income
    if massTotal >  MassIncome then
        return false
    end
	
    -- T1 Test
	-- add in the consumption of the T1 factories plus those about to be built
    massTotal = massTotal + ((GetCurrentUnits( aiBrain, categories.TECH1 * categories.FACTORY ) + GetManagerUnitsBeingBuilt(categories.TECH1 * categories.FACTORY)) * t1Drain)
    
	-- compare the drain to the income
	-- and add in consumption of the new factory
    if (massTotal + t1Drain) >  MassIncome then
        return false
    end
    
    return true    
end

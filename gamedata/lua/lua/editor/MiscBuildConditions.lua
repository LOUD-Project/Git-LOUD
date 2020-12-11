--**  File     :  /lua/MiscBuildConditions.lua

local AIGetClosestMarkerLocation = import('/lua/ai/aiutilities.lua').AIGetClosestMarkerLocation
local AIGetReclaimablesAroundLocation = import('/lua/ai/aiutilities.lua').AIGetReclaimablesAroundLocation
local LOUDGETN = table.getn



function RandomNumber(aiBrain, higherThan, lowerThan, minNumber, maxNumber)

    local num = Random( minNumber, maxNumber)
	
    if higherThan < num and lowerThan > num then
        return true
    end
    return false
end

function FactionIndex(aiBrain, factionNum, otherFactionNum, thirdFacNum)

	if aiBrain.FactionIndex == factionNum then
		return true
	end
	
	if otherFactionNum and aiBrain.FactionIndex == otherFactionNum then
		return true
	end
	
	if thirdFacNum and aiBrain.FactionIndex == thirdFacNum then
		return true
	end
	
	return false
end

function ReclaimablesInArea(aiBrain, locType, range)

    local ents = AIGetReclaimablesAroundLocation( aiBrain, locType, range )
	
    if ents and LOUDGETN(ents) > 0 then
	
		if not aiBrain.BadReclaimables then
			aiBrain.BadReclaimables = {}
		end	
		
		for _,v in ents do
			if ( (v.MassReclaim and v.MassReclaim > 0) or (v.EnergyReclaim and v.EnergyReclaim > 0) ) and ((not aiBrain.BadReclaimables[v]) and (not v.BeingReclaimed)) then
				return true
			end
		end
    end
    return false
end

function ReclaimablesInAreaEnergy(aiBrain, locType)

    local ents = AIGetReclaimablesAroundLocation( aiBrain, locType )
	
    if ents and LOUDGETN(ents) > 0 then
	
		if not aiBrain.BadReclaimables then
			aiBrain.BadReclaimables = {}
		end	
		
		for _,v in ents do
			if (v.EnergyReclaim and v.EnergyReclaim > 0) and ((not aiBrain.BadReclaimables[v]) and (not v.BeingReclaimed)) then
				return true
			end
		end
    end
    return false
end

function GreaterThanGameTime(aiBrain, num)
    return GetGameTimeSeconds() > num
end

function LessThanGameTime(aiBrain, num)
    return GetGameTimeSeconds() < num
end

function IsIsland(aiBrain, check) 

	if not aiBrain.islandCheck then 
		local startX, startZ = aiBrain:GetArmyStartPos()
		
		aiBrain.isIsland = false
		aiBrain.islandMarker = AIGetClosestMarkerLocation(aiBrain, 'Island', startX, startZ)
		aiBrain.islandCheck = true
		
		if aiBrain.islandMarker then
			aiBrain.isIsland = true
		end
	end
	return check == aiBrain.isIsland
end

-- this aibrain value will be set when the builder tables are loaded
-- see AIAddBuilderTable.lua
function IsWaterMap(aiBrain, bool)
	return bool == ScenarioInfo.IsWaterMap
end

function MapGreaterThan(aiBrain, size )	
	return (ScenarioInfo.size[1] > size or ScenarioInfo.size[2] > size)
end

function MapLessThan(aiBrain, size )
	return (ScenarioInfo.size[1] <= size or ScenarioInfo.size[2] <= size)	
end


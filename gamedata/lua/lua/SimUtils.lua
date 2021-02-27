---		/lua/SimUtils.lua
-- General Sim scripts


-- Diplomacy

function BreakAlliance( data )

    -- You can't change alliances in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if OkayToMessWithArmy(data.From) then
        SetAlliance(data.From,data.To,"Enemy")

        if Sync.BrokenAlliances == nil then
            Sync.BrokenAlliances = {}
        end
        table.insert(Sync.BrokenAlliances, { From = data.From, To = data.To })
    end
    import('/lua/simping.lua').OnAllianceChange()
end

function OnAllianceResult( resultData )

    -- You can't change alliances in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if OkayToMessWithArmy(resultData.From) then
        if resultData.ResultValue == "accept" then
            SetAlliance(resultData.From,resultData.To,"Ally")
            if Sync.FormedAlliances == nil then
                Sync.FormedAlliances = {}
            end
            table.insert(Sync.FormedAlliances, { From = resultData.From, To = resultData.To })
        end
    end
    import('/lua/simping.lua').OnAllianceChange()
end

import('/lua/simplayerquery.lua').AddResultListener( "OfferAlliance", OnAllianceResult )

function TransferUnitsOwnership(units, ToArmyIndex)

    local toBrain = GetArmyBrain(ToArmyIndex)
	
    if (not toBrain) or toBrain:IsDefeated() or (not units) or table.getn(units) < 1 then
        return
    end
	
    local newUnits = {}
	
    for k,v in units do
	
        local owner = v:GetArmy()

        local unit = v
        local bp = unit:GetBlueprint()
        local unitId = unit:GetUnitId()
		
        -- B E F O R E
        local numNukes = unit:GetNukeSiloAmmoCount()  #looks like one of these 2 works for SMDs also
        local numTacMsl = unit:GetTacticalSiloAmmoCount()
        local unitKills = unit:GetStat('KILLS', 0).Value   #also takes care of the veteran level
        local unitHealth = unit:GetHealth()

		local shieldIsOn = false
        local ShieldHealth = 0
		
        local hasFuel = false
        local fuelRatio = 0
		
        local enh = {}

        if unit.MyShield then
		
			shieldIsOn = unit:ShieldIsOn()
            ShieldHealth = unit.MyShield:GetHealth()
			
			unit:DisableShield()
        end
		
        if bp.Physics.FuelUseTime and bp.Physics.FuelUseTime > 0 then
            fuelRatio = unit:GetFuelRatio()
            hasFuel = true
        end
		
        local posblEnh = bp.Enhancements
		
        if posblEnh then
            for k,v in posblEnh do
                if unit:HasEnhancement( k ) then
                   table.insert( enh, k )
                end
            end
        end

        -- changing owner
		
		unit:OnBeforeTransferingOwnership(ToArmyIndex)
		
        unit = ChangeUnitArmy(unit,ToArmyIndex)
		
        if not unit then
            continue
        end
		
        table.insert(newUnits, unit)

        -- A F T E R
        if unitKills and unitKills > 0 then # set veterancy first
            unit:AddKills( unitKills )
        end
		
        if enh and table.getn(enh) > 0 then
            for k, v in enh do
                unit:CreateEnhancement( v )
            end
        end
		
        if unitHealth > unit:GetMaxHealth() then
            unitHealth = unit:GetMaxHealth()
        end
		
        unit:SetHealth(unit,unitHealth)
		
        if hasFuel then
            unit:SetFuelRatio(fuelRatio)
        end
		
        if numNukes and numNukes > 0 then
            unit:GiveNukeSiloAmmo( (numNukes - unit:GetNukeSiloAmmoCount()) )
        end
		
        if numTacMsl and numTacMsl > 0 then
            unit:GiveTacticalSiloAmmo( (numTacMsl - unit:GetTacticalSiloAmmoCount()) )
        end
		
        if unit.MyShield then
		
            unit.MyShield:SetHealth( unit, ShieldHealth )
			
			if shieldIsOn then
				unit:EnableShield()
			else
				unit:DisableShield()
			end
        end
		
		unit:OnAfterTransferingOwnership(owner)
    end
	
    return newUnits
end

function GiveUnitsToPlayer( data, units )
    if units then
        if OkayToMessWithArmy(units[1]:GetArmy()) then
            TransferUnitsOwnership( units, data.To )
        end
    end
end

function GiveResourcesToPlayer( data )
    if not OkayToMessWithArmy(data.From) then return end
    local fromBrain = GetArmyBrain(data.From)
    local toBrain = GetArmyBrain(data.To)
    if fromBrain:IsDefeated() or toBrain:IsDefeated() then return end
    local massTaken = fromBrain:TakeResource('Mass',data.Mass * fromBrain:GetEconomyStored('Mass'))
    local energyTaken = fromBrain:TakeResource('Energy',data.Energy * fromBrain:GetEconomyStored('Energy'))
    toBrain:GiveResource('Mass',massTaken)
    toBrain:GiveResource('Energy',energyTaken)
end

function SetResourceSharing( data )
    if not OkayToMessWithArmy(data.Army) then return end
    local brain = GetArmyBrain(data.Army)
    brain:SetResourceSharing(data.Value)
end

function RequestAlliedVictory( data )
    -- You can't change this in a team game
    if ScenarioInfo.TeamGame then
        return
    end

    if not OkayToMessWithArmy(data.Army) then return end

    local brain = GetArmyBrain(data.Army)
    brain.RequestingAlliedVictory = data.Value
end

function SetOfferDraw(data)
    if not OkayToMessWithArmy(data.Army) then return end

    local brain = GetArmyBrain(data.Army)
    brain.OfferingDraw = data.Value
end

-- Orders

function AreaReclaim(data, units)
    local allReclaimables = GetReclaimablesInRect(Rect(
		data.MousePos[1] - 3.5, 
		data.MousePos[3] - 3.5, 
		data.MousePos[1] + 3.5, 
		data.MousePos[3] + 3.5))
    if not allReclaimables or table.empty(allReclaimables) then
        return
    end
    -- Don't allow reclaiming of living units so user doesn't reclaim own stuff
    for i, v in allReclaimables do
        if v.BlueprintID then
            allReclaimables[i] = nil
        end
    end
	local numRecs = table.getn(allReclaimables)
	local numUnits = table.getn(units)

	local recArrays = {}

	-- Number of reclaimers dictates how many times reclaimables table must be divided
	for i = 1, numUnits do
		recArrays[i] = {}
	end

    -- Loop over reclaimers, assigning 1 reclaimable to each
    -- Iterate over recArrays as many times as needed to assign every reclaimable
	local j = 1
	local i, rec = next(allReclaimables, nil)
	while i do
		table.insert(recArrays[j], rec)
        i, rec = next(allReclaimables, i)
        j = j + 1
        if j > numUnits then j = 1 end
	end

    for i, arr in recArrays do
        for _, rec in arr do
            IssueReclaim({ units[i] }, rec)
        end
    end
end


-- UNIT CAP

--[[
function UpdateUnitCap()
    # If we are asked to share out unit cap for the defeated army, do the following...
    if not ScenarioInfo.Options.DoNotShareUnitCap then
        local aliveCount = 0
        for k,brain in ArmyBrains do
            if not brain:IsDefeated() then
                aliveCount = aliveCount + 1
            end
        end
        if aliveCount > 0 then
            local initialCap = tonumber(ScenarioInfo.Options.UnitCap)
            local totalCap = aliveCount * initialCap
            for k,brain in ArmyBrains do
                if not brain:IsDefeated() then
                    SetArmyUnitCap(brain:GetArmyIndex(),math.floor(totalCap / aliveCount))
                end
            end
        end
    end
end
--]]

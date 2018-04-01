do

local Entity = import('/lua/sim/Entity.lua').Entity

function CreateArmyUnit(strArmy,strUnit)

    local tblUnit = FindUnit(strUnit,Scenario.Armies[strArmy].Units)
    local brain = GetArmyBrain(strArmy)
	
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), true)
    end
	
	#-- Replace Human Player Command unit with BOACU commander unit
	if brain.BrainType == 'Human' then
	
		if nil != tblUnit then
			if string.sub(tblUnit.type, 1, 7) == 'ual0001' then
				tblUnit.type = 'eal0001'
			elseif string.sub(tblUnit.type, 1, 7) == 'uel0001' then
				tblUnit.type = 'eel0001'
			elseif string.sub(tblUnit.type, 1, 7) == 'url0001' then
				tblUnit.type = 'erl0001'
			end
			
			local unit = CreateUnitHPR(
				tblUnit.type,
				strArmy,
				tblUnit.Position[1], tblUnit.Position[2], tblUnit.Position[3],
				tblUnit.Orientation[1], tblUnit.Orientation[2], tblUnit.Orientation[3]
			)
			
			if unit:GetBlueprint().Physics.FlattenSkirt then
				unit:CreateTarmac(true, true, true, false, false)
			end 
		
			local platoon
			local brain = GetArmyBrain(strArmy)
		
			if tblUnit.platoon ~= nil and tblUnit.platoon ~= '' then
				local i = 3
				
				while i <= table.getn(Scenario.Platoons[tblUnit.platoon]) do
					if tblUnit.Type == currTemplate[i][1] then
						platoon = brain:MakePlatoon('None', 'None')
						brain:AssignUnitsToPlatoon(platoon, {unit}, currTemplate[i][4], currTemplate[i][5])
						break
					end
					
					i = i + 1
				end
			end
			
			local armyIndex = brain:GetArmyIndex()
			
			if ScenarioInfo.UnitNames[armyIndex] then
				ScenarioInfo.UnitNames[armyIndex][strUnit] = unit
			end
			
			unit.UnitName = strUnit
			
			if not brain.IgnoreArmyCaps then
				SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
			end
			
			return unit, platoon, tblUnit.platoon
		end
		
	else
		#-- Replace AI Command Unit with BOACU commander
		if nil != tblUnit then
		
			local unit = CreateUnitHPR(
				tblUnit.type,
				strArmy,
				tblUnit.Position[1], tblUnit.Position[2], tblUnit.Position[3],
				tblUnit.Orientation[1], tblUnit.Orientation[2], tblUnit.Orientation[3]
			)
			
			if unit:GetBlueprint().Physics.FlattenSkirt then
				unit:CreateTarmac(true, true, true, false, false)
			end             
			
			local platoon
			local brain = GetArmyBrain(strArmy)
			
			if tblUnit.platoon ~= nil and tblUnit.platoon ~= '' then
			
				local i = 3
				
				while i <= table.getn(Scenario.Platoons[tblUnit.platoon]) do
				
					if tblUnit.Type == currTemplate[i][1] then
						platoon = brain:MakePlatoon('None', 'None')
						brain:AssignUnitsToPlatoon(platoon, {unit}, currTemplate[i][4], currTemplate[i][5])
						break
					end
					
					i = i + 1
				end
			end
			
			local armyIndex = brain:GetArmyIndex()
			
			if ScenarioInfo.UnitNames[armyIndex] then
				ScenarioInfo.UnitNames[armyIndex][strUnit] = unit
			end
			
			unit.UnitName = strUnit
			
			if not brain.IgnoreArmyCaps then
				SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
			end
			
			return unit, platoon, tblUnit.platoon
		end
		
	end
	
    if not brain.IgnoreArmyCaps then
        SetIgnoreArmyUnitCap(brain:GetArmyIndex(), false)
    end
	
    return nil
end

end
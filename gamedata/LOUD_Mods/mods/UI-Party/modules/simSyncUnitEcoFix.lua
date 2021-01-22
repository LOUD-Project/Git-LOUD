function Invoke()
	pcall(function()
		Sync.FixedEcoData = {}

		if GetFocusArmy() ~= -1 then
			local brain = ArmyBrains[GetFocusArmy()]
			local units = brain:GetListOfUnits(categories.ALLUNITS, false)
			for k, unit in units do
				-- LOG(unit:GetEconData())
				if not unit:IsDead() then

					local econData = {
						massConsumed = 0,
						energyConsumed = 0,
						-- d=unit:GetBlueprint().Description
					}

					local f = unit:GetFocusUnit()
					if f and EntityCategoryContains(categories.SILO, f) and not unit:IsUnitState("Building") then
						continue;
					else
						econData.massConsumed = unit:GetConsumptionPerSecondMass() * unit:GetResourceConsumed()
						econData.energyConsumed = unit:GetConsumptionPerSecondEnergy() * unit:GetResourceConsumed()
					end

					Sync.FixedEcoData[unit:GetEntityId()] = econData
				end
			end
		end
	end)
	-- if not a then
	-- 	LOG("UI PARTY RESULT: ", a, b)
	-- end
end

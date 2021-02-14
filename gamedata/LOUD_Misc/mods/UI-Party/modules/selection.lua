local LINQ = import('/mods/UI-Party/modules/linq.lua')

function SelectSimilarOnscreenUnits()
	local units = GetSelectedUnits()
	if (units ~= nil) then
		local blueprints = LINQ.Select(units, function(k, u) return u:GetBlueprint() end)
		blueprints = LINQ.Distinct(blueprints)
		local str = ''
		for _, v in blueprints do
			str = str .. "+inview " .. v.BlueprintId .. ","
		end
		-- Dodgy hack
		-- ~ Crotalus
		ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE")
	end
end

function SelectOnScreenDirectFireLandUnits()
	-- MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT
	import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND DIRECTFIRE -ENGINEER -SCOUT')
end

function SelectOnScreenSupportLandUnits()
	-- (MOBILE LAND -DIRECTFIRE -ENGINEER) +(MOBILE LAND SCOUT)
	import('/lua/keymap/smartSelection.lua').smartSelect('+inview MOBILE LAND -DIRECTFIRE -ENGINEER')
	ForkThread(function()
		ConExecute("Ui_SelectByCategory +add +inview MOBILE LAND SCOUT")
	end)
end
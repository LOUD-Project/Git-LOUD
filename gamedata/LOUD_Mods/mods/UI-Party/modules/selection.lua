function SelectSimilarOnscreenUnits()
	UIPLOG("Here")
	local units = GetSelectedUnits()
	if (units ~= nil) then
		local blueprints = from(units).select(function(k, u) return u:GetBlueprint(); end).distinct()
		local str = ''
		blueprints.foreach(function(k,v)
			str = str .. "+inview " .. v.BlueprintId .. ","
		end)
		ConExecute("Ui_SelectByCategory " .. str .. "SOMETHINGUNPOSSIBLE") -- dodgy hack at the end there to
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
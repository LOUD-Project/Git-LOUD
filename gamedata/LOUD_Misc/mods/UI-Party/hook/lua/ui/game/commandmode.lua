
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldOnCommandIssued = OnCommandIssued
function OnCommandIssued(command)
	if UIP.GetSetting("factoriesStartWithRepeatOn") then
		if command.CommandType == "Guard" and command.Target.Type == "Entity" then
			local target = GetUnitById(command.Target.EntityId)
			if target ~= nil and target:IsInCategory("FACTORY") then
				local units = command.Units
				local factories = EntityCategoryFilterDown(categories.FACTORY, units)
				for _, v in factories do
					v:ProcessInfo('SetRepeatQueue', 'false')
				end
			end
		end
		if command.CommandType == "Stop" then
			local units = command.Units
			local factories = EntityCategoryFilterDown(categories.FACTORY, units)
			for _, v in factories do
				v:ProcessInfo('SetRepeatQueue', 'true')
			end
		end
	end
	oldOnCommandIssued(command)
end
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')

local oldOnGameOver = OnGameOver
function OnGameOver()
	oldOnGameOver()

	if UIP.GetSetting("hideMenusOnStart") then 
		Expand()
	end

end

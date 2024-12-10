
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldPositionWindow = PositionWindow
function PositionWindow()
	oldPositionWindow()

	if UIP.Enabled() and UIP.GetSetting("rearrangeBottomPanes") then 

		local controls = import('/lua/ui/game/unitview.lua').controls
		LayoutHelpers.AtLeftBottomIn(controls.bg, controls.parent, 17)
		LayoutHelpers.AtLeftBottomIn(controls.abilities, controls.bg, 30, 168)

	end
end

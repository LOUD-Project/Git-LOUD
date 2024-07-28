
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldPositionWindow = PositionWindow
function PositionWindow()
	oldPositionWindow()

	if UIP.Enabled() and UIP.GetSetting("rearrangeBottomPanes") then 

		local controls = import('/lua/ui/game/unitview.lua').controls
		LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
		controls.abilities.Left:Set(function() return LayoutHelpers.ScaleNumber(30) end)
		LayoutHelpers.AnchorToBottom(controls.abilities, controls.bg, 134)
		LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 17)

	end
end

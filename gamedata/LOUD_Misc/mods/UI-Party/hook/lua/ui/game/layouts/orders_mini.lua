
local UIP = import('/mods/UI-Party/modules/UI-Party.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local oldSetLayout = SetLayout
function SetLayout()
	oldSetLayout()

	if UIP.Enabled() and UIP.GetSetting("rearrangeBottomPanes") then 

		local controls = import('/lua/ui/game/orders.lua').controls
		LayoutHelpers.AtLeftIn(controls.bg, controls.controlClusterGroup, 350)

	end

end



local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')

do
numSlots = UIUtil.OrderLayout_Params('numSlots') or 12
firstAltSlot = UIUtil.OrderLayout_Params('firstAltSlot') or 7
vertRows = UIUtil.OrderLayout_Params('vertRows') or 6
horzRows = UIUtil.OrderLayout_Params('horzRows') or 2
vertCols = numSlots/vertRows
horzCols = numSlots/horzRows

local oldSetLayout = SetLayout
function SetLayout()

	oldSetLayout()
	
    local controls = import('/lua/ui/game/orders.lua').controls
        
	local params = UIUtil.OrderLayout_Params('iconsize')
	
	if params then 
		controls.bg.Width:Set(220)
		controls.bg.Height:Set(110)
		controls.orderButtonGrid.Width:Set(params.Width * horzCols)
		controls.orderButtonGrid.Height:Set(params.Height * horzRows)
		LayoutHelpers.AtCenterIn(controls.orderButtonGrid, controls.bg, 2, -2)
	else
		controls.orderButtonGrid.Width:Set(GameCommon.iconWidth * horzCols)
		controls.orderButtonGrid.Height:Set(GameCommon.iconHeight * horzRows)
		LayoutHelpers.AtCenterIn(controls.orderButtonGrid, controls.bg, 50, -6)
	end
    
    controls.bg.Mini = function(state)
        controls.bg:SetHidden(state)
        controls.orderButtonGrid:SetHidden(state)
    end
end

end
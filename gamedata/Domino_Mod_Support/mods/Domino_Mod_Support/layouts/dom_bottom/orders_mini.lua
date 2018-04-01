
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local GameCommon = import('/lua/ui/game/gamecommon.lua')

local numSlots = UIUtil.OrderLayout_Params('numSlots') or 12
local firstAltSlot = UIUtil.OrderLayout_Params('firstAltSlot') or 7
local vertRows = UIUtil.OrderLayout_Params('vertRows') or 6
local horzRows = UIUtil.OrderLayout_Params('horzRows') or 2
local vertCols = numSlots/vertRows
local horzCols = numSlots/horzRows

function SetLayout()
    local controls = import('/lua/ui/game/orders.lua').controls
		
    controls.bg:SetTexture(UIUtil.SkinnableFile('/game/orders-panel/order-panels_bmp.dds'))
	
	LayoutHelpers.AtLeftIn(controls.bg, controls.controlClusterGroup, 75)
	LayoutHelpers.AtBottomIn(controls.bg, controls.controlClusterGroup, 138)

    LayoutHelpers.ResetRight(controls.bg)
    LayoutHelpers.ResetTop(controls.bg)
    
    controls.bracket:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_t.dds'))
    LayoutHelpers.AtLeftIn(controls.bracket, controls.bg, -17)
    LayoutHelpers.AtTopIn(controls.bracket, controls.bg, -2)
    LayoutHelpers.ResetBottom(controls.bracket)
    LayoutHelpers.ResetRight(controls.bracket)
    
    controls.bracketMax:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_b.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMax, controls.bracket)
    LayoutHelpers.AtBottomIn(controls.bracketMax, controls.bg, -2)
    
    controls.bracketMid:SetTexture(UIUtil.UIFile('/game/bracket-left/bracket_bmp_m.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMid, controls.bracket, 7)
    controls.bracketMid.Top:Set(controls.bracket.Bottom)
    controls.bracketMid.Bottom:Set(controls.bracketMax.Top)
    
    if controls.bracketRightMin then
        controls.bracketRightMin:Destroy()
        controls.bracketRightMax:Destroy()
        controls.bracketRightMid:Destroy()
        
        controls.bracketRightMin = nil
        controls.bracketRightMax = nil
        controls.bracketRightMid = nil
    end
    	
	local params = UIUtil.OrderLayout_Params('iconsize')
	
	if params then 
		controls.bg.Width:Set(200)
		controls.bg.Height:Set(110)
		controls.orderButtonGrid.Width:Set(params.Width * horzCols)
		controls.orderButtonGrid.Height:Set(params.Height * horzRows)
		LayoutHelpers.AtCenterIn(controls.orderButtonGrid, controls.bg, -1, -1)
	else
		controls.orderButtonGrid.Width:Set(GameCommon.iconWidth * horzCols)
		controls.orderButtonGrid.Height:Set(GameCommon.iconHeight * horzRows)
		LayoutHelpers.AtCenterIn(controls.orderButtonGrid, controls.bg, 25, 1)
	end
	
    controls.orderButtonGrid:AppendRows(horzRows)
    controls.orderButtonGrid:AppendCols(horzCols)
    
    controls.bg.Mini = function(state)
        controls.bg:SetHidden(state)
        controls.orderButtonGrid:SetHidden(state)
    end
end
--[[

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

function PositionWindow()

    local controls = import('/lua/ui/game/unitview.lua').controls
    local consControl = import('/lua/ui/game/construction.lua').controls.constructionGroup
    
    if consControl:IsHidden() then
        LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
        controls.abilities.Bottom:Set(function() return controls.bg.Bottom() - 24 end)
    else
        LayoutHelpers.AtBottomIn(controls.bg, controls.parent, 147)
        controls.abilities.Bottom:Set(function() return controls.bg.Bottom() - 23 end)
    end
    
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 17)
end
--]]
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local modPath = '/mods/SupremeScoreBoard/'
local modTextures = modPath..'textures/'
local modScripts  = modPath..'modules/'
local log  = import(modScripts..'ext.logging.lua')

function SetLayout()
    LOG('>>>> HUSSAR: score_mini SetLayout... ')
    local controls = import('/lua/ui/game/score.lua').controls
    local mapGroup = import('/lua/ui/game/score.lua').savedParent
         
    controls.collapseArrow:SetTexture(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'))
    controls.collapseArrow:SetNewTextures(UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_up.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_up.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_over.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_over.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-close_btn_dis.dds'),
        UIUtil.UIFile('/game/tab-r-btn/tab-open_btn_dis.dds'))
    LayoutHelpers.AtRightTopIn(controls.collapseArrow, mapGroup, -3, 21)
    controls.collapseArrow.Depth:Set(function() return controls.bg.Depth() + 10 end)
    
    LayoutHelpers.AtRightTopIn(controls.bg, mapGroup, 18, 7)
    controls.bg.Width:Set(controls.bgTop.Width)
    
    LayoutHelpers.AtRightTopIn(controls.bgTop, controls.bg, 3)
    LayoutHelpers.AtLeftTopIn(controls.armyGroup, controls.bgTop, 10, 25)
    controls.armyGroup.Width:Set(controls.armyLines[1].Width)
    
    --LOG('>>>> HUSSAR: score_mini texture Bracket... ')
    controls.leftBracketMin:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_t.dds'))
    controls.leftBracketMin.Top:Set(function() return controls.bg.Top() - 1 end)
    controls.leftBracketMin.Left:Set(function() return controls.bg.Left() - 10 end)
    
    controls.leftBracketMax:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_b.dds'))
    controls.leftBracketMax.Bottom:Set(function() return controls.bg.Bottom() + 1 end)
    controls.leftBracketMax.Left:Set(controls.leftBracketMin.Left)
    
    controls.leftBracketMid:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_m.dds'))
    controls.leftBracketMid.Top:Set(controls.leftBracketMin.Bottom)
    controls.leftBracketMid.Bottom:Set(controls.leftBracketMax.Top)
    controls.leftBracketMid.Left:Set(function() return controls.leftBracketMin.Left() end)
    
    controls.rightBracketMin:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_t.dds'))
    controls.rightBracketMin.Top:Set(function() return controls.bg.Top() - 5 end)
    controls.rightBracketMin.Right:Set(function() return controls.bg.Right() + 18 end)
    
    controls.rightBracketMax:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_b.dds'))
    controls.rightBracketMax.Bottom:Set(function() 
            return math.max(controls.bg.Bottom() + 4, controls.rightBracketMin.Bottom() + controls.rightBracketMax.Height())
        end)
    controls.rightBracketMax.Right:Set(controls.rightBracketMin.Right)
    
    controls.rightBracketMid:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_m.dds'))
    controls.rightBracketMid.Top:Set(controls.rightBracketMin.Bottom)
    controls.rightBracketMid.Bottom:Set(controls.rightBracketMax.Top)
    controls.rightBracketMid.Right:Set(function() return controls.rightBracketMin.Right() - 7 end)
    
    --LOG('>>>> HUSSAR: score_mini texture panel... ')
    --controls.bgTop:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_t.dds'))
    --controls.bgBottom:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_b.dds'))
    --controls.bgStretch:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_m.dds'))
    
    controls.bgTop:SetTexture(modTextures..'score_top.dds')
    controls.bgBottom:SetTexture(modTextures..'score_bottom.dds')
    controls.bgStretch:SetTexture(modTextures..'score_strech.dds')

    controls.bgBottom.Top:Set(function() return math.max(controls.armyGroup.Bottom() - 14, controls.bgTop.Bottom()) end)
    controls.bgBottom.Right:Set(controls.bgTop.Right)
    controls.bgStretch.Top:Set(controls.bgTop.Bottom)
    controls.bgStretch.Bottom:Set(controls.bgBottom.Top)
    controls.bgStretch.Right:Set(function() return controls.bgTop.Right() - 0 end)
    
    controls.bg.Height:Set(function() return controls.bgBottom.Bottom() - controls.bgTop.Top() end)
    controls.armyGroup.Height:Set(function() 
        local totHeight = 0
        for _, line in controls.armyLines do
            totHeight = totHeight + line.Height()
        end
        return math.max(totHeight, 50)
    end)
    
    -- NOTE HUSSAR moved loading icons for timer and unit counter to score.LUA
    
    --LOG('>>>> HUSSAR: score_mini texture time/tank... ')
    local x = 10
    LayoutHelpers.AtLeftTopIn(controls.timeIcon, controls.bgTop, x, 8)
    x = x + 16
    LayoutHelpers.AtLeftTopIn(controls.time, controls.bgTop, x, 7)
    
    x = x + 80
    LayoutHelpers.AtLeftTopIn(controls.speedIcon, controls.bgTop, x, 8)
    x = x + 16
    LayoutHelpers.AtLeftTopIn(controls.speed, controls.bgTop, x, 7)
    
    x = x + 60
    LayoutHelpers.AtLeftTopIn(controls.qualityIcon, controls.bgTop, x, 8)
    x = x + 16
    LayoutHelpers.AtLeftTopIn(controls.quality, controls.bgTop, x, 7)
    
    LayoutHelpers.AtRightTopIn(controls.unitIcon, controls.bgTop, 10, 7)
    LayoutHelpers.LeftOf(controls.units, controls.unitIcon)
    
    -- offset Avatars UI by height of the score board
    local avatarGroup = import('/lua/ui/game/avatars.lua').controls.avatarGroup
    avatarGroup.Top:Set(function() return controls.bgBottom.Bottom() + 4 end)
	 
    
    
    --LOG('>>>> HUSSAR: score_mini layout lines... ')
    LayoutArmyLines()
end

function LayoutArmyLines()
    local controls = import('/lua/ui/game/score.lua').controls
    if not controls.armyLines then return end

    for index, line in controls.armyLines do
        local i = index
        if controls.armyLines[i] then
            if i == 1 then
                LayoutHelpers.AtLeftTopIn(controls.armyLines[i], controls.armyGroup)
            else
                LayoutHelpers.Below(controls.armyLines[i], controls.armyLines[i-1])
            end
        end
    end
end
    
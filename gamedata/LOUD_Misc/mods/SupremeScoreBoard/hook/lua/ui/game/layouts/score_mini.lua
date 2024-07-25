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
    LayoutHelpers.AtLeftTopIn(controls.armyGroup, controls.bgTop, 10, 10)
    controls.armyGroup.Width:Set(controls.armyLines[1].Width)
    
    --LOG('>>>> HUSSAR: score_mini texture Bracket... ')
    controls.leftBracketMin:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_t.dds'))
	LayoutHelpers.AtLeftTopIn(controls.leftBracketMin, controls.bg, -10, -1)
    
    controls.leftBracketMax:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_b.dds'))
	LayoutHelpers.AtBottomIn(controls.leftBracketMax, controls.bg, -1)
    controls.leftBracketMax.Left:Set(controls.leftBracketMin.Left)
    
    controls.leftBracketMid:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_m.dds'))
    controls.leftBracketMid.Top:Set(controls.leftBracketMin.Bottom)
    controls.leftBracketMid.Bottom:Set(controls.leftBracketMax.Top)
    controls.leftBracketMid.Left:Set(controls.leftBracketMin.Left)
    
    controls.rightBracketMin:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_t.dds'))
	LayoutHelpers.AtRightTopIn(controls.rightBracketMin, controls.bg, -18, -5)
    
    controls.rightBracketMax:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_b.dds'))
    controls.rightBracketMax.Bottom:Set(function() 
            return math.max(controls.bg.Bottom() + 4, controls.rightBracketMin.Bottom() + controls.rightBracketMax.Height())
        end)
    controls.rightBracketMax.Right:Set(controls.rightBracketMin.Right)
    
    controls.rightBracketMid:SetTexture(UIUtil.UIFile('/game/bracket-right/bracket_bmp_m.dds'))
    controls.rightBracketMid.Top:Set(controls.rightBracketMin.Bottom)
    controls.rightBracketMid.Bottom:Set(controls.rightBracketMax.Top)
	LayoutHelpers.AtRightIn(controls.rightBracketMid, controls.rightBracketMin, 7)
    
    --LOG('>>>> HUSSAR: score_mini texture panel... ')
    --controls.bgTop:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_t.dds'))
    --controls.bgBottom:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_b.dds'))
    --controls.bgStretch:SetTexture(UIUtil.UIFile('/game/score-panel/panel-score_bmp_m.dds'))
    
    controls.bgTop:SetTexture(modTextures..'score_top.dds')
    controls.bgBottom:SetTexture(modTextures..'score_bottom.dds')
    controls.bgStretch:SetTexture(modTextures..'score_strech.dds')

    controls.bgBottom.Top:Set(function() return math.max(controls.armyGroup.Bottom() - LayoutHelpers.ScaleNumber(14), controls.bgTop.Bottom()) end)
    controls.bgBottom.Right:Set(controls.bgTop.Right)
    controls.bgStretch.Top:Set(controls.bgTop.Bottom)
    controls.bgStretch.Bottom:Set(controls.bgBottom.Top)
    controls.bgStretch.Right:Set(controls.bgTop.Right)
    
    controls.bg.Height:Set(function() return controls.bgBottom.Bottom() - controls.bgTop.Top() end)
    controls.armyGroup.Height:Set(function() 
        local totHeight = 0
        for _, line in controls.armyLines do
            totHeight = totHeight + line.Height()
        end
        return math.max(totHeight, LayoutHelpers.ScaleNumber(50))
    end)
    
    -- NOTE HUSSAR moved loading icons for timer and unit counter to score.LUA
    
    --LOG('>>>> HUSSAR: score_mini texture time/tank... ')
    LayoutHelpers.AtLeftTopIn(controls.timeIcon, controls.bgTop, 10, 8)
	LayoutHelpers.AnchorToRight(controls.time, controls.timeIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.time, controls.timeIcon)
    
    LayoutHelpers.AtLeftIn(controls.speedIcon, controls.bgTop, 106)
	controls.speedIcon.Top:Set(controls.timeIcon.Top)
	LayoutHelpers.AnchorToRight(controls.speed, controls.speedIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.speed, controls.speedIcon)
    
    LayoutHelpers.AtLeftIn(controls.qualityIcon, controls.bgTop, 182)
	controls.qualityIcon.Top:Set(controls.speedIcon.Top)
	LayoutHelpers.AnchorToRight(controls.quality, controls.qualityIcon, 2)
	LayoutHelpers.AtVerticalCenterIn(controls.quality, controls.qualityIcon)
    
    LayoutHelpers.AtRightIn(controls.unitIcon, controls.bgTop, 10)
	controls.unitIcon.Top:Set(controls.qualityIcon.Top)
    LayoutHelpers.AnchorToLeft(controls.units, controls.unitIcon)
	LayoutHelpers.AtVerticalCenterIn(controls.units, controls.unitIcon)
    
    -- offset Avatars UI by height of the score board
    local avatarGroup = import('/lua/ui/game/avatars.lua').controls.avatarGroup
	LayoutHelpers.AnchorToBottom(avatarGroup, controls.bgBottom, 4)
    
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
    
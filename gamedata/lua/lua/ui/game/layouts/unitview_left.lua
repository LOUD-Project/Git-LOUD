local UIUtil = import('/lua/ui/uiutil.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local options = import('/lua/user/prefs.lua').GetFromCurrentProfile('options')
local controls = import('/lua/ui/game/unitview.lua').controls
local consControl = import('/lua/ui/game/construction.lua').controls.constructionGroup

local iconPositions = {
    [1] = {Left = 70, Top = 55},
    [2] = {Left = 70, Top = 70},
    [3] = {Left = 190, Top = 60},
    [4] = {Left = 130, Top = 55},
    [5] = {Left = 130, Top = 85},
    [6] = {Left = 130, Top = 70},
    [7] = {Left = 190, Top = 85},
    [8] = {Left = 70, Top = 85},
}
local iconTextures = {
    UIUtil.UIFile('/game/unit_view_icons/mass.dds'),
    UIUtil.UIFile('/game/unit_view_icons/energy.dds'),
    UIUtil.UIFile('/game/unit_view_icons/kills.dds'),
    UIUtil.UIFile('/game/unit_view_icons/kills.dds'),
    UIUtil.UIFile('/game/unit_view_icons/missiles.dds'),
    UIUtil.UIFile('/game/unit_view_icons/shield.dds'),
    UIUtil.UIFile('/game/unit_view_icons/fuel.dds'),
    UIUtil.UIFile('/game/unit_view_icons/build.dds'),
}

function SetLayout()
    controls.bg:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/build-over-back_bmp.dds'))
    LayoutHelpers.AtLeftIn(controls.bg, controls.parent)
    LayoutHelpers.AtBottomIn(controls.bg, controls.parent)

    controls.bracket:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_t.dds'))
    LayoutHelpers.AtLeftTopIn(controls.bracket, controls.bg, -6, 3)

    if not controls.bracketMax then
        controls.bracketMax = Bitmap(controls.bg)
    end
    controls.bracketMax:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_b.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMax, controls.bg, -6)
    LayoutHelpers.AtBottomIn(controls.bracketMax, controls.bg, 3)

    if not controls.bracketMid then
        controls.bracketMid = Bitmap(controls.bg)
    end
    controls.bracketMid:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_m.dds'))
    LayoutHelpers.AtLeftIn(controls.bracketMid, controls.bg, -6)
    controls.bracketMid.Top:Set(controls.bracket.Bottom)
    controls.bracketMid.Bottom:Set(controls.bracketMax.Top)

    LayoutHelpers.AtLeftTopIn(controls.name, controls.bg, 16, 14)
    LayoutHelpers.AtRightIn(controls.name, controls.bg, 16)
    controls.name:SetClipToWidth(true)
    controls.name:SetDropShadow(true)

    LayoutHelpers.AtLeftTopIn(controls.icon, controls.bg, 12, 34)
    LayoutHelpers.SetDimensions(controls.icon, 48, 48)
    LayoutHelpers.AtLeftTopIn(controls.stratIcon, controls.icon)
    LayoutHelpers.Below(controls.vetIcons[1], controls.icon, 5)
    LayoutHelpers.AtLeftIn(controls.vetIcons[1], controls.icon, -5)
    for index = 2, 5 do
        local i = index
        LayoutHelpers.RightOf(controls.vetIcons[i], controls.vetIcons[i-1], -3)
    end
    LayoutHelpers.AtLeftTopIn(controls.healthBar, controls.bg, 66, 35)
    LayoutHelpers.SetDimensions(controls.healthBar, 188, 16)
    controls.healthBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.healthBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_green.dds'))
    LayoutHelpers.AtBottomIn(controls.shieldBar, controls.healthBar)
    LayoutHelpers.AtLeftIn(controls.shieldBar, controls.healthBar)
    LayoutHelpers.SetDimensions(controls.shieldBar, 188, 2)
    controls.shieldBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.shieldBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/shieldbar.dds'))
    LayoutHelpers.Below(controls.fuelBar, controls.shieldBar)
    LayoutHelpers.SetDimensions(controls.fuelBar, 188, 2)
    controls.fuelBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.fuelBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))

    LayoutHelpers.AtLeftTopIn(controls.vetBar, controls.bg, 192, 68)
    LayoutHelpers.SetDimensions(controls.vetBar, 56, 3)
    controls.vetBar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/healthbar_bg.dds'))
    controls.vetBar._bar:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/fuelbar.dds'))
    
    LayoutHelpers.Below(controls.nextVet, controls.vetBar)
    controls.nextVet:SetDropShadow(true)
    LayoutHelpers.Above(controls.vetTitle, controls.vetBar)
    controls.vetTitle:SetDropShadow(true)

    LayoutHelpers.AtCenterIn(controls.health, controls.healthBar)
    controls.health:SetDropShadow(true)

    for index = 1, table.getn(iconPositions) do
        local i = index
        if iconPositions[i] then
            LayoutHelpers.AtLeftTopIn(controls.statGroups[i].icon, controls.bg, iconPositions[i].Left, iconPositions[i].Top)
        else
            LayoutHelpers.Below(controls.statGroups[i].icon, controls.statGroups[i-1].icon, 5)
        end
        controls.statGroups[i].icon:SetTexture(iconTextures[i])
        LayoutHelpers.RightOf(controls.statGroups[i].value, controls.statGroups[i].icon, 5)
        LayoutHelpers.AtVerticalCenterIn(controls.statGroups[i].value, controls.statGroups[i].icon)
        controls.statGroups[i].value:SetDropShadow(true)
    end
    LayoutHelpers.AtLeftTopIn(controls.actionIcon, controls.bg, 261, 34)
    LayoutHelpers.SetDimensions(controls.actionIcon, 48, 48)
    LayoutHelpers.Below(controls.actionText, controls.actionIcon)
    LayoutHelpers.AtHorizontalCenterIn(controls.actionText, controls.actionIcon)

    LayoutHelpers.AnchorToRight(controls.abilities, controls.bg, 20)
    LayoutHelpers.AtBottomIn(controls.abilities, controls.bg, 24)
    LayoutHelpers.SetDimensions(controls.abilities, 200, 50)

    SetBG(controls)

    if options.gui_detailed_unitview ~= 0 then
        LayoutHelpers.AtLeftTopIn(controls.healthBar, controls.bg, 66, 25)
        LayoutHelpers.Below(controls.shieldBar, controls.healthBar)
        LayoutHelpers.SetHeight(controls.shieldBar, 14)
        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar,0)
        LayoutHelpers.SetHeight(controls.shieldBar, 2)
    else
        LayoutHelpers.AtLeftTopIn(controls.statGroups[1].icon, controls.bg, 70, 60)
        LayoutHelpers.AtLeftTopIn(controls.statGroups[2].icon, controls.bg, 70, 80)
    end
end

function SetBG(controls)
    controls.abilityBG.TL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ul.dds'))
    controls.abilityBG.TL.Right:Set(controls.abilities.Left)
    controls.abilityBG.TL.Bottom:Set(controls.abilities.Top)

    controls.abilityBG.TM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_horz_um.dds'))
    controls.abilityBG.TM.Right:Set(controls.abilityBG.TL.Right)
    controls.abilityBG.TM.Bottom:Set(controls.abilities.Top)
    controls.abilityBG.TM.Left:Set(controls.abilityBG.TR.Left)

    controls.abilityBG.TR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ur.dds'))
    controls.abilityBG.TR.Left:Set(controls.abilities.Right)
    controls.abilityBG.TR.Bottom:Set(controls.abilities.Top)

    controls.abilityBG.ML:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_l.dds'))
    controls.abilityBG.ML.Right:Set(controls.abilities.Left)
    controls.abilityBG.ML.Top:Set(controls.abilityBG.TL.Bottom)
    controls.abilityBG.ML.Bottom:Set(controls.abilityBG.BL.Top)

    controls.abilityBG.M:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_m.dds'))
    controls.abilityBG.M.Top:Set(controls.abilityBG.TM.Bottom)
    controls.abilityBG.M.Left:Set(controls.abilityBG.ML.Right)
    controls.abilityBG.M.Right:Set(controls.abilityBG.MR.Left)
    controls.abilityBG.M.Bottom:Set(controls.abilityBG.BM.Top)

    controls.abilityBG.MR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_vert_r.dds'))
    controls.abilityBG.MR.Left:Set(controls.abilities.Right)
    controls.abilityBG.MR.Top:Set(controls.abilityBG.TR.Bottom)
    controls.abilityBG.MR.Bottom:Set(controls.abilityBG.BR.Top)

    controls.abilityBG.BL:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_ll.dds'))
    controls.abilityBG.BL.Right:Set(controls.abilities.Left)
    controls.abilityBG.BL.Top:Set(controls.abilities.Bottom)

    controls.abilityBG.BM:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lm.dds'))
    controls.abilityBG.BM.Right:Set(controls.abilityBG.BL.Right)
    controls.abilityBG.BM.Top:Set(controls.abilities.Bottom)
    controls.abilityBG.BM.Left:Set(controls.abilityBG.BR.Left)

    controls.abilityBG.BR:SetTexture(UIUtil.UIFile('/game/filter-ping-list-panel/panel_brd_lr.dds'))
    controls.abilityBG.BR.Left:Set(controls.abilities.Right)
    controls.abilityBG.BR.Top:Set(controls.abilities.Bottom)
end

function PositionWindow()
    if consControl:IsHidden() then
        LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
        LayoutHelpers.AtLeftIn(controls.bg, consControl, 18)
        controls.bracket:SetTexture(UIUtil.UIFile('/game/unit-build-over-panel/bracket-unit_bmp.dds'))
        LayoutHelpers.AtLeftTopIn(controls.bracket, controls.bg, -19, -2)
        controls.bracketMax:Hide()
        controls.bracketMid:Hide()
    else
        controls.bracket:SetTexture(UIUtil.UIFile('/game/bracket-left-energy/bracket_bmp_t.dds'))
        controls.bracketMax:Show()
        controls.bracketMid:Show()
        LayoutHelpers.AtLeftTopIn(controls.bracket, controls.bg, -6, 3)
        LayoutHelpers.AtBottomIn(controls.bg, controls.parent)
        LayoutHelpers.AtLeftIn(controls.bg, controls.parent, 207)
    end
end

function UpdateStatusBars(controls)
    if options.gui_detailed_unitview ~= 0 and controls.store == 1 then
        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar,3)
        LayoutHelpers.CenteredBelow(controls.shieldText, controls.fuelBar,-2.5)
    elseif options.gui_detailed_unitview ~= 0 then
        LayoutHelpers.CenteredBelow(controls.fuelBar, controls.shieldBar,0)
        LayoutHelpers.CenteredBelow(controls.shieldText, controls.shieldBar,0)
    end
end

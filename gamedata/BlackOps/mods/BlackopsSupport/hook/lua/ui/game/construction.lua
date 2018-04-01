do--(start of non-destructive hook)
--[[
local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local SpecialGrid = import('/lua/ui/controls/specialgrid.lua').SpecialGrid
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local Edit = import('/lua/maui/edit.lua').Edit
local StatusBar = import('/lua/maui/statusbar.lua').StatusBar
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local Tooltip = import('/lua/ui/game/tooltip.lua')
local TooltipInfo = import('/lua/ui/help/tooltips.lua').Tooltips
local Prefs = import('/lua/user/prefs.lua')
local EnhanceCommon = import('/lua/enhancementcommon.lua')
local Templates = import('/lua/ui/game/build_templates.lua')
local BuildMode = import('/lua/ui/game/buildmode.lua')
local UnitViewDetail = import('/lua/ui/game/unitviewDetail.lua')

local unitGridPages = {
    RULEUTL_Basic = {Order = 0, Label = "<LOC CONSTRUCT_0000>T1"},
    RULEUTL_Advanced = {Order = 1, Label = "<LOC CONSTRUCT_0001>T2"},
    RULEUTL_Secret = {Order = 2, Label = "<LOC CONSTRUCT_0002>T3"},
    RULEUTL_Experimental = {Order = 3, Label = "<LOC CONSTRUCT_0003>Exp"},
    RULEUTL_Munition = {Order = 4, Label = "<LOC CONSTRUCT_0004>Munition"},   # note that this doesn't exist yet
}

# these are external controls used for positioning, so don't add them to our local control table
controlClusterGroup = false
mfdControl = false
ordersControl = false

local capturingKeys = false
local layoutVar = false
local DisplayData = {}
local sortedOptions = {}
local newTechUnits = {}
local currentCommandQueue = false
local previousTabSet = nil
local previousTabSize = nil
local activeTab = nil

local showBuildIcons = false
]]--
local BlackopsIcons = import('/mods/BlackopsSupport/lua/BlackopsIconSearch.lua')
--info:   EXBBAT1A="/mods/blackopsacus/textures/ui/common/game/aeon-enhancements",

function GetEnhancementPrefix(unitID, iconID)
    local factionPrefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        factionPrefix = 'aeon-enhancements/' 
    elseif string.sub(unitID, 2, 2) == 'e' then
        factionPrefix = 'uef-enhancements/'
    elseif string.sub(unitID, 2, 2) == 'r' then
        factionPrefix = 'cybran-enhancements/'
    elseif string.sub(unitID, 2, 2) == 's' then
        factionPrefix = 'seraphim-enhancements/'
    end
    local prefix = '/game/' .. factionPrefix .. iconID
	--####################
	--Exavier Code Block +
	--####################
	local EXunitID = unitID
	if BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID) and DiskGetFileInfo(BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID)..iconID..'_btn_up.dds') then
		-- Check manually assigned overwrite table
		prefix = BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID)..iconID
		return prefix
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'A') and string.sub(unitID, 2, 2) == 'a' then
		local EXunitID = iconID..'A'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'U') and string.sub(unitID, 2, 2) == 'e' then
		local EXunitID = iconID..'U'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'C') and string.sub(unitID, 2, 2) == 'r' then
		local EXunitID = iconID..'C'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'S') and string.sub(unitID, 2, 2) == 's' then
		local EXunitID = iconID..'S'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix
	elseif DiskGetFileInfo('/textures/ui/common'..prefix..'_btn_up.dds') then
		prefix = '/textures/ui/common'..prefix
		return prefix
	else
		if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(iconID)] then
			-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
			WARN('Blackops Icon Mod: Upgrade Icon Not Found - '..iconID)
			BlackopsIcons.EXNoIconLogSpamControl[string.upper(iconID)] = iconID
		end
		return prefix
	end
	--####################
	--Exavier Code Block -
	--####################
end

function GetEnhancementTextures(unitID, iconID)
    local factionPrefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        factionPrefix = 'aeon-enhancements/' 
    elseif string.sub(unitID, 2, 2) == 'e' then
        factionPrefix = 'uef-enhancements/'
    elseif string.sub(unitID, 2, 2) == 'r' then
        factionPrefix = 'cybran-enhancements/'
    elseif string.sub(unitID, 2, 2) == 's' then
        factionPrefix = 'seraphim-enhancements/'
    end
    local prefix = '/game/' .. factionPrefix .. iconID
	--####################
	--Exavier Code Block +
	--####################
	local EXunitID = unitID
	if BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID) and DiskGetFileInfo(BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID)..iconID..'_btn_up.dds') then
		-- Check manually assigned overwrite table
		prefix = BlackopsIcons.EXUpgradeIconTableOverwrites(EXunitID)..iconID
		return prefix..'_btn_up.dds',
			prefix..'_btn_down.dds',
			prefix..'_btn_over.dds',
			prefix..'_btn_up.dds',
			prefix..'_btn_sel.dds'
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'A') and string.sub(unitID, 2, 2) == 'a' then
		local EXunitID = iconID..'A'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix..'_btn_up.dds',
			prefix..'_btn_down.dds',
			prefix..'_btn_over.dds',
			prefix..'_btn_up.dds',
			prefix..'_btn_sel.dds'
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'U') and string.sub(unitID, 2, 2) == 'e' then
		local EXunitID = iconID..'U'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix..'_btn_up.dds',
			prefix..'_btn_down.dds',
			prefix..'_btn_over.dds',
			prefix..'_btn_up.dds',
			prefix..'_btn_sel.dds'
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'C') and string.sub(unitID, 2, 2) == 'r' then
		local EXunitID = iconID..'C'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix..'_btn_up.dds',
			prefix..'_btn_down.dds',
			prefix..'_btn_over.dds',
			prefix..'_btn_up.dds',
			prefix..'_btn_sel.dds'
	elseif BlackopsIcons.EXUpgradeIconTableScan(iconID..'S') and string.sub(unitID, 2, 2) == 's' then
		local EXunitID = iconID..'S'
		prefix = BlackopsIcons.EXUpgradeIconTableScan(EXunitID)..iconID
		return prefix..'_btn_up.dds',
			prefix..'_btn_down.dds',
			prefix..'_btn_over.dds',
			prefix..'_btn_up.dds',
			prefix..'_btn_sel.dds'
	elseif DiskGetFileInfo('/textures/ui/common'..prefix..'_btn_up.dds') then
		return UIUtil.UIFile(prefix..'_btn_up.dds'),
			UIUtil.UIFile(prefix..'_btn_down.dds'),
			UIUtil.UIFile(prefix..'_btn_over.dds'),
			UIUtil.UIFile(prefix..'_btn_up.dds'),
			UIUtil.UIFile(prefix..'_btn_sel.dds')
	else
		if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(iconID)] then
			-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
			WARN('Blackops Icon Mod: Upgrade Icon Not Found - '..iconID)
			BlackopsIcons.EXNoIconLogSpamControl[string.upper(iconID)] = iconID
		end
		return UIUtil.UIFile(prefix..'_btn_up.dds'),
			UIUtil.UIFile(prefix..'_btn_down.dds'),
			UIUtil.UIFile(prefix..'_btn_over.dds'),
			UIUtil.UIFile(prefix..'_btn_up.dds'),
			UIUtil.UIFile(prefix..'_btn_sel.dds')
	end
	--####################
	--Exavier Code Block -
	--####################
end

function CommonLogic()
    controls.choices:SetupScrollControls(controls.scrollMin, controls.scrollMax, controls.pageMin, controls.pageMax)
    controls.secondaryChoices:SetupScrollControls(controls.secondaryScrollMin, controls.secondaryScrollMax, controls.secondaryPageMin, controls.secondaryPageMax)
    
    controls.secondaryProgress:SetNeedsFrameUpdate(true)
    controls.secondaryProgress.OnFrame = function(self, delta)
        if sortedOptions.selection[1] and not sortedOptions.selection[1]:IsDead() and sortedOptions.selection[1]:GetWorkProgress() then
            controls.secondaryProgress:SetValue(sortedOptions.selection[1]:GetWorkProgress())
        end
        if controls.secondaryChoices.top == 1 and not controls.selectionTab:IsChecked() and not controls.constructionGroup:IsHidden() then
            self:SetAlpha(1, true)
        else
            self:SetAlpha(0, true)
        end
    end
    
    controls.secondaryChoices.SetControlToType = function(control, type)
        local function SetIconTextures(control)
            local path = '/icons/units/'..control.Data.id..'_icon.dds'
			--####################
			--Exavier Code Block +
			--####################
			local EXunitID = control.Data.id
			if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
				-- Check manually assigned overwrite table
				local expath = EXunitID..'_icon.dds'
				control.Icon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID)..expath)
			elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
				-- Check modded icon hun table
				local expath = EXunitID..'_icon.dds'
				control.Icon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID)..expath)
			else
				-- Check default GPG directories
				if DiskGetFileInfo(UIUtil.UIFile(path)) then
					control.Icon:SetTexture(UIUtil.UIFile(path))
				else 
					-- Sets placeholder because no other icon was found
					control.Icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
					if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
						-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
						WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
						BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
					end
				end
			end
			--####################
			--Exavier Code Block -
			--####################
            if __blueprints[control.Data.id].StrategicIconName then
                local iconName = __blueprints[control.Data.id].StrategicIconName
                if DiskGetFileInfo('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds') then
					-- Exavier Possible Later Adjustment
                    control.StratIcon:SetTexture('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds')
                    control.StratIcon.Height:Set(control.StratIcon.BitmapHeight)
                    control.StratIcon.Width:Set(control.StratIcon.BitmapWidth)
                else
                    control.StratIcon:SetSolidColor('ff00ff00')
                end
            else
                control.StratIcon:SetSolidColor('00000000')
            end
        end
        
        if type == 'spacer' then
            if controls.secondaryChoices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_horizontal_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Width:Set(control.Icon.BitmapWidth)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Count:SetText('')
            control:Disable()
            control.StratIcon:SetSolidColor('00000000')
            control:SetSolidColor('00000000')
#            control.ConsBar:SetAlpha(0, true)
            control.BuildKey = nil
        elseif type == 'queuestack' or type == 'attachedunit' then
            SetIconTextures(control)
            local up, down, over, dis = GetBackgroundTextures(control.Data.id)
            control:SetNewTextures(up, down, over, dis)
            control:SetUpAltButtons(down,down,down,down)
            control.tooltipID = LOC(__blueprints[control.Data.id].Description) or 'no description'
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
#            if __blueprints[control.Data.id].General.ConstructionBar then
#                control.ConsBar:SetAlpha(1, true)
#            else
#                control.ConsBar:SetAlpha(0, true)
#            end
            control.BuildKey = nil
            if control.Data.count > 1 then 
                control.Count:SetText(control.Data.count)
                control.Count:SetColor('ffffffff')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
        end
    end
    
    controls.secondaryChoices.CreateElement = function()
        local btn = Button(controls.choices)
        
        btn.Icon = Bitmap(btn)
        btn.Icon:DisableHitTest()
        LayoutHelpers.AtCenterIn(btn.Icon, btn)
        
        btn.StratIcon = Bitmap(btn.Icon)
        btn.StratIcon:DisableHitTest()
        LayoutHelpers.AtTopIn(btn.StratIcon, btn.Icon, 4)
        LayoutHelpers.AtLeftIn(btn.StratIcon, btn.Icon, 4)
        
        btn.Count = UIUtil.CreateText(btn.Icon, '', 20, UIUtil.bodyFont)
        btn.Count:SetColor('ffffffff')
        btn.Count:SetDropShadow(true)
        btn.Count:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.Count, btn, 4)
        LayoutHelpers.AtRightIn(btn.Count, btn, 3)
        btn.Count.Depth:Set(function() return btn.Icon.Depth() + 10 end)
        
#        btn.ConsBar = Bitmap(btn, UIUtil.UIFile('/icons/units/cons_bar.dds'))
#        btn.ConsBar:DisableHitTest()
#        LayoutHelpers.AtCenterIn(btn.ConsBar, btn)
        
        btn.Glow = Bitmap(btn)
        btn.Glow:SetTexture(UIUtil.UIFile('/game/units_bmp/glow.dds'))
        btn.Glow:DisableHitTest()
        LayoutHelpers.FillParent(btn.Glow, btn)
        btn.Glow:SetAlpha(0)
        btn.Glow.Incrementing = 1
        btn.Glow.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing * GLOW_SPEED)
            if curAlpha > UPPER_GLOW_THRESHHOLD then
                curAlpha = UPPER_GLOW_THRESHHOLD
                glow.Incrementing = -1
            elseif curAlpha < LOWER_GLOW_THRESHHOLD then
                curAlpha = LOWER_GLOW_THRESHHOLD
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end
        
        btn.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_MFD_Rollover", Bank = "Interface"}))
                Tooltip.CreateMouseoverDisplay(self, self.tooltipID, nil, false)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            return Button.HandleEvent(self, event)
        end
        
        btn.OnRolloverEvent = OnRolloverHandler
        btn.OnClick = OnClickHandler
        
        return btn
    end
    
    controls.choices.CreateElement = function()
        local btn = Button(controls.choices)
        
        btn.Icon = Bitmap(btn)
        btn.Icon:DisableHitTest()
        LayoutHelpers.AtCenterIn(btn.Icon, btn)
        
        btn.StratIcon = Bitmap(btn.Icon)
        btn.StratIcon:DisableHitTest()
        LayoutHelpers.AtTopIn(btn.StratIcon, btn.Icon, 4)
        LayoutHelpers.AtLeftIn(btn.StratIcon, btn.Icon, 4)
        
        btn.Count = UIUtil.CreateText(btn.Icon, '', 20, UIUtil.bodyFont)
        btn.Count:SetColor('ffffffff')
        btn.Count:SetDropShadow(true)
        btn.Count:DisableHitTest()
        LayoutHelpers.AtBottomIn(btn.Count, btn)
        LayoutHelpers.AtRightIn(btn.Count, btn)
        
#        btn.ConsBar = Bitmap(btn, UIUtil.UIFile('/icons/units/cons_bar.dds'))
#        btn.ConsBar:DisableHitTest()
#        LayoutHelpers.AtCenterIn(btn.ConsBar, btn)
        
        btn.LowFuel = Bitmap(btn)
        btn.LowFuel:SetSolidColor('ffff0000')
        btn.LowFuel:DisableHitTest()
        LayoutHelpers.FillParent(btn.LowFuel, btn)
        btn.LowFuel:SetAlpha(0)
        btn.LowFuel:DisableHitTest()
        btn.LowFuel.Incrementing = 1
        
        btn.LowFuelIcon = Bitmap(btn.LowFuel, UIUtil.UIFile('/game/unit_view_icons/fuel.dds'))
        LayoutHelpers.AtLeftIn(btn.LowFuelIcon, btn, 4)
        LayoutHelpers.AtBottomIn(btn.LowFuelIcon, btn, 4)
        btn.LowFuelIcon:DisableHitTest()
        
        btn.LowFuel.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing)
            if curAlpha > .4 then
                curAlpha = .4
                glow.Incrementing = -1
            elseif curAlpha < 0 then
                curAlpha = 0
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end
        
        btn.Glow = Bitmap(btn)
        btn.Glow:SetTexture(UIUtil.UIFile('/game/units_bmp/glow.dds'))
        btn.Glow:DisableHitTest()
        LayoutHelpers.FillParent(btn.Glow, btn)
        btn.Glow:SetAlpha(0)
        btn.Glow.Incrementing = 1
        btn.Glow.OnFrame = function(glow, elapsedTime)
            local curAlpha = glow:GetAlpha()
            curAlpha = curAlpha + (elapsedTime * glow.Incrementing * GLOW_SPEED)
            if curAlpha > UPPER_GLOW_THRESHHOLD then
                curAlpha = UPPER_GLOW_THRESHHOLD
                glow.Incrementing = -1
            elseif curAlpha < LOWER_GLOW_THRESHHOLD then
                curAlpha = LOWER_GLOW_THRESHHOLD
                glow.Incrementing = 1
            end
            glow:SetAlpha(curAlpha)
        end
        
        
        btn.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                PlaySound(Sound({Cue = "UI_MFD_Rollover", Bank = "Interface"}))
                Tooltip.CreateMouseoverDisplay(self, self.tooltipID, nil, false)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            return Button.HandleEvent(self, event)
        end
        
        btn.OnRolloverEvent = OnRolloverHandler
        btn.OnClick = OnClickHandler
        
        return btn
    end
    
    controls.choices.SetControlToType = function(control, type)
        local function SetIconTextures(control, optID)
            local id = optID or control.Data.id
            local path = '/icons/units/'..id..'_icon.dds'
			--####################
			--Exavier Code Block +
			--####################
			local EXunitID = control.Data.id
			if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
				-- Check manually assigned overwrite table
				local expath = EXunitID..'_icon.dds'
				control.Icon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath)
			elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
				-- Check modded icon hun table
				local expath = EXunitID..'_icon.dds'
				control.Icon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID) .. expath)
			else
				-- Check default GPG directories
				if DiskGetFileInfo(UIUtil.UIFile(path)) then
					control.Icon:SetTexture(UIUtil.UIFile(path))
				else 
					-- Sets placeholder because no other icon was found
					control.Icon:SetTexture(UIUtil.UIFile('/icons/units/default_icon.dds'))
					if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
						-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
						WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
						BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
					end
				end
			end
			--####################
			--Exavier Code Block -
			--####################
            if __blueprints[id].StrategicIconName then
                local iconName = __blueprints[id].StrategicIconName
                if DiskGetFileInfo('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds') then
				-- Exavier Possible Future Adjustment
                    control.StratIcon:SetTexture('/textures/ui/common/game/strategicicons/'..iconName..'_rest.dds')
                    control.StratIcon.Height:Set(control.StratIcon.BitmapHeight)
                    control.StratIcon.Width:Set(control.StratIcon.BitmapWidth)
                else
                    control.StratIcon:SetSolidColor('ff00ff00')
                end
            else
                control.StratIcon:SetSolidColor('00000000')
            end
        end

        
        if type == 'arrow' then
            control.Count:SetText('')
            control:Disable()
            control:SetSolidColor('00000000')
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_vert_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/arrow_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Depth:Set(function() return control.Depth() + 5 end)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Icon.Width:Set(30)
            control.StratIcon:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
#            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
        elseif type == 'spacer' then
            if controls.choices._vertical then
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_horizontal_bmp.dds'))
                control.Width:Set(48)
                control.Height:Set(20)
            else
                control.Icon:SetTexture(UIUtil.UIFile('/game/c-q-e-panel/divider_bmp.dds'))
                control.Width:Set(20)
                control.Height:Set(48)
            end
            control.Icon.Width:Set(control.Icon.BitmapWidth)
            control.Icon.Height:Set(control.Icon.BitmapHeight)
            control.Count:SetText('')
            control:Disable()
            control.StratIcon:SetSolidColor('00000000')
            control:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
#            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
        elseif type == 'enhancement' then
            control.Icon:SetSolidColor('00000000')
            control:SetNewTextures(GetEnhancementTextures(control.Data.unitID, control.Data.icon))
            local _,down,over,_,up = GetEnhancementTextures(control.Data.unitID, control.Data.icon)
            control:SetUpAltButtons(up,up,up,up)
            control.tooltipID = LOC(control.Data.enhTable.Name) or 'no description'
            control.mAltToggledFlag = control.Data.Selected
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.Count:SetText('')
            control.StratIcon:SetSolidColor('00000000')
            control.LowFuel:SetAlpha(0, true)
#            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
            control.BuildKey = nil
            if control.Data.Disabled then
                control:Disable()
                if not control.Data.Selected then
                    control.Icon:SetSolidColor('aa000000')
                end
            else
                control:Enable()
            end
        elseif type == 'templates' then
            control.mAltToggledFlag = false
            SetIconTextures(control, control.Data.template.icon)
            control:SetNewTextures(GetBackgroundTextures(control.Data.template.icon))
            control.Height:Set(48)
            control.Width:Set(48)
            if control.Data.template.icon then
                local path = '/textures/ui/common/icons/units/'..control.Data.template.icon..'_icon.dds'
				--####################
				--Exavier Code Block +
				--####################
				local EXunitID = control.Data.id
				if BlackopsIcons.EXIconPathOverwrites[string.upper(EXunitID)] then
					-- Check manually assigned overwrite table
					local expath = EXunitID..'_icon.dds'
					control.Icon:SetTexture(BlackopsIcons.EXIconTableScanOverwrites(EXunitID) .. expath)
				elseif BlackopsIcons.EXIconPaths[string.upper(EXunitID)] then
					-- Check modded icon hun table
					local expath = EXunitID..'_icon.dds'
					control.Icon:SetTexture(BlackopsIcons.EXIconTableScan(EXunitID) .. expath)
				else
					-- Check default GPG directories
					if DiskGetFileInfo(path) then
						control.Icon:SetTexture(path)
					else 
						-- Sets placeholder because no other icon was found
						control.Icon:SetTexture('/textures/ui/common/icons/units/default_icon.dds')
						if not BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] then
							-- Log a warning & add unitID to anti-spam table to prevent future warnings when icons update
							WARN('Blackops Icon Mod: Icon Not Found - '..EXunitID)
							BlackopsIcons.EXNoIconLogSpamControl[string.upper(EXunitID)] = EXunitID
						end
					end
				end
				--####################
				--Exavier Code Block -
				--####################
            else
                control.Icon:SetTexture('/textures/ui/common/icons/units/default_icon.dds')
            end
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.StratIcon:SetSolidColor('00000000')
            control.tooltipID = control.Data.template.name or 'no description'
            control.BuildKey = control.Data.template.key
            if showBuildIcons and control.Data.template.key then 
                control.Count:SetText(string.char(control.Data.template.key) or '')
                control.Count:SetColor('ffff9000')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
            control.LowFuel:SetAlpha(0, true)
#            control.ConsBar:SetAlpha(0, true)
            control.LowFuel:SetNeedsFrameUpdate(false)
        elseif type == 'item' then
            SetIconTextures(control)
            control:SetNewTextures(GetBackgroundTextures(control.Data.id))
            local _,down = GetBackgroundTextures(control.Data.id)
            control.tooltipID = LOC(__blueprints[control.Data.id].Description) or 'no description'
            control:SetUpAltButtons(down,down,down,down)
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.Icon.Depth:Set(function() return control.Depth() + 1 end)
            control.BuildKey = nil
            if showBuildIcons then 
                local unitBuildKeys = BuildMode.GetUnitKeys(sortedOptions.selection[1]:GetBlueprint().BlueprintId, GetCurrentTechTab())
                control.Count:SetText(unitBuildKeys[control.Data.id] or '')
                control.Count:SetColor('ffff9000')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
            control.LowFuel:SetAlpha(0, true)
#            if __blueprints[control.Data.id].General.ConstructionBar then
#                control.ConsBar:SetAlpha(1, true)
#            else
#                control.ConsBar:SetAlpha(0, true)
#            end
            control.LowFuel:SetNeedsFrameUpdate(false)
            if newTechUnits and table.find(newTechUnits, control.Data.id) then
                table.remove(newTechUnits, table.find(newTechUnits, control.Data.id))
                control.NewInd = Bitmap(control, UIUtil.UIFile('/game/selection/selection_brackets_player_highlighted.dds'))
                control.NewInd.Height:Set(80)
                control.NewInd.Width:Set(80)
                LayoutHelpers.AtCenterIn(control.NewInd, control)
                control.NewInd:DisableHitTest()
                control.NewInd.Incrementing = false
                control.NewInd:SetNeedsFrameUpdate(true)
                control.NewInd.OnFrame = function(ind, delta)
                    local newAlpha = ind:GetAlpha() - delta / 5
                    if newAlpha < 0 then
                        ind:SetAlpha(0)
                        ind:SetNeedsFrameUpdate(false)
                        return
                    else
                        ind:SetAlpha(newAlpha)
                    end
                    if ind.Incrementing then
                        local newheight = ind.Height() + delta * 100
                        if newheight > 80 then
                            ind.Height:Set(80)
                            ind.Width:Set(80)
                            ind.Incrementing = false
                        else
                            ind.Height:Set(newheight)
                            ind.Width:Set(newheight)
                        end
                    else
                        local newheight = ind.Height() - delta * 100
                        if newheight < 50 then
                            ind.Height:Set(50)
                            ind.Width:Set(50)
                            ind.Incrementing = true
                        else
                            ind.Height:Set(newheight)
                            ind.Width:Set(newheight)
                        end
                    end
                end
            end
        elseif type == 'unitstack' then
            SetIconTextures(control)
            control:SetNewTextures(GetBackgroundTextures(control.Data.id))
            control.tooltipID = LOC(__blueprints[control.Data.id].Description) or 'no description'
            control.mAltToggledFlag = false
            control.Height:Set(48)
            control.Width:Set(48)
            control.Icon.Height:Set(48)
            control.Icon.Width:Set(48)
            control.LowFuel:SetAlpha(0, true)
#            if __blueprints[control.Data.id].General.ConstructionBar then
#                control.ConsBar:SetAlpha(1, true)
#            else
#                control.ConsBar:SetAlpha(0, true)
#            end
            control.BuildKey = nil
            if control.Data.lowFuel then
                control.LowFuel:SetNeedsFrameUpdate(true)
                control.LowFuelIcon:SetAlpha(1)
            else
                control.LowFuel:SetNeedsFrameUpdate(false)
            end
            if table.getn(control.Data.units) > 1 then 
                control.Count:SetText(table.getn(control.Data.units))
                control.Count:SetColor('ffffffff')
            else
                control.Count:SetText('')
            end
            control.Icon:Show()
            control:Enable()
        end
    end
end

end--(of non-destructive hook)
--*****************************************************************************
--* File: lua/modules/ui/dialogs/modmanager.lua
--* Author: Chris Blackwell
--* Summary: Allows you to choose mods
--*
--* Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Combo = import('/lua/ui/controls/combo.lua').Combo
local Edit = import('/lua/maui/edit.lua').Edit
local Group = import('/lua/maui/group.lua').Group
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Mods = import('/lua/mods.lua')
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Prefs = import('/lua/user/prefs.lua')
local Tooltip = import('/lua/ui/game/tooltip.lua')
local UIUtil = import('/lua/ui/uiutil.lua')

local _InternalUpdateStatus

local optionContainer = false
local mouseover = false
local modDetails = false

local DEFAULT_CLOSED_FOLDERS = {
    "Unofficial Rebalance",
    "Mutators",
    "Miscellaneous",
}

-- This function can be called while the ModManager is active, to update changes to the selected mods on the fly.
-- If called when the ModManger is -not- active, it is a no-op.
function UpdateClientModStatus(selectedModsFromHost)
    if _InternalUpdateStatus then
        _InternalUpdateStatus(selectedModsFromHost)
    end
end

function ClientModStatus(selectedModsFromHost)
    Mods.ClearCache() -- force reload of mod info to pick up changes on disk
    local my_all = Mods.AllSelectableMods()
    local my_sel = Mods.GetSelectedMods()
    local r = {}

    for uid, mod in my_all do

        if mod.ui_only then
            r[uid] = {
                checked = my_sel[uid],
                cantoggle = true,
                tooltip = nil
            }
        else
            r[uid] = {
                checked = (selectedModsFromHost[uid] or false),
                cantoggle = false,
                tooltip = 'modman_controlled_by_host'
            }
        end
    end
    return r
end

function HostModStatus(availableMods)
    Mods.ClearCache() -- force reload of mod info to pick up changes on disk
    local my_all = Mods.AllSelectableMods()
    local my_sel = Mods.GetSelectedMods()
    local r = {}

    local function everyoneHas(uid)
        for peer,modset in availableMods do
            if not modset[uid] then
                return false
            end
        end
        return true
    end

    for uid,mod in my_all do
        if mod.ui_only or everyoneHas(uid) then
            r[uid] = {
                checked = my_sel[uid],
                cantoggle = true,
                tooltip = nil
            }
        else
            r[uid] = {
                checked = false,
                cantoggle = false,
                tooltip = 'modman_some_missing',
            }
        end
    end
    return r
end

function LocalModStatus()
    Mods.ClearCache() -- force reload of mod info to pick up changes on disk
    local my_all = Mods.AllSelectableMods()
    local my_sel = Mods.GetSelectedMods()
    local r = {}

    for uid,mod in my_all do
        r[uid] = {
            checked = my_sel[uid],
            cantoggle = true,
            tooltip = nil
        }
    end
    return r
end

local function IsModExclusive(uid)
    local my_all = Mods.AllSelectableMods()
    if my_all[uid] and my_all[uid].exclusive then
        return true
    end
    return false
end

local function CreateDependsDialog(parent, text, yesFunc)
    local dialog = Group(parent)
    local background = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_m.dds'))
    background:SetTiled(true)
    LayoutHelpers.FillParent(background, dialog)

    dialog.Width:Set(background.Width)
    dialog.Height:Set(300)

    local backgroundTop = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_T.dds'))
    LayoutHelpers.Above(backgroundTop, dialog)
    local backgroundBottom = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_b.dds'))
    LayoutHelpers.Below(backgroundBottom, dialog)

    local textBox = UIUtil.CreateTextBox(background)
    LayoutHelpers.AtLeftTopIn(textBox, dialog, 30, 5)
    LayoutHelpers.AtRightIn(textBox, dialog, 64)
    LayoutHelpers.AtBottomIn(textBox, dialog, 5)

    local yesButton = UIUtil.CreateButtonStd( backgroundBottom, '/widgets/small', "<LOC _Yes>", 12, 0)
    LayoutHelpers.AtLeftIn(yesButton, backgroundBottom, 50)
    LayoutHelpers.AtTopIn(yesButton, backgroundBottom, 20)
    yesButton.OnClick = function(self)
        yesFunc()
        dialog:Destroy()
    end

    local noButton = UIUtil.CreateButtonStd( backgroundBottom, '/widgets/small', "<LOC _No>", 12, 0)
    LayoutHelpers.AtRightIn(noButton, backgroundBottom, 50)
    LayoutHelpers.AtTopIn(noButton, backgroundBottom, 20)
    noButton.OnClick = function(self)
        dialog:Destroy()
    end

    LayoutHelpers.AtCenterIn(dialog, parent:GetRootFrame())
    textBox:SetFont(UIUtil.bodyFont, 18)
    UIUtil.SetTextBoxText(textBox, text)
    UIUtil.CreateWorldCover(dialog)
end

local loudStandard = {
    '25D57D85-7D84-27HT-A501-BR3WL4N000079', -- BrewLAN
    '62e2j64a-53a2-y6sg-32h5-146as555a18u3', -- Total Mayhem
    '9a9C61C0-1787-10DF-A0AD-BATTLEPACK002', -- Wyvern Battle Pack
    'ffffffff-6e98-4864-9599-4133236eea7a', -- LOUD Integrated Storage
    'ffffffff-ffff-ffff-ffff-fffffffffffe', -- LOUD Structure Enhancements
    '454af309-5afb-458b-bf5b-a00000000007', -- 4th Dimension
    '9e8ea941-c306-4751-b367-a11000000502', -- BlackOps Unleashed
    'fffffffe-6e98-4864-9599-4133236eea7a', -- LOUD Unit Additions
    'HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1240', -- Supreme Score Board
    '9e8ea941-c306-4751-b367-e00000000302', -- BlackOps ACUs
    'ffffffff-6f00-4864-9599-4133236eea7a', -- LOUD Evenflow
    '2529ea71-93ef-41a6-b552-EXPERICON00005', -- Experimental Icons Overhaul
}

local modSchema = {
    ["Units"] = {
        '454af309-5afb-458b-bf5b-a00000000007', -- 4th Dimension
        '9e8ea941-c306-4751-b367-e00000000302', -- BlackOps ACUs
        '9e8ea941-c306-4751-b367-a11000000502', -- BlackOps Unleashed
        '25D57D85-7D84-27HT-A501-BR3WL4N000079', -- BrewLAN
        'fffffffe-6e98-4864-9599-4133236eea7a', -- LOUD Unit Additions
        '62e2j64a-53a2-y6sg-32h5-146as555a18u3', -- Total Mayhem
        '9a9C61C0-1787-10DF-A0AD-BATTLEPACK002', -- Wyvern Battle Pack
    },
    ["User Interface"] = {
        'Machd6c5-cd5c-4e34-b6cc-11503ed5e2da', -- Disperse Move
        '175542E4-D4F5-11DC-B450-11D755D89593', -- HotStats
        'EF3ADDB4-9D34-437F-B1C8-440DAF896802', -- Mass Fab Manager
        -- 'bc7731b6-1416-11ea-8d71-362b9e155667', -- Selection Depriotizer
        'D000E905-1E97-420D-8ED9-DF083282F59D', -- Sequential Mex Upgrade
        '89BF1572-9EA8-11DC-1313-635F56D89591', -- Supreme Economy
        'HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1240', -- Supreme Score Board
        '022E3DB4-9C00-5ED7-9876-4866D316E015', -- UI Party
    },
    ["Official Rebalance"] = {
        'ffffffff-6f00-4864-9599-4133236eea7a', -- Evenflow
        'ffffffff-6e98-4864-9599-4133236eea7a', -- Integrated Storage
        'ffffffff-ffff-ffff-ffff-fffffffffffe', -- Structure Enhancements
    },
    ["Unofficial Rebalance"] = {
        '25D57D85-9JA7-D842-BREW-INTEL00000002', -- BrewLAN: Bletchley Park
        '25D57D85-9JA7-LOUD-BREW-RESEARCH00005', -- BrewLAN: Research and Daiquiris
        '16678e1e-7fc9-11e5-8bcf-waterguard10', -- Water Guard
        '25D57D85-9JA7-D842-GKG4-ASJDKG49G8S70', -- Waterlag
        '16678e1e-7fc9-11e5-8bcf-wreckageA01' -- Wreckage Decay
    },
    ["Mutators"] = {
        'ffffffff-9d4e-11dc-8314-0800200c0605', -- Enhanced BO Commanders
        'ffffffff-9d4e-11dc-8314-0800200c0702', -- Enhanced T4 Artillery
        '0a970b58-533d-11dc-8314-0800200c9a66', -- Enhanced Nukes
        '74A9EAB2-E851-11DB-A1F1-F2C755D89593', -- Enhanced Resources
        'TANKSYS-EXPERIMENTS-1-COMBAT',         -- Tanksy's Experiments: Combat Changes
        -- BrewLAN
        'f31a09b5-2b2f-4bb4-aeac-47ab777a7cde', -- Antimass
        '190261d0-4bb0-11e2-bcSC-CITIES000001', -- Cityscapes
        '1a17998a-7355-11e5-8bcf-feff819cdc9f', -- Cost Variance
        'BREWLANS-a0a7-426d-88f2-CRATESZ00011', -- Crate Drop
        '16678e1e-7fc9-11e5-8bcf-x10health0010', -- Hench AF
        '16678e1e-7fc9-11e5-8bcf-dayofsex0010', -- Invisible War
        '25D57D85-7D84-27HT-A502-LDIPS0000002', -- Lucky Dip
        '25D57D85-7D84-27HT-A502-MASSRNG00002', -- Mass Point RNG
        '25D57D85-7D84-27HT-A501-METALWI0000013', -- Metal World
        'BREWLANS-22b4-4936-820e-PARAGON0040', -- Paragon Game
        '25D57D85-7D84-27HT-A502-RPS000000000', -- Rock Paper Scissors
        '16678e1e-7fc9-11e5-8bcf-scathingbe20', -- Scathing Beetles
        'BREWLANS-a0a7-426d-88f2-SPOMEN00000', -- Spomeniki
        '25D57D85-9JA7-D842-BREW-SUDDEN000001', -- Sudden Death
        -- '25D57D85-7D84-27HT-A502-TECHRND00000', -- Tech Level Randomiser
    },
    ["Miscellaneous"] = {
        '25D57D85-9JA7-D842-GKG4-ORIGIN0000001', -- BrewLAN Baristas
        '25D57D85-9JA7-D842-GKG4-DAMAGENO00000', -- BrewLAN Damage Numbers
        '2529ea71-93ef-41a6-b552-LOGS0000000009', -- BrewLAN Debug Tools
        'zcbf6277-24e3-437a-b968-Common-v1', -- Common Mod Tools
        '2529ea71-93ef-41a6-b552-EXPERICON00005', -- Experimental Icons Overhaul
        'eabdfda4-24b5-40dc-8995-LOUD000DEBUG', -- LOUD Debug Tools
        '7be1d5f4-c544-11ea-87d0-noalerts0001', -- No VO Alerts
        '5362BE90-44BE-11DD-A519-83AF56D89593', -- Supreme Commander Music
        'f31a09b5-2b2f-4bb4-aeac-resource0000001', -- Wonky Resources
    },
    ["Usermods"] = {},
}

local folderOrder = {
    "Units",
    "User Interface",
    "Official Rebalance",
    "Unofficial Rebalance",
    "Mutators",
    "Miscellaneous",
    "Usermods",
}

local folderTooltips = {
    ["Units"] = 'modmgr_folder_units',
    ["User Interface"] = 'modmgr_folder_ui',
    ["Official Rebalance"] = 'modmgr_folder_official',
    ["Unofficial Rebalance"] = 'modmgr_folder_unofficial',
    ["Mutators"] = 'modmgr_folder_mut',
    ["Miscellaneous"] = 'modmgr_folder_misc',
    ["Usermods"] = 'modmgr_folder_user',
}

local modStruct = {}

local function CreateLoadPresetDialog(parent, modListTable, modStatus)

    local dialog = Group(parent)
	dialog.Depth:Set(function() return parent.Depth() + 5 end)
    local background = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_m.dds'))
    background:SetTiled(true)
    LayoutHelpers.FillParent(background, dialog)

    dialog.Width:Set(background.Width)
    dialog.Height:Set(300)

    local backgroundTop = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_T.dds'))
    LayoutHelpers.Above(backgroundTop, dialog)
    local backgroundBottom = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_b.dds'))
    LayoutHelpers.Below(backgroundBottom, dialog)

    local presets = ItemList(dialog)
	presets:SetFont(UIUtil.bodyFont, 16)
	presets:SetColors(UIUtil.fontColor(), "Black", "Black", "Gainsboro", "Black", "Gainsboro")
	LayoutHelpers.DepthOverParent(presets, dialog, 10)
    LayoutHelpers.AtLeftTopIn(presets, dialog, 30, 5)
    LayoutHelpers.AtRightIn(presets, dialog, 64)
    LayoutHelpers.AtBottomIn(presets, dialog, 5)
	presetsScroll = UIUtil.CreateVertScrollbarFor(presets)

	local userPresets = Prefs.GetFromCurrentProfile('UserPresets')

	local function fillPresetList()
		presets:DeleteAllItems()
		if userPresets then
			for k, _ in userPresets do
				presets:AddItem(k)
			end
		end
	end

    local yesButton = UIUtil.CreateButtonStd(backgroundBottom, '/widgets/small', "Load", 12, 0)
    LayoutHelpers.AtLeftIn(yesButton, backgroundBottom, 0)
    LayoutHelpers.AtTopIn(yesButton, backgroundBottom, 20)
    yesButton.OnClick = function(self)
		local index = presets:GetSelection()
		if index and index >= 0 then
			local name = presets:GetItem(index)
            local presetMods = userPresets[name]
            for k, v in modStatus do
                -- Can't just transfer the boolean value, since presetMods[k]
                -- might not exist
                if presetMods[k] then
                    v.checked = true
                else
                    v.checked = false
                end
            end
            for _, v in modListTable do
                if v.uid then
                    v:SetVisual(modStatus[v.uid])
                end
            end
			dialog:Destroy()
		else
			UIUtil.ShowInfoDialog(dialog, "You have not selected a preset to load.", "OK")
		end
    end

    local deleteButton = UIUtil.CreateButtonStd(backgroundBottom, '/widgets/small', "Delete", 12, 0)
    LayoutHelpers.AtCenterIn(deleteButton, backgroundBottom)
    LayoutHelpers.AtTopIn(deleteButton, backgroundBottom, 20)
    deleteButton.OnClick = function(self)
		local index = presets:GetSelection()
		if index and index >= 0 then
			local name = presets:GetItem(index)
			UIUtil.QuickDialog(dialog, "Are you sure you want to delete the preset "..name.."?",
				"<LOC _Yes>", function()
					-- table.remove(userPresets, index + 1)
					userPresets[name] = nil
					Prefs.SetToCurrentProfile('UserPresets', userPresets)
					fillPresetList()
				end,
				"<LOC _No>", nil,
				nil, nil,
				true, {worldCover = false, enterButton = 1, escapeButton = 2})
		else
			UIUtil.ShowInfoDialog(dialog, "You have not selected a preset to delete.", "OK")
		end
    end

    local noButton = UIUtil.CreateButtonStd( backgroundBottom, '/widgets/small', "Cancel", 12, 0)
    LayoutHelpers.AtRightIn(noButton, backgroundBottom, 0)
    LayoutHelpers.AtTopIn(noButton, backgroundBottom, 20)
    noButton.OnClick = function(self)
		dialog:Destroy()
    end

	fillPresetList()

    LayoutHelpers.AtCenterIn(dialog, parent:GetRootFrame())
    UIUtil.CreateWorldCover(dialog)
end

local function CreateSavePresetDialog(parent, modStatus)
    local dialog = Group(parent)
	dialog.Depth:Set(function() return parent.Depth() + 5 end)
    local background = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_m.dds'))
    background:SetTiled(true)
    LayoutHelpers.FillParent(background, dialog)

    dialog.Width:Set(background.Width)
    dialog.Height:Set(60)

    local backgroundTop = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_T.dds'))
    LayoutHelpers.Above(backgroundTop, dialog)
    local backgroundBottom = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/dialog/panel_bmp_b.dds'))
    LayoutHelpers.Below(backgroundBottom, dialog)

    local title = UIUtil.CreateText(dialog, 'Name your preset', 18)
    LayoutHelpers.AtTopIn(title, dialog, 10)
    LayoutHelpers.AtHorizontalCenterIn(title, dialog)

	local nameEdit = Edit(dialog)
	nameEdit.Width:Set(function() return background.Width() - 80 end)
	nameEdit.Height:Set(function() return nameEdit:GetFontHeight() end)
    LayoutHelpers.AtTopIn(nameEdit, dialog, 30)
    LayoutHelpers.AtHorizontalCenterIn(nameEdit, dialog)
	UIUtil.SetupEditStd(nameEdit, UIUtil.fontColor, "00569FFF", UIUtil.highlightColor, "880085EF", UIUtil.bodyFont, 18, 30)
	nameEdit:AcquireFocus()

    local yesButton = UIUtil.CreateButtonStd( backgroundBottom, '/widgets/small', "Save", 12, 0)
    LayoutHelpers.AtLeftIn(yesButton, backgroundBottom, 50)
    LayoutHelpers.AtTopIn(yesButton, backgroundBottom, 20)
    yesButton.OnClick = function(self)
        local name = nameEdit:GetText()
		local presets = Prefs.GetFromCurrentProfile('UserPresets')
		if not presets then presets = {} end
        if name == "" then
            nameEdit:AbandonFocus()
            UIUtil.ShowInfoDialog(dialog, "Please fill in a preset name", "OK", function() nameEdit:AcquireFocus() end)
            return
		elseif presets[name] then
            nameEdit:AbandonFocus()
            UIUtil.QuickDialog(dialog, "A preset with that name already exists. Do you want to overwrite it?",
				"<LOC _Yes>", function()
                    local selMods = {}
                    for k, v in modStatus do
                        if v.checked then
                            selMods[k] = true
                        end
                    end
					presets[name] = selMods
					Prefs.SetToCurrentProfile('UserPresets', presets)
					nameEdit:AcquireFocus()
				end,
				"<LOC _No>", function() nameEdit:AcquireFocus() end,
				nil, nil,
				true, {worldCover = false, enterButton = 1, escapeButton = 2})
			return
		else
			local selMods = {}
			for k, v in modStatus do
                if v.checked then
                    selMods[k] = true
                end
            end
			presets[name] = selMods
			Prefs.SetToCurrentProfile('UserPresets', presets)
		end
        dialog:Destroy()
    end

    local noButton = UIUtil.CreateButtonStd( backgroundBottom, '/widgets/small', "Cancel", 12, 0)
    LayoutHelpers.AtRightIn(noButton, backgroundBottom, 50)
    LayoutHelpers.AtTopIn(noButton, backgroundBottom, 20)
    noButton.OnClick = function(self)
        dialog:Destroy()
    end

    LayoutHelpers.AtCenterIn(dialog, parent:GetRootFrame())
    UIUtil.CreateWorldCover(dialog)
end

local function ModConfigDialog(parent, modInfo, config, modStatusEntry)
    -- table.sort(config, function(a, b) return a.key < b.key end)

    local newConfig = Prefs.GetFromCurrentProfile("modConfig")
    if not newConfig then
        newConfig = {}
    end
    if not newConfig[modInfo.uid] then
        newConfig[modInfo.uid] = {}
        for _, v in config do
            newConfig[modInfo.uid][v.key] = v.values[v.default].key
        end
    end

    local dialog = Bitmap(parent, UIUtil.UIFile('/scx_menu/panel-brd/panel_brd_m.dds'))
    LayoutHelpers.AtCenterIn(dialog, parent)
    LayoutHelpers.DepthOverParent(dialog, parent, 100)
    dialog.Width:Set(300)
    dialog.Height:Set(450)
    dialog.border = import('/lua/ui/lobby/restrictedUnitsDlg.lua').CreateBorder(dialog)
    dialog.brackets = UIUtil.CreateDialogBrackets(dialog, 118, 106, 118, 104)

    local title = UIUtil.CreateText(dialog, "Mod Config: "..modInfo.name, 20, UIUtil.titleFont)
    LayoutHelpers.AtTopIn(title, dialog.border.tm, 12)
    LayoutHelpers.AtHorizontalCenterIn(title, dialog)
    local cancelBtn = UIUtil.CreateButtonStd(dialog, '/scx_menu/small-btn/small', "<LOC Cancel>", 16, 2, 0, "UI_Menu_Cancel_02", "UI_Opt_Affirm_Over")
    LayoutHelpers.Below(cancelBtn, dialog, -16)
    LayoutHelpers.AtHorizontalCenterIn(cancelBtn, dialog)
    local okBtn = UIUtil.CreateButtonStd(dialog, '/scx_menu/small-btn/small', "<LOC _Ok>", 16, 2, 0, "UI_Opt_Yes_No", "UI_Opt_Affirm_Over")
    LayoutHelpers.Below(okBtn, dialog, -20)
    LayoutHelpers.AtLeftIn(okBtn, dialog, -50)
    LayoutHelpers.RightOf(cancelBtn, okBtn)

    local optionList = {}

    optionContainer = Group(dialog)
    optionContainer.Height:Set(dialog.Height() - 32)
    optionContainer.Width:Set(dialog.Width)
    optionContainer.top = 0
    LayoutHelpers.AtCenterIn(optionContainer, parent, -12)

    local function CreateOptionElement(index)
        optionList[index] = Group(optionContainer)
        optionList[index].Height:Set(46)
        optionList[index].Width:Set(optionContainer.Width)

        optionList[index].bg = Bitmap(optionList[index])
        optionList[index].bg.Depth:Set(optionList[index].Depth)
        LayoutHelpers.FillParent(optionList[index].bg, optionList[index])
        optionList[index].bg.Right:Set(function() return optionList[index].Right() - 10 end)

        optionList[index].text = UIUtil.CreateText(optionContainer, '', 14, "Arial")
        optionList[index].text:DisableHitTest()
        LayoutHelpers.AtLeftTopIn(optionList[index].text, optionList[index], 10)

        optionList[index].combo = Combo(optionList[index], nil, nil, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
        optionList[index].combo.Width:Set(240)
        optionList[index].combo.Depth:Set(function() return optionList[index].Depth() + 10 end)
        optionList[index].combo.keyMap = {}
        optionList[index].combo.UpdateValue = function(key)
            optionList[index].combo:SetItem(optionList[index].combo.keyMap[key])
        end
        if not modStatusEntry.cantoggle then
            optionList[index].combo:Disable()
        end
        LayoutHelpers.AtLeftTopIn(optionList[index].combo, optionList[index], 5, 22)
    end

    CreateOptionElement(1)
    LayoutHelpers.AtLeftTopIn(optionList[1], optionContainer)

    for i = 2, 9 do
        CreateOptionElement(i)
        LayoutHelpers.Below(optionList[i], optionList[i - 1])
    end

    local numLines = function() return table.getsize(optionList) end

    local function DataSize()
        return table.getn(config)
    end

    -- Called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- aixs can be "Vert" or "Horz"
    optionContainer.GetScrollValues = function(self, axis)
        local size = DataSize()
        return 0, size, self.top, math.min(self.top + numLines(), size)
    end

    -- Called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    optionContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- Called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    optionContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
    end

    -- Called when the scrollbar wants to set a new visible top line
    optionContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = DataSize()
        self.top = math.max(math.min(size - numLines() , top), 0)
        self:CalcVisible()
    end

    -- Called to determine if the control is scrollable on a particular access. Must return true or false.
    optionContainer.IsScrollable = function(self, axis)
        return true
    end

    optionContainer.CalcVisible = function(self)
        local function SetTextLine(line, data, lineID)
            line.text:SetText(LOC(data.label))
            line.text:SetFont(UIUtil.bodyFont, 14)
            line.text:SetColor(UIUtil.fontColor)
            line.bg:SetTexture(UIUtil.UIFile('/dialogs/mapselect03/options-panel-bar_bmp.dds'))
            LayoutHelpers.AtLeftTopIn(line.text, line, 10, 5)
            line.combo:ClearItems()
            line.combo:Show()
            local itemArray = {}
            for index, val in data.values do
                itemArray[index] = val.text
            end
            local def = 1
            for i, v in data.values do
                if v.key == newConfig[modInfo.uid][data.key] then
                    def = i
                end
            end
            line.combo:AddItems(itemArray, def)
            line.combo.OnClick = function(self, index, text)
                newConfig[modInfo.uid][data.key] = data.values[index].key
            end
            line.combo.UpdateValue = function(key)
                line.combo:SetItem(line.combo.keyMap[key])
            end

            local lineTooltip = {
                text = data.label,
                body = data.help or "",
            }
            local comboTooltip = {}
            for i, v in data.values do
                table.insert(comboTooltip, { text = v.text, body = v.help or "" })
            end
            Tooltip.AddControlTooltip(line, lineTooltip)
            Tooltip.AddComboTooltip(line.combo, comboTooltip)
        end
        for i, v in optionList do
            if config[i + self.top] then
                SetTextLine(v, config[i + self.top], i + self.top)
            else
                v.text:SetText('')
                v.combo:Hide()
                v.bg:SetSolidColor('00000000')
            end
        end
    end

    optionContainer:CalcVisible()

    optionContainer.HandleEvent = function(self, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            self:ScrollLines(nil, lines)
        end
    end

    okBtn.OnClick = function(self, modifiers)
        Prefs.SetToCurrentProfile("modConfig", newConfig)
        modInfo.config = table.copy(newConfig[modInfo.uid])
        dialog:Destroy()
    end

    cancelBtn.OnClick = function(self, modifiers)
        dialog:Destroy()
    end

    UIUtil.CreateVertScrollbarFor(optionContainer)
    UIUtil.MakeInputModal(dialog, function() okBtn.OnClick(okBtn) end, function() cancelBtn.OnClick(cancelBtn) end)
    UIUtil.CreateWorldCover(dialog)
end

function CreateDialog(over, inLobby, exitBehavior, useCover, modStatus)

    ---------------------------------------------------------------------------
    -- Fill in default args
    ---------------------------------------------------------------------------

    modStatus = modStatus or LocalModStatus()

    local exclusiveModSelected = nil

    ---------------------------------------------------------------------------
    -- Basic layout and operation of dialog
    ---------------------------------------------------------------------------

	local parent = over

    local panel = Bitmap(parent, UIUtil.UIFile('/scx_menu/mod-manager/panel_bmp.dds'))
    LayoutHelpers.AtCenterIn(panel, parent)

    panel.brackets = UIUtil.CreateDialogBrackets(panel, 38, 24, 38, 24)

    local title = UIUtil.CreateText(panel, LOC("<LOC _Mod_Manager>Mod Manager"), 24)
    LayoutHelpers.AtTopIn(title, panel, 24)
    LayoutHelpers.AtHorizontalCenterIn(title, panel)

    panel.Depth:Set(GetFrame(over:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)

    local worldCover = nil
    if useCover then
    	worldCover = UIUtil.CreateWorldCover(panel)
    end

    local help1 = UIUtil.CreateText(panel, "Click a row to enable/disable.", 14, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(help1, panel, 30, 74)
    local help2 = UIUtil.CreateText(panel, "Click the > button or right-click on a mod to see more details.", 14, UIUtil.bodyFont)
    LayoutHelpers.Below(help2, help1, 2)

    ---------------------------------------------------------------------------
    -- Mod list control
    ---------------------------------------------------------------------------

    modStruct = {}

    local allmods = Mods.AllSelectableMods()
    local selmods = Mods.GetSelectedMods()

    local isUsermod = {}
    for uid, _ in allmods do
        isUsermod[uid] = true
    end

    for key, block in modSchema do
        modStruct[key] = {}
        modStruct[key].name = key
        -- Collapse certain folders by default
        modStruct[key].open = not table.find(DEFAULT_CLOSED_FOLDERS, key)
        modStruct[key].uids = {}
        for _, uid in block do
            -- Prevent complete blow-up if a UID in the schema is illegal
            if not allmods[uid] then
                WARN("MOD MANAGER: "..uid.." is in schema, but not installed or selectable")
                continue
            end
            table.insert(modStruct[key].uids, uid)
            isUsermod[uid] = false
        end
    end

    for _, v in allmods do
        if isUsermod[v.uid] then
            table.insert(modStruct['Usermods'].uids, v.uid)
        end
        if selmods[v.uid] then
            modStatus[v.uid].checked = true
        else
            modStatus[v.uid].checked = false
        end
        if IsModExclusive(v.uid) and modStatus[v.uid].checked then
            exclusiveModSelected = v.uid
        end
    end

    -- Empty folders get hidden
    -- Folders which are closed now but have enabled mods get opened
    for k, v in modStruct do
        if table.empty(v.uids) then
            modStruct[k] = nil
        else
            for _, uid in v.uids do
                if modStatus[uid].checked then
                    v.open = true
                    break
                end
            end
        end
    end

    if modStruct['Usermods'] then
        table.sort(modStruct['Usermods'].uids, function(a, b)
            if allmods[a].name and allmods[b].name
            and allmods[a].name ~= allmods[b].name then
                return allmods[a].name < allmods[b].name
            else
                return a > b
            end
        end)
    end

    local modListTable = {}

    local function UpdateModListTable()
        for _, v in modListTable do
            if v.uid then
                v:SetVisual(modStatus[v.uid])
            end
        end
    end

    local modListContainer = Group(panel)
    modListContainer.Width:Set(380)
    modListContainer.Height:Set(455)
    modListContainer.top = 0
    LayoutHelpers.AtLeftIn(modListContainer, panel, 28)
    LayoutHelpers.AtVerticalCenterIn(modListContainer, panel, -12)

    local function CreateModGroup(i)
        modListTable[i] = Group(modListContainer)
        local grp = modListTable[i]
        grp.Height:Set(36)
        grp.Width:Set(modListContainer.Width())
        grp.bg = Bitmap(grp)
        grp.bg.Depth:Set(grp.Depth)
        LayoutHelpers.FillParent(grp.bg, grp)
        grp.bg:SetSolidColor('22282B')
        grp.detailBtn = UIUtil.CreateButton(grp,
            '/widgets/large-h_scr/arrow-right_scr_up.dds',
            '/widgets/large-h_scr/arrow-right_scr_down.dds',
            '/widgets/large-h_scr/arrow-right_scr_over.dds',
            '/widgets/large-h_scr/arrow-right_scr_dis.dds')
        grp.detailBtn.Width:Set(math.floor(grp.detailBtn.Width() * 0.75))
        grp.detailBtn.Height:Set(math.floor(grp.detailBtn.Height() * 0.75))
        LayoutHelpers.AtRightIn(grp.detailBtn, grp, 2)
        LayoutHelpers.AtVerticalCenterIn(grp.detailBtn, grp)
        grp.configBtn = UIUtil.CreateButtonStd(grp, '/dialogs/config_btn/config')
        Tooltip.AddButtonTooltip(grp.configBtn, 'modmgr_modcfg')
        LayoutHelpers.LeftOf(grp.configBtn, grp.detailBtn, 4)
        LayoutHelpers.AtVerticalCenterIn(grp.configBtn, grp)
        -- Either '[+]' or '[-]' to indicate folder state
        grp.folded = UIUtil.CreateText(grp, '', 18, 'Arial Bold')
        LayoutHelpers.AtLeftIn(grp.folded, grp, 2)
        LayoutHelpers.AtVerticalCenterIn(grp.folded, grp)
        grp.icon = Bitmap(grp)
        grp.icon.Width:Set(36)
        grp.icon.Height:Set(36)
        LayoutHelpers.AtLeftIn(grp.icon, grp, 2)
        LayoutHelpers.AtVerticalCenterIn(grp.icon, grp)
        grp.name = UIUtil.CreateText(grp, '', 18, UIUtil.bodyFont)
        grp.name:SetDropShadow(true)
        LayoutHelpers.CenteredRightOf(grp.name, grp.icon, 4)
        grp.icon:DisableHitTest()
        grp.name:DisableHitTest()
        grp.Brighten = function(self)
            if not self.uid then
                grp.bg:SetSolidColor('7E979B')
            else
                local modStatusEntry = modStatus[self.uid]
                if modStatusEntry.checked then
                    if modStatusEntry.cantoggle then
                        grp.bg:SetSolidColor('75A65F') -- Green
                    else
                        grp.bg:SetSolidColor('AFAB46') -- Yellow
                    end
                else
                    if modStatusEntry.cantoggle then
                        grp.bg:SetSolidColor('42484B') -- Black
                    else
                        grp.bg:SetSolidColor('882028') -- Red
                    end
                end
            end
        end

        grp.Darken = function(self)
            if not self.uid then
                grp.bg:SetSolidColor('5E777B') -- Folder colour; desatured mid-cyan
            else
                local modStatusEntry = modStatus[self.uid]
                if modStatusEntry.checked then
                    if modStatusEntry.cantoggle then
                        grp.bg:SetSolidColor('55863F') -- Green
                    else
                        grp.bg:SetSolidColor('8F8B26') -- Yellow
                    end
                else
                    if modStatusEntry.cantoggle then
                        grp.bg:SetSolidColor('22282B') -- Black
                    else
                        grp.bg:SetSolidColor('680008') -- Red
                    end
                end
            end
        end

        grp.SetVisual = function(self, modStatusEntry)
            if modStatusEntry == nil then
                grp.bg:SetSolidColor('5E777B') -- Folder colour; desatured mid-cyan
            elseif modStatusEntry.checked then
                if modStatusEntry.cantoggle then
                    grp.bg:SetSolidColor('55863F') -- Green
                else
                    grp.bg:SetSolidColor('8F8B26') -- Yellow
                end
            else
                if modStatusEntry.cantoggle then
                    grp.bg:SetSolidColor('22282B') -- Black
                else
                    grp.bg:SetSolidColor('680008') -- Red
                end
            end
        end
    end

    local numElements = 12

    CreateModGroup(1)
    LayoutHelpers.AtLeftTopIn(modListTable[1], modListContainer)

    for i = 2, numElements do
        CreateModGroup(i)
        LayoutHelpers.Below(modListTable[i], modListTable[i - 1], 2)
    end

    local numLines = function() return table.getsize(modListTable) end

    local function DataSize()
        local ret = 0
        for _, block in modStruct do
            ret = ret + 1
            if block.open then
                for _, _ in block.uids do
                    ret = ret + 1
                end
            end
        end
        return ret
    end

    modListContainer.GetScrollValues = function(self, axis)
		local size = DataSize()
		return 0, size, self.top, math.min(self.top + numLines(), size)
	end

	modListContainer.ScrollLines = function(self, axis, delta)
		self:ScrollSetTop(axis, self.top + math.floor(delta))
	end

	modListContainer.ScrollPages = function(self, axis, delta)
		self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
	end

	modListContainer.ScrollSetTop = function(self, axis, top)
		top = math.floor(top)
        if top == self.top then return end
        local size = DataSize()
		self.top = math.max(math.min(size - numLines(), top), 0)
        self:CalcVisible()
	end

	modListContainer.IsScrollable = function(self, axis)
		return DataSize() > numElements
	end

    modListContainer.CalcVisible = function(selfMLC)
        local i = 0
        local skip = selfMLC.top -- Account for scroll bar offset
        for bi = 1, table.getsize(folderOrder) do
            local block = modStruct[folderOrder[bi]]
            -- Skip blocks which were empty and removed
            if not block then continue end
            -- Skip entire block if scroll bar dictates
            if not block.open and skip >= 1 then
                skip = skip - 1
                continue
            end

            -- Block is eligible to be displayed
            -- However, header might get skipped
            if skip <= 0 then
                i = i + 1
                if i > numElements then break end
                modListTable[i].uid = false
                modListTable[i].block = block
                modListTable[i].detailBtn:Hide()
                modListTable[i].configBtn:Hide()
                modListTable[i].icon:Hide()
                modListTable[i]:SetVisual(nil)
                if block.open then
                    modListTable[i].folded:SetText("[-]")
                else
                    modListTable[i].folded:SetText("[+]")
                end
                modListTable[i].name:SetNewFont('Arial', 20)
                modListTable[i].name:SetText(block.name)
                modListTable[i].HandleEvent = function(self, event)
                    if event.Type == 'MouseExit' then
                        Tooltip.DestroyMouseoverDisplay()
                        self:Darken()
                    elseif event.Type == 'MouseEnter' then
                        Tooltip.CreateMouseoverDisplay(self, folderTooltips[self.block.name], 0.25, true)
                        self:Brighten()
                    elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                        self.block.open = not self.block.open
                        -- Folding causes list shrinkage; better to adjust scrollbar
                        -- now, since it's jarring if user input causes it
                        if not self.block.open then
                            if self.top <= 1 then
                                selfMLC:ScrollLines(nil, -1)
                            else
                                selfMLC:ScrollLines(nil, -1)
                                selfMLC:ScrollLines(nil, 1)
                            end
                        end
                        local sound = Sound({Bank = 'Interface', Cue = 'UI_Camera_Delete_Position'})
                        PlaySound(sound)
                        selfMLC:CalcVisible()
                    end
                end
            else
                skip = skip - 1
            end

            -- Don't add block's contents if it's folded,
            -- or if all its contents are to be skipped
            if not block.open then
                continue
            elseif skip >= table.getsize(block.uids) then
                skip = skip - table.getsize(block.uids)
                continue
            end

            for _, uid in block.uids do
                if skip > 0 then
                    skip = skip - 1
                    continue
                end

                i = i + 1
                if i > numElements then break end

                modListTable[i].block = false
                modListTable[i].uid = uid
                local modInfo = allmods[uid]
                modListTable[i].detailBtn:Show()

                local function HandleExclusiveClick(line)
                    local function DoExclusiveBehavior()
                        exclusiveModSelected = line.uid
                        modStatus[line.uid].checked = true
                        for k, _ in modStatus do
                            if k ~= line.uid then
                                modStatus[k].checked = false
                            end
                        end
                        UpdateModListTable()
                    end

                    UIUtil.QuickDialog(
                        panel,
                        "<LOC uimod_0010>The mod you have requested is marked as exclusive. If you select this mod, all other mods will be disabled. Do you wish to enable this mod?",
                        "<LOC _Yes>", DoExclusiveBehavior,
                        "<LOC _No>")
                end

                local function HandleExclusiveActive(line, normalClickFunc)
                    UIUtil.QuickDialog(
                        panel,
                        "<LOC uimod_0011>You currently have an exclusive mod selected, do you wish to deselect it?",
                        "<LOC _Yes>", function()
                            modStatus[exclusiveModSelected].checked = false
                            if line.uid == exclusiveModSelected then
                                line:SetVisual(modStatus[exclusiveModSelected])
                            else
                                UpdateModListTable()
                                normalClickFunc(line)
                            end
                            exclusiveModSelected = nil
                        end,
                        "<LOC _No>")
                end

                local function HandleNormalClick(line)
                    -- Disabling is easy. Handle it and return
                    if modStatus[line.uid].checked then
                        modStatus[line.uid].checked = false
                        line:SetVisual(modStatus[line.uid])
                        return
                    end

                    local depends = Mods.GetDependencies(line.uid)
                    if depends.missing then
                        local boxText = LOC("<LOC uimod_0012>The requested mod can not be enabled as it requires the following mods that you don't currently have installed:\n\n")
                        for k_uid, _ in depends.missing do
                            local name
                            if modInfo.requiresNames and modInfo.requiresNames[k_uid] then
                                name = modInfo.requiresNames[k_uid]
                            else
                                name = k_uid
                            end
                            boxText = boxText .. name .. "\n"
                        end
                        UIUtil.QuickDialog(line:GetParent(), boxText, "<LOC _Ok>")
                    else
                        if depends.requires or depends.conflicts then
                            local needsRequiredActivated = false
                            local needsConflictsDisabled = false

                            if depends.requires then
                                for k_uid, _ in depends.requires do
                                    if modStatus[k_uid] and not modStatus[k_uid].checked then
                                        needsRequiredActivated = true
                                        break
                                    end
                                end
                            end

                            if depends.conflicts then
                                for k_uid, _ in depends.conflicts do
                                    if modStatus[k_uid] and modStatus[k_uid].checked then
                                        needsConflictsDisabled = true
                                        break
                                    end
                                end
                            end

                            if (needsRequiredActivated == true) or (needsConflictsDisabled == true) then
                                local allMods = Mods.AllMods()
                                local boxText = ""

                                if needsRequiredActivated == true then
                                    boxText = boxText .. LOC("<LOC uimod_0013>The requested mod requires the following mods be enabled:\n\n")
                                    for k_uid, _ in depends.requires do
                                        if modStatus[k_uid] and not modStatus[k_uid].checked then
                                            boxText = boxText .. allMods[k_uid].name .. "\n"
                                        end
                                    end
                                    boxText = boxText .. "\n"
                                end
                                if needsConflictsDisabled == true then
                                    boxText = boxText .. LOC("<LOC uimod_0014>The requested mod requires the following mods be disabled:\n\n")
                                    for k_uid, _ in depends.conflicts do
                                        if modStatus[k_uid] and modStatus[k_uid].checked then
                                            boxText = boxText .. allMods[k_uid].name .. "\n"
                                        end
                                    end
                                    boxText = boxText .. "\n"
                                end
                                boxText = boxText .. LOC("<LOC uimod_0015>Would you like to enable the requested mod? Selecting Yes will enable all required mods, and disable all conflicting mods.")
                                CreateDependsDialog(line:GetParent(), boxText, function()
                                    modStatus[line.uid].checked = true
                                    if depends.requires then
                                        for k_uid, _ in depends.requires do
                                            if modStatus[k_uid] and not modStatus[k_uid].checked then
                                                modStatus[k_uid].checked = true
                                            end
                                        end
                                    end
                                    if depends.conflicts then
                                        for k_uid, _ in depends.conflicts do
                                            if modStatus[k_uid] and modStatus[k_uid].checked then
                                                modStatus[k_uid].checked = false
                                            end
                                        end
                                    end
                                    UpdateModListTable()
                                end)
                            else
                                modStatus[line.uid].checked = true
                                line:SetVisual(modStatus[line.uid])
                            end
                        else
                            modStatus[line.uid].checked = true
                            line:SetVisual(modStatus[line.uid])
                        end
                    end
                end

                modListTable[i].folded:SetText('')
                modListTable[i]:SetVisual(modStatus[modListTable[i].uid])
                modListTable[i].icon:Show()
                modListTable[i].icon:SetTexture(modInfo.icon)
                modListTable[i].name:SetNewFont('Arial', 14)
                modListTable[i].name:SetText(modInfo.name)
                modListTable[i].HandleEvent = function(self, event)
                    if event.Type == 'MouseExit' then
                        self:Darken()
                    elseif event.Type == 'MouseEnter' then
                        self:Brighten()
                    elseif event.Type == 'ButtonPress' then
                        if event.Modifiers.Right then
                            DisplayModDetails(self.uid, modStatus)
                            local sound = Sound({Cue = 'UI_Mod_Select', Bank = 'Interface',})
                            PlaySound(sound)
                        else
                            local sound = Sound({Cue = 'UI_Mini_MouseDown', Bank = 'Interface',})
                            PlaySound(sound)
                            if modStatus[self.uid].cantoggle then
                                if IsModExclusive(modInfo.uid) and not self.enabled then
                                    HandleExclusiveClick(self)
                                else
                                    if exclusiveModSelected then
                                        HandleExclusiveActive(self, HandleNormalClick)
                                    else
                                        HandleNormalClick(self)
                                    end
                                end
                            end
                        end
                    end
                end
                modListTable[i].detailBtn.OnClick = function(self, modifiers)
                    DisplayModDetails(self:GetParent().uid, modStatus)
                    local sound = Sound({Cue = 'UI_Mod_Select', Bank = 'Interface',})
                    PlaySound(sound)
                end

                local env = {}
                local ok, _ = pcall(doscript, modInfo.location..'/config.lua', env)
                if ok then
                    modListTable[i].configBtn:Show()
                    modListTable[i].configBtn.OnClick = function(self, modifiers)
                        ModConfigDialog(modDetails:GetParent(), modInfo, env.config, modStatus[self:GetParent().uid])
                    end
                else
                    modListTable[i].configBtn:Hide()
                end
            end
        end
        -- Clear remaining lines if not all need to be filled
        if i < numElements then
            for j = i + 1, numElements do
                modListTable[j].bg:SetSolidColor('22282B')
                modListTable[j].uid = false
                modListTable[j].block = false
                modListTable[j].folded:SetText('')
                modListTable[j].detailBtn:Hide()
                modListTable[j].icon:Hide()
                modListTable[j].name:SetText('')
                modListTable[j].HandleEvent = function(self, event) end
            end
        end
	end

	modListContainer:CalcVisible()

	modListContainer.HandleEvent = function(self, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            self:ScrollLines(nil, lines)
        end
    end

    local listScrollbar = UIUtil.CreateVertScrollbarFor(modListContainer)
	listScrollbar.Depth:Set(panel.Depth() + 2)

    local index = 2
	for _, v in allmods do
		local uid = v.uid
        local status = modStatus[uid]
		if inLobby and uid == "F14E58B6-E7F3-11DD-88AB-418A55D89593" then
			status.cantoggle = false
		end
        index = index + 1
	end

    _InternalUpdateStatus = function(selectedModsFromHost)
        for i, modInfo in allmods do
            local uid = modInfo.uid
            if not modStatus[uid].cantoggle then
                modStatus[uid].checked = selectedModsFromHost[uid] or false
                UpdateModListTable()
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Mod details display
    ---------------------------------------------------------------------------

    modDetails = Group(panel)
    modDetails.Width:Set(500)
    modDetails.Height:Set(460)
    LayoutHelpers.RightOf(modDetails, modListContainer, 32)
    modDetails.icon = Bitmap(modDetails)
    modDetails.icon.Width:Set(70)
    modDetails.icon.Height:Set(70)
    LayoutHelpers.AtLeftTopIn(modDetails.icon, modDetails, 4, 4)
    modDetails.name = UIUtil.CreateText(modDetails, '', 20, UIUtil.titleFont)
    modDetails.name.Width:Set(320)
    LayoutHelpers.RightOf(modDetails.name, modDetails.icon, 4)
    modDetails.author = MultiLineText(modDetails, UIUtil.bodyFont, 14, UIUtil.fontColor)
    modDetails.author.Width:Set(300)
    LayoutHelpers.Below(modDetails.author, modDetails.name, 4)
    modDetails.desc = MultiLineText(modDetails, UIUtil.bodyFont, 14, UIUtil.fontColor)
    modDetails.desc.Height:Set(46)
    modDetails.desc.Width:Set(modDetails.Width())
    LayoutHelpers.Below(modDetails.desc, modDetails.icon, 16)
    modDetails.uiOnly = UIUtil.CreateText(modDetails, '', 14, 'Arial Bold')
    LayoutHelpers.Below(modDetails.uiOnly, modDetails.desc, 2)

    modDetails.extras = ItemList(modDetails)
    modDetails.extras.Height:Set(192)
    modDetails.extras.Width:Set(modDetails.Width() - 40)
    LayoutHelpers.Below(modDetails.extras, modDetails.uiOnly, 4)
    UIUtil.CreateVertScrollbarFor(modDetails.extras)
    modDetails.extras:Hide()

    modDetails.configBtn = UIUtil.CreateButtonStd(modDetails, '/lobby/lan-game-lobby/smalltoggle', "Settings", 12, 2)
    LayoutHelpers.Below(modDetails.configBtn, modDetails.extras, 4)
    modDetails.configBtn.OnClick = function(self, modifiers) end
    Tooltip.AddButtonTooltip(modDetails.configBtn, 'modmgr_modcfg')
    modDetails.configBtn:Hide()

    modDetails.copyright = MultiLineText(modDetails, UIUtil.bodyFont, 14, UIUtil.fontColor)
    modDetails.copyright.Width:Set(modDetails.Width())
    modDetails.copyright.Height:Set(28)
    LayoutHelpers.AtBottomIn(modDetails.copyright, modDetails, 16)
    LayoutHelpers.AtLeftIn(modDetails.copyright, modDetails, 4)
    modDetails.version = UIUtil.CreateText(modDetails, '', 14, UIUtil.bodyFont)
    LayoutHelpers.Above(modDetails.version, modDetails.copyright, 2)

    ---------------------------------------------------------------------------
    -- Misc. button behaviours
    ---------------------------------------------------------------------------
    local function KillDialog(cancel)
        local selectedMods
        if not cancel then
            selectedMods = {}

            for k, v in modStatus do
                if v.checked then
                    selectedMods[k] = true
                end
            end
        end

        -- Clear out the module var '_InternalUpdateStatus' to disable background updates
        _InternalUpdateStatus = nil

        modStruct = false

        if over then
            panel:Destroy()
        else
            parent:Destroy()
        end

        (exitBehavior or Mods.SetSelectedMods)(selectedMods)
    end

    local loudStdBtn = UIUtil.CreateButtonStd(panel, '/widgets/small', "LOUD Standard", 12, 2)
    LayoutHelpers.AtRightTopIn(loudStdBtn, panel, 30, 75)
    loudStdBtn.OnClick = function(self, modifiers)
        for _, v in loudStandard do
            modStatus[v].checked = true
        end
        UpdateModListTable()
    end
    Tooltip.AddButtonTooltip(loudStdBtn, 'modmgr_loudstandard')

    local loadBtn = UIUtil.CreateButtonStd(panel, '/widgets/tiny', "Load", 12, 2)
    LayoutHelpers.LeftOf(loadBtn, loudStdBtn)
    loadBtn.OnClick = function(self, modifiers)
		CreateLoadPresetDialog(panel, modListTable, modStatus)
    end

    local saveBtn = UIUtil.CreateButtonStd(panel, '/widgets/tiny', "Save", 12, 2)
    LayoutHelpers.LeftOf(saveBtn, loadBtn)
    saveBtn.OnClick = function(self, modifiers)
		CreateSavePresetDialog(panel, modStatus)
    end

    local cancelBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _Cancel>", 16, nil, nil, "UI_Menu_Cancel_02")
    LayoutHelpers.AtRightTopIn(cancelBtn, panel, 30, 580)
    cancelBtn.OnClick = function(self, modifiers)
        KillDialog(true)
    end

    local okBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _Ok>", 16, nil, nil, nil, "UI_Opt_Yes_No")
    LayoutHelpers.LeftOf(okBtn, cancelBtn)
    okBtn.OnClick = function(self, modifiers)
        KillDialog(false)
    end

    local disableBtn = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "Disable All", 16, 2)
    LayoutHelpers.AtLeftTopIn(disableBtn, panel, 30, 580)
    disableBtn.OnClick = function(self, modifiers)
        for _, v in modStatus do
            v.checked = false
        end
        for _, v in modListTable do
            if v.uid then
                v:SetVisual(modStatus[v.uid])
            end
        end
    end

    UIUtil.MakeInputModal(panel, function() okBtn.OnClick(okBtn) end, function() cancelBtn.OnClick(cancelBtn) end)
end

local function GetPossibleConflicts(modInfo, allMods)
    local ret = {}
    for _, v_uid in modInfo.conflicts do
        if allMods[v_uid] then
            table.insert(ret, allMods[v_uid].name)
        end
    end
    return ret
end

function DisplayModDetails(uid, modStatus)
    local allMods = Mods.AllSelectableMods()
    local modInfo = allMods[uid]
    modDetails.icon:SetTexture(modInfo.icon)
    modDetails.name:SetText(modInfo.name)
    -- If the mod's name is still too long,
    -- it probably needs a brevity check
    if modDetails.name:GetStringAdvance(modDetails.name:GetText()) > modDetails.name.Width() then
        modDetails.name:SetFont(UIUtil.titleFont, 16)
    else
        modDetails.name:SetFont(UIUtil.titleFont, 20)
    end
    modDetails.author:SetText("by "..modInfo.author)
    modDetails.version:SetText("Version "..string.format("%.2f", modInfo.version):gsub("%.?0+$", ""))
    modDetails.desc:SetText(modInfo.description)

    if modInfo.ui_only then
        modDetails.uiOnly:SetText("UI Mod (Client-Side)")
    else
        modDetails.uiOnly:SetText("Sim Mod (Server-Side)")
    end

    modDetails.extras:DeleteAllItems()
    modDetails.extras:Hide()

    if modInfo.requires and not table.empty(modInfo.requires) then
        modDetails.extras:Show()
        modDetails.extras:AddItem("Requires:")
        for _, v_uid in modInfo.requires do
            modDetails.extras:AddItem(" |--> "..allMods[v_uid].name or ("Missing Mod ("..v_uid..")"))
        end
    end

    if modInfo.conflicts then
        local possibleConflicts = GetPossibleConflicts(modInfo, allMods)
        if not table.empty(possibleConflicts) then
            modDetails.extras:Show()
            modDetails.extras:AddItem("Conflicts With:")
            for _, name in possibleConflicts do
                modDetails.extras:AddItem(" |--> "..name)
            end
        end
    end

    if modInfo.affects and not table.empty(modInfo.affects) then
        modDetails.extras:Show()
        modDetails.extras:AddItem("Affects:")
        for _, v_uid in modInfo.affects do
            modDetails.extras:AddItem(" |--> "..allMods[v_uid].name or ("Missing Mod ("..v_uid..")"))
        end
    end

    if modInfo.recommends and not table.empty(modInfo.recommends) then
        modDetails.extras:Show()
        modDetails.extras:AddItem("Also Recommended:")
        for _, v_uid in modInfo.recommends do
            modDetails.extras:AddItem(" |--> "..allMods[v_uid].name or ("Missing Mod ("..v_uid..")"))
        end
    end

    local env = {}
    local ok, _ = pcall(doscript, modInfo.location..'/config.lua', env)
    if ok then
        modDetails.configBtn:Show()
        modDetails.configBtn.OnClick = function(self, modifiers)
            ModConfigDialog(modDetails:GetParent(), modInfo, env.config, modStatus[uid])
        end
    else
        modDetails.configBtn.OnClick = function(self, modifiers) end
        modDetails.configBtn:Hide()
    end

    if not modInfo.copyright or modInfo.copyright == "" then
        modDetails.copyright:SetText("Copyright: None")
    else
        modDetails.copyright:SetText("Copyright: "..modInfo.copyright)
    end
end

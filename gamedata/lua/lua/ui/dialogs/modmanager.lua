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

local modDetails = false

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
        '2529ea71-93ef-41a6-b552-EXPERICON00005', -- Experimental Icons Overhaul
        'EF3ADDB4-9D34-437F-B1C8-440DAF896802', -- Mass Fab Manager
        'D000E905-1E97-420D-8ED9-DF083282F59D', -- Sequential Mex Upgrade
        '89BF1572-9EA8-11DC-1313-635F56D89591', -- Supreme Economy
        'HUSSAR-PL-a1e2-c4t4-scfa-ssbmod-v1240', -- Supreme Score Board
    },
    ["Mini-Mods"] = {
        'ffffffff-6f00-4864-9599-4133236eea7a', -- Evenflow
        'ffffffff-6e98-4864-9599-4133236eea7a', -- Integrated Storage
        'ffffffff-ffff-ffff-ffff-fffffffffffe', -- Structure Enhancements
    },
    ["Mutators"] = {
        'ffffffff-9d4e-11dc-8314-0800200c0605', -- Enhanced Commanders
        'ffffffff-9d4e-11dc-8314-0800200c0702', -- Enhanced Experimental Artillery
        '25D57D85-7D84-27HT-A502-LDIPS0000002', -- Lucky Dip
        '0a970b58-533d-11dc-8314-0800200c9a66', -- Realistic Nukes
        '74A9EAB2-E851-11DB-A1F1-F2C755D89593', -- Resource Rich
    },
    ["Miscellaneous"] = {
        '25D57D85-9JA7-D842-GKG4-ORIGIN0000001', -- BrewLAN Baristas
        '25D57D85-9JA7-D842-GKG4-DAMAGENO00000', -- BrewLAN Damage Numbers
        '2529ea71-93ef-41a6-b552-LOGS0000000009', -- BrewLAN Debug Tools
        '5362BE90-44BE-11DD-A519-83AF56D89593', -- Supreme Commander Music
    },
    ["Usermods"] = {},
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
                    v.checkbox:SetCheck(modStatus[v.uid].checked, true)
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

    local dlgLabel = UIUtil.CreateText(panel, "<LOC uimod_0001>Click to select or deselect", 20, 'Arial Bold')
    LayoutHelpers.AtLeftTopIn(dlgLabel, panel, 30, 80)

    ---------------------------------------------------------------------------
    -- Mod list control
    ---------------------------------------------------------------------------

    local function InSchema(uidArg)
        for _, v in modSchema do
            for _, uid in v do
                if uidArg == uid then
                    return true
                end
            end
        end
        return false
    end

    modStruct = {}

    for key, block in modSchema do
        modStruct[key] = {}
        modStruct[key].name = key
        -- RATODO: Leave some closed by default
        modStruct[key].open = true
        modStruct[key].uids = {}
        for _, uid in block do
            table.insert(modStruct[key].uids, uid)
        end
    end

    local allmods = Mods.AllSelectableMods()
    local selmods = Mods.GetSelectedMods()

    for _, v in allmods do
        if not InSchema(v.uid) then
            table.insert(modSchema['Usermods'], v.uid)
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

    local modListTable = {}

    local function UpdateModListTable()
        for _, v in modListTable do
            if v.uid then
                v.checkbox:SetCheck(modStatus[v.uid].checked, true)
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
        grp.checkbox = UIUtil.CreateCheckboxStd(grp, '/dialogs/check-box_btn/radio')
        LayoutHelpers.AtLeftIn(grp.checkbox, grp, 2)
        LayoutHelpers.AtVerticalCenterIn(grp.checkbox, grp)
        -- Either '[+]' or '[-]' to indicate folder state
        grp.folded = UIUtil.CreateText(grp, '', 18, 'Arial Bold')
        LayoutHelpers.AtLeftIn(grp.folded, grp, 2)
        LayoutHelpers.AtVerticalCenterIn(grp.folded, grp)
        grp.icon = Bitmap(grp)
        grp.icon.Width:Set(36)
        grp.icon.Height:Set(36)
        LayoutHelpers.CenteredRightOf(grp.icon, grp.checkbox, 4)
        grp.name = UIUtil.CreateText(grp, '', 18, UIUtil.bodyFont)
        LayoutHelpers.CenteredRightOf(grp.name, grp.icon, 4)
        grp.icon:DisableHitTest()
        grp.name:DisableHitTest()
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
        for _, block in modStruct do
            -- Skip entire block if scroll bar dictates
            if not block.open and skip >= 1 then
                skip = skip - 1
                continue
            end

            -- RATODO: If no mods in this block pass all filters, continue

            -- Block is eligible to be displayed
            -- However, header might get skipped
            if skip <= 0 then
                i = i + 1
                if i > numElements then break end
                modListTable[i].uid = false
                modListTable[i].block = block
                modListTable[i].checkbox:Hide()
                modListTable[i].icon:Hide()
                if block.open then
                    modListTable[i].folded:SetText("[-]")
                else
                    modListTable[i].folded:SetText("[+]")
                end
                modListTable[i].name:SetNewFont('Arial', 18)
                modListTable[i].name:SetText(block.name)
                modListTable[i].HandleEvent = function(self, event)
                    if event.Type == 'MouseExit' then
                        self.bg:SetSolidColor('22282B')
                    elseif event.Type == 'MouseEnter' then
                        self.bg:SetSolidColor('42484B')
                    elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                        self.block.open = not self.block.open
                        -- Folding causes list shrinkage; better to adjust scrollbar
                        -- now, since it's jarring if user input causes it
                        if not self.block.open then
                            if self.top == 0 then
                                selfMLC:ScrollLines(nil, 1)
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
                modListTable[i].checkbox:Show()

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
                                line.checkbox:SetCheck(false, true)
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
                        line.checkbox:SetCheck(false, true)
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
                        UIUtil.QuickDialog(parent, boxText, "<LOC _Ok>")
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
                                CreateDependsDialog(panel, boxText, function()
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
                            end
                        else
                            modStatus[line.uid].checked = true
                            line.checkbox:SetCheck(true, true)
                        end
                    end
                end

                modListTable[i].checkbox.OnClick = function(self, modifiers)
                    if modStatus[self:GetParent().uid].cantoggle then
                        if IsModExclusive(modInfo.uid) and not self:IsChecked() then
                            HandleExclusiveClick(self:GetParent())
                        else
                            if exclusiveModSelected then
                                HandleExclusiveActive(self:GetParent(), HandleNormalClick)
                            else
                                HandleNormalClick(self:GetParent())
                            end
                        end
                    end
                end
                modListTable[i].folded:SetText('')
                modListTable[i].checkbox:SetCheck(modStatus[uid].checked, true)
                modListTable[i].icon:Show()
                modListTable[i].icon:SetTexture(modInfo.icon)
                modListTable[i].name:SetNewFont('Arial', 14)
                modListTable[i].name:SetText(modInfo.name)
                modListTable[i].HandleEvent = function(self, event)
                    if event.Type == 'MouseExit' then
                        self.bg:SetSolidColor('22282B')
                    elseif event.Type == 'MouseEnter' then
                        self.bg:SetSolidColor('42484B')
                    elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                        DisplayModDetails(self.uid)
                        local sound = Sound({Cue = "UI_Mod_Select", Bank = "Interface",})
                        PlaySound(sound)
                    end
                end
            end
        end
        -- Clear remaining lines if not all need to be filled
        if i < numElements then
            for j = i + 1, numElements do
                modListTable[j].uid = false
                modListTable[j].block = false
                modListTable[j].folded:SetText('')
                modListTable[j].checkbox:Hide()
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
    modDetails.Width:Set(520)
    modDetails.Height:Set(460)
    LayoutHelpers.RightOf(modDetails, modListContainer, 24)
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
    modDetails.version = UIUtil.CreateText(modDetails, '', 14, UIUtil.bodyFont)
    LayoutHelpers.Below(modDetails.version, modDetails.author, 2)
    modDetails.desc = MultiLineText(modDetails, UIUtil.bodyFont, 14, UIUtil.fontColor)
    modDetails.desc.Height:Set(42)
    modDetails.desc.Width:Set(modDetails.Width())
    LayoutHelpers.Below(modDetails.desc, modDetails.icon, 16)
    modDetails.uiOnly = UIUtil.CreateText(modDetails, '', 14, 'Arial Bold')
    LayoutHelpers.Below(modDetails.uiOnly, modDetails.desc, 2)
    modDetails.copyright = UIUtil.CreateText(modDetails, '', 14, UIUtil.bodyFont)
    LayoutHelpers.AtBottomIn(modDetails.copyright, modDetails, 4)
    LayoutHelpers.AtLeftIn(modDetails.copyright, modDetails, 4)

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
		CreateSavePresetDialog(panel, modListTable)
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
                v.checkbox:SetCheck(false, true)
            end
        end
    end

    local filterCombo = Combo(panel, 14, 10, nil, nil, 'UI_Tab_Click_01', 'UI_Tab_Rollover_01')
    filterCombo.Width:Set(160)
    LayoutHelpers.CenteredRightOf(filterCombo, disableBtn, 8)

    UIUtil.MakeInputModal(panel, function() okBtn.OnClick(okBtn) end, function() cancelBtn.OnClick(cancelBtn) end)
end

function DisplayModDetails(uid)
    local modInfo = Mods.AllSelectableMods()[uid]
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
        modDetails.uiOnly:SetText("UI Mod")
    else
        modDetails.uiOnly:SetText("Sim Mod")
    end
    modDetails.copyright:SetText("Copyright: "..modInfo.copyright)
end
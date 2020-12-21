--*****************************************************************************
--* File: lua/modules/ui/dialogs/mapselect.lua
--* Author: Chris Blackwell
--* Summary: Dialog to facilitate map selection
--*
--* Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Edit = import('/lua/maui/edit.lua').Edit
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local Group = import('/lua/maui/group.lua').Group
local MenuCommon = import('/lua/ui/menus/menucommon.lua')
local MapPreview = import('/lua/ui/controls/mappreview.lua').MapPreview
local MapUtil = import('/lua/ui/maputil.lua')
local Mods = import('/lua/mods.lua')
local Combo = import('/lua/ui/controls/combo.lua').Combo
local Tooltip = import('/lua/ui/game/tooltip.lua')
local ModManager = import('/lua/ui/dialogs/modmanager.lua')
local EnhancedLobby = import('/lua/enhancedlobby.lua')

-- In folderMap, key corresponds to an ItemList row,
-- value[1] corresponds to a folder in folders{}
-- value[2] corresponds to a scenario in folders[x][3]
local folders = MapUtil.EnumerateSkirmishFolders()
local folderMap = { {} }

local selectedScenario = false
local description = false
local descText = false
local posGroup = false
local mapList = false
local filters = {}
local filterTitle = false
local mapsize = false
local mapplayers = false
local mapInfo = false
local selectButton = false

local currentFilters = { 
    ['map_select_supportedplayers'] = 0, 
    ['map_select_size'] = 0, 
    ['map_select_supportedplayers_limiter'] = "equal", 
    ['map_select_size_limiter'] = "equal", 
}

local Options = {}
local OptionSource = {}
local OptionContainer = false
local advOptions = false
local changedOptions = {}
local restrictedCategories = nil

mapFilters = {
    {
        FilterName = "<LOC MAPSEL_0009>Supported Players",
        FilterKey = 'map_select_supportedplayers',
        Options = {
            {text = "<LOC MAPSEL_0010>All", key = 0},
            {text = "<LOC MAPSEL_0011>2", key = 2},
            {text = "<LOC MAPSEL_0012>3", key = 3},
            {text = "<LOC MAPSEL_0013>4", key = 4},
            {text = "<LOC MAPSEL_0014>5", key = 5},
            {text = "<LOC MAPSEL_0015>6", key = 6},
            {text = "<LOC MAPSEL_0016>7", key = 7},
            {text = "<LOC MAPSEL_0017>8", key = 8},
            {text = "10", key = 10},
            {text = "12", key = 12},
            {text = "16", key = 16},
        }
    },
    {
        FilterName = "<LOC MAPSEL_0024>Map Size",
        FilterKey = 'map_select_size',
        Options = {
            {text = "<LOC MAPSEL_0025>All", key = 0},
            {text = "<LOC MAPSEL_0026>5km", key = 256},
            {text = "<LOC MAPSEL_0027>10km", key = 512},
            {text = "<LOC MAPSEL_0028>20km", key = 1024},
            {text = "<LOC MAPSEL_0029>40km", key = 2048},
            {text = "<LOC MAPSEL_0030>81km", key = 4096},
        }
    },
    {
        FilterName = "AI Markers",
        FilterKey = 'map_ai_markers',
		NoDelimiter = true,
        Options = {
			{text = "All", key = 0},
            {text = "Yes", key = true},
            {text = "No", key = false},
        }
    },
}

-- Used to compute the offset of spawn / mass / hydro markers on the (big) preview
-- when the map is not square
-- Courtesy of Jip
local function ComputeNonSquareOffset(width, height)
    -- determine the largest dimension
    local largest = width
    if height > largest then
        largest = height 
    end

    -- determine correction factor for uneven dimensions
    local yOffset = 0
    local xOffset = 0 
    if width > height then 
        local factor = height / width
        yOffset = 0.5 * factor
    end

    if width < height then 
        local factor = width / height
        xOffset = 0.5 * factor
    end

    return xOffset, yOffset, largest
end

-- Create a filter dropdown and title from the table above
function CreateFilter(parent, filterData)
    local group = Group(parent)
    group.Depth:Set(function() return parent.Depth() + 10 end)
    group.Width:Set(286)
    
    local tempname = filterData.FilterName
    group.title = UIUtil.CreateText(group, tempname, 16, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(group.title, group, 2)
    Tooltip.AddControlTooltip(group.title, filterData.FilterKey)
    
    group.combo = Combo(group, 14, 10, nil, nil, "UI_Tab_Click_01", "UI_Tab_Rollover_01")
    LayoutHelpers.AtVerticalCenterIn(group.combo, group.title)
    group.combo.Right:Set(group.Right)
    group.combo.Width:Set(80)
    
    local itemArray = {}
    group.combo.keyMap = {}
    for index, val in filterData.Options do
        itemArray[index] = val.text
        group.combo.keyMap[index] = val.key
    end
    group.combo.Key = filterData.FilterKey
    group.combo:AddItems(itemArray, 1)
    
    group.combo.OnClick = function(self, index, text)
        currentFilters[self.Key] = self.keyMap[index]
        PopulateMapList()
    end
	if not filterData.NoDelimiter then    
		group.comboFilter = Combo(group, 14, 10, nil, nil, "UI_Tab_Click_01", "UI_Tab_Rollover_01")
		LayoutHelpers.AtVerticalCenterIn(group.comboFilter, group.title)
		group.comboFilter.Right:Set(function() return group.combo.Left() - 5 end)
		group.comboFilter.Width:Set(60)
		
		local filterArray = {
			{text = "=", key = "equal"},
			{text = ">=", key = "greater"},
			{text = "<=", key = "less"}}

		local tempText = {}
		group.comboFilter.keyMap = {}
		for index, val in filterArray do
			tempText[index] = val.text
			group.comboFilter.keyMap[index] = val.key
		end
		group.comboFilter.Key = filterData.FilterKey.."_limiter"
		group.comboFilter:AddItems(tempText, 1)
		
		group.comboFilter.OnClick = function(self, index, text)
			currentFilters[self.Key] = self.keyMap[index]
			PopulateMapList()
		end
	end
    
    group.Height:Set(group.title.Height())
    
    return group
end

local function ResetFilters()
    currentFilters = { 
        ['map_select_supportedplayers'] = 0, 
        ['map_select_size'] = 0, 
        ['map_select_supportedplayers_limiter'] = "equal", 
        ['map_select_size_limiter'] = "equal", 
    }
    changedOptions = {}
    selectedScenario = nil
    restrictedCategories = nil    
end

local function ShowMapPositions(mapCtrl, scenario)
    if posGroup then
        posGroup:Destroy()
        posGroup = false
    end

    if not scenario.size then
        LOG("MapSelect: Can't show map positions as size field isn't in scenario yet (must be resaved with new editor!)")
        return
    end

    posGroup = Group(mapCtrl)
    LayoutHelpers.FillParent(posGroup, mapCtrl)

    local startPos = MapUtil.GetStartPositions(scenario)

    local cHeight = posGroup:Height()
    local cWidth = posGroup:Width()

    local mWidth = scenario.size[1]
    local mHeight = scenario.size[2]
    local xOffset, yOffset, largest = ComputeNonSquareOffset(mWidth, mHeight)
    
    for army, pos in startPos do
    
        local marker = Bitmap(posGroup, UIUtil.UIFile('/dialogs/mapselect02/commander.dds'))
        
        LayoutHelpers.AtLeftTopIn(
            marker, 
            posGroup, 
            ((xOffset + pos[1] / largest) * cWidth) - (marker.Width() / 2), 
            ((yOffset + pos[2] / largest) * cHeight) - (marker.Height() / 2)
        )
    end
end

function CreateDialog(selectBehavior, exitBehavior, over, singlePlayer, defaultScenarioName, curOptions, availableMods, OnModsChanged)
-- Control layout
    local parent = nil
    local background = nil
	
    if over then
        parent = UIUtil.CreateScreenGroup(over, "<LOC MAPSEL_0001>Map Select Screen Group")
        parent.Depth:Set(GetFrame(over:GetRootFrame():GetTargetHead()):GetTopmostDepth() + 1)
    else
        parent = UIUtil.CreateScreenGroup(GetFrame(0), "<LOC MAPSEL_0002>Map Select Screen Group")
        background = MenuCommon.SetupBackground(GetFrame(0))
    end

    -- don't parent background to screen group so it doesn't get destroyed until we leave the menus

    local exitButton = nil
	
    if background then
        exitButton = MenuCommon.CreateExitMenuButton(parent, background, "<LOC _Back>")
    end

    --TODO this panel needs to be moved to dialogs
    local panel = Bitmap(parent, UIUtil.UIFile('/scx_menu/game-settings/panel_bmp.dds'))
	
    panel.brackets = UIUtil.CreateDialogBrackets(panel, 40, 35, 40, 33)
    LayoutHelpers.AtCenterIn(panel, parent)

    local title = UIUtil.CreateText(panel, "<LOC map_sel_0000>", 24)
	
    LayoutHelpers.AtTopIn(title, panel, 22)
    LayoutHelpers.AtHorizontalCenterIn(title, panel)

    local cancelButton = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _Cancel>", 16, 2, 0, "UI_Menu_Cancel_02")
	
    LayoutHelpers.AtRightTopIn(cancelButton, panel, 15, 645)
    
    selectButton = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC _OK>", 16, 2)
    LayoutHelpers.LeftOf(selectButton, cancelButton)
    
    selectButton.Depth:Set(function() return panel.Depth() + 10 end) --TODO what is this getting under when it's in over state?
    
    local modButton = UIUtil.CreateButtonStd(panel, '/scx_menu/small-btn/small', "<LOC tooltipui0145>", 16, 2)
	
    LayoutHelpers.AtLeftIn(modButton, panel, 15)
    LayoutHelpers.AtVerticalCenterIn(modButton, selectButton)
    selectButton.Depth:Set(function() return panel.Depth() + 10 end)
    Tooltip.AddButtonTooltip(modButton, "Lobby_Mods")
	
    modButton.OnClick = function(self, modifiers)
	
        modstatus = ModManager.HostModStatus(availableMods or {})
        mapList:AbandonKeyboardFocus()
		
        ModManager.CreateDialog( panel, true, function(modsSelected) mapList:AcquireKeyboardFocus(true)	OnModsChanged(modsSelected) end, true, modstatus)
    end

    local restrictedUnitsButton = UIUtil.CreateButtonStd(modButton, '/scx_menu/small-btn/small', "<LOC sel_map_0006>Unit Manager", 16, 2)
    LayoutHelpers.RightOf(restrictedUnitsButton, modButton, -20)
    Tooltip.AddButtonTooltip(restrictedUnitsButton, "lob_RestrictedUnits")
   
    if not restrictedCategories then restrictedCategories = curOptions.RestrictedCategories end
    restrictedUnitsButton.OnClick = function(self, modifiers)
        mapList:AbandonKeyboardFocus()
        import('/lua/ui/lobby/restrictedunitsdlg.lua').CreateDialog(parent, 
            restrictedCategories, 
            function(rc) 
                restrictedCategories = rc 
                mapList:AcquireKeyboardFocus(true)
            end,
            function()
                mapList:AcquireKeyboardFocus(true)
            end,
            true)
    end
	
	local doNotRepeatMap
	local randomMapButton = UIUtil.CreateButtonStd(modButton, '/scx_menu/small-btn/small', "Random Map", 16, 2)
	LayoutHelpers.RightOf(randomMapButton, restrictedUnitsButton, -20)
	Tooltip.AddButtonTooltip(randomMapButton, 'lob_random_map')
	
	function randomLobbyMap(self)
        local nummapa
        local folderCount = table.getsize(folders)
        nummapa = math.random(1, folderCount)
        
        -- Random folder
		if folderCount >= 2 and nummapa == doNotRepeatMap then
			repeat
				nummapa = math.random(1, folderCount)
			until nummapa ~= doNotRepeatMap
		end
        doNotRepeatMap = nummapa
        local fold = folders[nummapa]
        local mapCount = table.getsize(fold[3])

        if mapCount == 1 then
            selectedScenario = fold[3][1]
        else
            -- Random map from folder
            doNotRepeatMap = nil
            nummapa = math.random(1, mapCount)
            if mapCount >= 2 and nummapa == doNotRepeatMap then
                repeat
                    nummapa = math.random(1, mapCount)
                until nummapa ~= doNotRepeatMap
            end
            doNotRepeatMap = nummapa
            selectedScenario = fold[3][nummapa]
        end

		selectBehavior(selectedScenario, changedOptions, restrictedCategories)
		import('/lua/ui/lobby/lobby.lua').PublicChat("("..EnhancedLobby.GetLEMVersion(true)..") Random Map Selected: "..selectedScenario.name)
		ResetFilters()
	end
	
    randomMapButton.OnClick = function(self, modifiers)
        -- RATODO: Somehow make this respect filters
		randomLobbyMap(self)
	end

    UIUtil.MakeInputModal(panel)

    mapListTitle = UIUtil.CreateText(panel, "<LOC sel_map_0005>Maps", 18)
    LayoutHelpers.AtLeftTopIn(mapListTitle, panel, 360, 176)

    mapList = ItemList(panel, "mapselect:mapList")
    mapList:SetFont(UIUtil.bodyFont, 14)
    mapList:SetColors(UIUtil.fontColor, "00000000", "FF000000",  UIUtil.highlightColor, "ffbcfffe")
    mapList:ShowMouseoverItem(true)
    mapList.Width:Set(258)
    mapList.Height:Set(438)
    LayoutHelpers.AtLeftTopIn(mapList, panel, 360, 202)
    mapList.Depth:Set(function() return panel.Depth() + 10 end) --TODO what is this getting under when it's in over state?
    mapList:AcquireKeyboardFocus(true)
    mapList.OnDestroy = function(control)
        mapList:AbandonKeyboardFocus()
        ItemList.OnDestroy(control)
    end
    
    mapList.HandleEvent = function(self,event)
        if event.Type == 'KeyDown' then
            if event.KeyCode == UIUtil.VK_ESCAPE then
                cancelButton.OnClick(cancelButton)
                return true
            elseif event.KeyCode == UIUtil.VK_ENTER then
                selectButton.OnClick(selectButton)
                return true
            end
        end
        
        return ItemList.HandleEvent(self,event)
    end

    UIUtil.CreateVertScrollbarFor(mapList)

    local preview = MapPreview(panel)
    preview.Width:Set(290)
    preview.Height:Set(288)
    LayoutHelpers.AtLeftTopIn(preview, panel, 37, 102)
    
    local previewOverlay = Bitmap(preview, UIUtil.UIFile('/dialogs/mapselect03/map-panel-glow_bmp.dds'))
    LayoutHelpers.AtCenterIn(previewOverlay, preview)

    local nopreviewtext = UIUtil.CreateText(panel, "<LOC _No_Preview>No Preview", 24)
    LayoutHelpers.AtCenterIn(nopreviewtext, preview)
    nopreviewtext:Hide()

    descriptionTitle = UIUtil.CreateText(panel, "<LOC sel_map_0000>Map Info", 18)
    LayoutHelpers.AtLeftTopIn(descriptionTitle, panel, 35, 420)
    
    description = ItemList(panel, "mapselect:description")
    description:SetFont(UIUtil.bodyFont, 14)
    description:SetColors(UIUtil.fontColor, "00000000", UIUtil.fontColor, "00000000")
    description.Width:Set(273)
    description.Height:Set(180)
    LayoutHelpers.AtLeftTopIn(description, panel, 33, 450)
    UIUtil.CreateVertScrollbarFor(description)
    
    filterTitle = UIUtil.CreateText(panel, "<LOC sel_map_0003>Filters", 18)
    LayoutHelpers.AtLeftTopIn(filterTitle, panel, 360, 60)
    
    for i, filterData in mapFilters do
        local index = i
        filters[index] = CreateFilter(filterTitle, filterData)
        if index == 1 then
            LayoutHelpers.Below(filters[1], filterTitle, 10)
        else
            LayoutHelpers.Below(filters[index], filters[index-1], 10)
        end
    end

-- Initialize controls
    PopulateMapList()
    SetupOptionsPanel(panel, singlePlayer, curOptions)
    
-- Control behvaior
    if exitButton then
        exitButton.OnClick = function(self)
            exitBehavior()
            ResetFilters()
        end
    end

    selectButton.OnClick = function(self, modifiers)
        selectBehavior(selectedScenario, changedOptions, restrictedCategories)
        ResetFilters()
    end

    cancelButton.OnClick = function(self, modifiers)
        exitBehavior()
        ResetFilters()
    end
    
    function PreloadMap(row)
        local fold = folders[folderMap[row + 1][1]]
        local scen = fold[3][folderMap[row + 1][2]]
        if scen == selectedScenario then
            return
        end
        selectedScenario = scen
        local mapfile = scen.map
        if DiskGetFileInfo(mapfile) then
            advOptions = scen.options
            RefreshOptions(false, singlePlayer)
            PrefetchSession(mapfile, Mods.GetGameMods(), false)
            preview:Show()
            if not preview:SetTexture(scen.preview) then
                preview:SetTextureFromMap(mapfile)
            end
            nopreviewtext:Hide()

            ShowMapPositions(preview,scen)
            SetDescription(scen)
        else
            WARN("No scenario map file defined")
            preview:Hide()
            nopreviewtext:Show()
            description:DeleteAllItems()
            description:AddItem(LOC("<LOC MAPSEL_0000>No description available."))
            mapplayers:SetText(LOCF("<LOC map_select_0002>NO START SPOTS DEFINED"))
            mapsize:SetText(LOCF("<LOC map_select_0003>NO MAP SIZE INFORMATION"))
            selectButton:Disable()
        end
    end

    mapList.OnKeySelect = function(self,row)
        -- If this is a true folder, open it and repop the map list
        local fold = folders[folderMap[row + 1][1]]
        if table.getsize(fold[3]) > 1 and not folderMap[row + 1][2] then
            fold[2] = true
            PopulateMapList()
            return
        end
        mapList:SetSelection(row)
        PreloadMap(row)
        local sound = Sound({Cue = "UI_Skirmish_Map_Select", Bank = "Interface",})
        PlaySound(sound)
    end
    
    mapList.OnClick = function(self, row, noSound)
        -- If this is a true folder, toggle it and repop the map list
        local fold = folders[folderMap[row + 1][1]]
        if table.getsize(fold[3]) > 1 and not folderMap[row + 1][2] then
            fold[2] = not fold[2]
            PopulateMapList()
            return
        end
        mapList:SetSelection(row)
        PreloadMap(row)
        local sound = Sound({Cue = "UI_Skirmish_Map_Select", Bank = "Interface",})
        if not noSound then
            PlaySound(sound)
        end
    end
    
    mapList.OnDoubleClick = function(self, row)
        -- If this is a true folder, toggle it and repop the map list
        local fold = folders[folderMap[row + 1][1]]
        if table.getsize(fold[3]) > 1 and not folderMap[row + 1][2] then
            fold[2] = not fold[2]
            PopulateMapList()
            return
        end
        -- If this is a scenario instead, select it and return to the main lobby
        mapList:SetSelection(row)
        PreloadMap(row)
        local scen = folders[folderMap[row + 1][1]][3][folderMap[row + 1][2]]
        selectedScenario = scen
        selectBehavior(selectedScenario, changedOptions, restrictedCategories)
        ResetFilters()
    end

    -- Set list to first item or default
    local defaultRow
    if not defaultScenarioName then
        -- If no true folder at folders[1], call up its scenario
        -- Otherwise call up its first scenario
        if not folderMap[1][2] then
            defaultRow = 0
        else
            defaultRow = 1
        end
    else
        -- RATODO
        defaultRow = 0
        -- local i = 0
        -- for _, folder in folders do
        --     for _, scenario in folder[3] do
        --         if scenario.file == defaultScenarioName then
        --             defaultRow = i - 1
        --             break
        --         end
        --     end
        --     i = i + 1
        -- end
    end
    mapList:OnClick(defaultRow, true)
    mapList:ShowItem(defaultRow)

    return parent
end

function RefreshOptions(skipRefresh, singlePlayer)
    -- a little weird, but the "skip refresh" is set to prevent calc visible from being called before the control is properly setup
    -- it also means it's a flag that tells you this is the first time the dialog has been opened
    -- so we'll used this flag to reset the options sources so they can set up for multiplayer
    if skipRefresh then
        OptionSource[2] = {title = "<LOC uilobby_0002>Game Options", options = import('/lua/ui/lobby/lobbyoptions.lua').globalOpts}
        OptionSource[1] = {title = "<LOC uilobby_0001>Team Options", options = import('/lua/ui/lobby/lobbyoptions.lua').teamOptions}
        OptionSource[4] = {title = "Advanced AI Options", options = import('/lua/ui/lobby/lobbyoptions.lua').advAIOptions}
        
        table.sort(OptionSource[4].options, function(a, b) return LOC(a.label) < LOC(b.label) end)
        table.sort(OptionSource[2].options, function(a, b) return LOC(a.label) < LOC(b.label) end)
        table.sort(OptionSource[1].options, function(a, b) return LOC(a.label) < LOC(b.label) end)
    end
    OptionSource[3] = {}
    OptionSource[3] = {title = "<LOC lobui_0164>Advanced", options = advOptions or {}}
    
    Options = {}
    
    for _, OptionTable in OptionSource do
        if table.getsize(OptionTable.options) > 0 then
            table.insert(Options, {type = 'title', text = OptionTable.title})
            for optionIndex, optionData in OptionTable.options do
                if optionData.type and optionData.type == 'edit' then
                    table.insert(Options, {type = 'opt_edit', text = optionData.label, data = optionData})
                elseif not(singlePlayer and optionData.mponly == true) then
                    table.insert(Options, {type = 'opt_combo', text = optionData.label, data = optionData})
                end
            end
        end
    end
    if not skipRefresh then
        OptionContainer:CalcVisible()
    end
end

function SetupOptionsPanel(parent, singlePlayer, curOptions)
    ---------------------------------------------
    --Set Up Debriefing Area
    ---------------------------------------------
    local title = UIUtil.CreateText(parent, '<LOC PROFILE_0012>', 18)
    LayoutHelpers.AtLeftTopIn(title, parent, 660, 60)
    
    OptionContainer = Group(parent)
    OptionContainer.Height:Set(556)
    OptionContainer.Width:Set(260)
    OptionContainer.top = 0
    LayoutHelpers.AtLeftTopIn(OptionContainer, parent, 670, 84)
    
    local OptionDisplay = {}
    RefreshOptions(true, singlePlayer)
    
    local function CreateOptionCombo(parent, optionData, width)
        local combo = Combo(parent, nil, nil, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
        combo.Width:Set(240)
        combo.Depth:Set(function() return parent.Depth() + 10 end)
        local itemArray = {}
        combo.keyMap = {}
        local tooltipTable = {}
        Tooltip.AddComboTooltip(combo, tooltipTable, combo._list)
        combo.UpdateValue = function(key)
            combo:SetItem(combo.keyMap[key])
        end

        return combo
    end
    
    local function CreateOptionEdit(parent, optionData, width)
        local edit = Edit(parent)
        edit.Width:Set(240)
        edit.Height:Set(18)
        edit:SetMaxChars(5)

        edit.OnCharPressed = function(self, charcode)
            if charcode == UIUtil.VK_TAB then
                return true
            end
            -- Forbid all characters except digits
            if charcode >= 58 or charcode <= 47 then
                return true
            end
            local charLim = self:GetMaxChars()
            if STR_Utf8Len(self:GetText()) >= charLim then
                local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
                PlaySound(sound)
            end
        end

        edit.OnLoseKeyboardFocus = function(self)
            edit:AcquireFocus()
        end

        edit.OnNonTextKeyPressed = function(self, keyCode)
            if commandQueue and table.getsize(commandQueue) > 0 then
                if keyCode == 38 then
                    if commandQueue[commandQueueIndex + 1] then
                        commandQueueIndex = commandQueueIndex + 1
                        self:SetText(commandQueue[commandQueueIndex])
                    end
                end
                if keyCode == 40 then
                    if commandQueueIndex ~= 1 then
                        if commandQueue[commandQueueIndex - 1] then
                            commandQueueIndex = commandQueueIndex - 1
                            self:SetText(commandQueue[commandQueueIndex])
                        end
                    else
                        commandQueueIndex = 0
                        self:ClearText()
                    end
                end
            end
        end

        return edit
    end

    local function CreateOptionElements()
        local function CreateElement(index)
            OptionDisplay[index] = Group(OptionContainer)
            OptionDisplay[index].Height:Set(46)
            OptionDisplay[index].Width:Set(OptionContainer.Width)
        
            OptionDisplay[index].bg = Bitmap(OptionDisplay[index])
            OptionDisplay[index].bg.Depth:Set(OptionDisplay[index].Depth)
            LayoutHelpers.FillParent(OptionDisplay[index].bg, OptionDisplay[index])
            OptionDisplay[index].bg.Right:Set(function() return OptionDisplay[index].Right() - 10 end)
        
            OptionDisplay[index].text = UIUtil.CreateText(OptionContainer, '', 14, "Arial")
            OptionDisplay[index].text:DisableHitTest()
            LayoutHelpers.AtLeftTopIn(OptionDisplay[index].text, OptionDisplay[index], 10)
            
            OptionDisplay[index].edit = CreateOptionEdit(OptionDisplay[index])
            LayoutHelpers.AtLeftTopIn(OptionDisplay[index].edit, OptionDisplay[index], 5, 22)
            OptionDisplay[index].edit:Hide()
            OptionDisplay[index].combo = CreateOptionCombo(OptionDisplay[index])
            LayoutHelpers.AtLeftTopIn(OptionDisplay[index].combo, OptionDisplay[index], 5, 22)
        end
        
        CreateElement(1)
        LayoutHelpers.AtLeftTopIn(OptionDisplay[1], OptionContainer)
        
        local index = 2
        while OptionDisplay[table.getsize(OptionDisplay)].Bottom() + OptionDisplay[1].Height() < OptionContainer.Bottom() do
            CreateElement(index)
            LayoutHelpers.Below(OptionDisplay[index], OptionDisplay[index-1])
            index = index + 1
        end
    end
	
    CreateOptionElements()

    local numLines = function() return table.getsize(OptionDisplay) end
    
    local function DataSize()
        return table.getn(Options)
    end
    
    -- called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax
    -- aixs can be "Vert" or "Horz"
    OptionContainer.GetScrollValues = function(self, axis)
        local size = DataSize()
        --LOG(size, ":", self.top, ":", math.min(self.top + numLines, size))
        return 0, size, self.top, math.min(self.top + numLines(), size)
    end

    -- called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    OptionContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    OptionContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
    end

    -- called when the scrollbar wants to set a new visible top line
    OptionContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = DataSize()
        self.top = math.max(math.min(size - numLines() , top), 0)
        self:CalcVisible()
    end

    -- called to determine if the control is scrollable on a particular access. Must return true or false.
    OptionContainer.IsScrollable = function(self, axis)
        return true
    end
    -- determines what controls should be visible or not
    OptionContainer.CalcVisible = function(self)
        local function SetTextLine(line, data, lineID)
            if data.type == 'title' then
                line.text:SetText(LOC(data.text))
                line.text:SetFont(UIUtil.titleFont, 14, 3)
                line.text:SetColor(UIUtil.fontOverColor)
                line.bg:SetSolidColor('00000000')
                line.combo:Hide()
                LayoutHelpers.AtLeftTopIn(line.text, line, 0, 20)
                LayoutHelpers.AtHorizontalCenterIn(line.text, line)
            elseif data.type == 'spacer' then
                line.text:SetText('')
                line.combo:Hide()
            elseif data.type == 'opt_edit' then
                line.text:SetText(LOC(data.text))
                line.text:SetFont(UIUtil.bodyFont, 14)
                line.text:SetColor(UIUtil.fontColor)
                line.bg:SetTexture(UIUtil.UIFile('/dialogs/mapselect03/options-panel-bar_bmp.dds'))
                LayoutHelpers.AtLeftTopIn(line.text, line, 10, 5)
                if line.combo and not line.combo:IsHidden() then
                    line.combo:Hide()
                    line.edit:Show()
                end
                line.edit.OnTextChanged = function(self, newText, oldText)
                    changedOptions[data.data.key] = {value = newText, type = 'edit', pref = data.data.pref}
                end
                Tooltip.AddControlTooltip(line, data.data.pref)
                line.edit:SetText(tostring(curOptions[data.data.key]))
            else
                if line.edit and not line.edit:IsHidden() then
                    line.edit:Hide()
                end
                line.text:SetText(LOC(data.text))
                line.text:SetFont(UIUtil.bodyFont, 14)
                line.text:SetColor(UIUtil.fontColor)
                line.bg:SetTexture(UIUtil.UIFile('/dialogs/mapselect03/options-panel-bar_bmp.dds'))
                LayoutHelpers.AtLeftTopIn(line.text, line, 10, 5)
                line.combo:ClearItems()
                line.combo:Show()
                local itemArray = {}
                line.combo.keyMap = {}
                local tooltipTable = {}
                for index, val in data.data.values do
                    itemArray[index] = val.text
                    line.combo.keyMap[val.key] = index
                    tooltipTable[index] = 'lob_'..data.data.key..'_'..val.key
                end
                local defValue = changedOptions[data.data.key].index or line.combo.keyMap[curOptions[data.data.key]] or 1
                line.combo:AddItems(itemArray, defValue)
                line.combo.OnClick = function(self, index, text)
                    changedOptions[data.data.key] = {value = data.data.values[index].key, type = 'combo', pref = data.data.pref, index = index}
                end
                line.HandleEvent = Group.HandleEvent
                Tooltip.AddControlTooltip(line, data.data.pref)
                Tooltip.AddComboTooltip(line.combo, tooltipTable, line.combo._list)
                line.combo.UpdateValue = function(key)
                    line.combo:SetItem(line.combo.keyMap[key])
                end
            end
        end
        for i, v in OptionDisplay do
            if Options[i + self.top] then
                SetTextLine(v, Options[i + self.top], i + self.top)
            else
                v.text:SetText('')
                v.combo:Hide()
                v.bg:SetSolidColor('00000000')
            end
        end
    end
    
    OptionContainer:CalcVisible()
    
    OptionContainer.HandleEvent = function(self, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            self:ScrollLines(nil, lines)
        end
    end
    
    UIUtil.CreateVertScrollbarFor(OptionContainer)
end

function SetDescription(scen)

    local errors = false
	
    description:DeleteAllItems()
	
    if scen.name then
        description:AddItem(scen.name) 
    else
        description:AddItem(LOC("<LOC map_select_0006>No Scenario Name"))
        errors = true
    end
	
    if scen.map_version then	
		local la = string.lower(__language)
		--local verStr = LOC("<LOC MAINMENU_0009>") .. scen.map_version
		local verStr = EnhancedLobby.VersionLoc(la) .. scen.map_version

        description:AddItem(verStr)
    end
	
    if scen.size then
        description:AddItem(LOCF("<LOC map_select_0000>Map Size: %dkm x %dkm", scen.size[1]/50, scen.size[2]/50))
    else
        description:AddItem(LOCF("<LOC map_select_0004>NO MAP SIZE INFORMATION"))
        errors = true
    end
	
    if scen.Configurations.standard.teams[1].armies then
        local maxplayers = table.getsize(scen.Configurations.standard.teams[1].armies)
        description:AddItem(LOCF("<LOC map_select_0001>Max Players: %d", maxplayers))
    else
        description:AddItem(LOCF("<LOC map_select_0005>NO START SPOTS DEFINED"))
        errors = true
    end
	
	if EnhancedLobby.CheckMapHasMarkers(scen) then
		description:AddItem("AI Markers: Yes")
	else
		description:AddItem("AI Markers: No")
	end
	
	if scen.norushradius then
		description:AddItem("No Rush Radius: " .. scen.norushradius)
	else
		description:AddItem("No Rush Radius: Not Set")
	end 
	
    description:AddItem("")
	
    if scen.description then
        local textBoxWidth = description.Width()
        local wrapped = import('/lua/maui/text.lua').WrapText(LOC(scen.description), textBoxWidth, 
            function(curText) return description:GetStringAdvance(curText) end)
        for i, line in wrapped do
            description:AddItem(line)
        end 
    else
        description:AddItem(LOC("<LOC map_select_0007>No Scenario Description"))
        errors = true
    end
	
    if errors then
        selectButton:Disable()
    else
        selectButton:Enable()
    end
end

function PopulateMapList()
    mapList:DeleteAllItems()
    local count = 1 -- Corresponds to row in mapList
    
    for j, folder in folders do
        local filtered = {}
        local size = table.getsize(folder[3])
        -- Predetermine which maps in the folder get filtered out
        for s, sceninfo in folder[3] do
            if currentFilters.map_select_supportedplayers ~= 0 and not CompareFunc(table.getsize(sceninfo.Configurations.standard.teams[1].armies), 
            currentFilters.map_select_supportedplayers, currentFilters.map_select_supportedplayers_limiter) and
            not filtered[s] then
                table.insert(filtered, s, true)
            end
            
            if currentFilters.map_select_size ~= 0 and not CompareFunc(sceninfo.size[1],
            currentFilters.map_select_size, currentFilters.map_select_size_limiter) and 
            not filtered[s] then
                table.insert(filtered, s, true)
            end
            
            if (currentFilters.map_ai_markers == true or currentFilters.map_ai_markers == false) and
            not EnhancedLobby.CheckMapHasMarkers(sceninfo) == currentFilters.map_ai_markers and
            not filtered[s] then
                table.insert(filtered, s, true)
            end
        end
        -- Add a folder, but only if it hasn't been entirely filtered out
        if table.getsize(filtered) == size then
            continue
        elseif size > 1 then
            -- Map this ItemList row to a folder, but not a scenario
            folderMap[count] = { j, nil }
            mapList:AddItem("*** FOLDER: "..folder[1])
            count = count + 1
        end
        if size == 1 or folder[2] then
            for i, sceninfo in folder[3] do
                -- Don't add filtered maps
                if filtered[i] then
                    continue
                end
                
                local name = sceninfo.name
                -- if sceninfo.map_version then
                    -- MAINMENU_0009 is "Version :"
                --     local la = string.lower(__language)
                --     name = name .. " (" .. EnhancedLobby.VersionLoc(la) .. sceninfo.map_version .. ")"
                -- end
                if folder[2] then
                    mapList:AddItem(" |-> "..LOC(name))
                else
                    mapList:AddItem(LOC(name))
                end
                -- Map this ItemList row to a folder and a scenario within
                folderMap[count] = { j, i }
                count = count + 1
            end
        end
    end
end

function CompareFunc(valA, valB, operatorVar)
    if operatorVar == 'equal' then
        if valA == valB then
            return true
        else
            return false
        end
    elseif operatorVar == 'less' then
        if valA <= valB then
            return true
        else
            return false
        end
    elseif operatorVar == 'greater' then
        if valA >= valB then
            return true
        else
            return false
        end
    end
end
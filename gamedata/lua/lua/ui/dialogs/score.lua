--*****************************************************************************
--* File: lua/modules/ui/dialogs/score.lua
--* Author: Chris Blackwell
--* Summary: Post game score dialog
--*
--* Copyright � :005 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local EffectHelpers = import('/lua/maui/effecthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button
--local Text = import('/lua/maui/text.lua').Text
local Movie = import('/lua/maui/movie.lua').Movie
local WrapText = import('/lua/maui/text.lua').WrapText
local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local Tooltip = import('/lua/ui/game/tooltip.lua')
local ItemList = import('/lua/maui/itemlist.lua').ItemList
local CampaignManager = false   -- import('/lua/ui/campaign/campaignmanager.lua')
local Prefs = import('/lua/user/prefs.lua')

dialog = false
local currentPage = false
local curGrid = false
local curInfo = false
local elapsedTime = false
local curType = false
local curSortCol = false
local curSortDescending = true
local savedGameTime = false
local curScore = false

local campaignScore = ''

scoreScreenActive = false

-- '<LOC SCORE_0058>Debrief'
-- '<LOC SCORE_0059>Combat Report'

local tabs = {

    {
        title = "<LOC SCORE_0000>General",
        button = "general",
        scoreKey = 'general',
        columns = {
          {title = "<LOC SCORE_0001>Score", scoreKey = 'score',},
          {title = "<LOC SCORE_0002>Kills", scoreKey = 'kills',},
          {title = "<LOC SCORE_0003>Built", scoreKey = 'built',},
          {title = "<LOC SCORE_0004>Losses", scoreKey = 'lost',},
          {title = "<LOC SCORE_0005>Mass", scoreKey = 'mass',},
          {title = "<LOC SCORE_0006>Energy", scoreKey = 'energy',},  
        },
        types = {
            {title = "<LOC SCORE_0007>Count", scoreKey = 'count',},
            {title = "<LOC SCORE_0008>Mass Value", scoreKey = 'mass',},
            {title = "<LOC SCORE_0009>Energy Value", scoreKey = 'energy',},
        },
        grid = true,
    },
    {
        title = "<LOC SCORE_0010>Units",
        button = "units",
        scoreKey = 'units',
        columns = {
            {title = "<LOC SCORE_0011>CDR", scoreKey = 'cdr',},
            {title = "<LOC SCORE_0012>Land", scoreKey = 'land',},
            {title = "<LOC SCORE_0013>Naval", scoreKey = 'naval',},
            {title = "<LOC SCORE_0014>Air", scoreKey = 'air',},
            {title = "<LOC SCORE_0015>Structures", scoreKey = 'structures',},
            {title = "<LOC SCORE_0016>Experimental", scoreKey = 'experimental',},
        },
        types = {
            {title = "<LOC SCORE_0017>Kills", scoreKey = 'kills',},
            {title = "<LOC SCORE_0003>Built", scoreKey = 'built',},
            {title = "<LOC SCORE_0019>Losses", scoreKey = 'lost',},                       
        },
        grid = true,
    },
    {
        title = "<LOC SCORE_0020>Resources",
        button = "resources",
        scoreKey = 'resources',
        columns = {
            {title = "<LOC SCORE_0021>Mass Collected", scoreKey = 'massin',},
            {title = "<LOC SCORE_0022>Mass Spent", scoreKey = 'massout',},
            {title = "<LOC SCORE_0023>Mass Wasted", scoreKey = 'massover',},
            {title = "<LOC SCORE_0024>Energy Collected", scoreKey = 'energyin',},
            {title = "<LOC SCORE_0025>Energy Spent", scoreKey = 'energyout',},
            {title = "<LOC SCORE_0026>Energy Wasted", scoreKey = 'energyover',},
        },
        types = {
            {title = "<LOC SCORE_0027>Total", scoreKey = 'total',},
            {title = "<LOC SCORE_0028>Rate", scoreKey = 'rate',},
        },
        grid = true,
    },
}

-- determine which data to show based on current page, data type and column
local function UpdateDisplay()
    -- show elapsed time
    elapsedTime:SetText(GetGameTime())

    if not curInfo or not curInfo.scoreData then
        return
	end

    -- set the current score page key
    local curScoreKey = currentPage.tabData.scoreKey
    
    -- set up a small table to sort by the current sort value
    local sortOrder = {}
    for index, info in ipairs(curInfo) do
        sortOrder[index] = {}
        sortOrder[index].infoIndex = index
        sortOrder[index].sortKey = curInfo.scoreData.current[index][curScoreKey][curSortCol][curType] or curInfo.scoreData.current[index][curScoreKey][curSortCol]
    end

    table.sort(sortOrder, function(first, second)
        if curSortDescending then
            return (first.sortKey > second.sortKey)
        else
            return (first.sortKey < second.sortKey)
        end
    end)
    
    if curGrid then
        for index, gridRow in ipairs(curGrid) do
            local curPlayerIndex = sortOrder[index].infoIndex
            local info = curInfo[curPlayerIndex]
            gridRow.color:SetSolidColor(info.color)
            gridRow.factionIcon:SetTexture(UIUtil.SkinnableFile(UIUtil.GetFactionIcon(info.faction)))
            gridRow.playerName:SetText(info.name)
            --gridRow.teamName:SetText(info.teamName)
            
            for curCol, colData in currentPage.tabData.columns do
                -- check if data sub-type otherwise use parent value
                curGrid[index].cols[curCol]:SetText(tostring(math.floor(
                    curInfo.scoreData.current[curPlayerIndex][curScoreKey][colData.scoreKey][curType] or 
                    curInfo.scoreData.current[curPlayerIndex][curScoreKey][colData.scoreKey])))
            end
        end
    end
end

local function SortByColumn(colKey)
    if curSortCol == colKey then
        curSortDescending = not curSortDescending
    else
        curSortCol = colKey
        curSortDescending = true
    end

    UpdateDisplay()
end

local function SetDataType(dataType)
    curType = dataType

    -- TODO coordinate buttons?
    UpdateDisplay()
end

function UpdateData()
    
    -- clear curInfo
    curInfo = {scoreData = { } }
    
    -- first get army info and place it in the 
    local armiesTable = GetArmiesTable().armiesTable

    local index = 1
    -- popluate data in to cur info
    for i, armyInfo in armiesTable do 
        if not armyInfo.civilian and armyInfo.showScore then
            -- set basic info from armies table
            curInfo[index] = {}
            curInfo[index].name = armyInfo.nickname
            curInfo[index].faction = armyInfo.faction
            curInfo[index].color = armyInfo.color
            --curInfo[index].teamName = index --TODO we need to get team data in here
            index = index + 1
        end
    end

    -- set score data
	--LOG("*AI DEBUG "..repr(scoreData))
    curInfo.scoreData.current = table.copy(scoreData.last)	--import('/lua/ui/game/scoreaccum.lua').scoreData
end

function CreateDialog(victory, showCampaign, operationVictoryTable, midGame)

    if midGame then
        ExitGame()
        return
    end
	
    scoreScreenActive = true

    SessionEndGame()
    DisableWorldSounds()
    StopAllSounds()
    UpdateData()

    CreateSkirmishScreen(victory, showCampaign, operationVictoryTable)
    
    if not SessionIsReplay() then
    
        -- all of this from GAZ UI --
        local Prefs = import('/lua/user/prefs.lua')
        local profile = Prefs.GetFromCurrentProfile('Name') or 'Player'
        local filename = 'Autosave' .. profile .. math.random(9999)
        local si
        local til = {}

        local sep1 = "."
        local sep2 = "-"
        
        til = GetSpecialFileInfo(profile, LOC("<LOC Engine0030>") , 'Replay').WriteTime
        
        si = string.gsub(SessionGetScenarioInfo().name, "'" , "")
        
        if string.len(si) > 18 then
            filename = string.sub(si, 1,18 )
        else
            filename = si
        end
        
        for k,v in til do
            if string.len(til[k]) == 1 then
                til[k] = "0" .. til[k]
            end
        end
        
        til.year = string.sub(til.year ,3,4)

        CopyCurrentReplay(profile, til.year .. til.month .. til.mday .. sep2 .. til.hour .. til.minute .. " " .. filename)

    end
    
end

function CreateSkirmishScreen(victory, showCampaign, operationVictoryTable)

    if dialog then return end

    GetCursor():Show()
    
    local factions = import('/lua/factions.lua').Factions
    
    UIUtil.SetCurrentSkin(factions[1].DefaultSkin)
    
    -- create the dialog
    dialog = Bitmap(GetFrame(0))
    dialog:SetRenderPass(UIUtil.UIRP_PostGlow)  -- just in case our parent is the map
    dialog.Depth:Set(GetFrame(0):GetTopmostDepth()+1)
    dialog:SetNeedsFrameUpdate(true)
    dialog:SetSolidColor('FF000000')
    dialog.OnFrame = function(self, delta)
        self:SetNeedsFrameUpdate(false)
    end
    
    movieBG = Movie(dialog, '/movies/menu_background.sfd')
    
    local bg = Bitmap(movieBG, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel_bmp.dds'))
    LayoutHelpers.AtCenterIn(bg, GetFrame(0))
    
    bg.brackets = UIUtil.CreateDialogBrackets(bg, 40, 30, 40, 30)
    
    LayoutHelpers.FillParent(dialog, GetFrame(0))

    movieBG.Height:Set(GetFrame(0).Height)
    
    movieBG.Width:Set(function()
        local ratio = GetFrame(0).Height() / 1024
        return 1824 * ratio
    end)
    
    movieBG.OnLoaded = function(self)
        self:Loop(true)
        self:Play()
    end
    
    LayoutHelpers.AtCenterIn(movieBG, GetFrame(0))
    
    movieBG:DisableHitTest()
    
    bg.title = UIUtil.CreateText(bg, "", 20, UIUtil.titleFont)
    LayoutHelpers.AtHorizontalCenterIn(bg.title, bg)
    LayoutHelpers.AtTopIn(bg.title, bg, 28)

    -- set controls that are global to the dialog
    bg.continueBtn = UIUtil.CreateButtonStd(bg, '/scx_menu/large-no-bracket-btn/large', "<LOC _Continue>", 22, 2, 0, "UI_Menu_MouseDown", "UI_Opt_Affirm_Over")
	LayoutHelpers.AtRightIn(bg.continueBtn, bg, -10)
	LayoutHelpers.AtBottomIn(bg.continueBtn, bg, 20)
	bg.continueBtn:UseAlphaHitTest(false)
	
	bg.continueBtn.glow = Bitmap(bg.continueBtn, UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_glow.dds'))
	LayoutHelpers.AtCenterIn(bg.continueBtn.glow, bg.continueBtn)
	bg.continueBtn.glow:SetAlpha(0)
	bg.continueBtn.glow:DisableHitTest()
	
    bg.continueBtn.pulse = Bitmap(bg.continueBtn, UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_glow.dds'))
	LayoutHelpers.AtCenterIn(bg.continueBtn.pulse, bg.continueBtn)
	bg.continueBtn.pulse:DisableHitTest()
	bg.continueBtn.pulse:SetAlpha(.5)
	
    EffectHelpers.Pulse(bg.continueBtn.pulse, 2, .5, 1)
    
    bg.continueBtn.OnRolloverEvent = function(self, event) 
	   	if event == 'enter' then
			EffectHelpers.FadeIn(self.glow, .25, 0, 1)
			self.label:SetColor('black')
		elseif event == 'down' then
			self.label:SetColor('black')
		else
			EffectHelpers.FadeOut(self.glow, .25, 1, 0)
			self.label:SetColor('FFbadbdb')
		end
	end
    
    bg.continueBtn.OnClick = function(self, modifiers)

        ConExecute("ren_Oblivion false")

        ExitGame()

    end
    
    Tooltip.AddButtonTooltip(bg.continueBtn, 'PostScore_Quit')

    UIUtil.MakeInputModal(dialog, function() bg.continueBtn:OnClick() end, function() bg.continueBtn:OnClick() end)
    
    local elapsedTimeLabel = UIUtil.CreateText(bg, "<LOC SCORE_0029>Game Time:", 16, UIUtil.bodyFont)
    LayoutHelpers.AtLeftTopIn(elapsedTimeLabel, bg, 760, 75)
    
    elapsedTime = UIUtil.CreateText(bg, "", 16, UIUtil.bodyFont)
    LayoutHelpers.RightOf(elapsedTime, elapsedTimeLabel, 5)
  
    bg.replayButton = UIUtil.CreateButtonStd(bg, '/scx_menu/medium-no-br-btn/medium-uef', "<LOC uireplay_0003>", 14, 2)
    LayoutHelpers.AtLeftIn(bg.replayButton, bg, 5)
    LayoutHelpers.AtBottomIn(bg.replayButton, bg, 20)
    bg.replayButton.OnClick = function(self, modifiers)
        import('/lua/ui/dialogs/replay.lua').CreateDialog(bg, false, nil)
    end
    
    Tooltip.AddButtonTooltip(bg.replayButton, "PostScore_Replay")

    if import('/lua/ui/game/gamemain.lua').IsSavedGame == true then
        bg.replayButton:Disable()
    end

    if SessionIsReplay() then
        bg.replayButton:Disable()
    end
    
    -- when a new page is selected, create the page and deal with the tab correctly
    function SetNewPage(tabControl)
        -- kill any other page
        if currentPage then
            currentPage.tabBitmap:Destroy()
            currentPage.tabButton:Show()
            currentPage:Destroy()
        end

        -- store the tab data for this tab for easy access
        local tabData = tabControl.tabData
        
        -- page is a big as group to make placement easy, and destruction of the page easy
        currentPage = Group(bg, "currentScorePageGroup")
        currentPage.tabData = tabData
        LayoutHelpers.FillParent(currentPage, bg)

        -- show the "selected" state of the tab, which hides the button and shows a bitmap
        currentPage.tabButton = tabControl
        currentPage.tabButton:Hide()
        currentPage.tabBitmap = Bitmap(bg, UIUtil.UIFile('/scx_menu/tab_btn/tab_btn_selected.dds'))
        currentPage.tabBitmap.Depth:Set(function() return bg.Depth() + 100 end)
        LayoutHelpers.AtCenterIn(currentPage.tabBitmap, currentPage.tabButton)
        local tabLabel = UIUtil.CreateText(currentPage.tabBitmap, tabData.title, 16, UIUtil.titleFont)
        LayoutHelpers.AtCenterIn(tabLabel, currentPage.tabBitmap)
        
        if bg.voHandle then
            StopSound(bg.voHandle)
        end
        
        -- if there's a grid to be shown, set it up
        -- Note: currently, only campaign score page won't have a grid
        if tabData.grid then

            -- create the grid group/bg
            local gridGroup = Group(currentPage, "scoreGridGroup")

            -- no layout info for these sub pages, so position manually
            LayoutHelpers.AtLeftTopIn(gridGroup, currentPage, 43, 102)
            LayoutHelpers.SetDimensions(gridGroup, 743, 257)

            local gridBG = Bitmap(gridGroup, UIUtil.SkinnableFile('/scx_menu/score-victory-defeat/totals-back_bmp.dds'))
            LayoutHelpers.AtLeftTopIn(gridBG, bg, 34, 114)
            
            -- set up labels (no layout info yet, so store x values in a table)
            -- note the numbers are colmun num, for easy access
            local labelXPos = {
                icon = 6,
                player = 38,
                team = 259,
                [1] = 312,
                [2] = 416,
                [3] = 520,
                [4] = 624,
                [5] = 728,
                [6] = 832,
            }
            
            local playerText = MultiLineText(gridBG, UIUtil.bodyFont, 16, UIUtil.fontColor)
			LayoutHelpers.SetDimensions(playerText, 250, 35)
            LayoutHelpers.AtLeftTopIn(playerText, gridBG, labelXPos.icon + 5, 12)   -- note this is at icon as there is none in the label
            playerText:SetText(LOC("<LOC _Player>"))
            
--            local teamText = MultiLineText(gridBG, UIUtil.titleFont, 16, UIUtil.fontColor)
--            teamText.Width:Set(80)
--            teamText.Height:Set(35)
--            LayoutHelpers.AtLeftTopIn(teamText, gridBG, labelXPos.team, 12)
--            teamText:SetText(LOC("<LOC _Team>"))

            local sortButtons = {}
            for index, colName in tabData.columns do
                local Index = index
                sortButtons[index] = {}
                sortButtons[index].checkbox = Checkbox(gridBG
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-d_btn_up.dds')
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-s_btn_up.dds')
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-d_btn_over.dds')
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-s_btn_over.dds')
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-d_btn_dis.dds')
                    , UIUtil.SkinnableFile('/scx_menu/toggle-lg_btn/toggle-s_btn_dis.dds')
                    , "UI_Tab_Click_02", "UI_Tab_Rollover_02")
                LayoutHelpers.AtLeftTopIn(sortButtons[index].checkbox, gridBG, labelXPos[index] - 30, -4)
                sortButtons[index].checkbox.toolTip = colName.scoreKey
                
                sortButtons[index].label = {}
                sortButtons[index].label[1] = UIUtil.CreateText(sortButtons[index].checkbox, '', 11, UIUtil.bodyFont)
                sortButtons[index].label[1]:DisableHitTest()
                
                local wrappedText = import('/lua/maui/text.lua').WrapText(LOC(colName.title), 
                    80,
                    function(text)
                        return sortButtons[Index].label[1]:GetStringAdvance(text)
                    end)
                    
                if table.getn(wrappedText) > 1 then
                    sortButtons[index].label[1]:SetText(wrappedText[1])
                    LayoutHelpers.AtTopIn(sortButtons[index].label[1], sortButtons[index].checkbox, 12)
                    LayoutHelpers.AtHorizontalCenterIn(sortButtons[index].label[1], sortButtons[index].checkbox)
                    for i = 2, table.getn(wrappedText) do
                        local lineIndex = i
                        sortButtons[index].label[lineIndex] = UIUtil.CreateText(sortButtons[index].checkbox, wrappedText[lineIndex], 11, UIUtil.bodyFont)
                        sortButtons[index].label[lineIndex]:DisableHitTest()
                        LayoutHelpers.Below(sortButtons[index].label[lineIndex], sortButtons[index].label[lineIndex-1], -2)
                        LayoutHelpers.AtHorizontalCenterIn(sortButtons[index].label[lineIndex], sortButtons[index].checkbox)
                    end
                else
                    sortButtons[index].label[1]:SetText(wrappedText[1])
                    LayoutHelpers.AtCenterIn(sortButtons[index].label[1], sortButtons[index].checkbox)
                end

                sortButtons[index].checkbox._sortCol = colName.scoreKey
            end
            
            local sortGroup = RadioGroup(sortButtons)
            sortGroup.OnClick = function(self, index, item)
                SortByColumn(item.checkbox._sortCol)
                return true
            end
            sortGroup:SetCheckboxEventHandler(function(self, event) 
                if event.Type == 'MouseEnter' then
                    Tooltip.CreateMouseoverDisplay(self, "PostScore_"..self.toolTip, nil, true)
                elseif event.Type == 'MouseExit' then
                    Tooltip.DestroyMouseoverDisplay()
                end
                return true
            end)
            
            --default sort col
            -- TODO should this be set elsewhere?
            curSortCol = tabData.columns[1].scoreKey
            
            -- clear out existing grid so we can have fresh data
            curGrid = {}
            
            -- set up a row for each player (well each army at least)
            -- layouts may have to change based on team?
            local armiesInfo = GetArmiesTable()
            
            local prev = false
            local index = 1
            for i, armyInfo in armiesInfo.armiesTable do
                if not armyInfo.civilian and armyInfo.showScore then
                    local armyBg = Bitmap(gridGroup, UIUtil.SkinnableFile('/scx_menu/score-victory-defeat/player-back_bmp.dds'))
                    if prev then
                        LayoutHelpers.Below(armyBg, prev, -10)
                    else
                        LayoutHelpers.AtLeftTopIn(armyBg, gridGroup, -10, 50)
                    end
                    prev = armyBg
                    
                    curGrid[index] = {}
                    
                    curGrid[index].color = Bitmap(armyBg)
					LayoutHelpers.SetDimensions(curGrid[index].color, 21, 20)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].color, armyBg, labelXPos.icon, 6)
    
                    curGrid[index].factionIcon = Bitmap(curGrid[index].color)
                    LayoutHelpers.FillParent(curGrid[index].factionIcon, curGrid[index].color)
    
                    local INDEX = index
                    curGrid[index].playerName = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].playerName, armyBg, labelXPos.player, 6)
					LayoutHelpers.AnchorToLeft(curGrid[index].playerName, curGrid[INDEX].playerName, -220)
                    curGrid[index].playerName:SetClipToWidth(true)
                    
                    --curGrid[index].teamName = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                    --LayoutHelpers.AtLeftTopIn(curGrid[index].teamName, armyBg, labelXPos.team, 6)
                    
                    curGrid[index].cols = {}
                    for col = 1, 6 do
                        curGrid[index].cols[col] = UIUtil.CreateText(armyBg, "", 14, UIUtil.bodyFont)
                        LayoutHelpers.AtVerticalCenterIn(curGrid[index].cols[col], armyBg)
                        LayoutHelpers.AtHorizontalCenterIn(curGrid[index].cols[col], sortButtons[col].checkbox)
                    end
                    index = index + 1
                end
            end

            -- set up data type buttons
            local typeButtons = {}
            local prevButton = false
            local typeGroup = Group(gridGroup)
            local width = 0
            for index, dataType in tabData.types do
                local i = index
                typeButtons[index] = {}
                typeButtons[index].checkbox = Checkbox(typeGroup
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_up.dds')
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_over.dds')
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_down.dds')
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_down.dds')
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_dis.dds')
                    , UIUtil.SkinnableFile('/scx_menu/small-btn/small_btn_dis.dds')
                    , "UI_Tab_Click_02", "UI_Tab_Rollover_02")
                
                if prevButton then
                    LayoutHelpers.RightOf(typeButtons[index].checkbox, prevButton)
                else
                    LayoutHelpers.AtLeftTopIn(typeButtons[index].checkbox, typeGroup)
                end
                prevButton = typeButtons[index].checkbox
                width = typeButtons[index].checkbox.Width() + width
                typeButtons[index].checkbox.toolTip = dataType.scoreKey
    
                typeButtons[index].label = {}
                typeButtons[index].label[1] = UIUtil.CreateText(sortButtons[index].checkbox, LOC(dataType.title), 14, UIUtil.bodyFont)
                typeButtons[index].label[1]:DisableHitTest()
                LayoutHelpers.AtCenterIn(typeButtons[index].label[1], typeButtons[index].checkbox, 2)
                
                typeButtons[index].checkbox.OnCheck = function(self, checked)
                    if checked then
                        typeButtons[i].label[1]:SetColor('ff000000')
                    else
                        typeButtons[i].label[1]:SetColor(UIUtil.fontColor)
                    end
                    Checkbox.OnCheck(self, checked)
                end
                
                typeButtons[index].checkbox._dataType = dataType.scoreKey
            end
            typeGroup.Width:Set(width)
			LayoutHelpers.SetHeight(typeGroup, 1)
            LayoutHelpers.AtTopIn(typeGroup, gridGroup, 316)
            LayoutHelpers.AtHorizontalCenterIn(typeGroup, bg)
            
            local typesGroup = RadioGroup(typeButtons)
            typesGroup.OnClick = function(self, index, item)
                SetDataType(item.checkbox._dataType)
                return true
            end
            typesGroup:SetCheckboxEventHandler(function(self, event) 
                if event.Type == 'MouseEnter' then
                    Tooltip.CreateMouseoverDisplay(self, "PostScore_"..self.toolTip, nil, true)
                elseif event.Type == 'MouseExit' then
                    Tooltip.DestroyMouseoverDisplay()
                end
            end)

            -- TODO default type? also when these become checkboxes, need to depress type
            -- maybe call SetDataType, but have an updateDisplay function so we don't call UpdateDisplay while creating
            curType = tabData.types[1].scoreKey

        end

        local victoryString
        if operationVictoryTable then
            if operationVictoryTable.success then
                victoryString = "<LOC SCORE_0055>Operation Successful"
            else
                victoryString = "<LOC SCORE_0056>Operation Failed"
            end
        else
            if victory != nil then
                if victory then
                    victoryString = "<LOC SCORE_0046>Victory"
                else
                    victoryString = "<LOC SCORE_0047>Defeat"
                end
            else
                victoryString = "<LOC _Score>"
            end

        end

        -- sets the score dialog box title to the appropriate string
        bg.title:SetText(LOC(victoryString))

        UpdateDisplay()
    end

    -- set up top level tabs
    local prev = false
    local defaultTab = false

    for index, value in tabs do
        
        local curButton = UIUtil.CreateButtonStd(bg, '/scx_menu/tab_btn/tab', value.title, 16, nil, nil, "UI_Tab_Click_02", "UI_Tab_Rollover_02")

        if prev then
            --curButton.Left:Set(function() return prev.Right() + 0 end)
            --curButton.Bottom:Set(function() return prev.Bottom() end)
            LayoutHelpers.RightOf(curButton, prev, -5)
        else
            --LayoutHelpers.RelativeTo(curButton, bg, 
            --    UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 
            --    'l_general_btn', 'panel_bmp', -10)
			LayoutHelpers.AtLeftTopIn(curButton, bg, 17, 57)
            defaultTab = curButton
        end
        prev = curButton

        curButton.OnClick = function(self, modifiers)
            SetNewPage(self)
        end
        local tempKey = value.scoreKey
        curButton.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                Tooltip.CreateMouseoverDisplay(self, "PostScore_" .. tempKey, nil, true)
            elseif event.Type == 'MouseExit' then
                Tooltip.DestroyMouseoverDisplay()
            end
            Button.HandleEvent(self, event)
        end
        
        curButton.tabData = value
    end
    SetNewPage(defaultTab)
end

function CreateBorderGroup(parent)
    local group = Group(parent)
    
    group.tl = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ul.dds'))
    group.tm = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_um.dds'))
    group.tr = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ur.dds'))
    group.l = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_vert_l.dds'))
    group.r = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_vert_r.dds'))
    group.bl = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_ll.dds'))
    group.bm = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_lm.dds'))
    group.br = Bitmap(group, UIUtil.UIFile('/scx_menu/score-victory-defeat/panel-campaign_brd_lr.dds'))
    
    group.tl.Bottom:Set(group.Top)
    group.tl.Right:Set(group.Left)
    
    group.tr.Bottom:Set(group.Top)
    group.tr.Left:Set(group.Right)
    
    group.tm.Bottom:Set(group.Top)
    group.tm.Left:Set(group.Left)
    group.tm.Right:Set(group.Right)
    
    group.bl.Top:Set(group.Bottom)
    group.bl.Right:Set(group.Left)
    
    group.br.Top:Set(group.Bottom)
    group.br.Left:Set(group.Right)
    
    group.bm.Top:Set(group.Bottom)
    group.bm.Left:Set(group.Left)
    group.bm.Right:Set(group.Right)
    
    group.l.Top:Set(group.Top)
    group.l.Bottom:Set(group.Bottom)
    group.l.Right:Set(group.Left)
    
    group.r.Top:Set(group.Top)
    group.r.Bottom:Set(group.Bottom)
    group.r.Left:Set(group.Right)
    
    return group
end

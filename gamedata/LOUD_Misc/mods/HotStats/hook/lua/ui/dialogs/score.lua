local pathMod = '/mods/hotstats/'
local hotstats = import(pathMod .. 'score.lua')

--[[table.insert(tabs, 
    {
        title = "Hotstats",
        button = "hotstats",
        scoreKey = 'hotstats',
        text = {
            "blabla",
        }
    })
	--]]

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
    
    local ambientSounds = PlaySound(Sound({Cue = "AMB_SER_OP_Briefing", Bank = "AmbientTest",}))
    dialog.OnDestroy = function(self)
        StopSound(ambientSounds)
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
	    hotstats.clean_view()
        ConExecute("ren_Oblivion false")
        if showCampaign then
            operationVictoryTable.allPrimary = true
            operationVictoryTable.allSecondary = true
            CampaignManager.OperationVictory(operationVictoryTable, true)
        end
        # Checking gpgnet too in case we switch to that
        if HasCommandLineArg("/online") or HasCommandLineArg("/gpgnet") then
            ExitApplication()
        else
            ExitGame()
        end
    end
    Tooltip.AddButtonTooltip(bg.continueBtn, 'PostScore_Quit')
    
    if showCampaign and not operationVictoryTable.success then
        bg.continueBtn.label:SetText(LOC('<LOC _Skip>Skip'))
        bg.continueBtn.HandleEvent = bg.continueBtn.oldHandleEvent
        Tooltip.AddButtonTooltip(bg.continueBtn, 'CampaignScore_Skip')
        -- set controls that are global to the dialog
        bg.restartBtn = UIUtil.CreateButtonStd(bg, '/scx_menu/large-no-bracket-btn/large', "<LOC _Restart>Restart", 22, 2, 0, "UI_Menu_MouseDown", "UI_Opt_Affirm_Over")
    	LayoutHelpers.LeftOf(bg.restartBtn, bg.continueBtn, -40)
    	bg.continueBtn:UseAlphaHitTest(false)
    	
    	bg.restartBtn.glow = Bitmap(bg.restartBtn, UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_glow.dds'))
    	LayoutHelpers.AtCenterIn(bg.restartBtn.glow, bg.restartBtn)
    	bg.restartBtn.glow:SetAlpha(0)
    	bg.restartBtn.glow:DisableHitTest()
    	
        bg.restartBtn.pulse = Bitmap(bg.restartBtn, UIUtil.UIFile('/scx_menu/large-no-bracket-btn/large_btn_glow.dds'))
    	LayoutHelpers.AtCenterIn(bg.restartBtn.pulse, bg.restartBtn)
    	bg.restartBtn.pulse:DisableHitTest()
    	bg.restartBtn.pulse:SetAlpha(.5)
    	
        EffectHelpers.Pulse(bg.restartBtn.pulse, 2, .5, 1)
        
        bg.restartBtn.OnRolloverEvent = function(self, event) 
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
        
        bg.restartBtn.OnClick = function(self, modifiers)
            ConExecute("ren_Oblivion false")
            RestartSession()
        end
        Tooltip.AddButtonTooltip(bg.restartBtn, 'CampaignScore_Restart')
    end

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
    if showCampaign then
        bg.replayButton:Disable()   -- no replays available in campaigns
    end
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
            gridGroup.Width:Set(743)
            gridGroup.Height:Set(257)

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
            playerText.Width:Set(250)
            playerText.Height:Set(35)
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
                        LayoutHelpers.Below(armyBg, prev, -5)
                    else
                        LayoutHelpers.AtLeftTopIn(armyBg, gridGroup, -10, 50)
                    end
                    prev = armyBg
                    
                    curGrid[index] = {}
                    
                    curGrid[index].color = Bitmap(armyBg)
                    curGrid[index].color.Width:Set(21)
                    curGrid[index].color.Height:Set(20)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].color, armyBg, labelXPos.icon, 6)
    
                    curGrid[index].factionIcon = Bitmap(curGrid[index].color)
                    LayoutHelpers.FillParent(curGrid[index].factionIcon, curGrid[index].color)
    
                    local INDEX = index
                    curGrid[index].playerName = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].playerName, armyBg, labelXPos.player, 6)
                    curGrid[index].playerName.Right:Set(function() return curGrid[INDEX].playerName.Left() + 220 end)
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
            typeGroup.Height:Set(1)
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
        elseif tabData.button == "campaign" then
            -- Set up campaign display
            local opData = import('/maps/'..operationVictoryTable.opKey..'/'..operationVictoryTable.opKey..'_operation.lua').operationData
            
            local prefix = {Cybran = {texture = '/icons/comm_cybran.dds', cue = 'UI_Comm_CYB'},
                Aeon = {texture = '/icons/comm_aeon.dds', cue = 'UI_Comm_AEON'},
                UEF = {texture = '/icons/comm_uef.dds', cue = 'UI_Comm_UEF'},
                Seraphim = {texture = '/icons/comm_seraphim.dds', cue = 'UI_Comm_SER'},
                NONE = {texture = '/icons/comm_allied.dds', cue = 'UI_Comm_UEF'}}
                
            local successKey = 'failure'
            if operationVictoryTable.success then
                successKey = 'success'
            end
            
            local movieGroup = CreateBorderGroup(currentPage)
            LayoutHelpers.AtLeftTopIn(movieGroup, currentPage, 40, 120)
            movieGroup.Height:Set(290)
            movieGroup.Width:Set(330)
            
            local debriefData = opData.opDebriefingFailure[1]
            if operationVictoryTable.success then
                debriefData = opData.opDebriefingSuccess[1]
            end
            
            local opDebriefMovie = Movie(movieGroup)
            LayoutHelpers.AtTopIn(opDebriefMovie, movieGroup, 2)
            LayoutHelpers.AtHorizontalCenterIn(opDebriefMovie, movieGroup)
            opDebriefMovie.Height:Set(192)
            opDebriefMovie.Width:Set(192)
            opDebriefMovie:Set('/movies/'..debriefData.vid)
            
            local opDebriefBitmap = Bitmap(opDebriefMovie, UIUtil.UIFile(prefix[debriefData.faction].texture))
            LayoutHelpers.FillParent(opDebriefBitmap, opDebriefMovie)
            opDebriefBitmap.time = 0
            opDebriefBitmap.first = true
            opDebriefBitmap.OnFrame = function(self, delta)
                self.time = self.time + delta
                if self.first then
                    PlaySound(Sound({Bank='Interface', Cue=prefix[debriefData.faction].cue..'_In'}))
                    self.first = false
                end
                if self.time > 1 then
                    self:Hide()
                    self:SetNeedsFrameUpdate(false)
                    opDebriefMovie:Play()
                    bg.voHandle = PlayVoice(Sound({Cue = debriefData.cue, Bank = debriefData.bank}))
                end
            end
            
            opDebriefMovie.OnLoaded = function(self)
                opDebriefBitmap:SetNeedsFrameUpdate(true)
            end
            
            opDebriefMovie.OnFinished = function()
                opDebriefBitmap:Show()
                PlaySound(Sound({Bank='Interface', Cue=prefix[debriefData.faction].cue..'_Out'}))
            end
            
            local movieBorder = Bitmap(opDebriefMovie, UIUtil.UIFile('/scx_menu/score-victory-defeat/video-frame_bmp.dds'))
            LayoutHelpers.AtCenterIn(movieBorder, opDebriefMovie)
            
            local debriefText = UIUtil.CreateTextBox(movieGroup)
            LayoutHelpers.AtBottomIn(debriefText, movieGroup)
            LayoutHelpers.AtHorizontalCenterIn(debriefText, movieGroup, -15)
            debriefText.Width:Set(function() return movieGroup.Width() - 30 end)
            debriefText.Height:Set(90)
            
            UIUtil.SetTextBoxText(debriefText, debriefData.text)
            
            local scoreGroup = CreateBorderGroup(currentPage)
            LayoutHelpers.AtTopIn(scoreGroup, currentPage, 120)
            scoreGroup.Height:Set(50)
            scoreGroup.Width:Set(150)
            
            local opScoreLabel = UIUtil.CreateText(scoreGroup, LOC("<LOC SCORE_0043>Operation Score"), 14, UIUtil.bodyFont)
            LayoutHelpers.AtTopIn(opScoreLabel, scoreGroup, 5)
            LayoutHelpers.AtHorizontalCenterIn(opScoreLabel, scoreGroup)
            
            local opScore = UIUtil.CreateText(scoreGroup, campaignScore, 14, UIUtil.bodyFont)
            LayoutHelpers.Below(opScore, opScoreLabel, 4)
            LayoutHelpers.AtHorizontalCenterIn(opScore, scoreGroup)
            
            local objGroup = CreateBorderGroup(currentPage)
            LayoutHelpers.AtLeftTopIn(objGroup, currentPage, 395, 190)
            objGroup.Height:Set(220)
            objGroup.Width:Set(535)
            
            LayoutHelpers.AtHorizontalCenterIn(scoreGroup, objGroup)
            
            local sortedObjectives = {}
            local tempObjectives = {}
            local obTable = import('/lua/ui/game/objectives2.lua').GetCurrentObjectiveTable()
            local hasPrimaries = false
            local hasSecondaries = false
            if obTable then
                for key, objective in obTable do
                    local compStr
                    local compColor = 'ffff0000'
                    if objective.complete == 'complete' then
                        compStr = "<LOC SCORE_0038>Accomplished"
                        compColor = 'ff00ff00'
                    elseif objective.complete == 'failed' then
                        compStr = "<LOC SCORE_0039>Failed"
                        compColor = 'ffff0000'
                    else
                        compStr = "<LOC SCORE_0054>Incomplete"
                        compColor = 'ff0000ff'
                    end
                    if objective.type == 'primary' then
                        hasPrimaries = true
                    elseif objective.type == 'secondary' then
                        hasSecondaries = true
                    end
                    table.insert(tempObjectives, {title = LOC(objective.title), complete = LOC(compStr), completeColor = compColor, type = objective.type})
                end
            end
            
            if hasPrimaries then
                table.insert(sortedObjectives, {title = LOC("<LOC SCORE_0037>Primary Objectives"), type = 'header'})
                for i, v in tempObjectives do
                    if v.type == 'primary' then
                        table.insert(sortedObjectives, v)
                    end
                end
            end
            
            if hasSecondaries then
                table.insert(sortedObjectives, {title = LOC("<LOC SCORE_0040>Secondary Objectives"), type = 'header'})
                for i, v in tempObjectives do
                    if v.type == 'secondary' then
                        table.insert(sortedObjectives, v)
                    end
                end
            end
            
            objContainer = Group(objGroup)
            objContainer.Height:Set(function() return objGroup.Height() + 0 end)
            objContainer.Width:Set(function() return objGroup.Width() - 30 end)
            objContainer.top = 0
            
            LayoutHelpers.AtLeftTopIn(objContainer, objGroup)
            UIUtil.CreateVertScrollbarFor(objContainer)
            
            local objEntries = {}
            
            local function CreateElement(index)
                objEntries[index] = {}
                objEntries[index].bg = Bitmap(objContainer)
                objEntries[index].bg.Left:Set(objContainer.Left)
                objEntries[index].bg.Right:Set(objContainer.Right)
                
                objEntries[index].title = UIUtil.CreateText(objEntries[1].bg, '', 16, UIUtil.bodyFont)
                objEntries[index].title:DisableHitTest()
                
                objEntries[index].result = UIUtil.CreateText(objEntries[1].bg, '', 16, UIUtil.bodyFont)
                objEntries[index].result:DisableHitTest()
                
                objEntries[index].bg.Height:Set(function() return objEntries[index].title.Height() + 4 end)
                
                LayoutHelpers.AtVerticalCenterIn(objEntries[index].title, objEntries[index].bg)
                LayoutHelpers.AtVerticalCenterIn(objEntries[index].result, objEntries[index].bg)
                LayoutHelpers.AtLeftIn(objEntries[index].title, objEntries[index].bg)
                LayoutHelpers.AtRightIn(objEntries[index].result, objEntries[index].bg, 5)
            end
            
            CreateElement(1)
            LayoutHelpers.AtTopIn(objEntries[1].bg, objContainer)
                
            local index = 2
            while objEntries[table.getsize(objEntries)].bg.Top() + (2 * objEntries[1].bg.Height()) < objContainer.Bottom() do
                CreateElement(index)
                LayoutHelpers.Below(objEntries[index].bg, objEntries[index-1].bg)
                index = index + 1
            end
            
            local numLines = function() return table.getsize(objEntries) end
            
            local function DataSize()
                return table.getn(sortedObjectives)
            end
            
            -- called when the scrollbar for the control requires data to size itself
            -- GetScrollValues must return 4 values in this order:
            -- rangeMin, rangeMax, visibleMin, visibleMax
            -- aixs can be "Vert" or "Horz"
            objContainer.GetScrollValues = function(self, axis)
                local size = DataSize()
                --LOG(size, ":", self.top, ":", math.min(self.top + numLines, size))
                return 0, size, self.top, math.min(self.top + numLines(), size)
            end
        
            -- called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
            objContainer.ScrollLines = function(self, axis, delta)
                self:ScrollSetTop(axis, self.top + math.floor(delta))
            end
        
            -- called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
            objContainer.ScrollPages = function(self, axis, delta)
                self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
            end
        
            -- called when the scrollbar wants to set a new visible top line
            objContainer.ScrollSetTop = function(self, axis, top)
                top = math.floor(top)
                if top == self.top then return end
                local size = DataSize()
                self.top = math.max(math.min(size - numLines() , top), 0)
                self:CalcVisible()
            end
        
            -- called to determine if the control is scrollable on a particular access. Must return true or false.
            objContainer.IsScrollable = function(self, axis)
                return true
            end
            -- determines what controls should be visible or not
            objContainer.CalcVisible = function(self)
                local function SetTextLine(line, data, lineID)
                    if data.type == 'header' then
                        LayoutHelpers.AtHorizontalCenterIn(line.title, objContainer)
                        line.bg:SetSolidColor('ff506268')
                        line.title:SetText(data.title)
                        line.title:SetFont(UIUtil.titleFont, 16)
                        line.title:SetColor(UIUtil.fontColor)
                        line.result:SetText('')
                    else
                        LayoutHelpers.AtLeftIn(line.title, line.bg, 5)
                        line.bg:SetSolidColor('00000000')
                        line.title:SetText(data.title)
                        line.title:SetColor('ffffffff')
                        line.title:SetFont(UIUtil.bodyFont, 14)
                        line.result:SetText(data.complete or "<LOC key_binding_0001>No action text")
                        line.result:SetColor(data.completeColor)
                    end
                end
                for i, v in objEntries do
                    if sortedObjectives[i + self.top] then
                        SetTextLine(v, sortedObjectives[i + self.top], i + self.top)
                    else
                        v.bg:SetSolidColor('00000000')
                        v.title:SetText('')
                        v.result:SetText('')
                    end
                end
            end
            objContainer.HandleEvent = function(control, event)
                if event.Type == 'WheelRotation' then
                    local lines = 1
                    if event.WheelRotation > 0 then
                        lines = -1
                    end
                    control:ScrollLines(nil, lines)
                end
            end
            objContainer:CalcVisible()
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
        -- don't show campaign button normally
        if value.button == "campaign" and not showCampaign then
            continue
        end
        
        local curButton = UIUtil.CreateButtonStd(bg, '/scx_menu/tab_btn/tab', value.title, 16, nil, nil, "UI_Tab_Click_02", "UI_Tab_Rollover_02")
        if prev then
            #curButton.Left:Set(function() return prev.Right() + 0 end)
            #curButton.Bottom:Set(function() return prev.Bottom() end)
            LayoutHelpers.RightOf(curButton, prev, -5)
        else
            #LayoutHelpers.RelativeTo(curButton, bg, 
            #    UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 
            #    'l_general_btn', 'panel_bmp', -10)
            curButton.Left:Set(function() return bg.Left() + 17 end)
            curButton.Top:Set(function() return bg.Top() + 57 end)
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
	
    hotstats.Set_graph(victory, showCampaign, operationVictoryTable, dialog, bg)
end


--[[
function CreateSkirmishScreen(victory, showCampaign, operationVictoryTable)
    if dialog then return end

    SessionEndGame()
    
    -- create the dialog
    dialog = Group(GetFrame(0), "scoreDialogParentGroup")
    dialog:SetRenderPass(UIUtil.UIRP_PostGlow)  -- just in case our parent is the map
    LayoutHelpers.FillParent(dialog, GetFrame(0))
    dialog.Depth:Set(GetFrame(0):GetTopmostDepth())
    
    local bg = Bitmap(dialog, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/panel_bmp.dds'))
    LayoutHelpers.AtCenterIn(bg, GetFrame(0))
    
    local border = Group(dialog, 'border')
    LayoutHelpers.FillParent(border, GetFrame(0))
    border.Depth:Set(function() return bg.Depth() - 1 end)   
    
    function CreateBorder()
        border.background = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/background_bmp.dds"))
        LayoutHelpers.FillParent(border.background, border)
        border.background.Depth:Set(border.Depth() - 1)
    
        border.um = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_horz_um.dds"))
        border.ur = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_ur.dds"))
        border.ul = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_ul.dds"))
        border.lr = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_lr.dds"))
        border.ll = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_ll.dds"))
        
        border.umr = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_horz_umr.dds"))
        border.uml = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_horz_uml.dds"))
        border.lml = Bitmap(border, UIUtil.UIFile("/dialogs/score-victory-defeat-border/back_brd_horz_lml.dds"))
        
        LayoutHelpers.AtHorizontalCenterIn(border.um, border)
        LayoutHelpers.AtTopIn(border.um, border)
        
        LayoutHelpers.AtRightIn(border.ur, border)
        LayoutHelpers.AtTopIn(border.ur, border)
        
        LayoutHelpers.AtLeftTopIn(border.ul, border)
        
        LayoutHelpers.AtRightIn(border.lr, border)
        LayoutHelpers.AtBottomIn(border.lr, border)
        
        LayoutHelpers.AtLeftIn(border.ll, border)
        LayoutHelpers.AtBottomIn(border.ll, border)
        
        border.umr.Left:Set(border.um.Right)
        border.umr.Right:Set(border.ur.Left)
        border.umr.Top:Set(border.Top)
        border.uml.Left:Set(border.ul.Right)
        border.uml.Right:Set(border.um.Left)
        border.uml.Top:Set(border.Top)
        border.lml.Left:Set(border.ll.Right)
        border.lml.Right:Set(border.lr.Left)
        border.lml.Bottom:Set(border.Bottom)
    end
    
    CreateBorder()
    
    border.title = UIUtil.CreateText(border.um, "", 18, UIUtil.titleFont)
    LayoutHelpers.AtHorizontalCenterIn(border.title, border)
    LayoutHelpers.AtTopIn(border.title, border, 10)

    -- set controls that are global to the dialog
    border.continueBtn = UIUtil.CreateButtonStd(border.lr, '/menus/main03/large', "<LOC _Continue>", 22, 0, 0, "UI_Menu_MouseDown", "UI_Opt_Affirm_Over")
	LayoutHelpers.AtRightIn(border.continueBtn, border, 114)
	LayoutHelpers.AtBottomIn(border.continueBtn, border, 12)
	EffectHelpers.ScaleTo(border.continueBtn, .88, 0)
	border.continueBtn.label.Top:Set(function() return border.continueBtn.Top() + 14 end)
	border.continueBtn:UseAlphaHitTest(false)
	
	border.continueBtn.glow = Bitmap(border.continueBtn, UIUtil.UIFile('/menus/main03/large_btn_glow.dds'))
	LayoutHelpers.AtCenterIn(border.continueBtn.glow, border.continueBtn)
	EffectHelpers.ScaleTo(border.continueBtn.glow, .88, 0)
	border.continueBtn.glow:SetAlpha(0)
	border.continueBtn.glow:DisableHitTest()
	
    border.continueBtn.pulse = Bitmap(border.continueBtn, UIUtil.UIFile('/menus/main03/large_btn_glow.dds'))
	LayoutHelpers.AtCenterIn(border.continueBtn.pulse, border.continueBtn)
    border.continueBtn.pulse.Width:Set(math.floor(border.continueBtn.pulse.BitmapWidth() * .88))
	border.continueBtn.pulse.Height:Set(math.floor(border.continueBtn.pulse.BitmapHeight() * .88))
	border.continueBtn.pulse:DisableHitTest()
	border.continueBtn.pulse:SetAlpha(.5)
	
    EffectHelpers.Pulse(border.continueBtn.pulse, 2, .5, 1)
    
    border.continueBtn.OnRolloverEvent = function(self, event) 
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
    
    border.continueBtn.OnClick = function(self, modifiers)
		score_sca.clean_view()
        if operationVictoryTable then
            import('/lua/ui/campaign/campaignmanager.lua').SetAutoContinueOpStatus(operationVictoryTable.success, operationVictoryTable.opKey, operationVictoryTable.difficulty)
        else
            import('/lua/ui/campaign/campaignmanager.lua').ClearAutoContinueOp()
        end

        # Checking gpgnet too in case we switch to that
        if HasCommandLineArg("/online") or HasCommandLineArg("/gpgnet") then
            ExitApplication()
        else
            ExitGame()
        end
    end
    Tooltip.AddButtonTooltip(border.continueBtn, 'PostScore_Quit')

    UIUtil.MakeInputModal(dialog, function() border.continueBtn.OnClick(border.continueBtn) end, function() border.continueBtn.OnClick(border.continueBtn) end)
    
#    # dev-only reload button
#    local reloadBtn = UIUtil.CreateButtonStd(bg, '/dialogs/standard_btn/standard', "Reload", 11)
#    LayoutHelpers.Above(reloadBtn, border.continueBtn, 10)
#    reloadBtn.OnClick = function()
#        import('/lua/ui/dialogs/score.lua').CreateSkirmishScreen()
#    end
#    # end reload button

    local elapsedTimeLabel = UIUtil.CreateText(bg, "<LOC SCORE_0029>Game Time:", 14, UIUtil.titleFont)
    LayoutHelpers.AtLeftTopIn(elapsedTimeLabel, bg, 40, 451)

    local elapsedTimeBack = Bitmap(bg)
    elapsedTimeBack.Width:Set(252)
    elapsedTimeBack.Height:Set(30)
    LayoutHelpers.AtLeftTopIn(elapsedTimeBack, bg, 26, 443)
    elapsedTimeBack:SetSolidColor('black')
    elapsedTimeBack:SetAlpha(.8)
    elapsedTimeBack.Depth:Set(bg.Depth() - 1)
    
    elapsedTime = UIUtil.CreateText(bg, "", 14, UIUtil.titleFont)
    LayoutHelpers.RightOf(elapsedTime, elapsedTimeLabel, 5)
  
    border.replayButton = UIUtil.CreateButtonStd(border.ll, '/small_wide_btn/small_wide', "<LOC uireplay_0003>", 11)
    LayoutHelpers.AtLeftIn(border.replayButton, border.ll, 99)
    LayoutHelpers.AtBottomIn(border.replayButton, border.ll, 6)
    border.replayButton.OnClick = function(self, modifiers)
        import('/lua/ui/dialogs/replay.lua').CreateDialog(dialog, false, nil)
    end
    Tooltip.AddButtonTooltip(border.replayButton, "PostScore_Replay")
    
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
        currentPage.tabBitmap = Bitmap(bg, UIUtil.SkinnableFile('/dialogs/tab_btn/general_btn_selected.dds'))
        currentPage.tabBitmap.Depth:Set(function() return bg.Depth() + 100 end)
        LayoutHelpers.AtCenterIn(currentPage.tabBitmap, currentPage.tabButton)
        local tabLabel = UIUtil.CreateText(currentPage.tabBitmap, tabData.title, 11, UIUtil.titleFont)
        LayoutHelpers.AtCenterIn(tabLabel, currentPage.tabBitmap)
        
        -- if there's a grid to be shown, set it up along with histogram
        -- Note: currently, only campaign score page won't have a grid
        if tabData.grid then
            -- create sub tabs to display grid or hisotogram
 --[[           local gridTab = Checkbox(currentPage
                , UIUtil.SkinnableFile('/dialogs/score_btn/grid_btn_up.dds')
                , UIUtil.SkinnableFile('/dialogs/score_btn/chart_btn_up.dds')
                , UIUtil.SkinnableFile('/dialogs/score_btn/grid_btn_down.dds')
                , UIUtil.SkinnableFile('/dialogs/score_btn/chart_btn_down.dds')
                , UIUtil.SkinnableFile('/dialogs/score_btn/grid_btn_dis.dds')
                , UIUtil.SkinnableFile('/dialogs/score_btn/chart_btn_dis.dds')
                , "UI_Tab_Click_02", "UI_Tab_Rollover_02")
            LayoutHelpers.RelativeTo(gridTab, bg, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 'l_chart_btn_up', 'panel_bmp')
            local tabLabel = UIUtil.CreateText(gridTab, "<LOC _Grid>", 11, UIUtil.titleFont)
            LayoutHelpers.AtCenterIn(tabLabel, gridTab)
            gridTab:Hide()--]]

            -- create the grid group/bg
            local gridGroup = Group(currentPage, "scoreGridGroup")
            -- no layout info for these sub pages, so position manually
            LayoutHelpers.AtLeftTopIn(gridGroup, currentPage, 43, 102)
            gridGroup.Width:Set(743)
            gridGroup.Height:Set(257)
#            gridTab:SetCheck(true)

            local gridBG = Bitmap(gridGroup, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/totals-back_bmp.dds'))
            LayoutHelpers.RelativeTo(gridBG, bg, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 'totals-back_bmp', 'panel_bmp')

            -- create the histogram group/bg
            local histogramGroup = Group(currentPage, "scoreHistogramGroup")
            LayoutHelpers.FillParent(histogramGroup, gridGroup)
            histogramGroup:Hide()

#            local histogramBG = Bitmap(histogramGroup, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/histograph-back_bmp.dds'))
#            LayoutHelpers.RelativeTo(histogramBG, bg, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 'histograph-back_bmp', 'panel_bmp')

--[[            -- set up behavior or histogram/group tabs
            gridTab.OnClick = function(self, modifiers)
                if not self:IsChecked() then
                    histogramGroup:Hide()
                    gridGroup:Show()
                    gridTab:SetCheck(true)
                    histogramTab:SetCheck(false)
                end
            end
            gridTab.HandleEvent = function(self, event)
                if event.Type == 'MouseEnter' then
                    Tooltip.CreateMouseoverDisplay(self, "PostScore_Grid", nil, true)
                elseif event.Type == 'MouseExit' then
                    Tooltip.DestroyMouseoverDisplay()
                end
                Checkbox.HandleEvent(self, event)
            end--]]
                        
            -- set up labels (no layout info yet, so store x values in a table)
            -- note the numbers are colmun num, for easy access
            local labelXPos = {
                icon = 6,
                player = 38,
                team = 259,
                [1] = 414,
                [2] = 508,
                [3] = 602,
                [4] = 696,
                [5] = 790,
                [6] = 884,
            }
            
            local playerText = MultiLineText(gridBG, UIUtil.titleFont, 16, UIUtil.fontColor)
            playerText.Width:Set(250)
            playerText.Height:Set(35)
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
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_up.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_up.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_over.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_over.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_dis.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_dis.dds')
                    , "UI_Tab_Click_02", "UI_Tab_Rollover_02")
                LayoutHelpers.AtLeftTopIn(sortButtons[index].checkbox, gridBG, labelXPos[index] - 30, -3)
                sortButtons[index].checkbox.toolTip = colName.scoreKey
                
                sortButtons[index].label = {}
                sortButtons[index].label[1] = UIUtil.CreateText(sortButtons[index].checkbox, '', 11, UIUtil.titleFont)
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
                        sortButtons[index].label[lineIndex] = UIUtil.CreateText(sortButtons[index].checkbox, wrappedText[lineIndex], 11, UIUtil.titleFont)
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
            
            local prev = gridBG
            local index = 1
            for i, armyInfo in armiesInfo.armiesTable do
                if not armyInfo.civilian then
                    local armyBg = Bitmap(gridGroup, UIUtil.SkinnableFile('/dialogs/score-victory-defeat/player-back_bmp.dds'))
                    LayoutHelpers.Below(armyBg, prev, -5)
                    prev = armyBg
                    
                    curGrid[index] = {}
                    
                    curGrid[index].color = Bitmap(armyBg)
                    curGrid[index].color.Width:Set(21)
                    curGrid[index].color.Height:Set(20)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].color, armyBg, labelXPos.icon, 6)
    
                    curGrid[index].factionIcon = Bitmap(curGrid[index].color)
                    LayoutHelpers.FillParent(curGrid[index].factionIcon, curGrid[index].color)
    
                    curGrid[index].playerName = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                    LayoutHelpers.AtLeftTopIn(curGrid[index].playerName, armyBg, labelXPos.player, 6)
                    
                    --curGrid[index].teamName = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                    --LayoutHelpers.AtLeftTopIn(curGrid[index].teamName, armyBg, labelXPos.team, 6)
                    
                    curGrid[index].cols = {}
                    for col = 1, 6 do
                        curGrid[index].cols[col] = UIUtil.CreateText(armyBg, "", 16, UIUtil.bodyFont)
                        LayoutHelpers.AtLeftTopIn(curGrid[index].cols[col], armyBg, labelXPos[col] - 20, 8)
                    end
                    index = index + 1
                end
            end

            -- set up data type buttons
            local typeButtons = {}
            for index, dataType in tabData.types do
                local Index = index
                typeButtons[index] = {}
                typeButtons[index].checkbox = Checkbox(gridGroup
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_up.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_up.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_over.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_over.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-d_btn_dis.dds')
                    , UIUtil.SkinnableFile('/dialogs/rect-box_btn/rect-box-s_btn_dis.dds')
                    , "UI_Tab_Click_02", "UI_Tab_Rollover_02")
                LayoutHelpers.RelativeTo(typeButtons[index].checkbox, bg, 
                    UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 
                    'l_btn0'..index, 'panel_bmp')
                typeButtons[index].checkbox.toolTip = dataType.scoreKey
    
                typeButtons[index].label = {}
                typeButtons[index].label[1] = UIUtil.CreateText(sortButtons[index].checkbox, '', 11, UIUtil.titleFont)
                typeButtons[index].label[1]:DisableHitTest()
                
                local wrappedText = import('/lua/maui/text.lua').WrapText(LOC(dataType.title), 
                    80,
                    function(text)
                        return typeButtons[Index].label[1]:GetStringAdvance(text)
                    end)
                    
                if table.getn(wrappedText) > 1 then
                    typeButtons[index].label[1]:SetText(wrappedText[1])
                    LayoutHelpers.AtTopIn(typeButtons[index].label[1], typeButtons[index].checkbox, 12)
                    LayoutHelpers.AtHorizontalCenterIn(typeButtons[index].label[1], typeButtons[index].checkbox)
                    for i = 2, table.getn(wrappedText) do
                        local lineIndex = i
                        typeButtons[index].label[lineIndex] = UIUtil.CreateText(typeButtons[index].checkbox, wrappedText[lineIndex], 11, UIUtil.titleFont)
                        typeButtons[index].label[lineIndex]:DisableHitTest()
                        LayoutHelpers.Below(typeButtons[index].label[lineIndex], typeButtons[index].label[lineIndex-1], -2)
                        LayoutHelpers.AtHorizontalCenterIn(typeButtons[index].label[lineIndex], typeButtons[index].checkbox)
                    end
                else
                    typeButtons[index].label[1]:SetText(wrappedText[1])
                    LayoutHelpers.AtCenterIn(typeButtons[index].label[1], typeButtons[index].checkbox)
                end
                
                typeButtons[index].checkbox._dataType = dataType.scoreKey
                
            end

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
            
            -- now create histogram display
        elseif tabData.button == "campaign" then
            -- Set up campaign display
            local campaignBG = Bitmap(currentPage)
            campaignBG:SetSolidColor("black")
            LayoutHelpers.AtLeftTopIn(campaignBG, currentPage, 38, 79)
            campaignBG.Width:Set(756)
            campaignBG.Height:Set(286)

            local primaryObjectivesLabel = UIUtil.CreateText(campaignBG, "<LOC SCORE_0037>Primary Objectives", 14, UIUtil.titleFont)
            LayoutHelpers.AtLeftTopIn(primaryObjectivesLabel, campaignBG, 0, 5)
            local primaryObjectives = ItemList(campaignBG)
            primaryObjectives:SetFont(UIUtil.bodyFont, 14)
            primaryObjectives.Width:Set(320)
            primaryObjectives.Height:Set(70)
            LayoutHelpers.Below(primaryObjectives, primaryObjectivesLabel)
            UIUtil.CreateVertScrollbarFor(primaryObjectives)

            local secondaryObjectivesLabel = UIUtil.CreateText(campaignBG, "<LOC SCORE_0040>Secondary Objectives", 14, UIUtil.titleFont)
            LayoutHelpers.Below(secondaryObjectivesLabel, primaryObjectives, 5)
            local secondaryObjectives = ItemList(campaignBG)
            secondaryObjectives:SetFont(UIUtil.bodyFont, 14)
            secondaryObjectives.Width:Set(primaryObjectives.Width)
            secondaryObjectives.Height:Set(primaryObjectives.Height)
            LayoutHelpers.Below(secondaryObjectives, secondaryObjectivesLabel)
            UIUtil.CreateVertScrollbarFor(secondaryObjectives)

            local bonusObjectivesLabel = UIUtil.CreateText(campaignBG, "<LOC SCORE_0041>Bonus Objectives", 14, UIUtil.titleFont)
            LayoutHelpers.Below(bonusObjectivesLabel, secondaryObjectives, 5)
            local bonusObjectives = ItemList(campaignBG)
            bonusObjectives:SetFont(UIUtil.bodyFont, 14)
            bonusObjectives.Width:Set(primaryObjectives.Width)
            bonusObjectives.Height:Set(primaryObjectives.Height)
            LayoutHelpers.Below(bonusObjectives, bonusObjectivesLabel)
            local sb = UIUtil.CreateVertScrollbarFor(bonusObjectives)
            
            local infoGroup = Group(campaignBG)
            infoGroup.Left:Set(sb.Right)
            infoGroup.Top:Set(campaignBG.Top)
            infoGroup.Bottom:Set(campaignBG.Bottom)
            infoGroup.Right:Set(campaignBG.Right)

            local debriefLabel = UIUtil.CreateText(infoGroup, "<LOC SCORE_0044>Debriefing", 14, UIUtil.titleFont)
            LayoutHelpers.AtLeftTopIn(debriefLabel, infoGroup, 0, 15)
            
            local debriefText = UIUtil.CreateTextBox(infoGroup)
            debriefText.Top:Set(debriefLabel.Bottom)
            debriefText.Bottom:Set(infoGroup.Bottom)
            debriefText.Width:Set(function() return math.floor(infoGroup.Width() / 2) end)
            LayoutHelpers.Below(debriefText, debriefLabel)

            local obTable = import('/lua/ui/game/objectives2.lua').GetCurrentObjectiveTable()
            if obTable then
                for key, objective in obTable do
                    local compStr
                    if objective.Status then
                        if objective.Status == 'complete' then
                            compStr = "<LOC SCORE_0038>Accomplished"
                        else
                            compStr = "<LOC SCORE_0039>Failed"
                        end
                    else
                        compStr = "<LOC SCORE_0054>Incomplete"
                    end
                    
                    local targetList
                    if objective.ObjData.type == 'primary' then
                        targetList = primaryObjectives
                    elseif objective.ObjData.type == 'secondary' then
                        targetList = secondaryObjectives
                    else
                        targetList = bonusObjectives
                    end

                    targetList:AddItem(LOC(objective.ObjData.title) .. " (" .. LOC(compStr) .. ")")
                end
            end
            
            local successKey 
            if operationVictoryTable.success then
                successKey = 'success'
            else
                successKey = 'failure'
            end
            
            local debriefString = import('/lua/ui/campaign/campaigndebriefingtext.lua').campaignDebriefingText[operationVictoryTable.opKey][successKey]
            UIUtil.SetTextBoxText(debriefText, debriefString)

            -- show medal
            local medalBmps = import('/lua/ui/campaign/campaignmanager.lua').GetMedalBitmaps(
                  operationVictoryTable.opKey
                , operationVictoryTable.difficulty
                , operationVictoryTable.allPrimary
                , operationVictoryTable.allSecondary
                , operationVictoryTable.allBonus)
            
            local medalLabel = UIUtil.CreateText(infoGroup, "<LOC SCORE_0057>Operation Medal", 14, UIUtil.titleFont)
            LayoutHelpers.RightOf(medalLabel, debriefText, 40)
            if medalBmps then
                local medalBottom = Bitmap(infoGroup)
                medalBottom:SetTexture(medalBmps.mission)
                LayoutHelpers.CenteredBelow(medalBottom, medalLabel)
                local medalMiddle = Bitmap(medalBottom)
                medalMiddle:SetTexture(medalBmps.difficulty)
                LayoutHelpers.AtCenterIn(medalMiddle, medalBottom)
                local medalTop = Bitmap(medalMiddle)
                medalTop:SetTexture(medalBmps.award)
                LayoutHelpers.AtCenterIn(medalTop, medalMiddle)
            end
            
            local opScoreLabel = UIUtil.CreateText(infoGroup, "<LOC SCORE_0043>Operation Score", 14, UIUtil.titleFont)
            LayoutHelpers.CenteredBelow(opScoreLabel, medalLabel, 40)
            
            local opScore = UIUtil.CreateText(infoGroup, tostring(curInfo.scoreData.current[GetArmiesTable().focusArmy].general.score), 14, UIUtil.titleFont)
            LayoutHelpers.CenteredBelow(opScore, opScoreLabel, 5)
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
        border.title:SetText(LOC(victoryString))

        UpdateDisplay()
    end

    -- set up top level tabs
    local prev = false
    local defaultTab = false
    for index, value in tabs do
        -- don't show campaign button normally
        if value.button == "campaign" and not showCampaign then
            continue
        end
        
        local curButton = UIUtil.CreateButtonStd(bg, '/dialogs/tab_btn/general', value.title, 12, nil, nil, "UI_Tab_Click_02", "UI_Tab_Rollover_02")

        if prev then
            #curButton.Left:Set(function() return prev.Right() + 0 end)
            #curButton.Bottom:Set(function() return prev.Bottom() end)
            LayoutHelpers.RightOf(curButton, prev)
        else
            #LayoutHelpers.RelativeTo(curButton, bg, 
            #    UIUtil.SkinnableFile('/dialogs/score-victory-defeat/score-victory-defeat_layout.lua'), 
            #    'l_general_btn', 'panel_bmp', -10)
            curButton.Left:Set(function() return bg.Left() + 21 end)
            curButton.Top:Set(function() return bg.Top() + 67 end)
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

    UpdateData()
    SetNewPage(defaultTab)

	score_sca.Set_graph(victory, showCampaign, operationVictoryTable, dialog, bg)
end
--]]
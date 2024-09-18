--* File: lua/modules/ui/game/gamemain.lua
--* Author: Chris Blackwell
--* Summary: Entry point for the in game UI

--LOG("*AI DEBUG Loading Gamemain")

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')

local WldUIProvider = import('/lua/ui/game/wlduiprovider.lua').WldUIProvider
local GameCommon = import('/lua/ui/game/gamecommon.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Movie = import('/lua/maui/movie.lua').Movie

local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')

local gameParent = false
local controlClusterGroup = false
local statusClusterGroup = false
local mapGroup = false
local mfdControl = false
local ordersControl = false

local OnDestroyFuncs = {}

local NISActive = false

local isReplay = false

local waitingDialog = false

-- The focus army as set at the start of the game.
-- Allows detection of whether someone was originally an observer or a player
OriginalFocusArmy = -1

-- from All Your Voice mod
local GetOption = import('/lua/user/prefs.lua').GetOption
local Ping = import("/lua/ui/game/ping.lua").DoPingOnPosition
local VOStrings = import('/lua/ui/game/vo_computer.lua')

local Economy = import('/lua/ui/game/economy.lua')
local MissionText = import('/lua/ui/game/missiontext.lua')
local UnitViewDetail = import('/lua/ui/game/unitviewdetail.lua')

local LastAlertPos
local OriginalPos

local ForkThread = ForkThread
local WaitTicks = coroutine.yield

local LOUDINSERT = table.insert
local LOUDREMOVE = table.remove


-- check this flag to see if it's valid to show the exit dialog
supressExitDialog = false

function GetReplayState()
    return isReplay
end

-- query this to see if the UI is hidden
gameUIHidden = false

PostScoreVideo = false

IsSavedGame = false

function KillWaitingDialog()
    if waitingDialog then
        waitingDialog:Destroy()
    end
end

function SetLayout(layout)

    UnitViewDetail.Hide()

    import('/lua/ui/game/construction.lua').SetLayout(layout)
    import('/lua/ui/game/borders.lua').SetLayout(layout)
    import('/lua/ui/game/multifunction.lua').SetLayout(layout)
    
    if not isReplay then
        import('/lua/ui/game/orders.lua').SetLayout(layout)
    end

    import('/lua/ui/game/unitview.lua').SetLayout(layout)
    import('/lua/ui/game/objectives2.lua').SetLayout(layout)

    UnitViewDetail.SetLayout(layout, mapGroup)
    Economy.SetLayout(layout)
    MissionText.SetLayout()

    import('/lua/ui/game/helptext.lua').SetLayout()
    import('/lua/ui/game/avatars.lua').SetLayout()

    Economy.SetLayout()

    import('/lua/ui/game/score.lua').SetLayout()
    import('/lua/ui/game/tabs.lua').SetLayout()
    import('/lua/ui/game/controlgroups.lua').SetLayout()
    import('/lua/ui/game/chat.lua').SetLayout()
    import('/lua/ui/game/minimap.lua').SetLayout()
end

function OnFirstUpdate()

    LOG("*AI DEBUG OnFirstUpdate")

    import("/lua/ui/override/SessionIsMultiplayer.lua")

    EnableWorldSounds()
	
    local avatars = GetArmyAvatars()
	
    if avatars and avatars[1]:IsInCategory("COMMAND") then
	
        local armiesInfo = GetArmiesTable()
        local focusArmy = armiesInfo.focusArmy
        local playerName = armiesInfo.armiesTable[focusArmy].nickname
		
        avatars[1]:SetCustomName(playerName)
		
    end
	
	-- Music
	import('/lua/UserMusic.lua').StartPeaceMusic()
	
	import('/lua/ui/game/score.lua').CreateScoreUI()

    ForkThread( 
        function()
            WaitSeconds(1.5)
            UIZoomTo(avatars, 1)
            WaitSeconds(1.5)
            SelectUnits(avatars)
            FlushEvents()
			
            if not IsNISMode() then
                import('/lua/ui/game/worldview.lua').UnlockInput()
            end
			
			--try to turn on cheating so we can issue path commands (not working)
			local oldcheat = SessionGetScenarioInfo().Options.CheatsEnabled
			
			if not Sync.Cheaters then
			
				Sync.Cheaters = false
				Sync.Cheaters.CheatsEnabled = true
				
			else
			
				Sync.Cheaters.CheatsEnabled = true
				
			end

			-- this is interesting -- I had to put this code here so that no desync would occur
			-- since if I put it inline a desync would occur on replays - since it's here it gets
			-- delayed for about 3 seconds once the sim in actually running
			ConExecute('path_armybudget = 6500')
			ConExecute('path_backgroundbudget = 3000')
			ConExecute('path_maxinstantworkunits = 1250')
			
			--ConExecute('path_UnreachableTimeoutSearchSteps = 750')
			
			--ConExecute('ren_ShadowCoeff 2')
			--ConExecute('ren_ShadowSize 2048')
			--ConExecute('ren_ShadowBias 0.0010')
			--ConExecute('ren_BloomGlowCopyScale 2.5')
			--ConExecute('ren_BloomBlurKernelScale 1.1')
			--ConExecute('ren_BloomBlurCount 0')
            
            ConExecute('ren_ViewError 0.004')
            ConExecute('ren_ClipDecalLevel 4')
            ConExecute('ren_DecalFadeFraction 0.25')
			
			ConExecute('fog_DistanceFog')
            
            ConExecute('d3d_WindowsCursor true')
            
            ConExecute('cam_SetLOD WorldCamera 0.5')

            OriginalFocusArmy = GetFocusArmy()

            InitAutoSaveGame()
        end
    )

    if Prefs.GetOption('skin_change_on_start') != 'no' then
	
        local focusarmy = GetFocusArmy()
        local armyInfo = GetArmiesTable()
		
        if focusarmy >= 1 then
		
            local factions = import('/lua/factions.lua').Factions
			
            if factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin then
			
                UIUtil.SetCurrentSkin(factions[armyInfo.armiesTable[focusarmy].faction+1].DefaultSkin)
				
            end
			
        end
		
    end

    -- Hotbuild requires these two calls to be fully functional at game start
    import('/lua/hotbuild/hotbuild.lua').init()
    IN_AddKeyMapTable(import('/lua/keymap/keymapper.lua').GetKeyMappings())
	
end

function CreateUI(isReplay)

    ConExecute("Cam_Free off")
    
    local prefetchTable = { models = {}, anims = {}, d3d_textures = {}, batch_textures = {} }
    
    -- set up our layout change function
    UIUtil.changeLayoutFunction = SetLayout

    -- update loc table with player's name
    local focusarmy = GetFocusArmy()
	
    if focusarmy >= 1 then
        LocGlobals.PlayerName = GetArmiesTable().armiesTable[focusarmy].nickname
    end

    -- GameCommon.InitializeUnitIconBitmaps(prefetchTable.batch_textures)

    gameParent = UIUtil.CreateScreenGroup(GetFrame(0), "GameMain ScreenGroup")

    controlClusterGroup, statusClusterGroup, mapGroup, windowGroup = import('/lua/ui/game/borders.lua').SetupBorderControl(gameParent)

    controlClusterGroup:SetNeedsFrameUpdate(true)
	
    controlClusterGroup.OnFrame = function(self, deltaTime)
        controlClusterGroup:SetNeedsFrameUpdate(false)
        OnFirstUpdate()
    end

    import('/lua/ui/game/worldview.lua').CreateMainWorldView(gameParent, mapGroup)
    import('/lua/ui/game/worldview.lua').LockInput()

    local massGroup, energyGroup = Economy.CreateEconomyBar(statusClusterGroup)
	
    import('/lua/ui/game/tabs.lua').Create(mapGroup)

    mfdControl = import('/lua/ui/game/multifunction.lua').Create(controlClusterGroup)
	
    if not isReplay then
        ordersControl = import('/lua/ui/game/orders.lua').SetupOrdersControl(controlClusterGroup, mfdControl)
    end
	
    import('/lua/ui/game/construction.lua').SetupConstructionControl(controlClusterGroup, mfdControl, ordersControl)
    import('/lua/ui/game/unitview.lua').SetupUnitViewLayout(mapGroup, ordersControl)

    UnitViewDetail.SetupUnitViewLayout(mapGroup, mapGroup)

    import('/lua/ui/game/avatars.lua').CreateAvatarUI(mapGroup)
    import('/lua/ui/game/controlgroups.lua').CreateUI(mapGroup)
    import('/lua/ui/game/transmissionlog.lua').CreateTransmissionLog()
    import('/lua/ui/game/helptext.lua').CreateHelpText(mapGroup)
    import('/lua/ui/game/timer.lua').CreateTimerDialog(mapGroup)
    import('/lua/ui/game/consoleecho.lua').CreateConsoleEcho(mapGroup)
    import('/lua/ui/game/build_templates.lua').Init()
    import('/lua/ui/game/taunt.lua').Init()
    
    import('/lua/ui/game/chat.lua').SetupChatLayout(windowGroup)
    import('/lua/ui/game/minimap.lua').CreateMinimap(windowGroup)
    
    -- this feature from GAZ UI - SCU Manager
    import('/lua/gaz_ui/modules/scumanager.lua').Init()
   	import('/lua/gaz_ui/modules/keymapping.lua').Init()

	-- this feature comes from BO Unleashed all credit to original author
	import('/lua/spreadattack.lua').Init()	

    if GetNumRootFrames() > 1 then
        import('/lua/ui/game/multihead.lua').CreateSecondView()
    end

    controlClusterGroup.HandleEvent = function(self, event)
        if event.Type == "WheelRotation" then
            import('/lua/ui/game/worldview.lua').ForwardMouseWheelInput(event)
            return true
        end
        return false
    end

    statusClusterGroup.HandleEvent = function(self, event)
        if event.Type == "WheelRotation" then
            import('/lua/ui/game/worldview.lua').ForwardMouseWheelInput(event)
            return true
        end
        return false
    end
    
    Prefetcher:Update(prefetchTable)
	
	-- from All Your Voice mod
	local keyMap = import('/lua/keymap/defaultKeyMap.lua')
	
	IN_AddKeyMapTable(keyMap.AYVModKeyMap)
	
	ForkThread(UnitEventAlerts)

	UnitEventAlerts = function()
    
        local PlayVoice = PlayVoice
        local WaitTicks = WaitTicks

        local FogOfWar = SessionGetScenarioInfo().Options.FogOfWar

        local last_vo, Text	

		while true do
		
			if UnitData.VOs then
			
				last_vo = false			
				
				for _,vo in pairs(UnitData.VOs) do
                
                    Text = vo.Text or false
			
					-- we always show the visual ping if it's turned on and fog of war is turned on -- 
					if Text != "EnemyUnitDetected" or (Text == "EnemyUnitDetected" and FogOfWar != 'none') then
						
						if vo.Marker and GetOption('vo_VisualAlertsMode') != 0 then
							Ping(vo.Marker.type, vo.Marker.position)
							LastAlertPos = vo.Marker.position
						end
						
						-- if this is a new audio cue --
						if GetOption('vo_'..Text) != false and last_vo != vo.Cue then
						
							PlayVoice(Sound{Bank = vo.Bank, Cue = vo.Cue}, true)

							-- note which cue we are playing
							last_vo = vo.Cue
							
						end
						
					end
					
				end
				
				UnitData.VOs = {}

			end
			
			WaitTicks(15)
			
		end
		
	end
	
	GoToLastAlert = function()
	
		if LastAlertPos then
		
			OriginalPos = GetCamera("WorldCamera"):SaveSettings()
			
			ForkThread(function()
			
				local cam = GetCamera("WorldCamera")
				local saved = cam:SaveSettings()
				local position = LastAlertPos
				local zoom = GetOption('alertcam_zoom')
				local closehpr = Vector(saved.Heading , 0.9, 0)
				local time = GetOption('alertcam_time') + 0.1
				local mode = GetOption('alertcam_mode')
				
				if mode == 1 then
				
					local dpos = {}
					
					for i,x in pairs(position) do
						LOUDINSERT(dpos, position[i] - 2 * saved.Focus[i])
					end
					
					WARN(repr(saved.Focus))
					WARN(repr(dpos))
					WARN(repr(position))
					
					local farhpr = Vector(saved.Heading , 1.5, 0)
					--cam:Reset()
					local mapview = cam:SaveSettings()
					--WARN(repr(mapview))
					--local farhpr = Vector(mapview.Heading , mapview.Pitch, 0)
					cam:MoveTo(dpos, farhpr, 350, time)
					WaitTicks(time * 10)
				end
				
				if mode == 5 then
				
					cam:Reset()
					WaitTicks(5)
				end 
				
				if mode == 1 or mode == 2 or mode == 5 then
					cam:MoveTo(position, closehpr, zoom, time)
				elseif mode == 3 then
					cam:SnapTo(position, closehpr, zoom)
				elseif mode == 4 then
					cam:Reset()
				end
				
				cam:EnableEaseInOut()
			end)
			
		end
		
	end

	GoBackToAction = function()
	
		local cam = GetCamera("WorldCamera")
		
		if OriginalPos then
		
			cam:RestoreSettings(OriginalPos)
			
		end
		
	end
    
    if options.gui_render_enemy_lifebars == 1 or options.gui_render_custom_names == 0 then
        import('/lua/gaz_ui/modules/console_commands.lua').Init()
    end

end
	

local provider = false

local function LoadDialog(parent)

    local movieFile = '/movies/UEF_load.sfd'
    local color = 'FFbadbdb'
    local loadingPref = Prefs.GetFromCurrentProfile('LoadingFaction')
    local factions = import('/lua/factions.lua').Factions
	
    if factions[loadingPref] and factions[loadingPref].loadingMovie then
        movieFile = factions[loadingPref].loadingMovie
        color = factions[loadingPref].loadingColor
    end
    
    local movie = Movie(parent, movieFile)
    LayoutHelpers.FillParent(movie, parent)
    movie:Loop(true)
    movie:Play()

    local text = '::  GET LOUD!  ::'
    local textControl = UIUtil.CreateText(movie, text, 28, UIUtil.bodyFont)
    textControl:SetColor(color)
    LayoutHelpers.AtCenterIn(textControl, parent, 200)
    import('/lua/maui/effecthelpers.lua').Pulse(textControl, 1, 0, .8)

    ConExecute('UI_RenderUnitBars true')
    ConExecute('UI_NisRenderIcons true')
    ConExecute('ren_SelectBoxes true')

    HideGameUI('off')

    return movie
end

function CreateWldUIProvider()

    provider = WldUIProvider()

    local loadingDialog = false
    local frame1Logo = false

    local lastTime = 0

    provider.StartLoadingDialog = function(self)
	
		GetCursor():Hide()
		
		supressExitDialog = true
		
        if not loadingDialog then
		
            self.loadingDialog = LoadDialog(GetFrame(0))
			
            if GetNumRootFrames() > 1 then
			
                local frame1 = GetFrame(1)
                local frame1Logo = Bitmap(frame1, UIUtil.UIFile('/marketing/splash.dds'))
				
                LayoutHelpers.FillParent(frame1Logo, frame1)
				
            end
			
        end
		
    end

    provider.UpdateLoadingDialog = function(self, elapsedTime)
	
        if loadingDialog then
        end
    end

    provider.StopLoadingDialog = function(self)
	
        local function InitialAnimations()
		
            import('/lua/ui/game/tabs.lua').InitialAnimation()
			
            WaitSeconds(.15)
			
            Economy.InitialAnimation()
            import('/lua/ui/game/score.lua').InitialAnimation()
			
            WaitSeconds(.15)
			
            import('/lua/ui/game/multifunction.lua').InitialAnimation()
            import('/lua/ui/game/avatars.lua').InitialAnimation()
            import('/lua/ui/game/controlgroups.lua').InitialAnimation()
			
            WaitSeconds(.15)
			
            HideGameUI('off')
        end
		
        local loadingPref = Prefs.GetFromCurrentProfile('LoadingFaction')
        local factions = import('/lua/factions.lua').Factions
        local texture = '/UEF_load.dds'
        local color = 'FFbadbdb'
		
        if factions[loadingPref] and factions[loadingPref].loadingTexture then
            texture = factions[loadingPref].loadingTexture
            color = factions[loadingPref].loadingColor
        end
		
		GetCursor():Show()
		
        local background = Bitmap(GetFrame(0), UIUtil.UIFile(texture))
		
        LayoutHelpers.FillParent(background, GetFrame(0))
		
        background.Depth:Set(200)
        background:SetNeedsFrameUpdate(true)
        background.time = 0
		
        background.OnFrame = function(self, delta)
		
            self.time = self.time + delta
			
            if self.time > 1.5 then
			
                local newAlpha = self:GetAlpha() - (delta/2)
				
                if newAlpha < 0 then
				
                    newAlpha = 0
                    self:Destroy()

                    ForkThread(InitialAnimations)
					
                end
				
                self:SetAlpha(newAlpha, true)
				
            end
			
        end
		
        local text = '::  GET LOUD!  ::'
        local textControl = UIUtil.CreateText(background, text, 20, UIUtil.bodyFont)
		
        textControl:SetColor(color)
        LayoutHelpers.AtCenterIn(textControl, GetFrame(0), 200)
		
        FlushEvents()
		
    end

    provider.StartWaitingDialog = function(self)
	
        if not waitingDialog then
			waitingDialog = UIUtil.ShowInfoDialog(GetFrame(0), "Waiting For Other Players...")
		end
		
    end

    provider.UpdateWaitingDialog = function(self, elapsedTime)
        -- currently no function, but could animate waiting dialog
    end

    provider.StopWaitingDialog = function(self)
	
        if waitingDialog then
		
            waitingDialog:Destroy()
            waitingDialog = false
			
        end
		
        FlushEvents()
		
    end

    provider.CreateGameInterface = function(self, inIsReplay)
	
        isReplay = inIsReplay
		
        if frame1Logo then
            frame1Logo:Destroy()
            frame1Logo = false
        end
		
        CreateUI(isReplay)
		
        HideGameUI('on')
		
		supressExitDialog = false
		
        FlushEvents()
		
    end

    provider.DestroyGameInterface = function(self)
	
        if gameParent then
			gameParent:Destroy()
		end
		
        for _, func in OnDestroyFuncs do
            func()
        end
		
        import('rallypoint.lua').ClearAllRallyPoints()
		
    end

    provider.GetPrefetchTextures = function(self)
	
        return import('/lua/ui/game/prefetchtextures.lua').prefetchTextures        
		
    end

end

function AddOnUIDestroyedFunction(func)

    LOUDINSERT(OnDestroyFuncs, func)
	
end

-- This function is called whenever the set of currently selected units changes
-- See /lua/unit.lua for more information on the lua unit object
--      oldSelection: What the selection was before
--      newSelection: What the selection is now
--      added: Which units were added to the old selection
--      removed: Which units where removed from the old selection
function OnSelectionChanged(oldSelection, newSelection, added, removed)

    -- Interface option: don't allow air units to get selected alongside land
    if options.land_unit_select_prio == 1 and not IsKeyDown('Shift') then

        local selectedLand = false
        local selectedAir = false

        -- First check if any land units were selected
        for _, unit in newSelection do
            if unit:IsInCategory('LAND') then
                selectedLand = true
            end
            if unit:IsInCategory('AIR') then
                selectedAir = true
            end
        end

        -- If a land unit is in this selection, trim off air
        if selectedLand and selectedAir then

            local temp = {}

            for _, unit in newSelection do
                if unit:IsInCategory('LAND') then
                    LOUDINSERT(temp, unit)
                end
            end

            newSelection = temp

            ForkThread(function() SelectUnits(newSelection) import('/lua/ui/game/selection.lua').PlaySelectionSound(newSelection) end)

            return
        end
    end

    local availableOrders, availableToggles, buildableCategories = GetUnitCommandData(newSelection)

    local isOldSelection = table.equal(oldSelection, newSelection)

    if not gameUIHidden then
	
        if not isReplay then
		
            import('/lua/ui/game/orders.lua').SetAvailableOrders(availableOrders, availableToggles, newSelection)
			
        end
		
        -- todo change the current command mode if no longer available? or set to nil?
        import('/lua/ui/game/construction.lua').OnSelection(buildableCategories,newSelection,isOldSelection)
		
    end

    if not isOldSelection then
	
        import('/lua/ui/game/selection.lua').PlaySelectionSound(added)
        import('/lua/ui/game/rallypoint.lua').OnSelectionChanged(newSelection)
		
    end
	
	local selUnits = newSelection

    if selUnits and table.getn(selUnits) == 1
    and import('/lua/gaz_ui/modules/selectedinfo.lua').SelectedOverlayOn then
    
        import('/lua/gaz_ui/modules/selectedinfo.lua').ActivateSingleRangeOverlay()
        
    else
		import('/lua/gaz_ui/modules/selectedinfo.lua').DeactivateSingleRangeOverlay()
        
	end 

end

function OnQueueChanged(newQueue)

    if not gameUIHidden then
	
        import('/lua/ui/game/construction.lua').OnQueueChanged(newQueue)
		
    end
	
end

-- Called after the Sim has confirmed the game is indeed paused. This will happen
-- on everyone's machine in a network game.
function OnPause(pausedBy, timeoutsRemaining)

    local isOwner = false
	
    if pausedBy == SessionGetLocalCommandSource() then
        isOwner = true
    end
	
    PauseSound("World",true)
    PauseVoice("VO",true)
	
    import('/lua/ui/game/tabs.lua').OnPause(true, pausedBy, timeoutsRemaining, isOwner)
    MissionText.OnGamePause(true)
	
end

-- Called after the Sim has confirmed that the game has resumed.
function OnResume()

    PauseSound("World",false)
    PauseVoice("VO",false)
	
    import('/lua/ui/game/tabs.lua').OnPause(false)
    MissionText.OnGamePause(false)
	
end

-- Called immediately when the user hits the pause button. This only ever gets
-- called on the machine that initiated the pause (i.e. other network players
-- won't call this)

function OnUserPause(pause)

    local Tabs = import('/lua/ui/game/tabs.lua')
    local focus = GetArmiesTable().focusArmy
	
    if Tabs.CanUserPause() then
	
        if focus == -1 and not SessionIsReplay() then
            return
        end

        if pause then
            MissionText.PauseTransmission()
        else
            MissionText.ResumeTransmission()
        end
		
    end
	
end

local _beatFunctions = {}

function AddBeatFunction(fn)

    LOUDINSERT(_beatFunctions, fn)
	
end

function RemoveBeatFunction(fn)

    for i,v in _beatFunctions do
	
        if v == fn then
		
            LOUDREMOVE(_beatFunctions, i)
            break
			
        end
		
    end
	
end

-- this function is called whenever the sim beats
function OnBeat()

    for i,v in _beatFunctions do
        if v then v() end
    end
	
end

function GetStatusCluster()

    return statusClusterGroup
	
end

function GetControlCluster()

    return controlClusterGroup
	
end

function GetGameParent()

    return gameParent
	
end

function HideGameUI(state)

	if gameParent then
	
		if gameUIHidden or state == 'off' then
		
			gameUIHidden = false
			
			controlClusterGroup:Show()
			statusClusterGroup:Show()
			
			import('/lua/ui/game/worldview.lua').Contract()
			import('/lua/ui/game/borders.lua').HideBorder(false)
			-- Set by Tanksy to fix the issue of the rollover stats showing with no data at the start of a game.
			-- UnitViewDetail.Expand()
			import('/lua/ui/game/unitview.lua').Expand()
			import('/lua/ui/game/avatars.lua').Expand()
			Economy.Expand()
			import('/lua/ui/game/score.lua').Expand()
			import('/lua/ui/game/objectives2.lua').Expand()
			import('/lua/ui/game/multifunction.lua').Expand()
			import('/lua/ui/game/controlgroups.lua').Expand()
			import('/lua/ui/game/tabs.lua').Expand()
			import('/lua/ui/game/announcement.lua').Expand()
			import('/lua/ui/game/minimap.lua').Expand()
			import('/lua/ui/game/construction.lua').Expand()
			
			if not SessionIsReplay() then
				import('/lua/ui/game/orders.lua').Expand()
			end
			
		else
		
			gameUIHidden = true
			
			controlClusterGroup:Hide()
			statusClusterGroup:Hide()
			
			import('/lua/ui/game/worldview.lua').Expand()
			import('/lua/ui/game/borders.lua').HideBorder(true)
			import('/lua/ui/game/unitview.lua').Contract()
			UnitViewDetail.Contract()
			import('/lua/ui/game/avatars.lua').Contract()
			Economy.Contract()
			import('/lua/ui/game/score.lua').Contract()
			import('/lua/ui/game/objectives2.lua').Contract()
			import('/lua/ui/game/multifunction.lua').Contract()
			import('/lua/ui/game/controlgroups.lua').Contract()
			import('/lua/ui/game/tabs.lua').Contract()
			import('/lua/ui/game/announcement.lua').Contract()
			import('/lua/ui/game/minimap.lua').Contract()
			import('/lua/ui/game/construction.lua').Contract()
			
			if not SessionIsReplay() then
				import('/lua/ui/game/orders.lua').Contract()
			end
		end
	end
end

-- Given a userunit that is adjacent to a given blueprint, does it yield a
-- bonus? Used by the UI to draw extra info
function OnDetectAdjacencyBonus(userUnit, otherBp)
    -- fixme: todo
    return true
end

function OnFocusArmyUnitDamaged(unit)
    import('/lua/UserMusic.lua').NotifyBattle()
end

local NISControls = { barTop = false, barBot = false }

local rangePrefs = { range_RenderHighlighted = false, range_RenderSelected = false, range_RenderHighlighted = false }

local preNISSettings = {}

function NISMode(state)

    NISActive = state
	
    local worldView = import("/lua/ui/game/worldview.lua")
	
    if state == 'on' then
	
        import('/lua/ui/dialogs/saveload.lua').OnNISBegin()
        import('/lua/ui/dialogs/options.lua').OnNISBegin()
        import('/lua/ui/game/consoleecho.lua').ToggleOutput(false)
        import('/lua/ui/game/multifunction.lua').PreNIS()
        import('/lua/ui/game/tooltip.lua').DestroyMouseoverDisplay()
        import('/lua/ui/game/chat.lua').OnNISBegin()
        UnitViewDetail.OnNIS()
		
        HideGameUI(state)
		
        ShowNISBars()
		
        if worldView.viewRight then
            import("/lua/ui/game/borders.lua").SplitMapGroup(false, true)
            preNISSettings.restoreSplitScreen = true
        else
            preNISSettings.restoreSplitScreen = false
        end
		
        preNISSettings.Resources = worldView.viewLeft:IsResourceRenderingEnabled()
        preNISSettings.Cartographic = worldView.viewLeft:IsCartographic()
        worldView.viewLeft:EnableResourceRendering(false)
        worldView.viewLeft:SetCartographic(false)
		
        ConExecute('UI_RenderUnitBars false')
        ConExecute('UI_NisRenderIcons false')
        ConExecute('ren_SelectBoxes false')
		
        for i, v in rangePrefs do
            ConExecute(i..' false')
        end
		
        preNISSettings.gameSpeed = GetGameSpeed()
		
        if preNISSettings.gameSpeed != 0 then
            SetGameSpeed(0)
        end
		
        preNISSettings.Units = GetSelectedUnits()
        SelectUnits({})
        RenderOverlayEconomy(false)
		
    else
	
        import('/lua/ui/game/worldview.lua').UnlockInput()
        import('/lua/ui/game/multifunction.lua').PostNIS()
		
        HideGameUI(state)
        HideNISBars()
		
        if preNISSettings.restoreSplitScreen then
            import("/lua/ui/game/borders.lua").SplitMapGroup(true, true)
        end
		
        worldView.viewLeft:EnableResourceRendering(preNISSettings.Resources)
        worldView.viewLeft:SetCartographic(preNISSettings.Cartographic)
		
        -- Todo: Restore settings of overlays, lifebars properly
        ConExecute('UI_RenderUnitBars true')
        ConExecute('UI_NisRenderIcons true')
        ConExecute('ren_SelectBoxes true')
		
        for i, v in rangePrefs do
            if Prefs.GetFromCurrentProfile(i) == nil then
                ConExecute(i..' true')
            else
                ConExecute(i..' '..tostring(Prefs.GetFromCurrentProfile(i)))
            end
        end
		
        if GetGameSpeed() != preNISSettings.gameSpeed then
            SetGameSpeed(preNISSettings.gameSpeed)
        end
		
        SelectUnits(preNISSettings.Units)
        import('/lua/ui/game/consoleecho.lua').ToggleOutput(true)
    end
	
    MissionText.SetLayout()
end

function ShowNISBars()

    if not NISControls.barTop then
        NISControls.barTop = Bitmap(GetFrame(0))
    end
	
    NISControls.barTop:SetSolidColor('ff000000')
    NISControls.barTop.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    NISControls.barTop.Left:Set(function() return GetFrame(0).Left() end)
    NISControls.barTop.Right:Set(function() return GetFrame(0).Right() end)
    NISControls.barTop.Top:Set(function() return GetFrame(0).Top() end)
    NISControls.barTop.Height:Set(1)
    
    if not NISControls.barBot then
        NISControls.barBot = Bitmap(GetFrame(0))
    end
    NISControls.barBot:SetSolidColor('ff000000')
    NISControls.barBot.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    NISControls.barBot.Left:Set(function() return GetFrame(0).Left() end)
    NISControls.barBot.Right:Set(function() return GetFrame(0).Right() end)
    NISControls.barBot.Bottom:Set(function() return GetFrame(0).Bottom() end)
    NISControls.barBot.Height:Set(NISControls.barTop.Height)
    
    NISControls.barTop:SetNeedsFrameUpdate(true)
	
    NISControls.barTop.OnFrame = function(self, delta)
        if delta then
            if self.Height() > GetFrame(0).Height() / 10 then
                self:SetNeedsFrameUpdate(false)
            else
                local curHeight = self.Height()
                self.Height:Set(function() return curHeight * 1.25 end)
            end
        end
    end
end

function IsNISMode()

    if NISActive == 'on' then
        return true
    else
        return false
    end
end

function HideNISBars()

    NISControls.barTop:SetNeedsFrameUpdate(true)
	
    NISControls.barTop.OnFrame = function(self, delta)
        if delta then
            local newAlpha = self:GetAlpha()*.8
            if newAlpha < .1 then
                NISControls.barBot:Destroy()
                NISControls.barBot = false
                NISControls.barTop:Destroy()
                NISControls.barTop = false
            else
                NISControls.barTop:SetAlpha(newAlpha)
                NISControls.barBot:SetAlpha(newAlpha)
            end
        end
    end
end

local chatFuncs = {}

function RegisterChatFunc(func, dataTag)
    LOUDINSERT(chatFuncs, {id = dataTag, func = func})
end

function ReceiveChat(sender, data)
    for i, chatFuncEntry in chatFuncs do
        if data[chatFuncEntry.id] then
            chatFuncEntry.func(sender, data)
        end
    end
end

autoSaveGameThread = false
autoSaveGameIntervalInMinutes = import('/lua/user/prefs.lua').GetFromCurrentProfile("options").auto_save_game_interval_in_minutes or 0

function SetAutoSaveGameIntervalInMinutes(value)
    if autoSaveGameIntervalInMinutes != value then
        LOG ("AutoSaveGame set to new interval of " .. value .. " minute(s)")
        autoSaveGameIntervalInMinutes = value
        InitAutoSaveGame()
    end
end

function InitAutoSaveGame()
    if autoSaveGameThread then
        LOG ("AutoSaveGame stopped")
        KillThread(autoSaveGameThread)
    end

    if IsQuickSaveAvailable() and autoSaveGameIntervalInMinutes > 0 then
        autoSaveGameThread = ForkThread(
            function()
                LOG ("AutoSaveGame started with interval of " .. autoSaveGameIntervalInMinutes .. " minute(s)")

                local intervalInSeconds = autoSaveGameIntervalInMinutes * 60
                local saveSlotIndex = 0
                while IsQuickSaveAvailable() do
                    WaitSeconds(intervalInSeconds)
                    QuickSave("AutoSave" .. (saveSlotIndex + 1))
                    saveSlotIndex = math.mod(saveSlotIndex + 1, 3)
                end

                LOG ("AutoSaveGame finished")
            end
        )
    end
end

function IsQuickSaveAvailable()
    return SessionIsActive() and WorldIsPlaying() and not SessionIsGameOver() and 
            not SessionIsMultiplayer() and not SessionIsReplay() and not IsNISMode()
end

function QuickSave(filename)

    if IsQuickSaveAvailable() then

        local saveType = "SaveGame"
        local path = GetSpecialFilePath(Prefs.GetCurrentProfile().Name, filename, saveType)
        local statusStr = "Quick Save in progress..."
        local status = UIUtil.ShowInfoDialog(GetFrame(0), statusStr)

        InternalSaveGame(path, filename, function(worked, errmsg)
            status:Destroy()

            if not worked then
                infoStr = "Save failed! " .. errmsg
                UIUtil.ShowInfoDialog(GetFrame(0), infoStr, "Ok")
            end
        end)
    end
end

defaultZoom = 1.4

function SimChangeCameraZoom(newMult)

    if IsQuickSaveAvailable then
       
        defaultZoom = newMult
        local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
        for _, viewControl in views do
            if viewControl._cameraName != 'MiniMap' then
                GetCamera(viewControl._cameraName):SetMaxZoomMult(newMult)
            end
        end
    end
end

UnitEventAlerts = function()

    local PlayVoice = PlayVoice
    local WaitTicks = WaitTicks
    
    local FogOfWar = SessionGetScenarioInfo().Options.FogOfWar
    local Text

    while true do
    
        if UnitData.VOs[1] then
            
            for _,vo in pairs(UnitData.VOs) do
            
                Text = vo.Text or false
                
                if Text != "EnemyUnitDetected" or (Text == "EnemyUnitDetected" and FogOfWar != 'none') then
                    
                    if vo.Marker and GetOption('vo_VisualAlertsMode') != 0 then
                        Ping(vo.Marker.type, vo.Marker.position)
                        LastAlertPos = vo.Marker.position
                    end

                    if Text and GetOption('vo_'..Text) != false then
                        PlayVoice(Sound{Bank = vo.Bank, Cue = vo.Cue}, true)
                    end

                end

            end

            UnitData.VOs = {}
            
        end
        
        WaitTicks(11)
        
    end
    
end

GoToLastAlert = function()

    if LastAlertPos then
    
        OriginalPos = GetCamera("WorldCamera"):SaveSettings()
        
        ForkThread(function()
            local cam = GetCamera("WorldCamera")
            local saved = cam:SaveSettings()
            local position = LastAlertPos
            local zoom = GetOption('alertcam_zoom')
            local closehpr = Vector(saved.Heading , 0.9, 0)
            local time = GetOption('alertcam_time') + 0.1
            local mode = GetOption('alertcam_mode')
            if mode == 1 then
                local dpos = {}
                for i,x in pairs(position) do
                    LOUDINSERT(dpos, position[i] - 2 * saved.Focus[i])
                end
                WARN(repr(saved.Focus))
                WARN(repr(dpos))
                WARN(repr(position))
                local farhpr = Vector(saved.Heading , 1.5, 0)
                --cam:Reset()
                local mapview = cam:SaveSettings()
                --WARN(repr(mapview))
                --local farhpr = Vector(mapview.Heading , mapview.Pitch, 0)
                cam:MoveTo(dpos, farhpr, 350, time)
                WaitTicks(time * 10)
            end
            if mode == 5 then
                cam:Reset()
                WaitTicks(5)
            end 
            if mode == 1 or mode == 2 or mode == 5 then
                cam:MoveTo(position, closehpr, zoom, time)
            elseif mode == 3 then
                cam:SnapTo(position, closehpr, zoom)
            elseif mode == 4 then
                cam:Reset()
            end
            cam:EnableEaseInOut()
        end)
    end
end

GoBackToAction = function()
    local cam = GetCamera("WorldCamera")
    
    if OriginalPos then
        cam:RestoreSettings(OriginalPos)
    end
end
	
function AreaReclaim()
    local mousePos = GetMouseWorldPos()
    local units = GetSelectedUnits()
    
    if not units[1] then return end
    
    local simCallback = { Func = 'AreaReclaim', Args = { MousePos = mousePos, Size = options.area_reclaim_size }}

    SimCallback(simCallback, true)
end

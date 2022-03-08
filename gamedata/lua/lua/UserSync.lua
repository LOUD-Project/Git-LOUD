LOG("*AI DEBUG Loading LOUD UserSync ")

-- The global sync table is copied from the sim layer every time the main and sim threads are
-- synchronized on the sim beat (which is like a tick but happens even when the game is paused)
Sync = {}

-- The PreviousSync table holds just what you'd expect it to, the sync table from the previous beat.
PreviousSync = {}

-- Unit specific data that's been sync'd. Data changes are accumulated by merging
-- the Sync.UnitData table into this table each sync (if there's new data)
UnitData = {}

scoreData = { ['current'] = {} }

local tmerge = table.merged
local tempty = table.empty
local dcopy = table.deepcopy

--local IsHeadPlaying = import('/lua/ui/game/missiontext.lua').IsHeadPlaying

local Dialogue = import('/lua/ui/game/simdialogue.lua')
local GameMain = import('/lua/ui/game/gamemain.lua')

local Ping = import('/lua/ui/game/ping.lua')
local Prefs = import('/lua/user/prefs.lua')

local PlaySound = moho.entity_methods.PlaySound

local CurrentSimSpeed = 0	-- record the current sim speed rate and use this to detect a change

-- Here's an opportunity for user side script to examine the Sync table for the new tick
function OnSync()

    if Sync.ProfilerData then 
        import("/lua/ui/game/Profiler.lua").ReceiveData(Sync.ProfilerData)
    end

    if Sync.Benchmarks then 
        import("/lua/ui/game/Profiler.lua").ReceiveBenchmarks(Sync.Benchmarks)
    end

    if Sync.BenchmarkOutput then 
        import("/lua/ui/game/Profiler.lua").ReceiveBenchmarkOutput(Sync.BenchmarkOutput)
    end

    if not tempty(Sync.CameraRequests) then
        import('/lua/UserCamera.lua').ProcessCameraRequests(Sync.CameraRequests)
    end

    if Sync.RequestingExit then
        ExitGame()
    end

	if Sync.SimData then
	
		-- if the sim rate has changed 
		if GetSimRate() != CurrentSimSpeed then
		
			local newspeed = GetSimRate()
			
			-- this creates a callback to the SIM
			SendSimSpeed(newspeed)
			
			CurrentSimSpeed = newspeed
		end
	end

    if Sync.ToggleGamePanels then
        ConExecute('UI_ToggleGamePanels')
    end

    if Sync.ToggleLifeBarsOff then
        ConExecute('UI_RenderUnitBars false')
    end

    if Sync.ToggleLifeBarsOn then
        ConExecute('UI_RenderUnitBars true')
    end
	
	if Sync.AIChat then
		for _, v in Sync.AIChat do
			import('/lua/aichatsorian.lua').AIChat(v.group, v.text, v.sender)
		end
		Sync.AiChat = nil
	end
    
    if Sync.AIDebug then
    
        LOG("*AI DEBUG Sync AIDEBUG data ")
        
        Sync.AIDebug = nil
    end
	
    if Sync.UserConRequests then
        for _, v in Sync.UserConRequests do
            ConExecute( v )
        end
    end
	
	if Sync.UnitData then
		UnitData = tmerge( UnitData, Sync.UnitData )
		Sync.UnitData = nil
	end
    
    for id,v in Sync.ReleaseIds do
        UnitData[id] = nil
    end
	
	Sync.ReleaseIds = {}

    if Sync.FocusArmyChanged then
	
        import('/lua/ui/game/avatars.lua').FocusArmyChanged()
        import('/lua/ui/game/multifunction.lua').FocusArmyChanged()
    end

    if Sync.UserUnitEnhancements then
	
        import('/lua/enhancementcommon.lua').SetEnhancementTable(Sync.UserUnitEnhancements)
    end

    if not tempty(Sync.Voice) then      --and not IsHeadPlaying() then
	
        for k, v in Sync.Voice do
            PlayVoice(Sound{ Bank=v.Bank, Cue=v.Cue }, true)
        end
    end

    if Sync.EnhanceRestrict then
        import('/lua/enhancementcommon.lua').RestrictList( Sync.EnhanceRestrict )
    end

    if Sync.HelpPrompt then
        import('/lua/ui/game/helptext.lua').AddHelpTextPrompt(Sync.HelpPrompt)
    end

    if Sync.MPTaunt then
	
        local msg = {}
        msg.tauntid = Sync.MPTaunt[1]
        msg.taunthead = Sync.MPTaunt[2]
        SessionSendChatMessage(msg)
    end
    
    if Sync.Ping then
        Ping.DisplayPing(Sync.Ping)
    end
    
    if Sync.MaxPingMarkers then
        Ping.MaxMarkers = Sync.MaxPingMarkers
    end

	-- update the scoreboard if the data has been accumulated
    if Sync.FullScoreSync then
	
        scoreData.current = dcopy(Sync.Score)
		Sync.FullScoreSync = false
    end

	if not tempty(Sync.GameResult) then
	
		for k,gameResult in Sync.GameResult do
		
			local armyIndex, result = unpack(gameResult)
			
			import('/lua/ui/game/gameresult.lua').DoGameResult(armyIndex, result)
		end
	end

    if Sync.PausedBy then
	
        if not PreviousSync.PausedBy then
            GameMain.OnPause(Sync.PausedBy, Sync.TimeoutsRemaining)
        end

    else
	
        if PreviousSync.PausedBy then
            GameMain.OnResume()
        end
    end

    if Sync.Paused != PreviousSync.Paused then
        GameMain.OnPause(Sync.Paused);
    end
	
    if Sync.Cheaters then
	
		if GetGameTimeSeconds() > 15 then
		
			local names = ''
			local isare = LOC('<LOC cheating_fragment_0000>is')
			local srcs = SessionGetCommandSourceNames()
		
			for k,v in ipairs(Sync.Cheaters) do
				if names != '' then
					names = names .. ', '
					isare = LOC('<LOC cheating_fragment_0001>are')
				end
				names = names .. (srcs[v] or '???')
			end
			
			if names != 'TESTLOUD' then
		
				local msg = names .. ' ' .. isare
		
				if Sync.Cheaters.CheatsEnabled then
					msg = msg .. LOC('<LOC cheating_fragment_0002> cheating!')
				else
					msg = msg .. LOC('<LOC cheating_fragment_0003> trying to cheat!')
				end
			
				LOG("*AI DEBUG CHEATING "..msg)
			
				print(msg)
			end
		end
		
    end
    
    if Sync.DiplomacyAction then
        import('/lua/ui/game/diplomacy.lua').ActionHandler(Sync.DiplomacyAction)
    end
    
    if Sync.DiplomacyAnnouncement then
        import('/lua/ui/game/diplomacy.lua').AnnouncementHandler(Sync.DiplomacyAnnouncement)
    end
    
    if Sync.PrintText then
    
        for _, textData in Sync.PrintText do
        
            local data = textData
            if type(Sync.PrintText) == 'string' then
                data = {text = Sync.PrintText, size = 14, color = 'ffffffff', duration = 5, location = 'center'}
            end
            
            import('/lua/ui/game/textdisplay.lua').PrintToScreen(data)
        end
    end
    
    if Sync.FloatingEntityText then
        for _, textData in Sync.FloatingEntityText do
            import('/lua/ui/game/unittext.lua').FloatingEntityText(textData)
        end
    end
    
    if Sync.StartCountdown then
        for _, textData in Sync.StartCountdown do
            import('/lua/ui/game/unittext.lua').StartCountdown(textData)
        end
    end
    
    if Sync.CancelCountdown then
        for _, textData in Sync.CancelCountdown do
            import('/lua/ui/game/unittext.lua').CancelCountdown(textData)
        end
    end

    if Sync.AddPingGroups then
        import('/lua/ui/game/objectives2.lua').AddPingGroups(Sync.AddPingGroups)
    end
    
    if Sync.RemovePingGroups then
        import('/lua/ui/game/objectives2.lua').RemovePingGroups(Sync.RemovePingGroups)
    end
    
    if Sync.SetAlliedVictory != nil then
        import('/lua/ui/game/diplomacy.lua').SetAlliedVictory(Sync.SetAlliedVictory)
    end
    
    if Sync.HighlightUIPanel then
        import('/lua/ui/game/tutorial.lua').HighlightPanels(Sync.HighlightUIPanel)
    end
	
    if Sync.SetButtonDisabled then
        Dialogue.SetButtonDisabled(Sync.SetButtonDisabled)
    end
    
    if Sync.UpdatePosition then
        Dialogue.UpdatePosition(Sync.UpdatePosition)
    end
    
    if Sync.UpdateButtonText then
        Dialogue.UpdateButtonText(Sync.UpdateButtonText)
    end
    
    if Sync.SetDialogueText then
        Dialogue.SetDialogueText(Sync.SetDialogueText)
    end
    
    if Sync.DestroyDialogue then
        Dialogue.DestroyDialogue(Sync.DestroyDialogue)
    end

    if Sync.IsSavedGame == true then
        GameMain.IsSavedGame = true
    end

    if Sync.ChangeCameraZoom != nil then
        GameMain.SimChangeCameraZoom(Sync.ChangeCameraZoom)
    end
    
--[[
    
    if Sync.RequestPlayerFaction then
		LOG("*AI DEBUG Request player faction")
        import('/lua/ui/game/factionselect.lua').RequestPlayerFaction()
    end

    -- from DMS --
	if Sync.PlayMFDMovieMP then
        --import('/lua/ui/game/missiontext.lua').PlayMFDMovieMP(Sync.PlayMFDMovieMP.Params, Sync.VideoText)
		--import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').PlayMFDMovieMP(Sync.PlayMFDMovieMP.Params, Sync.VideoText)

		--if Sync.PlayMFDMovieMP.Lengh and Sync.PlayMFDMovieMP.Lengh > 0 then
			--import('/lua/ui/game/missiontext.lua').CloseMFDMovie(Sync.PlayMFDMovieMP.Params, Sync.PlayMFDMovieMP.Lengh)
			--import('/mods/Domino_Mod_Support/lua/mfd_video/play_video.lua').CloseMFDMovie(Sync.PlayMFDMovieMP.Params, Sync.PlayMFDMovieMP.Lengh)
		--end
	end
    
	-- this is only for voice overs not unit sounds
	
	if Sync.Sounds then
		for _,v in Sync.Sounds do
			LOG("*AI DEBUG Sync Sound "..repr(v.Cue))
			PlaySound(Sound{ Bank=v.Bank, Cue=v.Cue })
		end
		Sync.Sounds = nil
	end
    
--]]
    
end

function UpdateSimSpeed(data)

	Prefs.SetToCurrentProfile('SimSpeed', data)
end

function SaveSimSpeed(name, params)

	local current = Prefs.GetFromCurrentProfile('SimSpeed') or { }
	current.name = params
	
	Prefs.SetToCurrentProfile('SimSpeed', current)
end

function SendSimSpeed()

	SimCallback( { Func = 'NoteSimSpeedChange', Args = GetSimRate() }, true )
end

function SetSimSpeed(name, param)
	
	if name and param then
		SaveSimSpeed(name, param)
		SendSimSpeed()
	end
end
#****************************************************************************
#**
#**  File     :  /lua/scenarioFramework.lua
#**  Author(s): John Comes, Drew Staltman
#**
#**  Summary  : Functions for use in the Operations.
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local SimUIVars = import('/lua/sim/SimUIState.lua')

MfdVideoInfo = {}
local UnitMFDTable = {}
local removetimerstarted = false

local MFDReplayTime = {
    Transport_Full = 4,
    Unit_Cap_Reached = 60,
    Unable_To_Transferre_Unit = 10,
    OnPlayNoStagingPlatformsVO = 5,
    OnPlayBusyStagingPlatformsVO = 5,
    OnCommanderUnderAttackVO = 15,
    ExperimentalDetected = 60,
    ExperimentalUnitDestroyed = 5,
    FerryPointSet = 5,
    CoordinatedAttackInitiated = 5,
    BaseUnderAttack = 30,
    UnderAttack = 60,
    EnemyForcesDetected = 120,
    NukeArmed = 1,
    NuclearLaunchInitiated = 1,
    NuclearLaunchDetected = 1,
    BattleshipDestroyed = 5,
    EnemyNavalForcesDetected = 60,
}

CheckMFD = function(speaker, video, dTable)
	if not UnitMFDTable[speaker:GetEntityId()] then
		UnitMFDTable[speaker:GetEntityId()] = {}
	end
	
	if UnitMFDTable[speaker:GetEntityId()].video then return end
	
	local gametime = GetGameTimeSeconds()
		
	table.insert(MfdVideoInfo.DialogueQueue, dTable)
	if not MfdVideoInfo.DialogueLock then
		MfdVideoInfo.DialogueLock = true
		ForkThread( PlayDialogueMP )
	end
	
end

function DialogueMP(speaker, video, callback, critical)
		
	local speaker = GetEntityById(speaker)
	
	if GetFocusArmy() == speaker:GetArmy() then
		RemoveOldMFDEntry()

		if not UnitMFDTable[speaker:GetEntityId()] then
			UnitMFDTable[speaker:GetEntityId()] = {}
		end
	
		if UnitMFDTable[speaker:GetEntityId()][video] then return end
	
		local canSpeak = true
		if speaker and speaker:IsDead() then
			canSpeak = false
		end
	
		if canSpeak and video then
			local Videos = import('/mods/Domino_Mod_Support/lua/initialize.lua').Custom_Mfd()
			local Fac = speaker:GetBlueprint().General.FactionName
			local faction = string.sub(Fac, 1, 1) .. string.lower(string.sub(Fac, 2, -1))
			local Uservideo = Videos[speaker:GetBlueprint().BlueprintId .. '_' .. video]
			local ValidVid = true
			local Videoset = false
							
			if not Uservideo then 
				ValidVid = false
			end
				
			if ValidVid then 
				if not Uservideo.lengh then 
					Uservideo.lengh = 27
				end
			end
						
			if ValidVid then 			
				if Uservideo.vid then 
					local vid = UIUtil.UIVideo(Uservideo.vid)
				
					if vid then 
						Uservideo.vid = vid
					else
						local Unitvid = UIUtil.UIVideo('/' .. faction .. '/unit_mfd/' .. faction ..'_' .. speaker:GetBlueprint().BlueprintId .. '_mfd.sfd')
				
						if Unitvid then 
							Uservideo.vid = Unitvid
						else
							Uservideo.vid = UIUtil.UIVideo('/' .. faction .. '/unit_mfd/' .. faction ..'_' .. 'default_mfd.sfd')
						end
					end
				else
					local Unitvid = UIUtil.UIVideo('/' .. faction .. '/unit_mfd/' .. faction ..'_' .. speaker:GetBlueprint().BlueprintId .. '_mfd.sfd')
				
					if Unitvid then 
						Uservideo.vid = Unitvid
					else
						Uservideo.vid = UIUtil.UIVideo('/' .. faction .. '/unit_mfd/' .. faction ..'_' .. 'default_mfd.sfd')
					end
				end
			
				if Uservideo.vid then 
					Uservideo.faction = faction
									
					local dTable = table.deepcopy( Uservideo )
		
					if callback then
						dTable.Callback = callback
					end
		
					if critical then
						dTable.Critical = critical
					end
				
					if MfdVideoInfo.DialogueLock == nil then
						MfdVideoInfo.DialogueLock = false
						MfdVideoInfo.DialogueLockPosition = 0
						MfdVideoInfo.DialogueQueue = {}
						MfdVideoInfo.DialogueFinished = {}
					end
			
					--UnitMFDTable[speaker:GetEntityId()][video] = GetGameTimeSeconds()
				
					UnitMFDTable[speaker:GetEntityId()][video] = { starttime = GetGameTimeSeconds(), lengh = Uservideo.lengh }
		
					table.insert(MfdVideoInfo.DialogueQueue, dTable)
					if not MfdVideoInfo.DialogueLock then
						MfdVideoInfo.DialogueLock = true
						ForkThread( PlayDialogueMP )
					end
	
				end
			end
		end
	end
end

function RemoveOldMFDEntry()
	for id, unit in UnitMFDTable do
		for mfd, params in unit do
			local gameTime = GetGameTimeSeconds()
			local EntryTime = params.starttime
			local mfdReplaytime = MFDReplayTime[mfd] or params.lengh or 27
			local removetime = EntryTime + mfdReplaytime
											
			if gameTime > removetime then
				UnitMFDTable[id][mfd] = nil
			end
		end
	end
end

function FlushDialogueQueue()
    if MfdVideoInfo.DialogueQueue then
        for k,v in MfdVideoInfo.DialogueQueue do
            v.Flushed = true
        end
    end
end

## This function sends movie data to the sync table and saves it off for reloading in save games
function SetupMFDSyncMP(movieTable, text)
    DisplayVideoTextMP( text )
	local MovieData = {}
	
	MovieData.Params = {  movieTable.movie[1], movieTable.movie[2], movieTable.movie[3], movieTable.movie[4] }
	MovieData.Lengh = movieTable.lengh
			
	Sync.PlayMFDMovieMP = MovieData
    MfdVideoInfo.DialogueFinished[movieTable.movie[1]] = false

    local tempText = LOC(text)
    local tempData = {}

    local nameStart = string.find(tempText, ']')
    if nameStart != nil then
        tempData.name = LOC("<LOC "..string.sub(tempText, 2, nameStart-1)..">")
        tempData.text = string.sub(tempText, nameStart+2)
    else
        tempData.name = "INVALID NAME"
        tempData.text = tempText
        LOG("ERROR: Unable to find name in string: " .. text .. " (" .. tempText .. ")")
    end

    local timeSecs = GetGameTimeSeconds()
    tempData.time = string.format("%02d:%02d:%02d", math.floor(timeSecs/360), math.floor(timeSecs/60), math.mod(timeSecs, 60))
    tempData.color = 'ffffffff'
    if movieTable.movie[4] == 'UEF' then
        tempData.color = 'ff00c1ff'
    elseif movieTable.movie[4] == 'Cybran' then
        tempData.color = 'ffff0000'
    elseif movieTable.movie[4] == 'Aeon' then
        tempData.color = 'ff89d300'
    end

    AddTransmissionDataMP(tempData)
    WaitForDialogueMP(movieTable.movie[1])
end

### Video Text
function DisplayVideoTextMP(string)
    if(not Sync.VideoText) then
        Sync.VideoText = {}
    end

    table.insert(Sync.VideoText, string)
end

function AddTransmissionDataMP(entryData)
    SimUIVars.SaveEntry(entryData)
end

### The actual thread used by Dialogue
function PlayDialogueMP()
    while table.getn(MfdVideoInfo.DialogueQueue) > 0 do
	   local dTable = MfdVideoInfo.DialogueQueue
            for k,v in dTable do
				local ValidVideo = false
				
				if not v.vid and v.bank and v.cue then
					table.insert(Sync.Voice, {Cue=v.cue, Bank=v.bank} )
					if not v.delay then
						WaitSeconds(5)
					end
				end
					
				if v.text and not v.vid then
					if not v.vid then
						DisplayMissionText( v.text )
					end
				end
					
				if v.vid then
					local vidText = ''
					local movieData = {}
						
					if v.text then
						vidText = v.text
					end
						
					if v.lengh then 
						movieData.lengh = v.lengh
					else
						movieData.lengh = false
					end
					
--[[					
					if GetMovieDuration('/movies/custom_movies/mfd/' .. v.faction .. '/' .. v.vid) > 0 then
						movieData.movie = {'/movies/custom_movies/mfd/' .. v.faction .. '/' .. v.vid, v.bank, v.cue, v.faction, }
						ValidVideo = true
					end
--]]

					if GetMovieDuration(v.vid) > 0 then
						movieData.movie = {v.vid, v.bank, v.cue, v.faction, }
						ValidVideo = true
					end

					if ValidVideo then 
						SetupMFDSyncMP(movieData, vidText)
						dTable = table.remove(MfdVideoInfo.DialogueQueue, 1)
					end
				end
					
				--delay after movie ends before executing the callback or playing next video in the queue.
				if v.delay and v.delay > 0 then
					WaitSeconds( v.delay )
				end
					
				if v.duration and v.duration > 0 then
					WaitSeconds( v.duration )
				end
			end
		
        if dTable.Callback then
            ForkThread(dTable.Callback)
        end
		
        WaitTicks(1)
    end
	
    MfdVideoInfo.DialogueLock = false
end

function WaitForDialogueMP(name)
    while not MfdVideoInfo.DialogueFinished[name] do
        WaitTicks(1)
    end
end

function DialogFinished(name)
	if MfdVideoInfo.DialogueFinished[name] != nil and not MfdVideoInfo.DialogueFinished[name] then 
		MfdVideoInfo.DialogueFinished[name] = true
	end
end
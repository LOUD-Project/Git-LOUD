--* File: lua/modules/ui/lobby/lobby.lua
--* Author: Chris Blackwell
--* Summary: Game selection UI
--* Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

local Bitmap            = import('/lua/maui/bitmap.lua').Bitmap
local Button            = import('/lua/maui/button.lua').Button
local Edit              = import('/lua/maui/edit.lua').Edit
local Group             = import('/lua/maui/group.lua').Group
local EnhancedLobby     = import('/lua/enhancedlobby.lua')
local FactionData       = import('/lua/factions.lua')
local LayoutHelpers     = import('/lua/maui/layouthelpers.lua')
local LobbyComm         = import('/lua/ui/lobby/lobbyComm.lua')
local MapUtil           = import('/lua/ui/maputil.lua')
local ModManager        = import('/lua/ui/dialogs/modmanager.lua')
local Mods              = import('/lua/mods.lua')
local Prefs             = import('/lua/user/prefs.lua')
local StatusBar         = import('/lua/maui/statusbar.lua').StatusBar
local Text              = import('/lua/maui/text.lua').Text
local Tooltip           = import('/lua/ui/game/tooltip.lua')
local UIUtil            = import('/lua/ui/uiutil.lua')

local numOpenSlots      = LobbyComm.maxPlayerSlots
local Strings           = LobbyComm.Strings

local aitypes           = false
local availableMods     = {} -- map from peer ID to set of available mods; each set is a map from "mod id"->true
local colorPicker       = false
local commandQueueIndex = 0
local commandQueue      = {}
local fillSlotsSet      = false
local formattedOptions  = {}

local gameInfo = {
        GameMods        = {},
        GameOptions     = {
            TeamSpawn       = 'fixed',
            TeamLock        = 'locked',
            Victory         = 'demoralization',
            Timeouts        = '3',
            CheatsEnabled   = 'true',
            GameSpeed       = 'normal',
            FogOfWar        = 'explored',
            UnitCap         = '725',
        },
        Observers       = {},
        PlayerOptions   = {},
    }
    

local gameName          = ""
local GUI               = false
local hasSupcom         = true
local hostID            = false
local launchThread      = false
local lobbyComm         = false
local localPlayerID     = false
local localPlayerName   = ""
local missingModDialog  = false
local selectedMods      = nil
local singlePlayer      = false
local teamSetting       = false
local wantToBeObserver  = false

--- load default lobby options (non-mod)
local globaloptions = import('/lua/ui/lobby/lobbyoptions.lua').globalOpts
local teamoptions   = import('/lua/ui/lobby/lobbyoptions.lua').teamOptions
local aioptions     = import('/lua/ui/lobby/lobbyoptions.lua').advAIOptions
local gameoptions   = import('/lua/ui/lobby/lobbyoptions.lua').advGameOptions
  

local lobbyOptMap   = {}
local lobbyOptOrder = {}

--local pmDialog = false

local teamIcons = {
    '/lobby/team_icons/team_no_icon.dds',
    '/lobby/team_icons/team_1_icon.dds',
    '/lobby/team_icons/team_2_icon.dds',
    '/lobby/team_icons/team_3_icon.dds',
    '/lobby/team_icons/team_4_icon.dds',
    '/lobby/team_icons/team_5_icon.dds',
    '/lobby/team_icons/team_6_icon.dds',
    '/lobby/team_icons/team_7_icon.dds',
    '/lobby/team_icons/team_8_icon.dds'
}

local teamTooltips = {'lob_team_none','lob_team_one','lob_team_two','lob_team_three','lob_team_four','lob_team_five','lob_team_six','lob_team_seven','lob_team_eight'}
local teamNumbers = {"<LOC _No>","1","2","3","4","5","6","7","8"}

-- builds the faction tables
local factionBmps       = {}
local factionTooltips   = {}

for index, tbl in FactionData.Factions do
    factionBmps[index]      = tbl.SmallIcon
    factionTooltips[index]  = tbl.TooltipID
end

table.insert(factionBmps, "/faction_icon-sm/random_ico.dds")
-- adds random faction icon to the end
table.insert(factionTooltips, 'lob_random')

function GetGlobalOptions()

    local newdata       = {}
    
    --- get CustomOptions files from source
	local OptionFiles = DiskFindFiles('/lua/CustomOptions', '*.lua')
    
    for _,mod in EnhancedLobby.GetActiveMods() do
    
        --- get CustomOptions files from all loaded mods
        OptionFiles = table.cat( OptionFiles, DiskFindFiles( mod.location..'/lua/CustomOptions', '*.lua') )
    
    end
    
    --LOG("*AI DEBUG LOBBY Option Files are "..repr(OptionFiles))
    
    local lobbyoptions      = {}
    local teamlobbyoptions  = {}
    local advAIlobbyoptions = {}
    local gamelobbyoptions  = {}
	
    --- scan all option files for lobby options
	for i, v in OptionFiles do

        --- import the raw data
        local data = import(v)
        
        newdata = {}

        --- process the raw data file & insert formatted data into newdata
        for k,v in data do
            if k != '__moduleinfo' and k != 'import' then
                newdata[k] = v
            end
        end

        if newdata.LobbyGlobalOptions then

			for _, option in newdata.LobbyGlobalOptions do

				lobbyoptions[option.label] = option
			end
            
        end

        if newdata.teamOptions then

			for _, option in newdata.teamOptions do

				teamlobbyoptions[option.label] = option
			end
            
        end

        if newdata.advAIOptions then

            for _, option in newdata.advAIOptions do
            
                advAIlobbyoptions[option.label] = option
            end
            
        end
            
        if newdata.advGameOptions then

            for _, option in newdata.advGameOptions do
            
                gamelobbyoptions[option.label] = option
            end
            
        end
		
	end

    --- add the default options to the mod options
    lobbyoptions        = table.cat( lobbyoptions, globaloptions )
    teamlobbyoptions    = table.cat( teamlobbyoptions, teamoptions )
    advAIlobbyoptions   = table.cat( advAIlobbyoptions, aioptions )
    gamelobbyoptions    = table.cat( gamelobbyoptions, gameoptions )
	
    lobbyOptMap     = {}
    lobbyOptOrder   = {}

    for _, v in lobbyoptions do
        table.insert(lobbyOptOrder, v.key)
        lobbyOptMap[v.key] = v
    end

    for _, v in teamlobbyoptions do
        table.insert(lobbyOptOrder, v.key)
        lobbyOptMap[v.key] = v
    end

    for _, v in advAIlobbyoptions do
        table.insert( lobbyOptOrder, v.key)
        lobbyOptMap[v.key] = v
    end

    for _, v in gamelobbyoptions do
        table.insert(lobbyOptOrder, v.key)
        lobbyOptMap[v.key] = v
    end
    
    return lobbyoptions, teamlobbyoptions, advAIlobbyoptions, gamelobbyoptions

end


local slotMenuStrings = {
    open    = "<LOC lobui_0219>Open",
    close   = "<LOC lobui_0220>Close",
    closed  = "<LOC lobui_0221>Closed",
    occupy  = "<LOC lobui_0222>Occupy",
    pm      = "<LOC lobui_0223>Private Message",
    remove  = "<LOC lobui_0224>Remove",
}

local slotMenuData = {

    open = {
        host    = { 'ailist','occupy','close' },
        client  = { 'occupy' },
    },
	
    closed = {
        host    = { 'open' },
        client  = {},
    },
	
    player = {
        host    = { 'pm','remove' },
        client  = { 'pm' },
    },
	
    ai = {
        host    = { 'ailist','remove' },
        client  = {},
    },
}

local function DisplayLEMData()

	if lobbyComm:IsHost() then
	
		PublicChat('LEM Data')
		PublicChat('-----------------------------------')
		
		for i = 1, LobbyComm.maxPlayerSlots do
		
			if not gameInfo.ClosedSlots[i] then
			
				if gameInfo.PlayerOptions[i] and gameInfo.PlayerOptions[i].LEM then
				
					local retChat = ""
					
					for i, v in gameInfo.PlayerOptions[i].LEM do
						retChat = retChat..v.."; "
					end
					
					PublicChat(gameInfo.PlayerOptions[i].PlayerName..': '..retChat)
					
				elseif gameInfo.PlayerOptions[i] then
				
					PublicChat(gameInfo.PlayerOptions[i].PlayerName..': No Data')
					
				end
				
			end
			
		end
		
	end
	
end

local function ParseWhisper(params)

    local delimStart = string.find(params, ":")
	
    if delimStart then
	
        local name = string.sub(params, 1, delimStart-1)
        local targID = FindIDForName(name)
		
        if targID then
		
            PrivateChat(targID, string.sub(params, delimStart+1))
			
        else
		
            AddChatText(LOC("<LOC lobby_0007>Invalid whisper target."))
			
        end
		
    else
	
        AddChatText(LOC("<LOC lobby_0008>You must have a colon (:) after the whisper target's name."))
		
    end
	
end

local commands = {
    { key = 'w',        action = ParseWhisper    },
    { key = 'whisper',  action = ParseWhisper    },
    { key = 'lem',      action = DisplayLEMData  },
}

local function GetAITooltipList()

    local retTable = {}
	
    for i, v in aitypes do
        table.insert(retTable, 'aitype_'..v.key)
    end
	
    return retTable
	
end

local function GetSlotMenuTables(stateKey, hostKey, noais)

    local keys = {}
    local strings = {}

    if not slotMenuData[stateKey] then
        ERROR("Invalid slot menu state selected: " .. stateKey)
    end

    if not slotMenuData[stateKey][hostKey] then
        ERROR("Invalid slot menu host key selected: " .. hostKey)
    end

    local isPlayerReady = false
    local localPlayerSlot = FindSlotForID(localPlayerID)
	
    if localPlayerSlot then
	
        if gameInfo.PlayerOptions[localPlayerSlot].Ready then
            isPlayerReady = true        
        end
		
    end

    for index, key in slotMenuData[stateKey][hostKey] do
	
        if key == 'ailist' and not noais then

            for aiindex, aidata in aitypes do
                table.insert(keys, aidata.key)
                table.insert(strings, aidata.name)
            end
			
        elseif key ~= 'ailist' then
		
            if not (isPlayerReady and key == 'occupy') then
			
                table.insert(keys, key)
                table.insert(strings, slotMenuStrings[key])
				
            end
			
        end
		
    end

    return keys, strings
	
end

local function DoSlotBehavior(slot, key, name)

    if key == 'open' then
	
        if lobbyComm:IsHost() then
            HostOpenSlot(hostID, slot)
        end 
		
    elseif key == 'close' then
	
        if lobbyComm:IsHost() then
            HostCloseSlot(hostID, slot)
        end
		
    elseif key == 'occupy' then
	
        if IsPlayer(localPlayerID) then
		
            if lobbyComm:IsHost() then
                HostTryMovePlayer(hostID, FindSlotForID(localPlayerID), slot)
            else
                lobbyComm:SendData(hostID, {Type = 'MovePlayer', CurrentSlot = FindSlotForID(localPlayerID), RequestedSlot =  slot})
            end
			
        elseif IsObserver(localPlayerID) then
		
            if lobbyComm:IsHost() then
                HostConvertObserverToPlayer(hostID, localPlayerName, FindObserverSlotForID(localPlayerID), slot)
            else
                lobbyComm:SendData(hostID, {Type = 'RequestConvertToPlayer', RequestedName = localPlayerName, ObserverSlot = FindObserverSlotForID(localPlayerID), PlayerSlot = slot})
            end
			
        end
		
    elseif key == 'pm' then
	
        if gameInfo.PlayerOptions[slot].Human then
            GUI.chatEdit:SetText(string.format("/whisper %s:", gameInfo.PlayerOptions[slot].PlayerName))
        end
		
    elseif key == 'remove' then
	
        if gameInfo.PlayerOptions[slot].Human then
		
            UIUtil.QuickDialog(GUI, "<LOC lobui_0166>Are you sure?",
                "<LOC lobui_0167>Kick Player", function() lobbyComm:EjectPeer(gameInfo.PlayerOptions[slot].OwnerID, "KickedByHost") end,
                "<LOC _Cancel>", nil, 
                nil, nil, 
                true,
                {worldCover = false, enterButton = 1, escapeButton = 2})
				
        else
		
            if lobbyComm:IsHost() then
			
                HostRemoveAI( slot)
				
            else
			
                lobbyComm:SendData( hostID, { Type = 'ClearSlot', Slot = slot } )
				
            end
			
        end
		
    else
	
        if lobbyComm:IsHost() then
		
            local color = false
            local faction = false
            local team = false
			
            if gameInfo.PlayerOptions[slot] then
                color = gameInfo.PlayerOptions[slot].WheelColor
                team = gameInfo.PlayerOptions[slot].Team
                faction = gameInfo.PlayerOptions[slot].Faction
            end
			
            HostTryAddPlayer(hostID, slot, name, false, key, color, faction, team)
			
        end
		
    end
	
end

local function GetLocallyAvailableMods()

    local result = {}
	
    for k,mod in Mods.AllMods() do
	
        if not mod.ui_only then
            result[mod.uid] = true
        end
		
    end
	
    return result
	
end

local function EveryoneHasLEM()

	for i = 1, LobbyComm.maxPlayerSlots do
	
		if not gameInfo.ClosedSlots[i] then
		
			if gameInfo.PlayerOptions[i] and not gameInfo.PlayerOptions[i].LEM then
			
				return false
				
			elseif gameInfo.PlayerOptions[i] and gameInfo.PlayerOptions[i].LEM and tonumber(string.sub(gameInfo.PlayerOptions[i].LEM[1], -3)) <= 4.4 then
			
				return false
				
			end
			
		end
		
	end
	
	return true
	
end

local outdatedWarning = false
local badmapWarning = false

local function CheckLEMVersion()
	
	if gameInfo.PlayerOptions[FindSlotForID(localPlayerID)].LEM then
	
		local myLEMVersion = tonumber(string.sub(gameInfo.PlayerOptions[FindSlotForID(localPlayerID)].LEM[1], -3))
		
		for i = 1, LobbyComm.maxPlayerSlots do
		
			if not gameInfo.ClosedSlots[i] then
			
				if gameInfo.PlayerOptions[i] and gameInfo.PlayerOptions[i].LEM and tonumber(string.sub(gameInfo.PlayerOptions[i].LEM[1], -3)) > myLEMVersion and not outdatedWarning then
				
					outdatedWarning = true

					AddChatText("Your version of LEM is out of date.")

				end
				
			end
			
		end
		
	end

	if gameInfo.GameOptions.ScenarioVersion then
		
		local myMAPVersion = gameInfo.PlayerOptions[FindSlotForID(localPlayerID)].MapVersion or false
		
		if myMAPVersion and myMAPVersion ~= gameInfo.GameOptions.ScenarioVersion then
		
			-- set the local data
			gameInfo.PlayerOptions[FindSlotForID(localPlayerID)].BadMap = true 
			
			-- send a global chat to everyone
			if not badmapWarning then
			
				PublicChat(" has Map Version "..repr(myMAPVersion).." Host has "..gameInfo.GameOptions.ScenarioVersion)
				-- this flag prevents this from occuring again
				badmapWarning = true				
			end
			
			-- send the bad map flag to host
			lobbyComm:SendData( hostID, {Type = 'BadMap', Result = true} )
			
		elseif myMAPVersion and myMAPVersion == gameInfo.GameOptions.ScenarioVersion then
			-- clear the local flag
			gameInfo.PlayerOptions[FindSlotForID(localPlayerID)].BadMap = false
			-- if not the host (the host is never wrong) tell host that you're good
			if not lobbyComm:IsHost() then
			
				lobbyComm:SendData( hostID, {Type = 'BadMap', Result = false} )
				
			end
			
			badmapWarning = false
			
		end
		
	end
	
end

local function TransmitMod(playerID, ModId)

	--LOG("*DEBUG: Requested Mod Transmission")
	
	local allMods = Mods.AllMods()
	local ModInfo = allMods[ModId]
	
	LOG("Transmit Mod " .. ModInfo.location .. "||" .. ModInfo.uid..ModInfo.version)
	
	WaitSeconds(.5)
	
	local lastsize
	local done = false
	
	repeat
	
		if not DiskGetFileInfo('/mods/'..ModInfo.uid..ModInfo.version..'.lua') then
			return
		end
		
		local fileInfo = DiskGetFileInfo('/mods/'..ModInfo.uid..ModInfo.version..'.lua')
		
		if lastsize and fileInfo.SizeBytes == lastsize then
		
			done = true
			
		end
		
		lastsize = fileInfo.SizeBytes
		
		WaitSeconds(.5)
		
	until done
	
	local Code = {}
	
	Code = table.deepcopy(import('/mods/'..ModInfo.uid..ModInfo.version..'.lua').Code)
	
	local playerName = FindNameForID(playerID) or "someone"
	
	AddChatText("Sending "..ModInfo.name.." to "..playerName)
	
	local pieces = table.getn(Code)
	local num = 0
	
	for k,v in Code do
	
		num = num + 1
		
		local lastPiece = num == pieces
		local sendCode = {}
		
		sendCode[k] = v
		
		LOG("*DEBUG: num =  "..num.." pieces = "..pieces)
		LOG("*DEBUG: Sending file "..k.." to "..playerName..". Last piece = "..repr(lastPiece))
		
		lobbyComm:SendData(playerID, {Type = 'TransmitMod', modCode = sendCode, modId = ModInfo.uid, last = lastPiece})
		
	end
	
end

local function ModReceivedNote(playerID, modId)

	local playerName = FindNameForID(playerID) or "someone"
	
	AddChatText(playerName.." received "..gameInfo.GameModNames[modId])
	
end

function FindNameForID(id)

    for k,player in gameInfo.PlayerOptions do
	
        if player.OwnerID == id and player.Human then
            return player.PlayerName
        end
		
    end
	
    return nil
	
end

local function ReceiveMod(Code, Uid, lastPiece)

	LOG("Receive mod")
	
	for k, v in Code do
	
		LOG("AutoTransfer FilePath: "..k)
		LOG(v)
		
	end

	LOG("Recieving ended")
	
	if lastPiece then
	
		Mods.ClearCache()

		local playerName = FindNameForID(hostID) or "someone"
		
		AddChatText("Received "..gameInfo.GameModNames[Uid].." from "..playerName)
		
		lobbyComm:SendData(hostID, {Type = 'ModReceived', modId = Uid})
		
	end
	
end

local function CheckIfHaveMods()

	local myMods = GetLocallyAvailableMods()
	local missingMods = {}
	local modString = ""
	local playerName = FindNameForID(hostID) or "someone"
	
	for k,v in gameInfo.GameMods do
	
		if not myMods[k] then
			table.insert(missingMods, k)
			modString = modString..gameInfo.GameModNames[k].."\n"
		end
	end
	
	if missingModDialog then missingModDialog:Destroy() end
	
	local function yesFunc()
		for k,v in missingMods do
			AddChatText("Requesting "..gameInfo.GameModNames[v].." from "..playerName)
			lobbyComm:SendData(hostID, {Type = 'RequestMod', modId = v})
		end
	end
	
	if table.getn(missingMods) > 0 then
		missingModDialog = UIUtil.QuickDialog(
			GUI,
			"You are missing the following mods:\n"..modString.."\nDo you wish to download them?\nClicking No will exit the lobby.",
			"<LOC _Yes>", yesFunc,
			"<LOC _No>", function() ReturnToMenu() end
		)
	end
end

local function IsModAvailable(modId)
	if not EveryoneHasLEM() then
		for k,v in availableMods do
			if not v[modId] then
				return false
			end
		end
	end
    return true
end

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

function Reset()
    lobbyComm = false
    wantToBeObserver = false
    localPlayerName = ""
    gameName = ""
    hostID = false
    singlePlayer = false
    GUI = false
    localPlayerID = false
    availableMods = {}
    selectedMods = nil
	fillSlotsSet = false
	teamSetting = false
    numOpenSlots = LobbyComm.maxPlayerSlots
    gameInfo = {
        GameOptions = {},
        PlayerOptions = {},
        Observers = {},
        ClosedSlots = {},
        GameMods = {},
		GameModNames = {},
    }
end

-- Create a new unconnected lobby.
function CreateLobby(protocol, localPort, desiredPlayerName, localPlayerUID, natTraversalProvider, over, exitBehavior, playerHasSupcom, useSteam)
    
    -- default to true, if the param is nil, then not playing through GPGnet
    if playerHasSupcom == nil or playerHasSupcom == true then
        hasSupcom = true
    else
        hasSupcom = false
    end
    
    Reset()

    if GUI then
        WARN('CreateLobby called but I already have one setup...?')
        GUI:Destroy()
    end

    GUI = UIUtil.CreateScreenGroup(over, "CreateLobby ScreenGroup")
    GUI.exitBehavior = exitBehavior

    GUI.optionControls = {}
    GUI.slots = {}

    GUI.connectdialog = UIUtil.ShowInfoDialog(GUI, Strings.TryingToConnect, Strings.AbortConnect, ReturnToMenu)

    InitLobbyComm(protocol, localPort, desiredPlayerName, localPlayerUID, natTraversalProvider, useSteam)

    -- Store off the validated playername
    localPlayerName = lobbyComm:GetLocalPlayerName()
end

-- create the lobby as a host
function HostGame(desiredGameName, scenarioFileName, inSinglePlayer, friendsOnly)

    singlePlayer = inSinglePlayer
    gameName = lobbyComm:MakeValidGameName(desiredGameName)
    lobbyComm.desiredScenario = scenarioFileName

	if string.sub(GetVersion(),1,3) ~= '1.6' then
	
		-- not Steam
		lobbyComm:HostGame()
		
	else
	
		-- Steam version
		lobbyComm:HostGame(friendsOnly)
		
	end
	
end

-- join an already existing lobby
function JoinGame(address, asObserver, playerName, uid)
    wantToBeObserver = asObserver
    lobbyComm:JoinGame(address, playerName, uid);
end

function JoinSteamGame(hostInfo, asObserver)
    wantToBeObserver = asObserver    
    lobbyComm:JoinSteamGame(hostInfo);
end

function ConnectToPeer(addressAndPort,name,uid)
    lobbyComm:ConnectToPeer(addressAndPort,name,uid)
end

function DisconnectFromPeer(uid)
    lobbyComm:DisconnectFromPeer(uid)
end

function SetHasSupcom(supcomInstalled)
    hasSupcom = supcomInstalled
end

function SetHasForgedAlliance(faInstalled)
    hadFA = faInstalled
end

function FindSlotForID(id)
    for k,player in gameInfo.PlayerOptions do
        if player.OwnerID == id and player.Human then
            return k
        end
    end
    return nil
end

function FindIDForName(name)
    for k,player in gameInfo.PlayerOptions do
        if player.PlayerName == name and player.Human then
            return player.OwnerID
        end
    end
    return nil
end

function FindObserverSlotForID(id)
    for k,observer in gameInfo.Observers do
        if observer.OwnerID == id then
            return k
        end
    end
    return nil
end

function IsLocallyOwned(slot)
    return (gameInfo.PlayerOptions[slot].OwnerID == localPlayerID)
end

function IsPlayer(id)
    return FindSlotForID(id) ~= nil
end

function IsObserver(id)
    return FindObserverSlotForID(id) ~= nil
end

-- Given an RGB colour structure, return a hex ARGB colour string
function ColorToStr(color)
    return string.format("FF%02x%02x%02x", color[1], color[2], color[3])
end

-- Given a hex ARGB or RGB colour string, return an RGB colour structure
function ColorToArray(color)
    if string.len(color) == 8 then
        return {
            tonumber(string.sub(color, 3, 4), 16),
            tonumber(string.sub(color, 5, 6), 16),
            tonumber(string.sub(color, 7, 8), 16)
        }
    else
        return {
            tonumber(string.sub(color, 1, 2), 16),
            tonumber(string.sub(color, 3, 4), 16),
            tonumber(string.sub(color, 5, 6), 16)
        }
    end
end

-- RGB array, each in range from 3 to 252
local function RandomColor()
    return { 
        math.random(3, 252), 
        math.random(3, 252), 
        math.random(3, 252) 
    }
end

-- update the data in a player slot
function SetSlotInfo(slot, playerInfo)

    local isLocallyOwned
	
    if IsLocallyOwned(slot) then
	
        if gameInfo.PlayerOptions[slot]['Ready'] then
            DisableSlot(slot, true)
        else
            EnableSlot(slot)
        end
		
        isLocallyOwned = true
		
        if not hasSupcom then
            GUI.slots[slot].faction:Disable()
        end
    else
        DisableSlot(slot)
        isLocallyOwned = false
    end

    local hostKey
	
    if lobbyComm:IsHost() then
        hostKey = 'host'
    else
        hostKey = 'client'
    end
	
	local numAIs = GetAICount()
	
	GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_green.dds'))
	Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_green_player')
	
	if playerInfo.LEM then
	
		if isLocallyOwned then
			GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_green.dds'))
			Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_green_self')
		else
		
			local myLEMData = EnhancedLobby.GetLEMData()	-- this will request LEM data from the host
			local LEMSize = table.getn(myLEMData)
			
			if table.getn(playerInfo.LEM) ~= LEMSize and numAIs == 0 then
				GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_yellow.dds'))
				Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_yellow_missing')
				
			elseif table.getn(playerInfo.LEM) ~= LEMSize and numAIs > 0 then
				GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_red.dds'))
				Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_red_missing')
				
			else
			
				if hostKey == "host" then
				
					local LEMCheck = true
				
					-- loop thru the LEM table, bypassing the first entry (LEM version) and compare all the mods
					for x=2,LEMSize do
				
						if myLEMData[x] ~= playerInfo.LEM[x] then
						
							PublicChat( playerInfo.PlayerName.." mod mismatch -- Host "..myLEMData[x].." -- Player "..playerInfo.LEM[x] )
			
							LEMCheck = false
							break
						end
					end
				
					if LEMCheck then
						GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_green.dds'))
						Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_green_player')
					
					elseif not LEMCheck and numAIs == 0 then
						GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_yellow.dds'))
						Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_yellow_mismatch')
					
					elseif not LEMCheck and numAIs > 0 then
						GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_red.dds'))
						Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_red_mismatch')
					
					end
				
				end
			end			
		end
		
	elseif not playerInfo.Human then
		GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_black.dds'))
		Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_black_ai')
		
	else
		if numAIs == 0 then
			GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_blue.dds'))
			Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_blue_noai')
		else
			GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_red.dds'))
			Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_blue_nolem')
		end
	end

	if playerInfo.BadMap then
		GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_red.dds'))
		Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_red_missing')
	end

    if not playerInfo.Human and lobbyComm:IsHost() then
    end

    local slotState
	
    if not playerInfo.Human then
        slotState = 'ai'
    elseif not isLocallyOwned then
        slotState = 'player'
    else
        slotState = nil
    end

    GUI.slots[slot].name:ClearItems()

    if slotState then
	
        GUI.slots[slot].name:Enable()
		
        local slotKeys, slotStrings = GetSlotMenuTables(slotState, hostKey)
		
        GUI.slots[slot].name.slotKeys = slotKeys
		
        if lobbyComm:IsHost() and (slotState == 'open' or slotState == 'ai') then
            Tooltip.AddComboTooltip(GUI.slots[slot].name, GetAITooltipList())
        else
            Tooltip.RemoveComboTooltip(GUI.slots[slot].name)
        end
		
        if table.getn(slotKeys) > 0 then
            GUI.slots[slot].name:AddItems(slotStrings)
            GUI.slots[slot].name:Enable()
        else
            GUI.slots[slot].name.slotKeys = nil
            GUI.slots[slot].name:Disable()
        end
		
        local popslotKeys, popslotStrings = GetSlotMenuTables(slotState, hostKey, true)
		
        GUI.slots[slot].Popup.slotKeys = popslotKeys
		GUI.slots[slot].Popup:DeleteAllItems()
		
		for k,v in popslotStrings do
			GUI.slots[slot].Popup:AddItem(LOC(v))
		end
		
		GUI.slots[slot].Popup.Height:Set(function() return GUI.slots[slot].Popup:GetItemCount() * GUI.slots[slot].Popup:GetRowHeight() end)
    else
        -- no slotState indicate this must be ourself, and you can't do anything to yourself
        GUI.slots[slot].name.slotKeys = nil
        GUI.slots[slot].name:Disable()
    end

    GUI.slots[slot].name:Show()
    GUI.slots[slot].name:SetTitleText(LOC(playerInfo.PlayerName))

    GUI.slots[slot].faction:Show()
    GUI.slots[slot].faction:SetItem(playerInfo.Faction)

    GUI.slots[slot].color:Show()
    GUI.slots[slot].color:SetSolidColor(ColorToStr(playerInfo.WheelColor))

    GUI.slots[slot].team:Show()
    GUI.slots[slot].team:SetItem(playerInfo.Team)
    
    if not playerInfo.Human then
        GUI.slots[slot].mult:Show()
        GUI.slots[slot].mult:SetText(tostring(playerInfo.Mult))
        GUI.slots[slot].act:Show()
        GUI.slots[slot].act:SetItem(playerInfo.ACT)
    end

    if GUI.slots[slot].ready then
	
        if playerInfo.Human then
            GUI.slots[slot].ready:Show()
            GUI.slots[slot].ready:SetCheck(playerInfo.Ready, true)
        else
            GUI.slots[slot].ready:Hide()
        end
    end

    if GUI.slots[slot].pingGroup then
	
        if isLocallyOwned or not playerInfo.Human then
            GUI.slots[slot].pingGroup:Hide()
        else
            GUI.slots[slot].pingGroup:Show()
        end
    end

    if isLocallyOwned and playerInfo.Human then
	
        Prefs.SetToCurrentProfile('LastColor', playerInfo.WheelColor)
        Prefs.SetToCurrentProfile('LastFaction', playerInfo.Faction)
    end
end

function ClearSlotInfo(slot)
    local hostKey
    if lobbyComm:IsHost() then
        hostKey = 'host'
    else
        hostKey = 'client'
    end

    local stateKey
    local stateText
    if gameInfo.ClosedSlots[slot] then
        stateKey = 'closed'
        stateText = slotMenuStrings.closed
    else
        stateKey = 'open'
        stateText = slotMenuStrings.open
    end

    local slotKeys, slotStrings = GetSlotMenuTables(stateKey, hostKey)

    -- set the text appropriately
	GUI.slots[slot].LEMindicator:SetTexture(UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_black.dds'))
	Tooltip.AddControlTooltip(GUI.slots[slot].LEMindicator, 'lob_LEMindicator_black_empty')
    GUI.slots[slot].name:ClearItems()
    GUI.slots[slot].name:SetTitleText(LOC(stateText))
    if table.getn(slotKeys) > 0 then
        GUI.slots[slot].name.slotKeys = slotKeys
        GUI.slots[slot].name:AddItems(slotStrings)
        GUI.slots[slot].name:Enable()
    else
        GUI.slots[slot].name.slotKeys = nil
        GUI.slots[slot].name:Disable()
    end
	local popslotKeys, popslotStrings = GetSlotMenuTables(stateKey, hostKey, true)
	GUI.slots[slot].Popup.slotKeys = popslotKeys
	GUI.slots[slot].Popup:DeleteAllItems()
	for k,v in popslotStrings do
		GUI.slots[slot].Popup:AddItem(LOC(v))
	end
	GUI.slots[slot].Popup.Height:Set(function() return GUI.slots[slot].Popup:GetItemCount() * GUI.slots[slot].Popup:GetRowHeight() end)
    if stateKey == 'closed' then
        GUI.slots[slot].name:SetTitleTextColor("Crimson")
    else
        GUI.slots[slot].name:SetTitleTextColor(UIUtil.fontColor)
    end
    if lobbyComm:IsHost() and (stateKey == 'open' or stateKey == 'ai') then
        Tooltip.AddComboTooltip(GUI.slots[slot].name, GetAITooltipList())
    else
        Tooltip.RemoveComboTooltip(GUI.slots[slot].name)
    end

    -- hide these to clear slot of visible data
    GUI.slots[slot].faction:Hide()
    GUI.slots[slot].color:Hide()
    GUI.slots[slot].team:Hide()
    GUI.slots[slot].mult:Hide()
    GUI.slots[slot].act:Hide()
	GUI.slots[slot].Popup:Hide()
    GUI.slots[slot].multiSpace:Hide()
    if GUI.slots[slot].pingGroup then
        GUI.slots[slot].pingGroup:Hide()
    end
end

function IsColorFree(color)
    for _, player in gameInfo.PlayerOptions do
        if player.WheelColor[1] == color[1]
        and player.WheelColor[2] == color[2]
        and player.WheelColor[3] == color[3] then
            return false
        end
    end

    return true
end

function GetPlayerCount()
    local numPlayers = 0
    for k,player in gameInfo.PlayerOptions do
        if player.Team >= 0 then
            numPlayers = numPlayers + 1
        end
    end
    return numPlayers
end

function GetHumanCount()
    local numHumans = 0
    for k,player in gameInfo.PlayerOptions do
        if player.Human then
            numHumans = numHumans + 1
        end
    end
    return numHumans
end

function GetAICount()
    local numAIs = 0
    for k,player in gameInfo.PlayerOptions do
        if not player.Human then
            numAIs = numAIs + 1
        end
    end
    return numAIs
end

local function GetPlayersNotReady()
    local notReady = false
    for k,v in gameInfo.PlayerOptions do
        if v.Human and not v.Ready then
            if not notReady then
                notReady = {}
            end
            table.insert(notReady,v.PlayerName)
        end
    end
    return notReady
end

-- Alternate code path that uses the functions from
-- Spread.assignments to distribute random players.
local function AssignSpreadFactions()
    -- Alternate faction randomization scheme
    local Spread = import('/lua/ui/lobby/spread.lua')

    local randomFactionID = table.getn(FactionData.Factions) + 1
    local players = {}
    for index, player in gameInfo.PlayerOptions do
        if hasSupcom then
            players[index] = player.Faction
        else
            players[index] = 4
        end
    end
    -- Compute the random assignments based on balanced frequencies
    local factions = Spread.assignments(players,randomFactionID)
    for index, faction in pairs(factions) do
        gameInfo.PlayerOptions[index].Faction = faction
        LOG("*RandomFactions - Assigned Player:" .. index .. " Faction:" .. faction)
    end
    local freqs = Spread.vfreqs(factions)
    LOG("RandomFactions - Faction -> Frequency: "..repr(freqs))
end

local function AssignRandomFactions(gameInfo)
    if gameInfo.GameOptions['EvenFactions'] == 'on' then
        AssignSpreadFactions()
        return
    end

    local randomFactionID = table.getn(FactionData.Factions) + 1
	
    for index, player in gameInfo.PlayerOptions do
	
        if hasSupcom then
		
            if player.Faction >= randomFactionID then
                player.Faction = math.random(1, table.getn(FactionData.Factions))
            end
			
        else
		
            player.Faction = 4
			
        end
		
    end
	
end

local function AssignDefaultMapOptions(gameInfo)

    local function CheckAndCorrectDefaultOption(option)

        -- assume the option is valid
        local valid = true

        -- check if it is a number
        valid = valid and type(option.default) == "number" 

        -- check if it is an integral number
        valid = valid and math.floor(option.default) == option.default 

        -- check if it is an valid index of the values table
        valid = valid and option.values[option.default]

        if not valid then 

            -- tell us (the developer) about it
            WARN("Option " .. option.label .. " has an invalid default (" .. option.default .. "). The default value is the table index, not the actual value.")

            -- try and find the actual index so that the game doesn't crash
            for k, t in option.values do 
                -- key-based
                if t.key == option.default then 
                    valid = true 
                    option.default = k 
                    break 
                end

                -- value-based 
                if t == option.default then 
                    valid = true 
                    option.default = k
                    break 
                end
            end

            -- we couldn't find the actual index: resetting to 1.
            if not valid then 
                option.default = 1 
                WARN("Option " .. option.label .. " could not retrieve the correct index-based default value. Defaulting to index 1.")
            end
        end
    end
    
    local scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
    
    if scenarioInfo.options then 

        for _, option in scenarioInfo.options do 

            if not gameInfo.GameOptions[option.key] then
            
                LOG("*AI DEBUG Assigning Default Map Option for "..repr(option.key))

                -- ensure the default is sane
                CheckAndCorrectDefaultOption(option)

                -- When the value data of the option is formatted as:
                -- values = {
                --     { text = "Easy", help = "We'll have sufficient time to start building up our defense strategy.", key = 1, },		
                --     { text = "Normal", help = "There's sufficient time - but we'll need to hurry up.", key = 2, },	
                --     { text = "Heroic", help = "There's little time - no space for errors.", key = 3, },	
                --     { text = "Legendary", help = "We're dropped in the middle of it - we knew it was a bad mission when we signed up for it.", key = 4, },
                -- },	
                local keyVersion = option.values[option.default].key

                -- When the value data of the option is formatted as:
                -- values = {
                --     '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20'
                -- }
                local valueVersion = option.values[option.default]

                -- Expect a key version, fall back on a value version
                gameInfo.GameOptions[option.key] = keyVersion or valueVersion

                -- Can be removed once this code leaves the develop branch
                LOG("Loading default map option: " .. tostring (option.key) .. " = " .. tostring (gameInfo.GameOptions[option.key]))
            end
        end
    end
end

local function AssignRandomStartSpots(gameInfo)

    if gameInfo.GameOptions['TeamSpawn'] == 'random' then
	
        local numAvailStartSpots = nil
        local scenarioInfo = nil
		
        if gameInfo.GameOptions.ScenarioFile and (gameInfo.GameOptions.ScenarioFile ~= "") then
            scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
        end
		
        if scenarioInfo then
		
            local armyTable = MapUtil.GetArmies(scenarioInfo)
			
            if armyTable then
                numAvailStartSpots = table.getn(armyTable)
            end
			
        else
		
            WARN("Can't assign random start spots, no scenario selected.")
            return
			
        end
        
        for i = 1, numAvailStartSpots do
		
            if gameInfo.PlayerOptions[i] then
			
                -- don't select closed slots for random pick
                local randSlot
				
                repeat
                    randSlot = math.random(1,numAvailStartSpots)
                until gameInfo.ClosedSlots[randSlot] == nil
                
                local temp = nil
				
                if gameInfo.PlayerOptions[randSlot] then
                    temp = table.deepcopy(gameInfo.PlayerOptions[randSlot])
                end
				
                gameInfo.PlayerOptions[randSlot] = table.deepcopy(gameInfo.PlayerOptions[i])
                gameInfo.PlayerOptions[i] = temp
				
            end
			
        end
		
    end
	
end

local function AssignAINames(gameInfo)

    local aiNames = import('/lua/ui/lobby/aiNames.lua').ainames
    local nameSlotsTaken = {}
	
    for index, faction in FactionData.Factions do
        nameSlotsTaken[index] = {}
    end
	
    for index, player in gameInfo.PlayerOptions do
	
        if player.Human == false then
		
            local factionNames = aiNames[FactionData.Factions[player.Faction].Key]
            local ranNum
			
            repeat
                ranNum = math.random(1, table.getn(factionNames))
            until nameSlotsTaken[player.Faction][ranNum] == nil
			
            nameSlotsTaken[player.Faction][ranNum] = true
            local newName = factionNames[ranNum]
            player.PlayerName = newName .. " (" .. player.PlayerName .. ")"
        end
    end
end

local function CalcTotalUnitCap()

    local ret = 0
    local unitCap = tonumber(gameInfo.GameOptions.UnitCap) or 750
    local biggestTeamSize = 0

    local teamSizes = {}

    -- First iterate over all players to get team sizes
    for slot, player in gameInfo.PlayerOptions do

        if not player then
            continue
        end

        teamSizes[slot] = 1

        -- Check all other players to see how big this player's team is
        for _, p in gameInfo.PlayerOptions do
            if p and p ~= player and p.Team == player.Team then
                teamSizes[slot] = teamSizes[slot] + 1
            end
        end

        if teamSizes[slot] > biggestTeamSize then
            biggestTeamSize = teamSizes[slot]
        end
        
    end

    for slot, player in gameInfo.PlayerOptions do

        if not player then
            continue
        end

        if player.Human then
            ret = ret + unitCap
        else

            local playerDiff = (biggestTeamSize or 1) / teamSizes[slot]

            if gameInfo.GameOptions.CapCheat == 'unlimited' then

                ret = ret + 99999

            elseif gameInfo.GameOptions.CapCheat == 'cheatlevel' then

                local mult = tonumber(player.Mult)
                local cheatCap = unitCap * mult * (math.max(playerDiff, 1))
                
                ret = ret + math.floor(cheatCap)

            else
                
                -- team unit cap is ALWAYS equalized 
                local cheatCap = unitCap * (math.max(playerDiff, 1))
                
                ret = ret + math.floor(cheatCap)    --unitCap
            end
        end
    end

    return ret
end

-- call this whenever the lobby needs to exit and not go in to the game
function ReturnToMenu()

    if lobbyComm then
        lobbyComm:Destroy()
        lobbyComm = false
    end

    local exitfn = GUI.exitBehavior

    GUI:Destroy()
    GUI = false

    exitfn()
end

local function SendSystemMessage(text)

    local data = { Type = "SystemMessage", Text = text }
	
    lobbyComm:BroadcastData(data)
	
    AddChatText(text)
end

function PublicChat(text)

    lobbyComm:BroadcastData( { Type = "PublicChat", Text = text } )
	
    AddChatText("["..localPlayerName.."] " .. text)
end

function PrivateChat(targetID,text)

    if targetID ~= localPlayerID then
	
        lobbyComm:SendData( targetID, { Type = 'PrivateChat', Text = text } )
    end
	
    AddChatText("<<"..localPlayerName..">> " .. text)
end

function UpdateAvailableSlots( numAvailStartSpots )

    if numAvailStartSpots > LobbyComm.maxPlayerSlots then
        WARN("Lobby requests " .. numAvailStartSpots .. " but there are only " .. LobbyComm.maxPlayerSlots .. " available")
    end

    -- if number of available slots has changed, update it
    if numOpenSlots ~= numAvailStartSpots then
	
        numOpenSlots = numAvailStartSpots
		
        for i = 1, LobbyComm.maxPlayerSlots do
		
            if i <= numAvailStartSpots then
			
                if GUI.slots[i].closed then
				
                    GUI.slots[i].closed = false
                    GUI.slots[i]:Show()
                    GUI.slots[i].color.glow:Hide()
					
                    if not gameInfo.PlayerOptions[i] then
                        ClearSlotInfo(i)
                    end
					
                    if not gameInfo.PlayerOptions[i]['Ready'] then
                        EnableSlot(i)
                    end
					
                end
            else
                if not GUI.slots[i].closed then
				
                    if lobbyComm:IsHost() and gameInfo.PlayerOptions[i] then
					
                        local info = gameInfo.PlayerOptions[i]
						
                        if info.Human then
                            HostConvertPlayerToObserver(info.OwnerID, info.PlayerName, i)
                        else
                            HostRemoveAI(i)
                        end
                    end
					
                    DisableSlot(i)
                    GUI.slots[i]:Hide()
                    GUI.slots[i].closed = true
                end
            end
        end
    end
	
	
end

local function TryLaunch(skipNoObserversCheck, skipSandboxCheck, skipTimeLimitCheck, skipUnitCapCheck)

    if not singlePlayer then
	
        local notReady = GetPlayersNotReady()
		
        if notReady then
		
            for k,v in notReady do
			
                AddChatText(LOCF("<LOC lobui_0203>%s isn't ready.",v))
            end
            return
        end
    end

    local clientsMissingMap = ClientsMissingMap()
	
    if clientsMissingMap then
	
        local names = ""
		
        for index, name in clientsMissingMap do
            names = names .. " " .. name
        end
            AddChatText(LOCF("<LOC lobui_0329>The following players do not have the currently selected map, unable to launch:%s", names))
        return
    end

    -- make sure there are some players (could all be observers?)
    -- Also count teams. There needs to be at least 2 teams (or all FFA) represented
    local totalPlayers      = 0
    local totalHumanPlayers = 0
    local lastTeam          = false
    local allFFA            = true
    local moreThanOneTeam   = false
    
    -- Sanitize colours here so Sim::Create() doesn't fail
    for slot, player in gameInfo.PlayerOptions do

        if player then

            player.PlayerColor = slot
            player.ArmyColor = slot

            totalPlayers = totalPlayers + 1

            if player.Human then
                totalHumanPlayers = totalHumanPlayers + 1
            end

            if not moreThanOneTeam and lastTeam and lastTeam ~= player.Team then
                moreThanOneTeam = true
                LOG('team = ', player.Team, ' last = ',lastTeam)
            end

            if player.Team ~= 1 then
                allFFA = false
            end

            lastTeam = player.Team
        end
    end

    -- All cheat multi input has to match n+.n+ or n+
    for k, v in GUI.slots do

        if v.mult:IsHidden() then
            -- Skip this slot
        elseif not (string.find(v.mult:GetText(), "^%d+%.%d+$") or
                    string.find(v.mult:GetText(), "^%.%d+$") or
                    string.find(v.mult:GetText(), "^%d+$")) then
            AddChatText("Not all AI cheat multipliers are valid (Valid examples: '1', '1.0', '.95'). Can not launch.")
            return
        end
    end

    -- Sanity check on GameOptions
    local canLaunch = true
    local badOptions = {}
    
    -- Guard against nils
    for k, v in lobbyOptMap do

        if not gameInfo.GameOptions[v.key] then
            canLaunch = false
            table.insert(badOptions, LOC(lobbyOptMap[k].label))
        end
    end
    
    -- Validate edit-based options
    for k, v in gameInfo.GameOptions do

        local optionValid = false

        if not lobbyOptMap[k].valid then
            continue
        end

        if type(lobbyOptMap[k].valid) == 'table' then

            for _, pat in lobbyOptMap[k].valid do

                if string.find(v, pat) then
                    optionValid = true
                    break -- Don't bother with other patterns
                end

            end

        elseif type(lobbyOptMap[k].valid) == 'string' then

            if string.find(v, lobbyOptMap[k].valid) then
                optionValid = true
            end
        end

        if not optionValid then
            table.insert(badOptions, LOC(lobbyOptMap[k].label))
            canLaunch = false
        end
    end

    if not canLaunch then
        local str = 
            "Can't launch. The following settings have invalid values: "..
            table.concat(badOptions, ", ")
        AddChatText(str)
        return
    end

    if tonumber(gameInfo.GameOptions['UnitCap']) < 400 then
        AddChatText("Unit Cap is too low. Please set it between 400 and 5000.")
        return
        
    elseif tonumber(gameInfo.GameOptions['UnitCap']) > 5000 and not skipUnitCapCheck then
    	
		UIUtil.QuickDialog(GUI, "Your unit cap is Excessively high. Do you still wish to launch?",
						   "<LOC _Yes>", function() TryLaunch(false, false, false, true) end,
						   "<LOC _No>", nil,
						   nil, nil, 
						   true,
						   {worldCover = false, enterButton = 1, escapeButton = 2}
					   )
		return	
        --AddChatText("Unit Cap is too high - this game may crash. We suggest you set it between 400 and 5000.")
        --return
    end

    if gameInfo.GameOptions['Victory'] ~= 'sandbox' then
	
        local valid = true
		
        if totalPlayers == 1 then
            valid = false
        end
		
        if not allFFA and not moreThanOneTeam then
            valid = false
        end
		
        if not valid then 
            AddChatText(LOC("<LOC lobui_0241>There must be more than one player or team or the Victory Condition must be set to Sandbox. "))
            return
        end
		
	elseif gameInfo.GameOptions['Victory'] == 'sandbox'	and not skipSandboxCheck then
	
		UIUtil.QuickDialog(GUI, "Victory condition is set to Sandbox. Do you still wish to launch?",
						   "<LOC _Yes>", function() TryLaunch(false, true, true, true) end,
						   "<LOC _No>", nil,
						   nil, nil, 
						   true,
						   {worldCover = false, enterButton = 1, escapeButton = 2}
					   )
		return
    end
	
	if gameInfo.GameOptions['Victory'] ~= 'sandbox' and gameInfo.GameOptions['TimeLimitSetting'] ~= "0" and not skipTimeLimitCheck then
	
		UIUtil.QuickDialog(GUI, "A Time Limit has been set on this game. Do you still wish to launch?",
						   "<LOC _Yes>", function() TryLaunch(false, true, true, true) end,
						   "<LOC _No>", nil,
						   nil, nil, 
						   true,
						   {worldCover = false, enterButton = 1, escapeButton = 2}
					   )
		return	
	end	

    if totalPlayers == 0 then
        AddChatText(LOC("<LOC lobui_0233>There are no players assigned to player slots, can not continue"))
        return
    end

    if totalHumanPlayers == 0 and table.empty(gameInfo.Observers) then
        AddChatText(LOC("<LOC lobui_0239>There must be at least one non-ai player or one observer, can not continue"))
        return
    end

    if not EveryoneHasEstablishedConnections() then
        return
    end

    if not gameInfo.GameOptions.AllowObservers then
	
        local hostIsObserver = false
        local anyOtherObservers = false
		
        for k,observer in gameInfo.Observers do
		
            if observer.OwnerID == localPlayerID then
                hostIsObserver = true
            else
                anyOtherObservers = true
            end
        end

        if hostIsObserver then
            AddChatText(LOC("<LOC lobui_0277>Cannot launch if the host isn't assigned a slot and observers are not allowed."))
            return
        end

        if anyOtherObservers then
		
            if skipNoObserversCheck then
			
                for k,observer in gameInfo.Observers do
                    lobbyComm:EjectPeer(observer.OwnerID, "KickedByHost")
                end
				
                gameInfo.Observers = {}
				
            else
                UIUtil.QuickDialog(GUI, "<LOC lobui_0278>There are players who are not assigned slots and observers are not allowed.  Launching will cause them to be ejected.  Do you still wish to launch?",
                                   "<LOC _Yes>", function() TryLaunch(true) end,
                                   "<LOC _No>", nil,
                                   nil, nil, 
                                   true,
                                   {worldCover = false, enterButton = 1, escapeButton = 2}
                               )
                return
            end
        end
    end
    
    local function LaunchGame()
	
        SetFrontEndData('NextOpBriefing', nil)
		
        -- assign random factions just as game is launched
        AssignRandomFactions(gameInfo)
        AssignRandomStartSpots(gameInfo)
        AssignAINames(gameInfo)

        -- Delete some no-longer-needed data
        gameInfo.GameOptions.EvenFactions = nil
        
		LOG("HERE WE GO "..repr({ Options = gameInfo.GameOptions, HostedBy = localPlayerName, PlayerCount = GetPlayerCount(), GameName = gameName }) )
    
        local modConfigs = Mods.GetSimConfigs(gameInfo.GameMods)

        --LOG("*AI DEBUG MODCONFIGS ARE "..repr(modConfigs) )        

        -- Tell everyone else to launch and then launch ourselves.
        lobbyComm:BroadcastData({
            Type = 'Launch', 
            GameInfo = gameInfo, 
            ModConfigs = modConfigs
        })
    
        -- set the mods
        gameInfo.GameMods = Mods.GetGameMods(gameInfo.GameMods)
        
        --LOG("*AI DEBUG GAMEINFO IS "..repr(gameInfo) )
    
        lobbyComm:LaunchGame(gameInfo)
    end

    if singlePlayer or HasCommandLineArg('/gpgnet') then
	
        LaunchGame()
		
    else
	
        launchThread = ForkThread(function()
		
            GUI.launchGameButton.label:SetText(LOC("<LOC PROFILE_0005>"))
			
            GUI.launchGameButton.OnClick = function(self)
                CancelLaunch()
                self.OnClick = function(self) TryLaunch(false) end
                GUI.launchGameButton.label:SetText(LOC("<LOC lobui_0212>Launch"))
            end
			
            local timer = 5
			
            while timer > 0 do
                local text = LOCF('%s %d', "<LOC lobby_0001>Game will launch in", timer)
                SendSystemMessage(text)
                timer = timer - 1
                WaitSeconds(1)
            end
			
            LaunchGame()
        end)
    end
end

function CancelLaunch()

    if launchThread then 
	
        KillThread(launchThread)
        launchThread = false
		
        GUI.launchGameButton.label:SetText(LOC("<LOC lobui_0212>Launch"))
		
        GUI.launchGameButton.OnClick = function(self)
            TryLaunch(false)
        end
		
        if GetPlayersNotReady() then
            local msg = LOCF('<LOC lobui_0308>Launch sequence has been aborted by %s.', GetPlayersNotReady()[1])
            SendSystemMessage(msg)
        else
            SendSystemMessage(LOC('<LOC lobui_0309>Host has cancelled the launch sequence.'))
        end
    end
end

local function AlertHostMapMissing()
    if lobbyComm:IsHost() then
        HostPlayerMissingMapAlert(localPlayerID)
    else
        lobbyComm:SendData(hostID, {Type = 'MissingMap', Id = localPlayerID})    
    end
end

local function UpdateGame()

    --LOG("*AI DEBUG LOBBY UpdateGame "..repr(lobbyOptOrder) )
	
    local scenarioInfo = nil

    if gameInfo.GameOptions.ScenarioFile and (gameInfo.GameOptions.ScenarioFile ~= "") then
	
        scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
		
		if lobbyComm:IsHost() then

			gameInfo.GameOptions.ScenarioVersion = scenarioInfo.map_version or 1
		end
		
		local playerSlot = FindSlotForID(localPlayerID)
		
		if playerSlot then
			-- get the local players map version
			gameInfo.PlayerOptions[playerSlot].MapVersion = scenarioInfo.map_version or 1

		end

        if scenarioInfo and scenarioInfo.map and scenarioInfo.map ~= '' then
		
            local mods = Mods.GetGameMods(gameInfo.GameMods)

            PrefetchSession(scenarioInfo.map, mods, true)
			
        else
            AlertHostMapMissing()
        end
    end
	
	CheckLEMVersion()

    RefreshOptionDisplayData(scenarioInfo)
	
    if not GUI.uiCreated then return end

    if lobbyComm:IsHost() then
	
        GUI.changeMapButton:Show()
		
        GUI.launchGameButton:Show()
		
        if GUI.allowObservers then
            GUI.allowObservers:Show()
        end
		
    else
	
        GUI.changeMapButton.label:SetText(LOC('<LOC tooltipui0145>'))
		
        GUI.changeMapButton.OnClick = function(self, modifiers)
            modstatus = ModManager.ClientModStatus(gameInfo.GameMods)
            ModManager.CreateDialog(GUI, true, OnModsChanged, true, modstatus)
        end
		
        Tooltip.AddButtonTooltip(GUI.changeMapButton, 'Lobby_Mods')
		
        GUI.launchGameButton:Hide()
		
        if GUI.allowObservers then
            GUI.allowObservers:Hide()
        end
    end

    if GUI.becomeObserver then
	
        if IsObserver(localPlayerID) then
            GUI.becomeObserver:Hide()
            GUI.becomeObserver:Disable()
        else
            GUI.becomeObserver:Show()
            GUI.becomeObserver:Enable()
        end
    end

    if GUI.observerList then
	
        -- clear every update and repopulate
        GUI.observerList:DeleteAllItems()

    end
    
    local numPlayers = GetPlayerCount()

    local numAvailStartSpots = LobbyComm.maxPlayerSlots
	
    if scenarioInfo then
	
        local armyTable = MapUtil.GetArmies(scenarioInfo)
		
        if armyTable then
            numAvailStartSpots = table.getn(armyTable)
        end
    end

    UpdateAvailableSlots(numAvailStartSpots)

    for i = 1, LobbyComm.maxPlayerSlots do
	
        if not GUI.slots[i].closed then
		
            if gameInfo.PlayerOptions[i] then
			
                SetSlotInfo(i, gameInfo.PlayerOptions[i])
            else
                ClearSlotInfo(i)
            end
        end
    end

    if scenarioInfo and scenarioInfo.map and (scenarioInfo.map ~= "") then
	
        if not GUI.mapView:SetTexture(scenarioInfo.preview) then
            GUI.mapView:SetTextureFromMap(scenarioInfo.map)
        end
		
        GUI.mapName:SetText(LOC(scenarioInfo.name))

        ShowMapPositions(GUI.mapView,scenarioInfo,numPlayers)
    else
        GUI.mapView:ClearTexture()
        ShowMapPositions(nil, false)
    end

	SetupFillSlots()
	
	if lobbyComm:IsHost() then
	
		if teamSetting ~= gameInfo.GameOptions['TeamSpawn'] and gameInfo.GameOptions['TeamSpawn'] ~= 'random' then
	
			teamSetting = gameInfo.GameOptions['TeamSpawn']
		
			GUI.teamsCombo:ClearItems()
		
			GUI.teamsCombo:AddItems({'2','3','4','5','6','7','8','T/B','L/R'})
		
			local tooltips = {'lob_teamsetup_2','lob_teamsetup_3','lob_teamsetup_4','lob_teamsetup_5','lob_teamsetup_6','lob_teamsetup_7','lob_teamsetup_8','lob_teamsetup_TB','lob_teamsetup_LR'}
		
			Tooltip.AddComboTooltip(GUI.teamsCombo, tooltips)
		
		elseif teamSetting ~= gameInfo.GameOptions['TeamSpawn'] and gameInfo.GameOptions['TeamSpawn'] == 'random' then
	
			teamSetting = gameInfo.GameOptions['TeamSpawn']
		
			GUI.teamsCombo:ClearItems()
		
			GUI.teamsCombo:AddItems({'2','3','4','5','6','7','8'})
		
			local tooltips = {'lob_teamsetup_2','lob_teamsetup_3','lob_teamsetup_4','lob_teamsetup_5','lob_teamsetup_6','lob_teamsetup_7','lob_teamsetup_8'}
		
			Tooltip.AddComboTooltip(GUI.teamsCombo, tooltips)
		end
	
        -- disable options when all players are marked ready
        if not singlePlayer then
		
            local allPlayersReady = true
			
            if GetHumanCount() == 0 or GetPlayersNotReady() ~= false then
                allPlayersReady = false
            end

            if allPlayersReady then
			
                GUI.changeMapButton:Disable()
                GUI.becomeObserver:Disable()
				GUI.fillOpenBtn:Disable()
				GUI.clearAIBtn:Disable()
				GUI.teamsBtn:Disable()

                GUI.launchGameButton:Enable()
				
            else
			
                GUI.changeMapButton:Enable()
                GUI.becomeObserver:Enable()
				GUI.fillOpenBtn:Enable()
				GUI.clearAIBtn:Enable()
				GUI.teamsBtn:Enable()
                
                if launchThread then CancelLaunch() end
                
                GUI.launchGameButton:Disable()
            end
			
			if GetHumanCount() == 0 and GetAICount() > 0 then
				GUI.launchGameButton:Enable()
			end
        end
    end
	
	if bMP then
		scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
		CreateBigPreview(GUI.mapPanel)
	end
	
	gameInfo.GameOptions.PlayerCount = GetPlayerCount()
	
	if string.sub(GetVersion(),1,3) == '1.6' and lobbyComm:IsHost() then
    
        gameInfo.GameOptions.MaxSlots = '16'
        
        --LOG("*AI DEBUG Updating Steam Lobby game options with "..repr(gameInfo.GameOptions))

        -- Prevent a crash caused by profiles from before unit cap textbox
        if type(gameInfo.GameOptions.UnitCap) ~= 'string' then
            gameInfo.GameOptions.UnitCap = "800"
        end

		lobbyComm:UpdateSteamLobby(  
        
            {
				Options = gameInfo.GameOptions,
				HostedBy = localPlayerName,
                MaxPlayers = 16,
				PlayerCount = GetPlayerCount(),
				GameName = gameName,
				ProductCode = import('/lua/productcode.lua').productCode,
			}
        )
        
        --lobbyComm:UpdateSteamLobby()
    
	else
	
	end

end

-- Update our local gameInfo.GameMods from selected map name and selected mods, then
-- notify other clients about the change.
local function HostUpdateMods()

    if lobbyComm:IsHost() then
	
		local all_mods = Mods.AllMods()

        local newmods = {}
		local modnames = {}
		
        for k,modId in selectedMods do
		
            if IsModAvailable(modId) then
                newmods[modId] = true
				modnames[modId] = all_mods[modId].name
            end
        end
		
        if not table.equal(gameInfo.GameMods, newmods) then
		
            gameInfo.GameMods = newmods
			gameInfo.GameModNames = modnames
			
            lobbyComm:BroadcastData { Type = "ModsChanged", GameMods = gameInfo.GameMods, GameModNames = gameInfo.GameModNames }
        end
    end
	
end

-- callback when Mod Manager dialog finishes (modlist==nil on cancel)
-- FIXME: The mod manager should be given a list of game mods set by the host, which
-- clients can look at but not change, and which don't get saved in our local prefs.
function OnModsChanged(modlist)

    if modlist then
    
        LOG("*AI DEBUG LOBBY MODS CHANGED")
	
        Mods.SetSelectedMods(modlist)
		
        if lobbyComm:IsHost() then
		
            selectedMods = table.map(function (m) return m.uid end, Mods.GetGameMods())
            HostUpdateMods()
        end
        
        import('/lua/ui/dialogs/mapselect.lua').RefreshOptions( false, singlePlayer, false)
        
        aitypes = import('/lua/enhancedlobby.lua').GetAIList()
        
        Tooltip.ReloadTooltips()
        
        GetGlobalOptions()
        
        UpdateGame()
    end
end

-- host makes a specific slot closed to players
function HostCloseSlot(senderID, slot)

    -- don't close an already closed slot or an occupied slot
    if gameInfo.ClosedSlots[slot] ~= nil or gameInfo.PlayerOptions[slot] ~= nil then
        return
    end

    gameInfo.ClosedSlots[slot] = true

    lobbyComm:BroadcastData( { Type = 'SlotClose', Slot = slot } )

    UpdateGame()

end

-- host makes a specific slot open for players
function HostOpenSlot(senderID, slot)

    -- don't try to open an already open slot
    if gameInfo.ClosedSlots[slot] == nil then
        return
    end

    gameInfo.ClosedSlots[slot] = nil

    lobbyComm:BroadcastData( { Type = 'SlotOpen', Slot = slot } )

    UpdateGame()
end

-- slot less than 1 means try to find a slot
function HostTryAddPlayer( senderID, slot, requestedPlayerName, human, aiPersonality, requestedColor, requestedFaction, requestedTeam )

    local newSlot = slot

    if not slot or slot < 1 then
	
        newSlot = -1
		
        for i = 1, numOpenSlots do
		
            if gameInfo.PlayerOptions[i] == nil and gameInfo.ClosedSlots[i] == nil then
                newSlot = i
                break
            end
        end
    else
	
        if newSlot > numOpenSlots then
            newSlot = -1
        end
    end

    -- if no slot available, and human, try to make them an observer
    if newSlot == -1 then
        if human then
			PrivateChat( senderID, LOC("<LOC lobui_0237>No slots available, attempting to make you an observer"))
            HostTryAddObserver(senderID, requestedPlayerName, requestedColor or RandomColor())
        end
        return
    end

    local playerName = lobbyComm:MakeValidPlayerName(senderID,requestedPlayerName)

    gameInfo.PlayerOptions[newSlot] = LobbyComm.GetDefaultPlayerOptions(playerName)
    gameInfo.PlayerOptions[newSlot].Human = human
    gameInfo.PlayerOptions[newSlot].OwnerID = senderID
	
    gameInfo.PlayerOptions[newSlot].Faction = table.getn(FactionData.Factions) + 1
    gameInfo.PlayerOptions[newSlot].Mult = '1.0'
    gameInfo.PlayerOptions[newSlot].ACT = 1 -- Neither ACT by default

    if requestedTeam then
        gameInfo.PlayerOptions[newSlot].Team = requestedTeam
    end
	
    if not human and aiPersonality then
        gameInfo.PlayerOptions[newSlot].AIPersonality = aiPersonality
        GUI.slots[newSlot].mult:SetText(GUI.fillAIMult:GetText())
    end

    -- If a color is requested, attempt to use that color if available;
    -- otherwise, assign first available
    -- Clear out player color first so default color isn't blocked from color free list
    gameInfo.PlayerOptions[newSlot].WheelColor = nil
	
    if requestedColor and IsColorFree(requestedColor) then
        gameInfo.PlayerOptions[newSlot].WheelColor = requestedColor
    else
        -- Generate a random colour for what's probably an AI
        gameInfo.PlayerOptions[newSlot].WheelColor = RandomColor()
    end

    lobbyComm:BroadcastData( { Type = 'SlotAssigned', Slot = newSlot, Options = gameInfo.PlayerOptions[newSlot] } )

	if human then
		lobbyComm:SendData( senderID, { Type = 'PrivateChat', Text = "Lobby Hosted Using: "..gameInfo.PlayerOptions[1].LEM[1] } )
	end

    UpdateGame()
end

function HostTryMovePlayer(senderID, currentSlot, requestedSlot)

    if gameInfo.PlayerOptions[currentSlot].Ready == true then
        LOG("HostTryMovePlayer: player is marked ready and can not move")
        return
    end
    
    if gameInfo.PlayerOptions[requestedSlot] then
        LOG("HostTryMovePlayer: requested slot " .. requestedSlot .. " already occupied")
        return
    end
    
    if gameInfo.ClosedSlots[requestedSlot] ~= nil then
        LOG("HostTryMovePlayer: requested slot " .. requestedSlot .. " is closed")
        return    
    end

    if requestedSlot > numOpenSlots or requestedSlot < 1 then
        LOG("HostTryMovePlayer: requested slot " .. requestedSlot .. " is out of range")
        return
    end

    gameInfo.PlayerOptions[requestedSlot] = gameInfo.PlayerOptions[currentSlot]
    gameInfo.PlayerOptions[currentSlot] = nil
    ClearSlotInfo(currentSlot)

    lobbyComm:BroadcastData( { Type = 'SlotMove', OldSlot = currentSlot, NewSlot = requestedSlot, Options = gameInfo.PlayerOptions[requestedSlot] } )

    UpdateGame()
end

function HostTryAddObserver( senderID, requestedObserverName, requestedColor )

    local index = 18
    
    while gameInfo.Observers[index] do
        index = index + 1
    end

    local observerName = lobbyComm:MakeValidPlayerName(senderID,requestedObserverName)
	
    gameInfo.Observers[index] = {
        PlayerName = observerName,
        OwnerID = senderID,
        Color = requestedColor or RandomColor()
    }

    lobbyComm:BroadcastData( { Type = 'ObserverAdded', Slot = index, Options = gameInfo.Observers[index] } )
	
    SendSystemMessage(LOCF("<LOC lobui_0202>%s has joined as an observer.",observerName))

    UpdateGame()
    
    LOG("*AI DEBUG Added Observer using Index "..index)
end

function HostConvertPlayerToObserver(senderID, name, playerSlot)

    -- make sure player exists
    if not gameInfo.PlayerOptions[playerSlot] then
        return
    end

    -- find a free observer slot
    local index = 18
	
    while gameInfo.Observers[index] do
        index = index + 1
    end

    gameInfo.Observers[index] = {
        PlayerName = name,
        
        OwnerID = senderID,

        -- Preserve WheelColor in case player switches back from observer;
        -- they might want their colour back
        Color = gameInfo.PlayerOptions[playerSlot].WheelColor
    }
	
    gameInfo.PlayerOptions[playerSlot] = nil
	
    ClearSlotInfo(playerSlot)

    lobbyComm:BroadcastData( { Type = 'ConvertPlayerToObserver', OldSlot = playerSlot, NewSlot = index, Options = gameInfo.Observers[index] } )

    SendSystemMessage(LOCF("<LOC lobui_0226>%s has switched from a player to an observer.", name))

    UpdateGame()
    
    --LOG("*AI DEBUG Moved Player "..repr(playerSlot).." to Observer with index "..index.." gameInfo is "..repr(gameInfo) )
    
    
end

function HostConvertObserverToPlayer(senderID, name, fromObserverSlot, toPlayerSlot)

    if gameInfo.Observers[fromObserverSlot] == nil then
        return
    end

    if gameInfo.PlayerOptions[toPlayerSlot] ~= nil then
        return
    end
    
    if gameInfo.ClosedSlots[toPlayerSlot] ~= nil then
        return 
    end

    gameInfo.PlayerOptions[toPlayerSlot] = LobbyComm.GetDefaultPlayerOptions(name)
    gameInfo.PlayerOptions[toPlayerSlot].OwnerID = senderID

    gameInfo.PlayerOptions[toPlayerSlot].WheelColor = gameInfo.Observers[fromObserverSlot].Color or RandomColor()

    gameInfo.Observers[fromObserverSlot] = nil

    lobbyComm:BroadcastData( { Type = 'ConvertObserverToPlayer', OldSlot = fromObserverSlot, NewSlot = toPlayerSlot, Options =  gameInfo.PlayerOptions[toPlayerSlot] } )
	
	if lobbyComm:IsHost() then
	
		local LEMinfo = EnhancedLobby.GetLEMData()
		
		gameInfo.PlayerOptions[toPlayerSlot].LEM = LEMinfo
		
		lobbyComm:BroadcastData( { Type = 'SetLEMInfo',	Slot = toPlayerSlot, LEM = LEMinfo } )
	end

    SendSystemMessage(LOCF("<LOC lobui_0227>%s has switched from an observer to player.", name))

    UpdateGame()
    
    LOG("*AI DEBUG Moved Observer "..repr(fromObserverSlot).." to Player "..repr(toPlayerSlot))
end

function HostClearPlayer(uid)

    local slot = FindSlotForID(peerID)
	
    if slot then
        ClearSlotInfo( slot )
        gameInfo.PlayerOptions[slot] = nil

    else
	
        slot = FindObserverSlotForID(peerID)
		
        if slot then
            gameInfo.Observers[slot] = nil
        end
    end

	UpdateGame()
	
    availableMods[peerID] = nil
	
    HostUpdateMods()
end

function HostRemoveAI( slot )

    if gameInfo.PlayerOptions[slot].Human then
        WARN('Use EjectPlayer to remove humans')
        return
    end

    ClearSlotInfo(slot)
	
    gameInfo.PlayerOptions[slot] = nil
	
    lobbyComm:BroadcastData( { Type = 'ClearSlot', Slot = slot } )

    UpdateGame()
end

function HostPlayerMissingMapAlert(id)

    local slot = FindSlotForID(id)
    local name = ""
    local needMessage = false
	
    if slot then
        name = gameInfo.PlayerOptions[slot].PlayerName
		
        if not gameInfo.PlayerOptions[slot].BadMap then
			needMessage = true
		end
		
        gameInfo.PlayerOptions[slot].BadMap = true
		
    else
        slot = FindObserverSlotForID(id)
        if slot then
            name = gameInfo.Observers[slot].PlayerName
            if not gameInfo.Observers[slot].BadMap then needMessage = true end
            gameInfo.Observers[slot].BadMap = true
        end
    end

    if needMessage then
        SendSystemMessage(LOCF("<LOC lobui_0330>%s is missing map/wrong verion %s.", name, gameInfo.GameOptions.ScenarioFile))
    end        
end

function ClientsMissingMap()

    local ret = nil

    for index, player in gameInfo.PlayerOptions do
	
        if player.BadMap == true then
            if not ret then ret = {} end
            table.insert(ret, player.PlayerName)
        end
		
    end

    for index, observer in gameInfo.Observers do
	
        if observer.BadMap == true then
            if not ret then ret = {} end
            table.insert(ret, observer.PlayerName)
        end
		
    end
    
    return ret
end

function ClearBadMapFlags()

    for index, player in gameInfo.PlayerOptions do
        player.BadMap = nil
    end

    for index, observer in gameInfo.Observers do
        observer.BadMap = nil
    end
end

function ShowColorPicker(row, x, y)
-- Helper functions
-- Credit for converters: https://gist.github.com/GigsD4X/8513963
    local function HSVToRGB(hue, saturation, value)
        -- Returns the RGB equivalent of the given HSV-defined color
        -- (adapted from some code found around the web)
    
        -- If it's achromatic, just return the value
        if saturation == 0 then
            return value, value, value;
        end;
    
        -- Get the hue sector
        local hue_sector = math.floor(hue / 60);
        local hue_sector_offset = (hue / 60) - hue_sector;
    
        local p = value * (1 - saturation);
        local q = value * (1 - saturation * hue_sector_offset);
        local t = value * (1 - saturation * (1 - hue_sector_offset));
    
        if hue_sector == 0 then
            return value, t, p
        elseif hue_sector == 1 then
            return q, value, p
        elseif hue_sector == 2 then
            return p, value, t
        elseif hue_sector == 3 then
            return p, q, value
        elseif hue_sector == 4 then
            return t, p, value
        elseif hue_sector == 5 then
            return value, p, q
        end
    end

    -- Note: returns lightness between 0, 255
    local function RGBToHSV(red, green, blue)
        -- Returns the HSV equivalent of the given RGB-defined color
        -- (adapted from some code found around the web)
    
        local hue, saturation, value
    
        local min_value = math.min(red, green, blue)
        local max_value = math.max(red, green, blue)
    
        value = max_value
    
        local value_delta = max_value - min_value
    
        -- If the color is not black
        if max_value ~= 0 then
            saturation = value_delta / max_value
    
        -- If the color is purely black
        else
            saturation = 0
            hue = -1
            return hue, saturation, value
        end;
    
        if red == max_value then
            hue = (green - blue) / value_delta
        elseif green == max_value then
            hue = 2 + (blue - red) / value_delta
        else
            hue = 4 + (red - green) / value_delta
        end
    
        hue = hue * 60
        if hue < 0 then
            hue = hue + 360
        end
    
        return hue, saturation, value
    end

    -- colorPicker.color is stored as an ARGB string to maintain simplicity
    -- across this module. Use RGBStr() for values the user sees
    local function RGBStr()
        return string.sub(colorPicker.color, 3, 8)
    end

-- Core
    colorPicker = Bitmap(GUI, UIUtil.UIFile('/dialogs/exit-dialog/panel02_bmp.dds'))
    colorPicker.Left:Set(x)
    colorPicker.Top:Set(y)
    colorPicker.Depth:Set(GUI.Depth() + 20)
    -- "Color circle (RGB)" distributed under CC BY-SA 4.0
    -- Author: Sanjay7373, Wikimedia Commons
    -- https://creativecommons.org/licenses/by-sa/4.0/deed.en
    colorPicker.wheel = Bitmap(colorPicker, UIUtil.UIFile('/lobby/colorwheel.dds'))
    LayoutHelpers.AtTopIn(colorPicker.wheel, colorPicker, 8)
    LayoutHelpers.AtHorizontalCenterIn(colorPicker.wheel, colorPicker)
    colorPicker.wheel.Depth:Set(colorPicker.Depth() + 2)
    colorPicker.overlay = Bitmap(colorPicker, UIUtil.UIFile('/lobby/colorwheel_overlay.dds'))
    colorPicker.overlay.Depth:Set(colorPicker.wheel.Depth() + 1)
    colorPicker.overlay:DisableHitTest()
    LayoutHelpers.AtCenterIn(colorPicker.overlay, colorPicker.wheel)
    local c = gameInfo.PlayerOptions[row].WheelColor
    colorPicker.color = ColorToStr(c)
    -- H, S, and V are stored as [0..360], [0..1], [0..255], respectively
    colorPicker.hue, colorPicker.sat, colorPicker.val = RGBToHSV(c[1], c[2], c[3])
    colorPicker.overlay:SetAlpha((255 - colorPicker.val) / 255)
    colorPicker.wheelCentre = {
        x = colorPicker.wheel.Left() + (colorPicker.wheel.Width() / 2),
        y = colorPicker.wheel.Top() + (colorPicker.wheel.Height() / 2),
    }
    colorPicker.preview = Bitmap(colorPicker)
	LayoutHelpers.SetDimensions(colorPicker.preview, 60, 20)
    colorPicker.preview:SetSolidColor(colorPicker.color)
    colorPicker.wheel.HandleEvent = function(self, event)
        if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            local cX = event.MouseX - colorPicker.wheelCentre.x 
            local cY = event.MouseY - colorPicker.wheelCentre.y
            local dist = LayoutHelpers.InvScaleNumber(math.sqrt(math.pow(cX, 2) + math.pow(cY, 2)))
            if dist > 120 then return end -- User has clicked outside wheel
            local vUp = {
                x = 0,
                y = -120,
            }
            local vE = {
                x = cX,
                y = cY,
            }
            local angle = math.atan2(vE.y, vE.x) - math.atan2(vUp.y, vUp.x)
            if angle < 0 then angle = angle + (2 * math.pi) end -- Normalize
            colorPicker.hue = math.deg(angle)
            colorPicker.sat = dist * (1 / 120)
            local r, g, b = HSVToRGB(colorPicker.hue, colorPicker.sat, colorPicker.val / 255)
            colorPicker.color = string.format("%02x%02x%02x%02x", 255, r * 255, g * 255, b * 255)
            colorPicker.preview:SetSolidColor(colorPicker.color)
            colorPicker.readout:SetText(RGBStr())
        end
    end
-- Value (lightness) slider
    colorPicker.valStatus = StatusBar(colorPicker, 0, 255, false, false, UIUtil.UIFile('/slider/slider-back_bmp.dds'), UIUtil.UIFile('/slider/slider-back_bmp.dds'), false)

    colorPicker.valSlider = import('/lua/maui/slider.lua').Slider(colorPicker, false, 0, 255, UIUtil.UIFile('/slider/slider_btn_up.dds'), UIUtil.UIFile('/slider/slider_btn_over.dds'), UIUtil.UIFile('/slider/slider_btn_down.dds'))

    LayoutHelpers.AnchorToBottom(colorPicker.valSlider, colorPicker.wheel, 18)
	LayoutHelpers.AtLeftIn(colorPicker.valSlider, colorPicker, 16)
	LayoutHelpers.AtRightIn(colorPicker.valSlider, colorPicker, 16)
    colorPicker.valSlider:SetValue(colorPicker.val)

    colorPicker.valSlider.OnValueChanged = function(self, newValue)
        colorPicker.val = newValue
        local r, g, b = HSVToRGB(colorPicker.hue, colorPicker.sat, colorPicker.val / 255)
        colorPicker.color = string.format("%02x%02x%02x%02x", 255, r * 255, g * 255, b * 255)
        colorPicker.overlay:SetAlpha((255 - colorPicker.val) / 255)
        colorPicker.preview:SetSolidColor(colorPicker.color)
        colorPicker.readout:SetText(RGBStr())
    end
	LayoutHelpers.AtTopIn(colorPicker.valStatus, colorPicker.valSlider, -10)
    colorPicker.valStatus.Left:Set(colorPicker.valSlider.Left)
    colorPicker.valStatus.Right:Set(colorPicker.valSlider.Right)
    colorPicker.valStatus.Depth:Set(function() return colorPicker.valSlider.Depth() - 1 end)
    colorPicker.valStatus:SetRange(0, 255)
    colorPicker.valStatus:SetValue(colorPicker.val)

    LayoutHelpers.Below(colorPicker.preview, colorPicker.valSlider, 12)
    LayoutHelpers.AtHorizontalCenterIn(colorPicker.preview, colorPicker)

    -- Confirm button
    colorPicker.confirm = UIUtil.CreateButtonStd(colorPicker, '/lobby/lan-game-lobby/smalltoggle', "Confirm", 12, 2)

    LayoutHelpers.LeftOf(colorPicker.confirm, colorPicker.preview, 4)

    colorPicker.confirm.OnClick = function(self, modifiers)
        Tooltip.DestroyMouseoverDisplay()
        local color = ColorToArray(colorPicker.color)
        -- Try getting colour from edit field if valid
        local editText = colorPicker.edit:GetText()
        if string.len(editText) == 6 then
            colorPicker.color = 'FF'..editText
            color = ColorToArray(colorPicker.color)
            local r, g, b = RGBToHSV(color[1], color[2], color[3])
            colorPicker.hue = r
            colorPicker.sat = g
            colorPicker.val = b
            colorPicker.readout:SetText(RGBStr())
            colorPicker.preview:SetSolidColor(colorPicker.color)
        end

        if not lobbyComm:IsHost() then
            lobbyComm:SendData(hostID, { Type = 'RequestColor', Color = color, Slot = row } )
            gameInfo.PlayerOptions[row].WheelColor = color
            UpdateGame()
        else
            if IsColorFree(color) then
                lobbyComm:BroadcastData( { Type = 'SetColor', Color = color, Slot = row } )
                gameInfo.PlayerOptions[row].WheelColor = color
                LOG("*AI DEBUG HostCreateUI - Host Set Player Color")
                UpdateGame()
            else
                colorPicker.color = ColorToStr(gameInfo.PlayerOptions[row].WheelColor)
                GUI.slots[row].color:SetSolidColor(colorPicker.color)
            end
        end
        colorPicker:Destroy()
        colorPicker = false
    end

    colorPicker.cancel = UIUtil.CreateButtonStd(colorPicker, '/lobby/lan-game-lobby/smalltoggle', "Cancel", 12, 2)

    LayoutHelpers.Below(colorPicker.cancel, colorPicker.confirm, -4)

    colorPicker.cancel.OnClick = function(self, modifiers)
        Tooltip.DestroyMouseoverDisplay()
        colorPicker:Destroy()
        colorPicker = false
    end

    -- Readout to tell user hex code
    colorPicker.readout = UIUtil.CreateText(colorPicker, RGBStr(), 14, UIUtil.bodyFont)
    LayoutHelpers.Below(colorPicker.readout, colorPicker.preview, 4)
    -- Text I/O
    colorPicker.edit = Edit(colorPicker)
    LayoutHelpers.RightOf(colorPicker.edit, colorPicker.preview, 4)
	LayoutHelpers.SetDimensions(colorPicker.edit, 80, 14)
    colorPicker.edit:SetFont(UIUtil.bodyFont, 12)
    colorPicker.edit:SetForegroundColor(UIUtil.fontColor)
    colorPicker.edit:SetHighlightBackgroundColor('00000000')
    colorPicker.edit:SetHighlightForegroundColor(UIUtil.fontColor)
    colorPicker.edit:ShowBackground(true)
    colorPicker.edit:SetMaxChars(6)

    colorPicker.edit.OnCharPressed = function(self, charcode)
        -- Forbid non-hex characters
        if charcode == UIUtil.VK_TAB then
            return true
        end
        if (charcode >= 48 and charcode <= 57)
        or (charcode >= 65 and charcode <= 70)
        or (charcode >= 97 and charcode <= 102) then
            return false
        end
        local charLim = self:GetMaxChars()
        if STR_Utf8Len(self:GetText()) >= charLim then
            local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
            PlaySound(sound)
        end
    end

    colorPicker.edit.OnLoseKeyboardFocus = function(self)
        colorPicker.edit:AcquireFocus()    
    end
    
    colorPicker.edit.OnEnterPressed = function(self, text)
        if string.len(text) ~= 6 then
            return
        end
        colorPicker.color = 'FF'..text
        local c = ColorToArray(colorPicker.color)
        local r, g, b = RGBToHSV(c[1], c[2], c[3])
        colorPicker.hue = r
        colorPicker.sat = g
        colorPicker.val = b
        colorPicker.readout:SetText(RGBStr())
        colorPicker.preview:SetSolidColor(colorPicker.color)
    end

    colorPicker.edit.OnEscPressed = function(self, text)
        return true
    end
end

-- create UI won't typically be called directly by another module
function CreateUI(maxPlayers, useSteam)

    local BitmapCombo   = import('/lua/ui/controls/combo.lua').BitmapCombo
    local Checkbox      = import('/lua/maui/checkbox.lua').Checkbox
    local Combo         = import('/lua/ui/controls/combo.lua').Combo
    local EffectHelpers = import('/lua/maui/effecthelpers.lua')
    local ItemList      = import('/lua/maui/itemlist.lua').ItemList
    local MapPreview    = import('/lua/ui/controls/mappreview.lua').MapPreview
    local MultiLineText = import('/lua/maui/multilinetext.lua').MultiLineText
    local Prefs         = import('/lua/user/prefs.lua')
    --local StatusBar     = import('/lua/maui/statusbar.lua').StatusBar
    --local Text          = import('/lua/maui/text.lua').Text	

	local ELobbyVersion = import('/lua/enhancedlobby.lua').GetLEMVersion()
    
    aitypes = import('/lua/enhancedlobby.lua').GetAIList()
	
    UIUtil.SetCurrentSkin('uef')
    
    if (GUI.connectdialog ~= false) then
        import('/lua/ui/menus/menucommon.lua').MenuCleanup()
        GUI.connectdialog:Destroy()
        GUI.connectdialog = false
    end

    local title
	
    if singlePlayer then
        title = "<LOC _Skirmish_Setup>"

	elseif useSteam then
		title = "<LOC _Matchmaking_Game_Lobby>Matchmaking Game"  

    else
        title = "<LOC _LAN_Game_Lobby>"
    end

    -----------------------------
    -- Set up main control panels
    -----------------------------
    if singlePlayer then
        GUI.panel = Bitmap(GUI, UIUtil.SkinnableFile("/scx_menu/lan-game-lobby/panel-skirmish_bmp.dds"))
    else
        GUI.panel = Bitmap(GUI, UIUtil.SkinnableFile("/scx_menu/lan-game-lobby/panel_bmp.dds"))
    end

    LayoutHelpers.AtCenterIn(GUI.panel, GUI)
    GUI.panel.brackets = UIUtil.CreateDialogBrackets(GUI.panel, 18, 17, 18, 15)

    local titleText = UIUtil.CreateText(GUI.panel, title, 26, UIUtil.titleFont)
    LayoutHelpers.AtLeftTopIn(titleText, GUI.panel, 50, 36)
	
	local lobbyEnhancementText = UIUtil.CreateText(GUI.panel, ELobbyVersion, 18, UIUtil.titleFont)
	
	LayoutHelpers.CenteredRightOf(lobbyEnhancementText, titleText, 150)

    GUI.playerPanel = Group(GUI.panel, "playerPanel")
    LayoutHelpers.AtLeftTopIn(GUI.playerPanel, GUI.panel, 40, 66)
	LayoutHelpers.SetDimensions(GUI.playerPanel, 706, 387)

    GUI.observerPanel = Group(GUI.panel, "observerPanel")
    LayoutHelpers.AtLeftTopIn(GUI.observerPanel, GUI.panel, 40, 458)
	LayoutHelpers.SetDimensions(GUI.observerPanel, 706, 34)

    GUI.chatPanel = Group(GUI.panel, "chatPanel")
    LayoutHelpers.AtLeftTopIn(GUI.chatPanel, GUI.panel, 40, 646)
	LayoutHelpers.SetDimensions(GUI.chatPanel, 705, 25)

    GUI.mapPanel = Group(GUI.panel, "mapPanel")
    LayoutHelpers.AtLeftTopIn(GUI.mapPanel, GUI.panel, 750, 68)
	LayoutHelpers.SetDimensions(GUI.mapPanel, 238, 600)

    GUI.optionsPanel = Group(GUI.panel, "optionsPanel")
    LayoutHelpers.AtLeftTopIn(GUI.optionsPanel, GUI.panel, 746, 600)
	LayoutHelpers.SetDimensions(GUI.optionsPanel, 238, 260)

    GUI.launchPanel = Group(GUI.panel, "controlGroup")
    LayoutHelpers.AtLeftTopIn(GUI.launchPanel, GUI.panel, 735, 668)
	LayoutHelpers.SetDimensions(GUI.launchPanel, 238, 66)

    -------------------
    -- set up map panel
    -------------------
    local mapOverlay = Bitmap(GUI.mapPanel, UIUtil.SkinnableFile("/lobby/lan-game-lobby/map-pane-border_bmp.dds"))
	
    LayoutHelpers.AtLeftTopIn(mapOverlay, GUI.panel, 750, 69) -- 74
	
    mapOverlay:DisableHitTest()

    GUI.mapView = MapPreview(GUI.mapPanel)
	
    LayoutHelpers.AtCenterIn(GUI.mapView, mapOverlay)
	
	LayoutHelpers.SetDimensions(GUI.mapView, 195, 195)

    mapOverlay.Depth:Set(function() return GUI.mapView.Depth() + 10 end)

    GUI.mapName = UIUtil.CreateText(GUI.mapPanel, "", 16, UIUtil.titleFont)
    GUI.mapName:SetColor(UIUtil.bodyColor)
    LayoutHelpers.CenteredBelow(GUI.mapName, mapOverlay, 15) -- 10

    GUI.changeMapButton = UIUtil.CreateButtonStd(GUI.mapPanel, '/scx_menu/small-btn/small', "<LOC map_sel_0000>Game Options", 12, 2)
    LayoutHelpers.AtBottomIn(GUI.changeMapButton, GUI.mapPanel, -6)
    LayoutHelpers.AtHorizontalCenterIn(GUI.changeMapButton, GUI.mapPanel)

    Tooltip.AddButtonTooltip(GUI.changeMapButton, 'lob_select_map')

    GUI.changeMapButton.OnClick = function(self)
	
        local mapSelectDialog
		
		GUI.randomMapButton:Show()
		
        local function selectBehavior(selectedScenario, changedOptions, restrictedCategories)
		
            Prefs.SetToCurrentProfile('LastScenario', selectedScenario.file)
			
            mapSelectDialog:Destroy()
			
            GUI.chatEdit:AcquireFocus() 
            
            for optionKey, data in changedOptions do
                if data.type and data.type == 'edit' then
                    Prefs.SetToCurrentProfile(data.pref, data.value)
                else
                    Prefs.SetToCurrentProfile(data.pref, data.index)
                end
                SetGameOption(optionKey, data.value)
            end
			
            SetGameOption('ScenarioFile',selectedScenario.file)
			
			Prefs.SetToCurrentProfile('RestrictedCategories', restrictedCategories)
            SetGameOption('RestrictedCategories', restrictedCategories, true)
			
            ClearBadMapFlags()  -- every new map, clear the flags, and clients will report if a new map is bad
			
            HostUpdateMods()
        end

        local function exitBehavior()
		
            mapSelectDialog:Destroy()
			
            GUI.chatEdit:AcquireFocus()
			
        end

        GUI.chatEdit:AbandonFocus()
		
		if EveryoneHasLEM() then
		
			mapSelectDialog = import('/lua/ui/dialogs/mapselect.lua').CreateDialog(	selectBehavior,	exitBehavior, GUI, singlePlayer, gameInfo.GameOptions.ScenarioFile, gameInfo.GameOptions, nil, OnModsChanged )
			
		else
		
			mapSelectDialog = import('/lua/ui/dialogs/mapselect.lua').CreateDialog(	selectBehavior,	exitBehavior, GUI, singlePlayer, gameInfo.GameOptions.ScenarioFile,	gameInfo.GameOptions, availableMods, OnModsChanged )
			
		end

    end

    ----------------------
    -- set up launch panel
    ----------------------
    GUI.launchGameButton = UIUtil.CreateButtonStd(GUI.launchPanel, '/scx_menu/large-no-bracket-btn/large', "<LOC lobui_0212>Launch", 18, 4)
    GUI.exitButton = UIUtil.CreateButtonStd(GUI.launchPanel, '/scx_menu/small-btn/small', "", 18, 4)


    GUI.exitButton.label:SetText(LOC("<LOC _Back>"))
    
    import('/lua/ui/uimain.lua').SetEscapeHandler(function() GUI.exitButton.OnClick(GUI.exitButton) end)

    LayoutHelpers.AtCenterIn(GUI.launchGameButton, GUI.launchPanel, -1, -22)
    LayoutHelpers.AtLeftIn(GUI.exitButton, GUI.chatPanel, 10)
    LayoutHelpers.AtVerticalCenterIn(GUI.exitButton, GUI.launchGameButton)
	
	GUI.randomMapButton = UIUtil.CreateButtonStd(GUI.launchPanel, '/scx_menu/small-btn/small', "Random Map", 18, 4)
	LayoutHelpers.RightOf(GUI.randomMapButton, GUI.exitButton)
	GUI.randomMapButton:Hide()
	Tooltip.AddButtonTooltip(GUI.randomMapButton, 'lob_random_map')
	
	GUI.randomMapButton.OnClick = function(self)
		import('/lua/ui/dialogs/mapselect.lua').randomLobbyMap(self)
	end

    GUI.launchGameButton:UseAlphaHitTest(false)
    GUI.launchGameButton.glow = Bitmap(GUI.launchGameButton, UIUtil.UIFile('/menus/main03/large_btn_glow.dds'))
    LayoutHelpers.AtCenterIn(GUI.launchGameButton.glow, GUI.launchGameButton)
    GUI.launchGameButton.glow:SetAlpha(0)
    GUI.launchGameButton.glow:DisableHitTest()

    GUI.launchGameButton.OnRolloverEvent = function(self, event) 
           if event == 'enter' then
            EffectHelpers.FadeIn(self.glow, .25, 0, 1)
            self.label:SetColor('black')
        elseif event == 'down' then
            self.label:SetColor('black')
        else
            EffectHelpers.FadeOut(self.glow, .4, 1, 0)
            self.label:SetColor(UIUtil.fontColor)
        end
    end
    
    GUI.launchGameButton.pulse = Bitmap(GUI.launchGameButton, UIUtil.UIFile('/menus/main03/large_btn_glow.dds'))
    LayoutHelpers.AtCenterIn(GUI.launchGameButton.pulse, GUI.launchGameButton)
    GUI.launchGameButton.pulse:DisableHitTest()
    GUI.launchGameButton.pulse:SetAlpha(.5)
    EffectHelpers.Pulse(GUI.launchGameButton.pulse, 2, .5, 1)
    
    Tooltip.AddButtonTooltip(GUI.launchGameButton, 'Lobby_Launch')

    --- hide unless we're the game host
    GUI.launchGameButton:Hide()

    GUI.launchGameButton.OnClick = function(self)
        TryLaunch(false)
    end

    ---------------
    -- chat display
    ---------------
    GUI.chatEdit = Edit(GUI.chatPanel)

    LayoutHelpers.AtLeftTopIn(GUI.chatEdit, GUI.panel, 84, 634)
	LayoutHelpers.SetDimensions(GUI.chatEdit, 640, 14)

    GUI.chatEdit:SetFont(UIUtil.bodyFont, 12)
    GUI.chatEdit:SetForegroundColor(UIUtil.fontColor)
    GUI.chatEdit:SetHighlightBackgroundColor('00000000')
    GUI.chatEdit:SetHighlightForegroundColor(UIUtil.fontColor)
    GUI.chatEdit:ShowBackground(false)
    GUI.chatEdit:AcquireFocus()

    GUI.chatDisplay = ItemList(GUI.chatPanel)
    GUI.chatDisplay:SetFont(UIUtil.bodyFont, 12)
    GUI.chatDisplay:SetColors(UIUtil.fontColor(), "00000000", UIUtil.fontColor(), "00000000")

    LayoutHelpers.AtLeftTopIn(GUI.chatDisplay, GUI.panel, 50, 504)
    LayoutHelpers.AnchorToTop(GUI.chatDisplay, GUI.chatEdit, 15)
	LayoutHelpers.AtRightIn(GUI.chatDisplay, GUI.chatPanel, 40)

    GUI.chatDisplay.Height:Set(function() return GUI.chatDisplay.Bottom() - GUI.chatDisplay.Top() end)
    GUI.chatDisplay.Width:Set(function() return GUI.chatDisplay.Right() - GUI.chatDisplay.Left() end)

    GUI.chatDisplayScroll = UIUtil.CreateVertScrollbarFor(GUI.chatDisplay)
    
    GUI.chatEdit:SetMaxChars(200)

    GUI.chatEdit.OnCharPressed = function(self, charcode)
        if charcode == UIUtil.VK_TAB then
            return true
        end
        local charLim = self:GetMaxChars()
        if STR_Utf8Len(self:GetText()) >= charLim then
            local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
            PlaySound(sound)
        end
    end
    
    GUI.chatEdit.OnLoseKeyboardFocus = function(self)
        GUI.chatEdit:AcquireFocus()
    end
    
    GUI.chatEdit.OnEnterPressed = function(self, text)
        if text ~= "" then

            table.insert(commandQueue, 1, text)
            commandQueueIndex = 0
            if GUI.chatDisplay then
                --this next section just removes /commmands from broadcasting.
                if string.sub(text, 1, 1) == '/' then
                    local spaceStart = string.find(text, " ") or string.len(text)
                    local comKey = string.sub(text, 2, spaceStart - 1)
					local altcomKey = string.sub(text, 2, spaceStart)
                    local params = string.sub(text, spaceStart + 1)
                    local found = false
                    for i, command in commands do
                        if command.key == string.lower(comKey) or command.key == string.lower(altcomKey) then
                            command.action(params)
                            found = true
                            break
                        end
                    end
                    if not found then
                        AddChatText(LOCF("<LOC lobui_0396>Command Not Known: %s", comKey))
                    end
                else
                    PublicChat(text)
                end
            end
        end
    end

    GUI.chatEdit.OnNonTextKeyPressed = function(self, keyCode)
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

    ---------------
    -- team Options
    ---------------
	GUI.teamsLabel = UIUtil.CreateText(GUI.optionsPanel, "Teams", 14, UIUtil.bodyFont)

	LayoutHelpers.AtLeftTopIn(GUI.teamsLabel, GUI.mapPanel, 5, 235)
	
	GUI.teamsCombo = Combo(GUI.optionsPanel, 14, 10, false, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")

	LayoutHelpers.CenteredRightOf(GUI.teamsCombo, GUI.teamsLabel, 5)
	LayoutHelpers.SetWidth(GUI.teamsCombo, 60)

	Tooltip.AddControlTooltip(GUI.teamsCombo, 'lob_teams_combo')
	
	GUI.teamsBtn = UIUtil.CreateButtonStd(GUI.optionsPanel, '/lobby/lan-game-lobby/toggle', "Setup Teams", 10, 0)

	LayoutHelpers.CenteredRightOf(GUI.teamsBtn, GUI.teamsCombo, 5)

	Tooltip.AddButtonTooltip(GUI.teamsBtn, 'lob_random_teams')
	
	GUI.teamsBtn.OnClick = function(self, modifiers)

		if lobbyComm:IsHost() then

			local key, text = GUI.teamsCombo:GetItem()

			if key > 7 then
				if key == 8 then -- T/B
					local midLine = GUI.mapView.Top() + (GUI.mapView.Height() / 2)
					for i = 1, LobbyComm.maxPlayerSlots do
						if not gameInfo.ClosedSlots[i] and gameInfo.PlayerOptions[i] then
							local markerPos = GUI.markers[i].marker.Top()
							if markerPos < midLine then
								SetPlayerOption(i, 'Team', 2, true)
							else
								SetPlayerOption(i, 'Team', 3, true)
							end
						end
					end
				elseif key == 9 then -- L/R
					local midLine = GUI.mapView.Left() + (GUI.mapView.Width() / 2)
					for i = 1, LobbyComm.maxPlayerSlots do
						if not gameInfo.ClosedSlots[i] and gameInfo.PlayerOptions[i] then
							local markerPos = GUI.markers[i].marker.Left()
							if markerPos < midLine then
								SetPlayerOption(i, 'Team', 2, true)
							else
								SetPlayerOption(i, 'Team', 3, true)
							end
						end
					end
				else
					WARN('*DEBUG: Unknown option for random teams!')
				end
			else
				
				local num_teams = tonumber(text)
				local current_team = 1
				---local randomFactionID = table.getn(FactionData.Factions) + 1
				for i = 1, LobbyComm.maxPlayerSlots do
					if not gameInfo.ClosedSlots[i] and gameInfo.PlayerOptions[i] then
						---Team values begin at 2 (for team 1). Odd yes.
						SetPlayerOption(i, 'Team', current_team + 1, true)
						
						---SetPlayerOption(i, 'Faction', randomFactionID, true)
						current_team = current_team + 1
						if current_team > num_teams then
							current_team = 1
						end
					end
				end
			
				---local teams = tonumber(text)
				---local perTeam = math.ceil(GetPlayerCount() / teams)
				---local teamSlots = {}
				---for x = 1, teams do
				---	teamSlots[x] = perTeam
				---end
				---for i = 1, LobbyComm.maxPlayerSlots do
				---	if not gameInfo.ClosedSlots[i] and gameInfo.PlayerOptions[i] then
				---		local playerTeam = Random(1,teams)
				---		if teamSlots[playerTeam] <= 0 then
				---			for k,v in teamSlots do
				---				if v > 0 then
				---					playerTeam = k
				---					break
				---				end
				---			end
				---		end
				---		teamSlots[playerTeam] = teamSlots[playerTeam] - 1
				---		SetPlayerOption(i, 'Team', playerTeam + 1, true)
				---	end
				---end
			end
		end
	end 

    -----------------
    -- Option display
    -----------------
    GUI.OptionContainer = Group(GUI.optionsPanel)

	LayoutHelpers.SetDimensions(GUI.OptionContainer, 182, 254)

    GUI.OptionContainer.top = 0

    LayoutHelpers.AtLeftTopIn(GUI.OptionContainer, GUI.mapPanel, 15, 280)
    
    GUI.OptionDisplay = {}

    RefreshOptionDisplayData()
    
    local function CreateOptionElements()

        local function CreateElement(index)
            GUI.OptionDisplay[index] = Group(GUI.OptionContainer)
			LayoutHelpers.SetHeight(GUI.OptionDisplay[index], 36)
            GUI.OptionDisplay[index].Width:Set(GUI.OptionContainer.Width)
            GUI.OptionDisplay[index].Depth:Set(function() return GUI.OptionContainer.Depth() + 10 end)
            GUI.OptionDisplay[index]:DisableHitTest()

            GUI.OptionDisplay[index].text = UIUtil.CreateText(GUI.OptionDisplay[index], '', 14, "Arial")
            GUI.OptionDisplay[index].text:SetColor(UIUtil.fontColor)
            GUI.OptionDisplay[index].text:DisableHitTest()
            LayoutHelpers.AtLeftTopIn(GUI.OptionDisplay[index].text, GUI.OptionDisplay[index], 5)        
               
            GUI.OptionDisplay[index].value = UIUtil.CreateText(GUI.OptionDisplay[index], '', 14, "Arial")
            GUI.OptionDisplay[index].value:SetColor(UIUtil.fontOverColor)
            GUI.OptionDisplay[index].value:DisableHitTest()
            LayoutHelpers.AtRightTopIn(GUI.OptionDisplay[index].value, GUI.OptionDisplay[index], 5, 16)   
            
            GUI.OptionDisplay[index].value.bg = Bitmap(GUI.OptionDisplay[index])
            GUI.OptionDisplay[index].value.bg:SetSolidColor('ff333333')
            GUI.OptionDisplay[index].value.bg.Left:Set(GUI.OptionDisplay[index].Left)
            GUI.OptionDisplay[index].value.bg.Right:Set(GUI.OptionDisplay[index].Right)
			LayoutHelpers.AtBottomIn(GUI.OptionDisplay[index].value.bg, GUI.OptionDisplay[index].value, -2)
            GUI.OptionDisplay[index].value.bg.Top:Set(GUI.OptionDisplay[index].Top)
            GUI.OptionDisplay[index].value.bg.Depth:Set(function() return GUI.OptionDisplay[index].Depth() - 2 end)
            
            GUI.OptionDisplay[index].value.bg2 = Bitmap(GUI.OptionDisplay[index])
            GUI.OptionDisplay[index].value.bg2:SetSolidColor('ff000000')
			LayoutHelpers.AtLeftIn(GUI.OptionDisplay[index].value.bg2, GUI.OptionDisplay[index].value.bg, 1)
			LayoutHelpers.AtRightIn(GUI.OptionDisplay[index].value.bg2, GUI.OptionDisplay[index].value.bg, 1)
			LayoutHelpers.AtBottomIn(GUI.OptionDisplay[index].value.bg2, GUI.OptionDisplay[index].value.bg, 1)
            GUI.OptionDisplay[index].value.bg2.Top:Set(GUI.OptionDisplay[index].value.Top)
            GUI.OptionDisplay[index].value.bg2.Depth:Set(function() return GUI.OptionDisplay[index].value.bg.Depth() + 1 end)
        end
        
        CreateElement(1)
        LayoutHelpers.AtLeftTopIn(GUI.OptionDisplay[1], GUI.OptionContainer)

        local index = 2

        while GUI.OptionDisplay[table.getsize(GUI.OptionDisplay)].Bottom() + GUI.OptionDisplay[1].Height() < GUI.OptionContainer.Bottom() do
            CreateElement(index)
            LayoutHelpers.Below(GUI.OptionDisplay[index], GUI.OptionDisplay[index-1])
            index = index + 1
        end
    end
	
    CreateOptionElements()

    local numLines = function() return table.getsize(GUI.OptionDisplay) end
    
    local function DataSize()
        return table.getn(formattedOptions)
    end
    
    -- called when the scrollbar for the control requires data to size itself
    -- GetScrollValues must return 4 values in this order:
    -- rangeMin, rangeMax, visibleMin, visibleMax -- axis can be "Vert" or "Horz"
    GUI.OptionContainer.GetScrollValues = function(self, axis)
        local size = DataSize()
        --LOG(size, ":", self.top, ":", math.min(self.top + numLines, size))
        return 0, size, self.top, math.min(self.top + numLines(), size)
    end

    -- called when the scrollbar wants to scroll a specific number of lines (negative indicates scroll up)
    GUI.OptionContainer.ScrollLines = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta))
    end

    -- called when the scrollbar wants to scroll a specific number of pages (negative indicates scroll up)
    GUI.OptionContainer.ScrollPages = function(self, axis, delta)
        self:ScrollSetTop(axis, self.top + math.floor(delta) * numLines())
    end

    -- called when the scrollbar wants to set a new visible top line
    GUI.OptionContainer.ScrollSetTop = function(self, axis, top)
        top = math.floor(top)
        if top == self.top then return end
        local size = DataSize()
        self.top = math.max(math.min(size - numLines() , top), 0)
        self:CalcVisible()
    end

    -- called to determine if the control is scrollable on a particular access. Must return true or false.
    GUI.OptionContainer.IsScrollable = function(self, axis)
        return true
    end

    -- determines what controls should be visible or not
    GUI.OptionContainer.CalcVisible = function(self)

        local function SetTextLine(line, data, lineID)

            if data.mod then
                line.text:SetColor('ffff7777') -- Mid-red
                LayoutHelpers.AtHorizontalCenterIn(line.text, line, 5)
                LayoutHelpers.AtHorizontalCenterIn(line.value, line, 5, 16) 
                LayoutHelpers.ResetRight(line.value) 

            elseif data.totalUnitCap then
                line.text:SetColor('fff5cb42') -- Mid-orange
                LayoutHelpers.AtHorizontalCenterIn(line.text, line, 5)
                LayoutHelpers.AtHorizontalCenterIn(line.value, line, 5, 16) 
                LayoutHelpers.ResetRight(line.value) 

            else
                line.text:SetColor(UIUtil.fontColor)
                LayoutHelpers.AtLeftTopIn(line.text, line, 5)
                LayoutHelpers.AtRightTopIn(line.value, line, 5, 16)  
                LayoutHelpers.ResetLeft(line.value)
            end

            local wrappedText = import('/lua/maui/text.lua').FitText(LOC(data.text), 
                LayoutHelpers.ScaleNumber(170), -- Can't use line.text.Width() here or lobby crashes
                function(text)
                    return line.text:GetStringAdvance(text)
                end)

            if table.getn(wrappedText) > 1 then
                line.text:SetText(wrappedText[1]..'...')
            else
                line.text:SetText(wrappedText[1])
            end

            line.value:SetText(LOC(data.value))
            line.value.bg.HandleEvent = Group.HandleEvent
            line.value.bg2.HandleEvent = Bitmap.HandleEvent

            if data.tooltip then
                Tooltip.AddControlTooltip(line.value.bg, data.tooltip)
                Tooltip.AddControlTooltip(line.value.bg2, data.valueTooltip)
            end

        end

        for i, v in GUI.OptionDisplay do
            if formattedOptions[i + self.top] then
                SetTextLine(v, formattedOptions[i + self.top], i + self.top)
            end
        end
    end
    
    GUI.OptionContainer:CalcVisible()
    
    GUI.OptionContainer.HandleEvent = function(self, event)
        if event.Type == 'WheelRotation' then
            local lines = 1
            if event.WheelRotation > 0 then
                lines = -1
            end
            self:ScrollLines(nil, lines)
        end
    end
    
    UIUtil.CreateVertScrollbarFor(GUI.OptionContainer)
    
    if singlePlayer then

        GUI.loadButton = UIUtil.CreateButtonStd(GUI.optionsPanel, '/scx_menu/small-btn/small', "<LOC lobui_0176>Load", 18, 2)

        LayoutHelpers.LeftOf(GUI.loadButton, GUI.launchGameButton, 10)
        LayoutHelpers.AtVerticalCenterIn(GUI.loadButton, GUI.launchGameButton)

        GUI.loadButton.OnClick = function(self, modifiers)
            import('/lua/ui/dialogs/saveload.lua').CreateLoadDialog(GUI)
        end

        Tooltip.AddButtonTooltip(GUI.loadButton, 'Lobby_Load')

    elseif not lobbyComm:IsHost() then

        GUI.restrictedUnitsButton = UIUtil.CreateButtonStd(GUI.optionsPanel, '/scx_menu/small-btn/small', "<LOC lobui_0376>Unit Manager", 14, 2)

        LayoutHelpers.LeftOf(GUI.restrictedUnitsButton, GUI.launchGameButton, 10)
        LayoutHelpers.AtVerticalCenterIn(GUI.restrictedUnitsButton, GUI.launchGameButton)

        GUI.restrictedUnitsButton.OnClick = function(self, modifiers)
            import('/lua/ui/lobby/restrictedunitsdlg.lua').CreateDialog(GUI.panel, gameInfo.GameOptions.RestrictedCategories, function() end, function() end, false)
        end

        Tooltip.AddButtonTooltip(GUI.restrictedUnitsButton, 'lob_RestrictedUnitsClient')
    end

    ---------------------
    -- Set up player grid
    ---------------------
	
    -- Set up player "slots" (rows representing players and player specific options)
    local prev = nil

	local slotColumnSizes = {
		LEMindicator    = {x = 48, width = 24},
        player          = {x = 72, width = 278},
        color           = {x = 354, width = 59},
        faction         = {x = 419, width = 59},
        team            = {x = 478, width = 60},
        mult            = {x = 538, width = 40},
        act             = {x = 583, width = 90},
        ping            = {x = 620, width = 62},
        ready           = {x = 695, width = 51},
    }
	
    GUI.labelGroup = Group(GUI.playerPanel)

	LayoutHelpers.SetDimensions(GUI.labelGroup, 690, 20)
    LayoutHelpers.AtLeftTopIn(GUI.labelGroup, GUI.playerPanel, 5, 5)

    GUI.nameLabel = UIUtil.CreateText(GUI.labelGroup, "<LOC lobui_0213>Player Name", 14, UIUtil.titleFont)

    LayoutHelpers.AtLeftIn(GUI.nameLabel, GUI.panel, slotColumnSizes.player.x)
    LayoutHelpers.AtVerticalCenterIn(GUI.nameLabel, GUI.labelGroup)

    GUI.nameLabel:SetDropShadow(true)
    Tooltip.AddControlTooltip(GUI.nameLabel, 'lob_slot')

    GUI.colorLabel = UIUtil.CreateText(GUI.labelGroup, "<LOC lobui_0214>Color", 14, UIUtil.titleFont)

    LayoutHelpers.AtLeftIn(GUI.colorLabel, GUI.panel, slotColumnSizes.color.x)
    LayoutHelpers.AtVerticalCenterIn(GUI.colorLabel, GUI.labelGroup)

    GUI.colorLabel:SetDropShadow(true)
    Tooltip.AddControlTooltip(GUI.colorLabel, 'lob_color')

    GUI.factionLabel = UIUtil.CreateText(GUI.labelGroup, "<LOC lobui_0215>Faction", 14, UIUtil.titleFont)

    LayoutHelpers.AtLeftIn(GUI.factionLabel, GUI.panel, slotColumnSizes.faction.x)
    LayoutHelpers.AtVerticalCenterIn(GUI.factionLabel, GUI.labelGroup)

    GUI.factionLabel:SetDropShadow(true)
    Tooltip.AddControlTooltip(GUI.factionLabel, 'lob_faction')

    GUI.teamLabel = UIUtil.CreateText(GUI.labelGroup, "<LOC lobui_0216>Team", 14, UIUtil.titleFont)

    LayoutHelpers.AtLeftIn(GUI.teamLabel, GUI.panel, slotColumnSizes.team.x)
    LayoutHelpers.AtVerticalCenterIn(GUI.teamLabel, GUI.labelGroup)

    GUI.teamLabel:SetDropShadow(true)
    Tooltip.AddControlTooltip(GUI.teamLabel, 'lob_team')

    if not singlePlayer then
        GUI.aiPingLabel = UIUtil.CreateText(GUI.labelGroup, "Ping/AI Settings", 14, UIUtil.titleFont)
        LayoutHelpers.AtLeftIn(GUI.aiPingLabel, GUI.panel, slotColumnSizes.mult.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.aiPingLabel, GUI.labelGroup)
        GUI.aiPingLabel:SetDropShadow(true)
        Tooltip.AddControlTooltip(GUI.aiPingLabel, 'lob_ai_ping')

        GUI.readyLabel = UIUtil.CreateText(GUI.labelGroup, "<LOC lobui_0218>Ready", 14, UIUtil.titleFont)
        LayoutHelpers.AtLeftIn(GUI.readyLabel, GUI.panel, slotColumnSizes.ready.x)
        GUI.readyLabel:SetDropShadow(true)
        LayoutHelpers.AtVerticalCenterIn(GUI.readyLabel, GUI.labelGroup)
    else
        GUI.aiLabel = UIUtil.CreateText(GUI.labelGroup, "AI Settings", 14, UIUtil.titleFont)
        LayoutHelpers.AtLeftIn(GUI.aiLabel, GUI.panel, slotColumnSizes.mult.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.aiLabel, GUI.labelGroup)
        GUI.aiLabel:SetDropShadow(true)
        Tooltip.AddControlTooltip(GUI.aiLabel, 'lob_ai')
    end

    for i= 1, LobbyComm.maxPlayerSlots do
        -- capture t-he index in the current closure so it's accessible on callbacks
        local curRow = i

        GUI.slots[i] = Group(GUI.playerPanel, "playerSlot " .. tostring(i))
        GUI.slots[i].closed = false
        --TODO these need layout from art when available
        GUI.slots[i].Width:Set(GUI.labelGroup.Width)
        GUI.slots[i].Height:Set(GUI.labelGroup.Height)
        GUI.slots[i]._slot = i
        GUI.slots[i].HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                if gameInfo.GameOptions['TeamSpawn'] ~= 'random' and GUI.markers[curRow].Indicator then
                    GUI.markers[curRow].Indicator:Play()
                end
            elseif event.Type == 'MouseExit' then
                if GUI.markers[curRow].Indicator then
                    GUI.markers[curRow].Indicator:Stop()
                end
            end
            return Group.HandleEvent(self, event)
        end

        local bg = GUI.slots[i]
		
		GUI.slots[i].LEMindicator = Bitmap(bg, UIUtil.UIFile('/lobby/indicator_icons/lem_indicator_black.dds'))
		LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].LEMindicator, GUI.slots[i])
        LayoutHelpers.AtLeftIn(GUI.slots[i].LEMindicator, GUI.panel, slotColumnSizes.LEMindicator.x)
		Tooltip.AddControlTooltip(GUI.slots[i].LEMindicator, 'lob_LEMindicator_black_empty')

        GUI.slots[i].name = Combo(bg, 16, 10, true, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].name, GUI.slots[i])
        LayoutHelpers.AtLeftIn(GUI.slots[i].name, GUI.panel, slotColumnSizes.player.x)
		LayoutHelpers.SetWidth(GUI.slots[i].name, slotColumnSizes.player.width)
        GUI.slots[i].name.row = i

        -- left deal with name clicks
        GUI.slots[i].name.OnClick = function(self, index, text)
            DoSlotBehavior(self.row, self.slotKeys[index], text)
        end
        
        GUI.slots[i].name.OnEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                if gameInfo.GameOptions['TeamSpawn'] ~= 'random' and GUI.markers[curRow].Indicator then
                    GUI.markers[curRow].Indicator:Play()
                end
            elseif event.Type == 'MouseExit' then
                if GUI.markers[curRow].Indicator then
                    GUI.markers[curRow].Indicator:Stop()
                end
			elseif event.Type == 'ButtonPress' and event.Modifiers.Right then
				self._dropdown:SetHidden(true)
				self._ddhidden = true
				self._listhidden = true
				GUI.slots[curRow].Popup:Show()
			end
        end
		
		GUI.slots[i].Popup = ItemList(bg)
		GUI.slots[i].Popup:SetFont(UIUtil.bodyFont, 16)
		GUI.slots[i].Popup:SetColors(UIUtil.fontColor(), "Black", "Black", "Gainsboro", "Black", "Gainsboro")
		GUI.slots[i].Popup:ShowMouseoverItem(true)
		LayoutHelpers.AtRightTopIn(GUI.slots[i].Popup, GUI.slots[i].name, 45, 15)
		LayoutHelpers.DepthOverParent(GUI.slots[i].Popup, GUI.slots[i].name, 5)
		LayoutHelpers.SetDimensions(GUI.slots[i].Popup, 75, 50)
		GUI.slots[i].Popup.row = i
		GUI.slots[i].Popup:Hide()

		GUI.slots[i].Popup.OnHide = function(self, hidden)
			if not hidden then
				self.OnOutsideMouseClick = function(event)
					if self then
						if not self:IsHidden() then
							if (event.x < self.Left() or event.x > self.Right()) or (event.y < self.Top() or event.y > self.Bottom()) then
								self:Hide()
							end
						end
					end
				end
				import('/lua/ui/uimain.lua').AddOnMouseClickedFunc(self.OnOutsideMouseClick)
			else
				import('/lua/ui/uimain.lua').RemoveOnMouseClickedFunc(self.OnOutsideMouseClick)
			end
		end
		
		GUI.slots[i].Popup.OnClick = function(self, row, event)
			local item = self:GetItem(row)
			DoSlotBehavior(self.row, self.slotKeys[row+1], item)
			self:Hide()
		end

        GUI.slots[i].color = Bitmap(bg)
        LayoutHelpers.AtLeftIn(GUI.slots[i].color, GUI.panel, slotColumnSizes.color.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].color, GUI.slots[i])
		LayoutHelpers.SetWidth(GUI.slots[i].color, slotColumnSizes.color.width)
		LayoutHelpers.SetHeight(GUI.slots[i].color, 14)
        GUI.slots[i].color.row = i

        GUI.slots[i].color.glow = Bitmap(bg)
        GUI.slots[i].color.glow.Width:Set(function() return GUI.slots[i].color.Width() + LayoutHelpers.ScaleNumber(4) end)
        GUI.slots[i].color.glow.Height:Set(function() return GUI.slots[i].color.Height() + LayoutHelpers.ScaleNumber(4) end)
        LayoutHelpers.AtCenterIn(GUI.slots[i].color.glow, GUI.slots[i].color)
        GUI.slots[i].color.glow.Depth:Set(function() return GUI.slots[i].color.Depth() - LayoutHelpers.ScaleNumber(1) end)
        GUI.slots[i].color.glow:SetSolidColor('FFFFFFFF')
        GUI.slots[i].color.glow:Hide()
        EffectHelpers.Pulse(GUI.slots[i].color.glow)

        GUI.slots[i].color.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                self.glow:Show()
            elseif event.Type == 'MouseExit' then
                self.glow:Hide()
            elseif event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                if not colorPicker then
                    ShowColorPicker(self.row, event.MouseX, event.MouseY)
                end
                Tooltip.DestroyMouseoverDisplay()
            end
        end

        Tooltip.AddControlTooltip(GUI.slots[i].color, 'lob_color')

        GUI.slots[i].faction = BitmapCombo(bg, factionBmps, table.getn(factionBmps), nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
		
        LayoutHelpers.AtLeftIn(GUI.slots[i].faction, GUI.panel, slotColumnSizes.faction.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].faction, GUI.slots[i])
		
		LayoutHelpers.SetWidth(GUI.slots[i].faction, slotColumnSizes.faction.width)

        GUI.slots[i].faction.OnClick = function(self, index)
            SetPlayerOption(self.row,'Faction',index)
            Tooltip.DestroyMouseoverDisplay()
        end
		
        Tooltip.AddControlTooltip(GUI.slots[i].faction, 'lob_faction')
        Tooltip.AddComboTooltip(GUI.slots[i].faction, factionTooltips)
		
        GUI.slots[i].faction.row = i
        GUI.slots[i].faction.OnEvent = GUI.slots[curRow].name.OnEvent
		
        if not hasSupcom then
            GUI.slots[i].faction:SetItem(4)
        end

        GUI.slots[i].team = BitmapCombo(bg, teamIcons, 1, false, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
		
        LayoutHelpers.AtLeftIn(GUI.slots[i].team, GUI.panel, slotColumnSizes.team.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].team, GUI.slots[i])
		
		LayoutHelpers.SetWidth(GUI.slots[i].team, slotColumnSizes.team.width)
        GUI.slots[i].team.row = i
		
        GUI.slots[i].team.OnClick = function(self, index, text)
            Tooltip.DestroyMouseoverDisplay()
            SetPlayerOption(self.row,'Team',index)
        end
		
        Tooltip.AddControlTooltip(GUI.slots[i].team, 'lob_team')
        Tooltip.AddComboTooltip(GUI.slots[i].team, teamTooltips)
        GUI.slots[i].team.OnEvent = GUI.slots[curRow].name.OnEvent

        -------------------------------
        --- AI cheat multiplier textbox
        -------------------------------
        GUI.slots[i].mult = Edit(bg)
        LayoutHelpers.AtLeftIn(GUI.slots[i].mult, GUI.panel, slotColumnSizes.mult.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].mult, GUI.slots[i])
        LayoutHelpers.SetDimensions(GUI.slots[i].mult, 40, 14)
        GUI.slots[i].mult:SetFont(UIUtil.bodyFont, 12)
        GUI.slots[i].mult:SetForegroundColor(UIUtil.fontColor)
        GUI.slots[i].mult:SetHighlightBackgroundColor('00000000')
        GUI.slots[i].mult:SetHighlightForegroundColor(UIUtil.fontColor)
        GUI.slots[i].mult:ShowBackground(true)
        GUI.slots[i].mult.row = i
        
        GUI.slots[i].mult:SetMaxChars(5)
        GUI.slots[i].mult:SetText("1.0")

        GUI.slots[i].mult.OnCharPressed = function(self, charcode)
            if charcode == UIUtil.VK_TAB then
                return true
            end
            -- Forbid all characters except digits and .
            if charcode == 47 or charcode >= 58 or charcode <= 45 then
                return true
            end
            local charLim = self:GetMaxChars()
            if STR_Utf8Len(self:GetText()) >= charLim then
                local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
                PlaySound(sound)
            end
        end

        GUI.slots[i].mult.OnLoseKeyboardFocus = function(self)
            SetPlayerOption(self.row, 'Mult', self:GetText())
        end

        GUI.slots[i].mult.OnEscPressed = function(self, text)
            return true
        end
        
        GUI.slots[i].mult.OnNonTextKeyPressed = function(self, keyCode)
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
        
        ---------------
        -- ACT dropdown
        ---------------
        GUI.slots[i].act = Combo(bg, 14, 23, false, nil,  "UI_Tab_Rollover_01", "UI_Tab_Click_01")
        LayoutHelpers.AtLeftIn(GUI.slots[i].act, GUI.panel, slotColumnSizes.act.x)
        LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].act, GUI.slots[i])
        LayoutHelpers.SetWidth(GUI.slots[i].act, 90)
        GUI.slots[i].act.row = i
        GUI.slots[i].act:AddItems({ "Fixed", "Feedback", "Time", "Both" })

        GUI.slots[i].act.OnClick = function(self, index, text)
            Tooltip.DestroyMouseoverDisplay()
            SetPlayerOption(self.row, 'ACT', index)
        end

        Tooltip.AddControlTooltip(GUI.slots[i].act, 'lob_act')
        Tooltip.AddComboTooltip(GUI.slots[i].act, {
            'lob_act_none',
            'lob_act_ratio',
            'lob_act_time',
            'lob_act_both',
        })

        if not singlePlayer then
            GUI.slots[i].pingGroup = Group(bg)
			LayoutHelpers.SetWidth(GUI.slots[i].pingGroup, slotColumnSizes.ping.width)
            GUI.slots[i].pingGroup.Height:Set(GUI.slots[curRow].Height)
            LayoutHelpers.AtLeftIn(GUI.slots[i].pingGroup, GUI.panel, slotColumnSizes.ping.x)
            LayoutHelpers.AtVerticalCenterIn(GUI.slots[i].pingGroup, GUI.slots[i])

            GUI.slots[i].pingText = UIUtil.CreateText(GUI.slots[i].pingGroup, "xx", 14, UIUtil.bodyFont)
            LayoutHelpers.AtBottomIn(GUI.slots[i].pingText, GUI.slots[i].pingGroup)
            LayoutHelpers.AtHorizontalCenterIn(GUI.slots[i].pingText, GUI.slots[i].pingGroup)

            GUI.slots[i].pingStatus = StatusBar(GUI.slots[i].pingGroup, 0, 1000, false, false,
                UIUtil.SkinnableFile('/game/unit_bmp/bar-back_bmp.dds'),
                UIUtil.SkinnableFile('/game/unit_bmp/bar-01_bmp.dds'),
                true)
            LayoutHelpers.AtTopIn(GUI.slots[i].pingStatus, GUI.slots[i].pingGroup)
            LayoutHelpers.AtLeftIn(GUI.slots[i].pingStatus, GUI.slots[i].pingGroup, 5)
            LayoutHelpers.AtRightIn(GUI.slots[i].pingStatus, GUI.slots[i].pingGroup, 5)
            GUI.slots[i].pingStatus.Bottom:Set(GUI.slots[curRow].pingText.Top)
        end

        -- depending on if this is single player or multiplayer this displays different info
        GUI.slots[i].multiSpace = Group(bg, "multiSpace " .. tonumber(i))
		LayoutHelpers.SetWidth(GUI.slots[i].multiSpace, slotColumnSizes.ready.width)
        GUI.slots[i].multiSpace.Height:Set(GUI.slots[curRow].Height)
        LayoutHelpers.AtLeftIn(GUI.slots[i].multiSpace, GUI.panel, slotColumnSizes.ready.x)
        GUI.slots[i].multiSpace.Top:Set(GUI.slots[curRow].Top)

        if not singlePlayer then
            GUI.slots[i].ready = UIUtil.CreateCheckboxStd(GUI.slots[i].multiSpace, '/dialogs/check-box_btn/radio')
            GUI.slots[i].ready.row = i
            LayoutHelpers.AtVerticalCenterIn(GUI.slots[curRow].ready, GUI.slots[curRow].multiSpace)
            LayoutHelpers.AtLeftIn(GUI.slots[curRow].ready, GUI.slots[curRow].multiSpace, 10)
            GUI.slots[i].ready.OnCheck = function(self, checked)
                if checked then
                    DisableSlot(self.row, true)
                    if GUI.becomeObserver then
                        GUI.becomeObserver:Disable()
                    end
                else
                    EnableSlot(self.row)
                    if GUI.becomeObserver then
                        GUI.becomeObserver:Enable()
                    end
                end
                SetPlayerOption(self.row,'Ready',checked)
            end
        end

        if i == 1 then
            LayoutHelpers.Below(GUI.slots[i], GUI.labelGroup, -5)
        else
            LayoutHelpers.Below(GUI.slots[i], GUI.slots[i - 1], 3)
        end
    end

    function EnableSlot(slot)
        GUI.slots[slot].team:Enable()
        GUI.slots[slot].color:Enable()
        GUI.slots[slot].faction:Enable()
        if not gameInfo.PlayerOptions[slot].Human then
            GUI.slots[slot].mult:Enable()
            GUI.slots[slot].act:Enable()
        end
        if GUI.slots[slot].ready then
            GUI.slots[slot].ready:Enable()
        end
    end

    function DisableSlot(slot, exceptReady)
        GUI.slots[slot].team:Disable()
        GUI.slots[slot].color:Disable()
        GUI.slots[slot].faction:Disable()
        if not gameInfo.PlayerOptions[slot].Human then
            GUI.slots[slot].mult:Disable()
            GUI.slots[slot].act:Disable()
        end
        if GUI.slots[slot].ready and not exceptReady then
            GUI.slots[slot].ready:Disable()
        end
    end
	
	function SetupFillSlots()
	
		if not fillSlotsSet then
		
			local aitypes = import('/lua/ui/lobby/aitypes.lua').aitypes
			local keys = {}
			local names = {}
			local tooltips = {}
			
			for i,v in aitypes do
				table.insert(keys, v.key)
				table.insert(names, v.name)
				table.insert(tooltips, 'aitype_'..v.key)
			end
			
			GUI.fillOpenCombo.slotKeys = keys
			GUI.fillOpenCombo:AddItems(names)
			GUI.fillOpenCombo:Enable()
			
			Tooltip.AddComboTooltip(GUI.fillOpenCombo, tooltips)
			
			fillSlotsSet = true
		end
	end

    --- Initially clear all slots
    for slot = 1, maxPlayers do
        ClearSlotInfo(slot)
    end

    ---------------------------------
    -- set up observer and limbo grid
    ---------------------------------
    GUI.allowObservers = nil
    GUI.observerList = nil

    if not singlePlayer then

        GUI.observerLabel = UIUtil.CreateText(GUI.observerPanel, "<LOC lobui_0275>Observers", 14, UIUtil.bodyFont)

        LayoutHelpers.AtLeftTopIn(GUI.observerLabel, GUI.observerPanel, 5, 5)

        Tooltip.AddControlTooltip(GUI.observerLabel, 'lob_describe_observers')

        GUI.allowObservers = UIUtil.CreateCheckboxStd(GUI.observerPanel, '/dialogs/check-box_btn/radio')

        LayoutHelpers.CenteredRightOf(GUI.allowObservers, GUI.observerLabel, 6)

        GUI.allowObserversLabel = UIUtil.CreateText(GUI.observerPanel, "<LOC lobui_0276>Allow", 14, UIUtil.bodyFont)

        LayoutHelpers.CenteredRightOf(GUI.allowObserversLabel, GUI.allowObservers)

        Tooltip.AddControlTooltip(GUI.allowObservers, 'lob_observers_allowed')
        Tooltip.AddControlTooltip(GUI.allowObserversLabel, 'lob_observers_allowed')

        GUI.allowObservers:SetCheck(true)

        if lobbyComm:IsHost() then

            GUI.allowObservers.OnCheck = function(self, checked)
                SetGameOption("AllowObservers",checked)
            end
        end

        GUI.allowObservers.OnHide = function(self, hidden)
            GUI.allowObserversLabel:SetHidden(hidden)
        end
		
        GUI.allowObservers:Hide()

        GUI.becomeObserver = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/smalltoggle', "<LOC lobui_0228>Observe", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.becomeObserver, GUI.allowObserversLabel, 6)
        
        Tooltip.AddButtonTooltip(GUI.becomeObserver, 'lob_become_observer')
        
        GUI.becomeObserver.OnClick = function(self, modifiers)
            if IsPlayer(localPlayerID) then
                if lobbyComm:IsHost() then
                    HostConvertPlayerToObserver(hostID, localPlayerName, FindSlotForID(localPlayerID))
                else
                    lobbyComm:SendData(hostID, {Type = 'RequestConvertToObserver', RequestedName = localPlayerName, RequestedSlot =  FindSlotForID(localPlayerID)})
                end
            end
        end

        GUI.fillOpenLabel = UIUtil.CreateText(GUI.observerPanel, "Fill slots:", 14, UIUtil.bodyFont)

        LayoutHelpers.CenteredRightOf(GUI.fillOpenLabel, GUI.becomeObserver, 6)
		
		GUI.fillOpenCombo = Combo(GUI.observerPanel, 14, 10, false, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")

		LayoutHelpers.CenteredRightOf(GUI.fillOpenCombo, GUI.fillOpenLabel, 2)
		LayoutHelpers.SetWidth(GUI.fillOpenCombo, 90)

		Tooltip.AddControlTooltip(GUI.fillOpenCombo, 'lob_fill_combo')
		
        GUI.fillOpenBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/smalltoggle', "Add AIs", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.fillOpenBtn, GUI.fillOpenCombo, 2)

		Tooltip.AddButtonTooltip(GUI.fillOpenBtn, 'lob_fill_open')
		
        GUI.fillOpenBtn.OnClick = function(self, modifiers)			
			local index, text = GUI.fillOpenCombo:GetItem()
			if lobbyComm:IsHost() then
				for i = 1, LobbyComm.maxPlayerSlots do
					if not gameInfo.ClosedSlots[i] and not gameInfo.PlayerOptions[i] then
                        DoSlotBehavior(i, GUI.fillOpenCombo.slotKeys[index], text)
                        -- If the slot was able to be filled, set it up
                        if gameInfo.PlayerOptions[i] then
                            GUI.slots[i].mult:SetText(GUI.fillAIMult:GetText())
                            SetPlayerOption(i, 'Mult', GUI.slots[i].mult:GetText(), true)
                        end
					end
                end
			end
        end
		
        GUI.clearAIBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/smalltoggle', "Clear AIs", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.clearAIBtn, GUI.fillOpenBtn, 2)

		Tooltip.AddButtonTooltip(GUI.clearAIBtn, 'lob_clear_ai')
		
		GUI.clearAIBtn.OnClick = function(self, modifiers)
			if lobbyComm:IsHost() then
				for i = 1, LobbyComm.maxPlayerSlots do
					if not gameInfo.ClosedSlots[i] and not gameInfo.PlayerOptions[i].Human then
						HostRemoveAI(i)
					end
				end
			end
        end

        GUI.fillAIMult = Edit(GUI.observerPanel)

        LayoutHelpers.CenteredRightOf(GUI.fillAIMult, GUI.clearAIBtn)
        LayoutHelpers.SetDimensions(GUI.fillAIMult, 40, 14)

        GUI.fillAIMult:SetFont(UIUtil.bodyFont, 12)
        GUI.fillAIMult:SetForegroundColor(UIUtil.fontColor)
        GUI.fillAIMult:SetHighlightBackgroundColor('00000000')
        GUI.fillAIMult:SetHighlightForegroundColor(UIUtil.fontColor)
        GUI.fillAIMult:ShowBackground(true)
        GUI.fillAIMult:SetMaxChars(5)
        GUI.fillAIMult:SetText("1.0")

        GUI.fillAIMult.OnCharPressed = function(self, charcode)
            if charcode == UIUtil.VK_TAB then
                return true
            end
            -- Forbid all characters except digits and .
            if charcode == 47 or charcode >= 58 or charcode <= 45 then
                return true
            end
            local charLim = self:GetMaxChars()
            if STR_Utf8Len(self:GetText()) >= charLim then
                local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
                PlaySound(sound)
            end
        end

        GUI.fillAIMult.OnLoseKeyboardFocus = function(self)
            GUI.fillAIMult:AcquireFocus()
        end

        GUI.fillAIMult.OnNonTextKeyPressed = function(self, keyCode)
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

        GUI.setAllAIMultBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/toggle', "Set All AI Cheat", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.setAllAIMultBtn, GUI.fillAIMult)

        Tooltip.AddButtonTooltip(GUI.setAllAIMultBtn, 'lob_set_all_ai_multi')

        GUI.setAllAIMultBtn.OnClick = function(self, modifiers)
            if not lobbyComm:IsHost() then
                return
            end
            for i, v in gameInfo.PlayerOptions do
                if not v.Human then
                    SetPlayerOption(i, 'Mult', GUI.fillAIMult:GetText(), true)
                end
            end
        end
        
        GUI.observerList = ItemList(GUI.observerPanel, "observer list")
        GUI.observerList:SetFont(UIUtil.bodyFont, 14)
        GUI.observerList:SetColors(UIUtil.fontColor, "00000000", UIUtil.fontOverColor, UIUtil.highlightColor, "ffbcfffe")

        LayoutHelpers.Below(GUI.observerList, GUI.observerLabel, 8)
		LayoutHelpers.AtLeftIn(GUI.observerList, GUI.observerLabel, 5)
		LayoutHelpers.AtRightBottomIn(GUI.observerList, GUI.observerPanel, 40, 12)
        
        GUI.observerList.OnClick = function(self, row, event)
            if lobbyComm:IsHost() and event.Modifiers.Right then
                UIUtil.QuickDialog(GUI, "<LOC lobui_0166>Are you sure?",
                    "<LOC lobui_0167>Kick Player", function() 
                            lobbyComm:EjectPeer(gameInfo.Observers[row+1].OwnerID, "KickedByHost") 
                        end,
                    "<LOC _Cancel>", nil, 
                    nil, nil, 
                    true,
                    {worldCover = false, enterButton = 1, escapeButton = 2})
            end
        end

    else
	
        GUI.fillOpenLabel = UIUtil.CreateText(GUI.observerPanel, "Fill open slots with", 14, UIUtil.bodyFont)

		LayoutHelpers.AtLeftTopIn(GUI.fillOpenLabel, GUI.observerPanel, 5, 5)
		
		GUI.fillOpenCombo = Combo(GUI.observerPanel, 14, 10, false, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")

		LayoutHelpers.CenteredRightOf(GUI.fillOpenCombo, GUI.fillOpenLabel, 5)
		LayoutHelpers.SetWidth(GUI.fillOpenCombo, 90)

		Tooltip.AddControlTooltip(GUI.fillOpenCombo, 'lob_fill_combo')
		
        GUI.fillOpenBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/smalltoggle', "Add AIs", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.fillOpenBtn, GUI.fillOpenCombo, 5)

		Tooltip.AddButtonTooltip(GUI.fillOpenBtn, 'lob_fill_open')
		
        GUI.fillOpenBtn.OnClick = function(self, modifiers)			
			local index, text = GUI.fillOpenCombo:GetItem()
			if lobbyComm:IsHost() then
				for i = 1, LobbyComm.maxPlayerSlots do
					if not gameInfo.ClosedSlots[i] and not gameInfo.PlayerOptions[i] then
						DoSlotBehavior(i, GUI.fillOpenCombo.slotKeys[index], text)
                        -- If the slot was able to be filled, set it up
                        if gameInfo.PlayerOptions[i] then
                            GUI.slots[i].mult:SetText(GUI.fillAIMult:GetText())
                            SetPlayerOption(i, 'Mult', GUI.slots[i].mult:GetText(), true)
                        end
                    end
				end
			end
        end
		
        GUI.clearAIBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/smalltoggle', "Clear AIs", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.clearAIBtn, GUI.fillOpenBtn, 5)

		Tooltip.AddButtonTooltip(GUI.clearAIBtn, 'lob_clear_ai')
		
		GUI.clearAIBtn.OnClick = function(self, modifiers)
			if lobbyComm:IsHost() then
				for i = 1, LobbyComm.maxPlayerSlots do
					if not gameInfo.ClosedSlots[i] and not gameInfo.PlayerOptions[i].Human then
						HostRemoveAI(i)
					end
				end
			end
        end

        GUI.fillAIMult = Edit(GUI.observerPanel)

        LayoutHelpers.CenteredRightOf(GUI.fillAIMult, GUI.clearAIBtn)
		LayoutHelpers.SetDimensions(GUI.fillAIMult, 40, 14)

        GUI.fillAIMult:SetFont(UIUtil.bodyFont, 12)
        GUI.fillAIMult:SetForegroundColor(UIUtil.fontColor)
        GUI.fillAIMult:SetHighlightBackgroundColor('00000000')
        GUI.fillAIMult:SetHighlightForegroundColor(UIUtil.fontColor)
        GUI.fillAIMult:ShowBackground(true)
        GUI.fillAIMult:SetMaxChars(5)
        GUI.fillAIMult:SetText("1.0")

        GUI.fillAIMult.OnCharPressed = function(self, charcode)
            if charcode == UIUtil.VK_TAB then
                return true
            end
            -- Forbid all characters except digits and .
            if charcode == 47 or charcode >= 58 or charcode <= 45 then
                return true
            end
            local charLim = self:GetMaxChars()
            if STR_Utf8Len(self:GetText()) >= charLim then
                local sound = Sound({Cue = 'UI_Menu_Error_01', Bank = 'Interface',})
                PlaySound(sound)
            end
        end

        GUI.fillAIMult.OnLoseKeyboardFocus = function(self)
            GUI.fillAIMult:AcquireFocus()
        end

        GUI.fillAIMult.OnNonTextKeyPressed = function(self, keyCode)
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

        GUI.setAllAIMultBtn = UIUtil.CreateButtonStd(GUI.observerPanel, '/lobby/lan-game-lobby/toggle', "Set All AI Cheat", 10, 0)

        LayoutHelpers.CenteredRightOf(GUI.setAllAIMultBtn, GUI.fillAIMult)

        Tooltip.AddButtonTooltip(GUI.setAllAIMultBtn, 'lob_set_all_ai_multi')

        GUI.setAllAIMultBtn.OnClick = function(self, modifiers)
            if not lobbyComm:IsHost() then
                return
            end
            for i, v in gameInfo.PlayerOptions do
                if not v.Human then
                    SetPlayerOption(i, 'Mult', GUI.fillAIMult:GetText(), true)
                end
            end
        end

        -- observers are always allowed in skirmish games.
        SetGameOption("AllowObservers",true, true, true)

    end

    -----------------------------------------
    -- other logic, including lobby callbacks
    -----------------------------------------
    GUI.posGroup = false

    --  control behvaior
    GUI.exitButton.OnClick = function(self)

        GUI.chatEdit:AbandonFocus()

        UIUtil.QuickDialog(GUI,
            "<LOC lobby_0000>Exit game lobby?",
            "<LOC _Yes>", function() 
                    ReturnToMenu()
                end,
            "<LOC _Cancel>", function()
                    GUI.chatEdit:AcquireFocus()
                end, 
            nil, nil, 
            true,
            {worldCover = true, enterButton = 1, escapeButton = 2})
        
    end

    -- get ping times
    GUI.pingThread = ForkThread(
        function()
            while true and lobbyComm do
                for slot,player in gameInfo.PlayerOptions do
                    if player.Human and player.OwnerID ~= localPlayerID then
                        local peer = lobbyComm:GetPeer(player.OwnerID)
                        local ping = peer.ping and math.floor(peer.ping)
                        GUI.slots[slot].pingText:SetText(tostring(ping))
                        GUI.slots[slot].pingText:SetColor(CalcConnectionStatus(peer))
                        if ping then
                            GUI.slots[slot].pingStatus:SetValue(ping)
                            GUI.slots[slot].pingStatus:Show()
                        else
                            GUI.slots[slot].pingStatus:Hide()
                        end
                    end
                end
                for slot, observer in gameInfo.Observers do
                    if observer and (observer.OwnerID ~= localPlayerID) and observer.ObserverListIndex then
                        local peer = lobbyComm:GetPeer(observer.OwnerID)
                        local ping = math.floor(peer.ping)
                        GUI.observerList:ModifyItem(observer.ObserverListIndex, observer.PlayerName  .. LOC("<LOC lobui_0240> (Ping = ") .. tostring(ping) .. ")")
                    end
                end
                WaitSeconds(1)
            end
        end
    )

    GUI.uiCreated = true

    local bigMap = UIUtil.CreateButtonStd(GUI.mapPanel, '/lobby/lan-game-lobby/small-back', "Map Preview", 12, 0, 0, "UI_Tab_Click_01", "UI_Tab_Rollover_01")

	LayoutHelpers.AtTopIn(bigMap, GUI.mapPanel, -36)
	LayoutHelpers.AtHorizontalCenterIn(bigMap, GUI.mapPanel)
	bigMap.Depth:Set(996)

	bigMap.OnClick = function()
		CreateBigPreview(GUI.mapPanel)
	end
    
end

function RefreshOptionDisplayData(scenarioInfo)

    --LOG("*AI DEBUG LOBBY Refreshing Option Display Data with Scenario "..repr(scenarioInfo != nil) )
    
    formattedOptions = {}
    
    local modNum = table.getn(Mods.GetGameMods(gameInfo.GameMods))
    
    if modNum > 0 then

        local modStr = '<LOC lobby_0002>%d Mods Enabled'

        if modNum == 1 then
            modStr = '<LOC lobby_0004>%d Mod Enabled'
        end

        table.insert(formattedOptions, {text = LOCF(modStr, modNum), value = LOC('<LOC lobby_0003>Check Mod Manager'), mod = true, tooltip = 'Lobby_Mod_Option', valueTooltip = 'Lobby_Mod_Option'} )
    end

    if gameInfo.GameOptions.RestrictedCategories ~= nil then

        if table.getn(gameInfo.GameOptions.RestrictedCategories) ~= 0 then
            table.insert(formattedOptions, {text = LOC("<LOC lobby_0005>Build Restrictions Enabled"), value = LOC("<LOC lobby_0006>Check Unit Manager"), mod = true, tooltip = 'Lobby_BuildRestrict_Option', valueTooltip = 'Lobby_BuildRestrict_Option'} )
        end
    end 

    if scenarioInfo then
        table.insert(formattedOptions, {text = '<LOC MAPSEL_0024>', value = LOCF("<LOC map_select_0008>%dkm x %dkm", scenarioInfo.size[1]/50, scenarioInfo.size[2]/50), tooltip = 'map_select_sizeoption', valueTooltip = 'map_select_sizeoption'} )
        table.insert(formattedOptions, {text = '<LOC MAPSEL_0031>Max Players', value = LOCF("<LOC map_select_0009>%d", table.getsize(scenarioInfo.Configurations.standard.teams[1].armies)), tooltip = 'map_select_maxplayers', valueTooltip = 'map_select_maxplayers'} )
    end

    local totalUnitCap = CalcTotalUnitCap()

    table.insert(formattedOptions, {text = "Total Unit Cap", tooltip = { text = "Total Unit Cap", body = "All player and AI unit caps, after increases from cheat values and differences in team size, added together." }, totalUnitCap = true, value = tostring(totalUnitCap), valueTooltip = { text = tostring(totalUnitCap), body = "" }, } )

    for _, k in lobbyOptOrder do
        
        if not gameInfo.GameOptions[k] and lobbyOptMap[k].default then
            gameInfo.GameOptions[k] = lobbyOptMap[k].default
        end

        local v = gameInfo.GameOptions[k]
        
        --LOG("*AI DEBUG LOBBY OPTION "..repr(k).." value is "..repr(v) )

        -- GameOptions might be empty at this moment
        if not v then
            continue
        end

        local option = false
        local mpOnly = false
        local optData = lobbyOptMap[k]

        mpOnly = optData.mponly or false

        if optData then

            option = { text = optData.label, tooltip = optData.pref }

            if optData.type == 'edit' then
                option.value = gameInfo.GameOptions[k]
                option.valueTooltip = { text = gameInfo.GameOptions[k], body = "" }
            else
                for _, val in optData.values do
                    if val.key == v then
                        option.value = val.text
                        option.valueTooltip = 'lob_'..optData.key..'_'..val.key
                        break
                    end
                end
            end
        end

        if not option and scenarioInfo.options then

            for index, optData in scenarioInfo.options do

                if k == optData.key then
                    -- Map options are not considered to be official options
                    option = { text = optData.label, tooltip = { text = optData.label, body = optData.help } }
                    
                    for _, val in optData.values do
                        if val.key == v then
                            option.value = val.text
                            option.valueTooltip = { text = val.text, body = val.help }
                            break
                        end
                    end
                    break
                end
            end
        end

        if option then
            if not mpOnly or not singlePlayer then
                table.insert(formattedOptions, option)
            end
        end
    end

    if GUI.OptionContainer.CalcVisible then
        GUI.OptionContainer:CalcVisible()
    end
end

function CalcConnectionStatus(peer)

    if peer.status ~= 'Established' then
        return 'red'
    else
        if not table.find(peer.establishedPeers, lobbyComm:GetLocalPlayerID()) then
            -- they haven't reported that they can talk to us?
            return 'yellow'
        end

        local peers = lobbyComm:GetPeers()
        for k,v in peers do
            if v.id ~= peer.id and v.status == 'Established' then
                if not table.find(peer.establishedPeers, v.id) then
                    -- they can't talk to someone we can talk to.
                    return 'yellow'
                end
            end
        end
        return 'green'
    end
end

function EveryoneHasEstablishedConnections()

    local important = {}

    for slot,player in gameInfo.PlayerOptions do
        if not table.find(important, player.OwnerID) then
            table.insert(important, player.OwnerID)
        end
    end

    for slot,observer in gameInfo.Observers do
        if not table.find(important, observer.OwnerID) then
            table.insert(important, observer.OwnerID)
        end
    end

    local result = true

    for k,id in important do

        if id ~= localPlayerID then

            local peer = lobbyComm:GetPeer(id)

            for k2,other in important do
                if id ~= other and not table.find(peer.establishedPeers, other) then
                    result = false
                    AddChatText(LOCF("<LOC lobui_0299>%s doesn't have an established connection to %s", peer.name, lobbyComm:GetPeer(other).name))
                end
            end
        end
    end
    return result
end

function AddChatText(text)
    if not GUI.chatDisplay then
        LOG("Can't add chat text -- no chat display")
        LOG("text=" .. repr(text))
        return
    end
    local textBoxWidth = GUI.chatDisplay.Width()
    local wrapped = import('/lua/maui/text.lua').WrapText(text, textBoxWidth,
        function(curText) return GUI.chatDisplay:GetStringAdvance(curText) end)
    for i, line in wrapped do
        GUI.chatDisplay:AddItem(line)
    end
    GUI.chatDisplay:ScrollToBottom()
end

function ShowMapPositions(mapCtrl, scenario, numPlayers)
    if nil == scenario.starts then
        scenario.starts = true
    end

    if GUI.posGroup then
        GUI.posGroup:Destroy()
        GUI.posGroup = false
    end

    if GUI.markers and table.getn(GUI.markers) > 0 then
        for i, v in GUI.markers do
            v.marker:Destroy()
        end
    end
    GUI.markers = {}

    if not scenario.starts then
        return
    end

    if not scenario.size then
        LOG("Lobby: Can't show map positions as size field isn't in scenario yet (must be resaved with new editor!)")
        return
    end

    GUI.posGroup = Group(mapCtrl)
    LayoutHelpers.FillParent(GUI.posGroup, mapCtrl)

    local startPos = MapUtil.GetStartPositions(scenario)

    local cHeight = LayoutHelpers.InvScaleNumber(GUI.posGroup:Height())
    local cWidth = LayoutHelpers.InvScaleNumber(GUI.posGroup:Width())

    local mWidth = scenario.size[1]
    local mHeight = scenario.size[2]
    local xOffset, yOffset, largest = ComputeNonSquareOffset(mWidth, mHeight)

    local playerArmyArray = MapUtil.GetArmies(scenario)

    for inSlot, army in playerArmyArray do
    
        local pos = startPos[army]
        
        -- dont process this army if no start position is defined --
        if not pos then
            continue
        end
        
        local slot = inSlot
        
        GUI.markers[slot] = {}
        GUI.markers[slot].marker = Bitmap(GUI.posGroup)
		LayoutHelpers.SetDimensions(GUI.markers[slot].marker, 8, 10)
        GUI.markers[slot].marker.Depth:Set(function() return GUI.posGroup.Depth() + 10 end)
        GUI.markers[slot].marker:SetSolidColor('ff777777')
        
        GUI.markers[slot].teamIndicator = Bitmap(GUI.markers[slot].marker)
        LayoutHelpers.AnchorToRight(GUI.markers[slot].teamIndicator, GUI.markers[slot].marker, 1)
        LayoutHelpers.AtTopIn(GUI.markers[slot].teamIndicator, GUI.markers[slot].marker, 5)
        GUI.markers[slot].teamIndicator:DisableHitTest()
        
        GUI.markers[slot].markerOverlay = Button(GUI.markers[slot].marker, UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'), UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'), UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'), UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'))

        LayoutHelpers.AtCenterIn(GUI.markers[slot].markerOverlay, GUI.markers[slot].marker)
        
        GUI.markers[slot].markerOverlay.Slot = slot
        
        GUI.markers[slot].markerOverlay.OnClick = function(self, modifiers)
        
            if modifiers.Left then
            
                if FindSlotForID(localPlayerID) ~= self.Slot and gameInfo.PlayerOptions[self.Slot] == nil then
                
                    if IsPlayer(localPlayerID) then
                    
                        if lobbyComm:IsHost() then
                        
                            HostTryMovePlayer(hostID, FindSlotForID(localPlayerID), self.Slot)
                            
                        else
                        
                            lobbyComm:SendData(hostID, {Type = 'MovePlayer', CurrentSlot = FindSlotForID(localPlayerID), RequestedSlot =  self.Slot})
                            
                        end
                        
                    elseif IsObserver(localPlayerID) then
                    
                        if lobbyComm:IsHost() then
                        
                            HostConvertObserverToPlayer(hostID, localPlayerName, FindObserverSlotForID(localPlayerID), self.Slot)
                            
                        else
                        
                            lobbyComm:SendData(hostID, {Type = 'RequestConvertToPlayer', RequestedName = localPlayerName, ObserverSlot = FindObserverSlotForID(localPlayerID), PlayerSlot = self.Slot})
                            
                        end
                    end
                end
                
            elseif modifiers.Right then
            
                if lobbyComm:IsHost() then
                
                    if gameInfo.ClosedSlots[self.Slot] == nil then
                    
                        HostCloseSlot(hostID, self.Slot)
                        
                    else
                    
                        HostOpenSlot(hostID, self.Slot)
                        
                    end    
                end
            end
        end
        
        GUI.markers[slot].markerOverlay.HandleEvent = function(self, event)
        
            if event.Type == 'MouseEnter' then
            
                if gameInfo.GameOptions['TeamSpawn'] ~= 'random' then
                    GUI.slots[self.Slot].name.HandleEvent(self, event)
                end
                
            elseif event.Type == 'MouseExit' then
                GUI.slots[self.Slot].name.HandleEvent(self, event)
            end
            
            Button.HandleEvent(self, event)
        end

        LayoutHelpers.AtLeftTopIn(
            GUI.markers[slot].marker, 
            GUI.posGroup, 
            ((xOffset + pos[1] / largest) * cWidth) - LayoutHelpers.InvScaleNumber(GUI.markers[slot].marker.Width() / 2), 
            ((yOffset + pos[2] / largest) * cHeight) - LayoutHelpers.InvScaleNumber(GUI.markers[slot].marker.Height() / 2)
        )
        
        local index = slot
        
        GUI.markers[slot].Indicator = Bitmap(GUI.markers[slot].marker, UIUtil.UIFile('/game/beacons/beacon-quantum-gate_btn_up.dds'))
        LayoutHelpers.AtCenterIn(GUI.markers[slot].Indicator, GUI.markers[slot].marker)
        
        LayoutHelpers.SetDimensions(GUI.markers[slot].Indicator, GUI.markers[index].Indicator.BitmapWidth() * .3, GUI.markers[index].Indicator.BitmapHeight() * .3)
        GUI.markers[slot].Indicator.Depth:Set(function() return GUI.markers[index].marker.Depth() - 1 end)
        GUI.markers[slot].Indicator:Hide()
        GUI.markers[slot].Indicator:DisableHitTest()
        
        GUI.markers[slot].Indicator.Play = function(self)
            self:SetAlpha(1)
            self:Show()
            self:SetNeedsFrameUpdate(true)
            self.time = 0
            self.OnFrame = function(control, time)
                control.time = control.time + (time*4)
                control:SetAlpha(MATH_Lerp(math.sin(control.time), -.5, .5, 0.3, 0.5))
            end
        end
        
        GUI.markers[slot].Indicator.Stop = function(self)
            self:SetAlpha(0)
            self:Hide()
            self:SetNeedsFrameUpdate(false)
        end

        if gameInfo.GameOptions['TeamSpawn'] == 'random' then
            GUI.markers[slot].marker:SetSolidColor("ff777777")
        else
            if gameInfo.PlayerOptions[slot] then
                GUI.markers[slot].marker:SetSolidColor(ColorToStr(gameInfo.PlayerOptions[slot].WheelColor))
                if gameInfo.PlayerOptions[slot].Team == 1 then
                    GUI.markers[slot].teamIndicator:SetSolidColor('00000000')
                else
                    GUI.markers[slot].teamIndicator:SetTexture(UIUtil.UIFile(teamIcons[gameInfo.PlayerOptions[slot].Team]))
                end
            else
                GUI.markers[slot].marker:SetSolidColor("ff777777")
                GUI.markers[slot].teamIndicator:SetSolidColor('00000000')
            end
        end

        if gameInfo.ClosedSlots[slot] ~= nil then
            local textOverlay = Text(GUI.markers[slot].markerOverlay)
            textOverlay:SetFont(UIUtil.bodyFont, 14)
            textOverlay:SetColor("Crimson")
            textOverlay:SetText("X")
            LayoutHelpers.AtCenterIn(textOverlay, GUI.markers[slot].markerOverlay)
        end
    end
end

-- LobbyComm Callbacks
function InitLobbyComm(protocol, localPort, desiredPlayerName, localPlayerUID, natTraversalProvider, useSteam)

    lobbyComm = LobbyComm.CreateLobbyComm(protocol, localPort, desiredPlayerName, localPlayerUID, natTraversalProvider)
	
    if not lobbyComm then
        error('Failed to create lobby using port ' .. tostring(localPort))
    end

    lobbyComm.ConnectionFailed = function(self, reason)

        GUI.connectionFailedDialog = UIUtil.ShowInfoDialog(GUI.panel, LOCF(Strings.ConnectionFailed, Strings[reason] or reason), "<LOC _OK>", ReturnToMenu)

        lobbyComm:Destroy()
        lobbyComm = nil
    end

    lobbyComm.LaunchFailed = function(self,reasonKey)
        AddChatText(LOC(Strings[reasonKey] or reasonKey))
    end

    lobbyComm.Ejected = function(self,reason)

        GUI.connectionFailedDialog = UIUtil.ShowInfoDialog(GUI, LOCF(Strings.Ejected, Strings[reason] or reason), "<LOC _OK>", ReturnToMenu)
        lobbyComm:Destroy()
        lobbyComm = nil
    end

    lobbyComm.ConnectionToHostEstablished = function(self,myID,myName,theHostID, useSteam)

        hostID = theHostID
        localPlayerID = myID
        localPlayerName = myName

        lobbyComm:SendData(hostID, { Type = 'SetAvailableMods', Mods = GetLocallyAvailableMods() } )

        if wantToBeObserver then
            -- Ok, I'm connected to the host. Now request to become an observer
            lobbyComm:SendData( hostID, {
                Type = 'AddObserver', 
                RequestedObserverName = localPlayerName, 
                RequestedColor = Prefs.GetFromCurrentProfile('LastColor') 
            })
        else
            -- Ok, I'm connected to the host. Now request to become a player
            local requestedFaction = Prefs.GetFromCurrentProfile('LastFaction')
            if (requestedFaction == nil) or (requestedFaction > table.getn(FactionData.Factions)) then
                requestedFaction = table.getn(FactionData.Factions) + 1
            end
            
            if hasSupcom == false then
                requestedFaction = 4
            end
           
            lobbyComm:SendData( hostID, { 
                Type = 'AddPlayer', 
                RequestedSlot = -1, 
                RequestedPlayerName = localPlayerName, 
                Human = true, 
                RequestedColor = Prefs.GetFromCurrentProfile('LastColor'),
                RequestedFaction = requestedFaction, } )
        end

        local function KeepAliveThreadFunc()
            local threshold = LobbyComm.quietTimeout
            local active = true
            local prev = 0
            while lobbyComm do
                local host = lobbyComm:GetPeer(hostID)
                if active and host.quiet > threshold then
                    active = false
                    local function OnRetry()
                        host = lobbyComm:GetPeer(hostID)
                        threshold = host.quiet + LobbyComm.quietTimeout
                        active = true
                    end
                    UIUtil.QuickDialog(GUI, "<LOC lobui_0266>Connection to host timed out.",
                                       "<LOC lobui_0267>Keep Trying", OnRetry,
                                       "<LOC lobui_0268>Give Up", ReturnToMenu, 
                                       nil, nil,
                                       true,
                                       {worldCover = false, escapeButton = 2})
                elseif host.quiet < prev then
                    threshold = LobbyComm.quietTimeout
                end
                prev = host.quiet

                WaitSeconds(1)
            end
        end
        GUI.keepAliveThread = ForkThread(KeepAliveThreadFunc)

        CreateUI(LobbyComm.maxPlayerSlots, useSteam)
    end

    lobbyComm.DataReceived = function(self,data)

        -- Messages anyone can receive
        if data.Type == 'PlayerOption' then
            if gameInfo.PlayerOptions[data.Slot].OwnerID ~= data.SenderID and not data.Override then
                WARN("Attempt to set option on unowned slot.")
                return
            end
            gameInfo.PlayerOptions[data.Slot][data.Key] = data.Value
			LOG("*AI DEBUG Client Recv Player Option")
            UpdateGame()
			
        elseif data.Type == 'PublicChat' then
            AddChatText("["..data.SenderName.."] "..data.Text)
			
        elseif data.Type == 'PrivateChat' then
            AddChatText("<<"..data.SenderName..">> "..data.Text)
			

        end

        if lobbyComm:IsHost() then
            -- Host only messages

            if data.Type == 'GetGameInfo' then
                lobbyComm:SendData( data.SenderID, {Type = 'GameInfo', GameInfo = gameInfo} )

            elseif data.Type == 'AddPlayer' then
                -- create empty slot if possible and give it to the player
                HostTryAddPlayer( data.SenderID, data.RequestedSlot, data.RequestedPlayerName, data.Human, data.AIPersonality, data.RequestedColor, data.RequestedFaction )

            elseif data.Type == 'MovePlayer' then
                -- attempt to move a player from current slot to empty slot
                HostTryMovePlayer(data.SenderID, data.CurrentSlot, data.RequestedSlot)

            elseif data.Type == 'AddObserver' then
                -- create empty slot if possible and give it to the observer
                if gameInfo.GameOptions.AllowObservers then
                    HostTryAddObserver( data.SenderID, data.RequestedObserverName, data.RequestedColor )
                else
                    lobbyComm:EjectPeer(data.SenderID, 'NoObservers');
                end

            elseif data.Type == 'RequestConvertToObserver' then
                HostConvertPlayerToObserver(data.SenderID, data.RequestedName, data.RequestedSlot)

            elseif data.Type == 'RequestConvertToPlayer' then
                HostConvertObserverToPlayer(data.SenderID, data.RequestedName, data.ObserverSlot, data.PlayerSlot)

            elseif data.Type == 'RequestColor' then
			
                if IsColorFree(data.Color) then
                    -- Color is available, let everyone else know
                    gameInfo.PlayerOptions[data.Slot].WheelColor = data.Color
                    lobbyComm:BroadcastData( { Type = 'SetColor', Color = data.Color, Slot = data.Slot } )

                    UpdateGame()
                else
                    -- Sorry, it's not free. Force the player back to the color we have for him.
                    lobbyComm:SendData( data.SenderID, { Type = 'SetColor', Color = gameInfo.PlayerOptions[data.Slot].WheelColor, Slot = data.Slot } )
                end
				
            elseif data.Type == 'GiveLEMInfo' then
				gameInfo.PlayerOptions[data.Slot].LEM = data.LEM
				lobbyComm:BroadcastData( { Type = 'SetLEMInfo', Slot = data.Slot, LEM = data.LEM } )

				UpdateGame()
				
			elseif data.Type == 'RequestMod' then
			
				ForkThread(TransmitMod, data.SenderID, data.modId)
				
			elseif data.Type == 'ModReceived' then
			
				ModReceivedNote(data.SenderID, data.modId)
				
            elseif data.Type == 'ClearSlot' then
			
                if gameInfo.PlayerOptions[data.Slot].OwnerID == data.SenderID then
                    HostRemoveAI(data.Slot)
                else
                    WARN("Attempt to clear unowned slot")
                end
				
            elseif data.Type == 'SetAvailableMods' then
			
                availableMods[data.SenderID] = data.Mods
                HostUpdateMods()
				
            elseif data.Type == 'MissingMap' then
			
                HostPlayerMissingMapAlert(data.Id)

				UpdateGame()
				
			elseif data.Type == 'BadMap' then
			
				gameInfo.PlayerOptions[FindSlotForID(data.SenderID)].BadMap = data.Result
				
				if data.Result == 'true' then
					-- if the map is actually bad
					lobbyComm:BroadcastData( { Type = 'SetBadMap', Slot = FindSlotForID(data.SenderID), Result = data.Result } )

					UpdateGame()
				end
			end
        else
            -- Non-host only messages
            if data.Type == 'SystemMessage' then
                AddChatText(data.Text)
				
			elseif data.Type == 'SetBadMap' then
				gameInfo.PlayerOptions[data.Slot].BadMap = data.Result

            elseif data.Type == 'SlotAssigned' then
                if data.Options.OwnerID == localPlayerID and data.Options.Human then
                    -- The new slot is for us. Request the full game info from the host
                    localPlayerName = data.Options.PlayerName -- validated by server
					EnhancedLobby.BroadcastAIInfo(lobbyComm:IsHost())
                    lobbyComm:SendData( hostID, {Type = "GetGameInfo"} )
					lobbyComm:SendData( hostID, {Type = "GiveLEMInfo", Slot = data.Slot, LEM = EnhancedLobby.GetLEMData() } )
                else
                    -- The new slot was someone else, just add that info.
                    gameInfo.PlayerOptions[data.Slot] = data.Options
                end

                UpdateGame()

            elseif data.Type == 'SlotMove' then
                if data.Options.OwnerID == localPlayerID and data.Options.Human then
                    localPlayerName = data.Options.PlayerName -- validated by server
                    lobbyComm:SendData( hostID, {Type = "GetGameInfo"} )
                else
                    gameInfo.PlayerOptions[data.OldSlot] = nil
                    gameInfo.PlayerOptions[data.NewSlot] = data.Options
                end
                ClearSlotInfo(data.OldSlot)

                UpdateGame()

            elseif data.Type == 'ObserverAdded' then
			
                if data.Options.OwnerID == localPlayerID then
                    -- The new slot is for us. Request the full game info from the host
                    localPlayerName = data.Options.PlayerName -- validated by server
                    lobbyComm:SendData( hostID, {Type = "GetGameInfo"} )
                else
                    -- The new slot was someone else, just add that info.
                    gameInfo.Observers[data.Slot] = data.Options
                end

                UpdateGame()

            elseif data.Type == 'ConvertObserverToPlayer' then
			
                if data.Options.OwnerID == localPlayerID then
					EnhancedLobby.BroadcastAIInfo(lobbyComm:IsHost())
                    lobbyComm:SendData( hostID, {Type = "GetGameInfo"} )
					lobbyComm:SendData( hostID, {Type = "GiveLEMInfo", Slot = data.NewSlot, LEM = EnhancedLobby.GetLEMData() } )
                else
                    gameInfo.Observers[data.OldSlot] = nil
                    gameInfo.PlayerOptions[data.NewSlot] = data.Options
					
                end

                UpdateGame()

            elseif data.Type == 'ConvertPlayerToObserver' then
                if data.Options.OwnerID == localPlayerID then
                    lobbyComm:SendData( hostID, {Type = "GetGameInfo"} )
                else
                    gameInfo.Observers[data.NewSlot] = data.Options
                    gameInfo.PlayerOptions[data.OldSlot] = nil
                end
                ClearSlotInfo(data.OldSlot)

                UpdateGame()

            elseif data.Type == 'SetColor' then
			
                gameInfo.PlayerOptions[data.Slot].WheelColor = data.Color
                gameInfo.PlayerOptions[data.Slot].ArmyColor = data.Color
                ---gameInfo.PlayerOptions[data.Slot].ArmyColor = 1

                UpdateGame()
				
            elseif data.Type == 'SetLEMInfo' then
			
                gameInfo.PlayerOptions[data.Slot].LEM = data.LEM

                UpdateGame()
				
			elseif data.Type == 'TransmitMod' then
			
				ReceiveMod(data.modCode, data.modId, data.last)
				if data.last then
					UpdateGame()
					ModManager.UpdateClientModStatus(gameInfo.GameMods)
				end
				
            elseif data.Type == 'GameInfo' then
			
                -- Note: this nukes whatever options I may have set locally
                gameInfo = data.GameInfo
				
				CheckIfHaveMods()
                --LOG('Got GameInfo: ', repr(gameInfo))

                UpdateGame()

            elseif data.Type == 'GameOption' then
			
                gameInfo.GameOptions[data.Key] = data.Value

                UpdateGame()

            elseif data.Type == 'Launch' then
			
                local info = data.GameInfo

                info.GameMods = Mods.GetGameMods(info.GameMods)

                for i, config in data.ModConfigs do
                    info.GameMods[i].config = config
                end

                LOG("LOBBY: Client launching with gameInfo: "..repr(info))

                lobbyComm:LaunchGame(info)

            elseif data.Type == 'ClearSlot' then
			
                ClearSlotInfo(data.Slot)
                gameInfo.PlayerOptions[data.Slot] = nil

                UpdateGame()

            elseif data.Type == 'ClearObserver' then
			
                gameInfo.Observers[data.Slot] = nil

                UpdateGame()

            elseif data.Type == 'ModsChanged' then
			
                gameInfo.GameMods = data.GameMods
				gameInfo.GameModNames = data.GameModNames
				CheckIfHaveMods()

                UpdateGame()
                ModManager.UpdateClientModStatus(gameInfo.GameMods)
            
            elseif data.Type == 'SlotClose' then
			
                gameInfo.ClosedSlots[data.Slot] = true

                UpdateGame()
            
            elseif data.Type == 'SlotOpen' then
			
                gameInfo.ClosedSlots[data.Slot] = nil

                UpdateGame()
            end
        end
    end

    lobbyComm.SystemMessage = function(self, text)
	
        AddChatText(text)
    end

    lobbyComm.GameLaunched = function(self)
	
        local player = lobbyComm:GetLocalPlayerID()
        for i, v in gameInfo.PlayerOptions do
            if v.Human and v.OwnerID == player then
                Prefs.SetToCurrentProfile('LoadingFaction', v.Faction)
                break
            end
        end

        if GUI.pingThread then
            KillThread(GUI.pingThread)
        end
        if GUI.keepAliveThread then
            KillThread(GUI.keepAliveThread)
        end
        GUI:Destroy()
        GUI = false
        import('/lua/ui/menus/menucommon.lua').MenuCleanup()
        lobbyComm:Destroy()
        lobbyComm = false

        -- determine if cheat keys should be mapped
        if not DebugFacilitiesEnabled() then
            IN_ClearKeyMap()
            IN_AddKeyMapTable(import('/lua/keymap/keymapper.lua').GetKeyMappings(gameInfo.GameOptions['CheatsEnabled'] == 'true'))
        end

    end

    lobbyComm.Hosting = function(self)
    
        LOG("*AI DEBUG LOBBY CREATING MP LOBBY")
	
        localPlayerID = lobbyComm:GetLocalPlayerID()
        hostID = localPlayerID

        selectedMods = table.map(function (m) return m.uid end, Mods.GetGameMods())

        HostUpdateMods()

        -- Give myself the first slot
        gameInfo.PlayerOptions[1]               = LobbyComm.GetDefaultPlayerOptions(localPlayerName)
        gameInfo.PlayerOptions[1].OwnerID       = localPlayerID
        gameInfo.PlayerOptions[1].Human         = true
        gameInfo.PlayerOptions[1].WheelColor    = Prefs.GetFromCurrentProfile('LastColor')

        -- Backwards compatibility
        if type(gameInfo.PlayerOptions[1].WheelColor) ~= 'table' then
            gameInfo.PlayerOptions[1].WheelColor = { 255, 0, 0 }
        end

        gameInfo.PlayerOptions[1].ArmyColor     = Prefs.GetFromCurrentProfile('LastColor') or 1
        gameInfo.PlayerOptions[1].ArmyColor     = 1
		gameInfo.PlayerOptions[1].LEM           = EnhancedLobby.GetLEMData() or {}

        local requestedFaction = Prefs.GetFromCurrentProfile('LastFaction')
		
        if (requestedFaction == nil) or (requestedFaction > table.getn(FactionData.Factions)) then
            requestedFaction = table.getn(FactionData.Factions) + 1
        end
		
        if hasSupcom then
            gameInfo.PlayerOptions[1].Faction   = requestedFaction
        else
            gameInfo.PlayerOptions[1].Faction   = 4
        end

        LOG("*AI DEBUG LOBBY SET DEFAULT OPTIONS")

        aitypes = import('/lua/enhancedlobby.lua').GetAIList()
        
        -- this will load all the default options 
        -- and any global options from active mods
        GetGlobalOptions()
        
        -- Game speed adjustable by default
        SetGameOption('GameSpeed', 'adjustable', true, true)

        -- Allow Observers by default
        SetGameOption("AllowObservers",true, true, true)

        -- Set default lobby values - all of them bypass the refresh in here
        --for index, option in import('/lua/ui/lobby/lobbyoptions.lua').teamOptions do
            --local defValue = Prefs.GetFromCurrentProfile(option.pref) or option.default
            --SetGameOption(option.key,option.values[defValue].key, true, true)
        --end

        for index, option in lobbyOptMap do
        
            --LOG("*AI DEBUG LOBBY Processing Option "..repr(index).."  type is "..repr(option.type))
        
            if option.type and option.type == 'edit' then
                local defValue = Prefs.GetFromCurrentProfile(option.pref) or option.default

                if defValue == nil then
                    defValue = option.default
                end
                
                SetGameOption(option.key, defValue, true, true)
            else
                local defValue = Prefs.GetFromCurrentProfile(option.pref) or option.default

                if defValue == nil then
                    defValue = option.default
                end

                SetGameOption(option.key,option.values[defValue].key, true, true)
            end
            
        end

        -- set scenario(map) default
        if self.desiredScenario and self.desiredScenario ~= "" then
            Prefs.SetToCurrentProfile('LastScenario', self.desiredScenario)
            SetGameOption('ScenarioFile',self.desiredScenario, true, true)
        else
            local scen = Prefs.GetFromCurrentProfile('LastScenario')
            if scen and scen ~= "" then
                SetGameOption('ScenarioFile',scen, true, true)
            end
        end

        -- set Restricted Categories
		if Prefs.GetFromCurrentProfile('RestrictedCategories') then
			local restrictedCategories = Prefs.GetFromCurrentProfile('RestrictedCategories')
			SetGameOption('RestrictedCategories', restrictedCategories, true, true)
		end
        
        GUI.keepAliveThread = ForkThread(
            -- Eject players who haven't sent a heartbeat in a while
            function()
                while true and lobbyComm do
                    local peers = lobbyComm:GetPeers()
                    for k,peer in peers do
                        if peer.quiet > LobbyComm.quietTimeout then
                            SendSystemMessage(LOCF(Strings.TimedOut,peer.name))
                            lobbyComm:EjectPeer(peer.id,'TimedOutToHost')
                        end
                    end
                    WaitSeconds(1)
                end
            end
        )

        CreateUI(LobbyComm.maxPlayerSlots, useSteam)
		
		EnhancedLobby.BroadcastAIInfo(lobbyComm:IsHost())

        -- Assign (default) map options if applicable
        AssignDefaultMapOptions(gameInfo)

        UpdateGame()    -- this will do the necessary refresh of the options

        if not singlePlayer and not useSteam then
            AddChatText(LOCF('<LOC lobui_0290>Hosting on port %d', lobbyComm:GetLocalPort()))
        end
    end

    lobbyComm.PeerDisconnected = function(self,peerName,peerID)

        local slot = FindSlotForID(peerID)
		
        if slot then
		
            ClearSlotInfo( slot )
            gameInfo.PlayerOptions[slot] = nil
            
        else
		
            slot = FindObserverSlotForID(peerID)
			
            if slot then
                gameInfo.Observers[slot] = nil
            end
        end

        availableMods[peerID] = nil
		
        HostUpdateMods()

		UpdateGame()
    end

    lobbyComm.GameConfigRequested = function(self)

        return {
            Options = gameInfo.GameOptions,
            HostedBy = localPlayerName,
            PlayerCount = GetPlayerCount(),
            GameName = gameName,
            ProductCode = import('/lua/productcode.lua').productCode,
        }
    end
	
end

function SetPlayerOption(slot, key, val, override)

    if not IsLocallyOwned(slot) and not override then

        local lpid = tostring(localPlayerID)
        local ownerID = tostring(gameInfo.PlayerOptions[slot].OwnerID)

        WARN(
            string.format("Illegal SetPlayerOption attempt (%s = %s) by %s on slot %d (%s)",
            key, val, lpid, slot, ownerID))
        return
    end

    if not hasSupcom then
        if key == 'Faction' then
            val = 4
        end
    end

    gameInfo.PlayerOptions[slot][key] = val
   
    lobbyComm:BroadcastData( { Type = 'PlayerOption', Key = key, Value = val, Slot = slot, Override = override } )

    UpdateGame()
end

function SetGameOption( key, val, ignoreNilValue, bypassrefresh )

    ignoreNilValue = ignoreNilValue or false
    
    if (not ignoreNilValue) and ((key == nil) or (val == nil)) then
	
        WARN('Attempt to set nil lobby game option: ' .. tostring(key) .. ' ' .. tostring(val))
        return
    end
    
    if lobbyComm:IsHost() then
    
        --LOG("*AI DEBUG LOBBY setGameOption "..repr(key).." val "..repr(val))
    
        if gameInfo.GameOptions[key] and gameInfo.GameOptions[key] == val then return end

        local change        = true
        local scenarioinfo  = nil
        
        gameInfo.GameOptions['MaxSlots'] = "16"
        lobbyComm:BroadcastData { Type = 'GameOption', Key = 'MaxSlots', Value = "16" }
	
        gameInfo.GameOptions[key] = val
		
        lobbyComm:BroadcastData { Type = 'GameOption', Key = key, Value = val }
		
		if key == 'ScenarioFile' then
		
			scenarioinfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
			gameInfo.GameOptions['ScenarioVersion'] = scenarioinfo.map_version or 1
			
			lobbyComm:BroadcastData { Type = 'GameOption', Key = 'ScenarioVersion',	Value = scenarioinfo.map_version or 1 }

		end
        
        -- don't want to send all restricted categories to gpgnet, so just send bool
        -- note if more things need to be translated to gpgnet, a translation table would be a better implementation
        -- but since there's only one, we'll call it out here
        if key == 'RestrictedCategories' then

            local restrictionsEnabled = false
            local change = false

            if val ~= nil then

                if table.getn(val) ~= 0 then
                    restrictionsEnabled = true
                    change = true
                end

            end

        end

        if change and not bypassrefresh then
    
            LOG("*AI DEBUG LOBBY Changing Game Option key "..repr(key).." value "..repr(val) )

            RefreshOptionDisplayData(scenarioinfo)
        end

    end
    
    UpdateGame()
    
end

function DebugDump()

    if lobbyComm then
	
        lobbyComm:DebugDump()
		
    end
	
end

-- Big Map Preview stuff.
bMP = false

function CreateBigPreview(parent)
	if bMP then
		CloseBigPreview()
	end
	
	local MapPreview = import('/lua/ui/controls/mappreview.lua').MapPreview
	bMP = MapPreview(parent)
	
	bMP.OnDestroy = function(self) bMP = false end

	bMP:Show()
	
	-- The Overlay texture needs to be larger than the underlying map preview image.
	-- So, we'll scale the map preview to fit the Overlay, not the other way around.
	bMP.Overlay = Bitmap(bMP, UIUtil.SkinnableFile("/lobby/lan-game-lobby/map-pane-border-big_bmp.dds"))
	
	scWidth = GetFrame(0).Width() -- Get the Game's Width & Height values.
	scHeight = GetFrame(0).Height()
	
	bMP.Overlay.Width:Set(scHeight*0.75)
	bMP.Overlay.Height:Set(scHeight*0.75)
	bMP.Overlay.Left:Set((scWidth*0.5)-(bMP.Overlay.Width()/2))
	bMP.Overlay.Top:Set((scHeight*0.5)-(bMP.Overlay.Height()/2))
	bMP.Overlay.Depth:Set(998)

	bMP.Width:Set(bMP.Overlay.Width()-(bMP.Overlay.Width()*0.01))
	bMP.Height:Set(bMP.Overlay.Height()-(bMP.Overlay.Height()*0.01))
    LayoutHelpers.AtLeftTopIn(bMP, bMP.Overlay, 5, 5)
	bMP.Depth:Set(997)
	
	bMP.CloseBtn = UIUtil.CreateButtonStd(bMP.Overlay, '/scx_menu/popup_btn/popup', "Close", 12, 0, 0, "UI_Tab_Click_01", "UI_Tab_Rollover_01")
	LayoutHelpers.AtTopIn(bMP.CloseBtn, bMP.Overlay, 0)
	LayoutHelpers.AtHorizontalCenterIn(bMP.CloseBtn, bMP.Overlay)
	bMP.CloseBtn.Depth:Set(999)
	
	bMP.CloseBtn.OnClick = function()
		CloseBigPreview()
	end
	
	scenarioInfo = MapUtil.LoadScenario(gameInfo.GameOptions.ScenarioFile)
	
	if scenarioInfo and scenarioInfo.map and (scenarioInfo.map ~= "") then
	
		if not bMP:SetTexture(scenarioInfo.preview) then
		
			bMP:SetTextureFromMap(scenarioInfo.map)
			
		end
		
	end
	
	local mapdata = {}
	
	doscript('/lua/dataInit.lua', mapdata) -- needed for the format of _save files
	doscript(scenarioInfo.save, mapdata)
	
	local allmarkers = mapdata.Scenario.MasterChain['_MASTERCHAIN_'].Markers -- get the markers from the save file
	local massmarkers = {}
	local hydromarkers = {}
	
	for markname in allmarkers do
	
		if allmarkers[markname]['type'] == "Mass" then
		
			table.insert(massmarkers, allmarkers[markname])
			
		elseif allmarkers[markname]['type'] == "Hydrocarbon" then
		
			table.insert(hydromarkers, allmarkers[markname])
			
		end
		
	end
	
	bMP.massmarkers = {}
    bMP.hydros = {}

    local width = scenarioInfo.size[1]
    local height = scenarioInfo.size[2]
    local xOffset, yOffset, largest = ComputeNonSquareOffset(width, height)

    -- locate all the extractors
    for i = 1, table.getn(massmarkers) do
 
        bMP.massmarkers[i] = Bitmap(bMP, UIUtil.SkinnableFile("/game/build-ui/icon-mass_bmp.dds"))
		LayoutHelpers.SetDimensions(bMP.massmarkers[i], 10, 10)
        bMP.massmarkers[i].Left:Set(
            bMP.Left() + 
            (xOffset + massmarkers[i].position[1] / largest) * bMP.Width() - 
            bMP.massmarkers[i].Width() / 2
        )
        bMP.massmarkers[i].Top:Set(
            bMP.Top() + 
            (yOffset + massmarkers[i].position[3] / largest) * bMP.Height() - 
            bMP.massmarkers[i].Height() / 2
        )
    end

    -- locate all the hydro's
 
    for i = 1, table.getn(hydromarkers) do
 
        bMP.hydros[i] = Bitmap(bMP, UIUtil.SkinnableFile("/game/build-ui/icon-energy_bmp.dds"))
		LayoutHelpers.SetDimensions(bMP.hydros[i], 10, 10)
        bMP.hydros[i].Left:Set(
            bMP.Left() + 
            (xOffset + hydromarkers[i].position[1] / largest) * bMP.Width() - 
            bMP.hydros[i].Width() / 2
        )
        bMP.hydros[i].Top:Set(
            bMP.Top() + 
            (yOffset + hydromarkers[i].position[3] / largest) * bMP.Height() - 
            bMP.hydros[i].Height() / 2
        )
    end

	-- start positions
	bMP.markers = {}
	NewShowMapPositions(bMP,scenarioInfo,GetPlayerCount())
	
end

function CloseBigPreview()

	if bMP then
	
		bMP.CloseBtn:Destroy()
		bMP.Overlay:Destroy()
		
		for i = 1, table.getn(bMP.massmarkers) do
			bMP.massmarkers[i]:Destroy()
		end
		
		for i = 1, table.getn(bMP.hydros) do
			bMP.hydros[i]:Destroy()
		end
		
		bMP:Destroy()
		bMP = false
		
	end
	
end -- CloseBigPreview()

local posGroup = false

 -- copied from the old lobby.lua, needed to change GUI. into bMP. for a separately handled set of markers
function NewShowMapPositions(mapCtrl, scenario, numPlayers)

	if scenario.starts == nil then scenario.starts = true end

	if posGroup then
	
		posGroup:Destroy()
		posGroup = false
		
	end

	if bMP.markers and table.getn(bMP.markers) > 0 then
	
		for i, v in bMP.markers do
		
			v.marker:Destroy()
			
		end
		
	end

	if not scenario.starts or not scenario.size then return end

	local posGroup = Group(mapCtrl)
	
	LayoutHelpers.FillParent(posGroup, mapCtrl)

	local startPos = MapUtil.GetStartPositions(scenario)

	local cHeight = LayoutHelpers.InvScaleNumber(posGroup:Height())
	local cWidth = LayoutHelpers.InvScaleNumber(posGroup:Width())

	local mWidth = scenario.size[1]
	local mHeight = scenario.size[2]
	local xOffset, yOffset, largest = ComputeNonSquareOffset(mWidth, mHeight)

	local playerArmyArray = MapUtil.GetArmies(scenario)

	for inSlot, army in playerArmyArray do
	
		local pos = startPos[army]
        
        if not pos then
            continue
        end
        
		local slot = inSlot
		
		bMP.markers[slot] = {}
		bMP.markers[slot].marker = Bitmap(posGroup)
		LayoutHelpers.SetDimensions(bMP.markers[slot].marker, 8, 10)
		bMP.markers[slot].marker.Depth:Set(function() return posGroup.Depth() + 10 end)
		bMP.markers[slot].marker:SetSolidColor('ff777777')
		
		bMP.markers[slot].teamIndicator = Bitmap(bMP.markers[slot].marker)
		
		LayoutHelpers.AnchorToRight(bMP.markers[slot].teamIndicator, bMP.markers[slot].marker, 1)
		LayoutHelpers.AtTopIn(bMP.markers[slot].teamIndicator, bMP.markers[slot].marker, 5)
		
		bMP.markers[slot].teamIndicator:DisableHitTest()
		
		bMP.markers[slot].markerOverlay = Button(bMP.markers[slot].marker, 
			UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'),
			UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'),
			UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'),
			UIUtil.UIFile('/dialogs/mapselect02/commander_alpha.dds'))
			
		LayoutHelpers.AtCenterIn(bMP.markers[slot].markerOverlay, bMP.markers[slot].marker)
		
		bMP.markers[slot].markerOverlay.Slot = slot
		
		bMP.markers[slot].markerOverlay.OnClick = function(self, modifiers)
		
			if modifiers.Left then
			
				if FindSlotForID(localPlayerID) ~= self.Slot and gameInfo.PlayerOptions[self.Slot] == nil then
				
					if IsPlayer(localPlayerID) then
					
						if lobbyComm:IsHost() then
						
							HostTryMovePlayer(hostID, FindSlotForID(localPlayerID), self.Slot)
							
						else
						
							lobbyComm:SendData(hostID, {Type = 'MovePlayer', CurrentSlot = FindSlotForID(localPlayerID), RequestedSlot =  self.Slot})
							
						end
						
					elseif IsObserver(localPlayerID) then
					
						if lobbyComm:IsHost() then
						
							HostConvertObserverToPlayer(hostID, localPlayerName, FindObserverSlotForID(localPlayerID), self.Slot)
							
						else
						
							lobbyComm:SendData(hostID, {Type = 'RequestConvertToPlayer', RequestedName = localPlayerName, ObserverSlot = FindObserverSlotForID(localPlayerID), PlayerSlot = self.Slot})
							
						end
						
					end
					
				end
				
			elseif modifiers.Right then
			
				if lobbyComm:IsHost() then
				
					if gameInfo.ClosedSlots[self.Slot] == nil then
					
						HostCloseSlot(hostID, self.Slot)
						
					else
					
						HostOpenSlot(hostID, self.Slot)
						
					end	
					
				end
				
			end
			
		end
		
		bMP.markers[slot].markerOverlay.HandleEvent = function(self, event)
		
			if event.Type == 'MouseEnter' then
			
				if gameInfo.GameOptions['TeamSpawn'] ~= 'random' then
				
					GUI.slots[self.Slot].name.HandleEvent(self, event)
					bMP.markers[self.Slot].Indicator:Play()
					
				end
				
			elseif event.Type == 'MouseExit' then
			
				GUI.slots[self.Slot].name.HandleEvent(self, event)
				bMP.markers[self.Slot].Indicator:Stop()
				
			end
			
			Button.HandleEvent(self, event)
			
		end
        

		LayoutHelpers.AtLeftTopIn(bMP.markers[slot].marker, posGroup, 
			((xOffset + pos[1] / largest) * cWidth) - LayoutHelpers.InvScaleNumber(bMP.markers[slot].marker.Width() / 2), 
			((yOffset + pos[2] / largest) * cHeight) - LayoutHelpers.InvScaleNumber(bMP.markers[slot].marker.Height() / 2))
        
		local index = slot
		
		bMP.markers[slot].Indicator = Bitmap(bMP.markers[slot].marker, UIUtil.UIFile('/game/beacons/beacon-quantum-gate_btn_up.dds'))
		
		LayoutHelpers.AtCenterIn(bMP.markers[slot].Indicator, bMP.markers[slot].marker)
		
		LayoutHelpers.SetDimensions(bMP.markers[slot].Indicator, bMP.markers[index].Indicator.BitmapWidth() * .3, bMP.markers[index].Indicator.BitmapHeight() * .3)
		bMP.markers[slot].Indicator.Depth:Set(function() return bMP.markers[index].marker.Depth() - 1 end)
		bMP.markers[slot].Indicator:Hide()
		bMP.markers[slot].Indicator:DisableHitTest()
		
		bMP.markers[slot].Indicator.Play = function(self)
		
			self:SetAlpha(1)
			self:Show()
			self:SetNeedsFrameUpdate(true)
			self.time = 0
			self.OnFrame = function(control, time)
			
				control.time = control.time + (time*4)
				control:SetAlpha(MATH_Lerp(math.sin(control.time), -.5, .5, 0.3, 0.5))
				
			end
			
		end
		
		bMP.markers[slot].Indicator.Stop = function(self)
		
			self:SetAlpha(0)
			self:Hide()
			self:SetNeedsFrameUpdate(false)
			
		end

		if gameInfo.GameOptions['TeamSpawn'] == 'random' then
		
			bMP.markers[slot].marker:SetSolidColor("ff777777")
			
		else
		
			if gameInfo.PlayerOptions[slot] then
			
				bMP.markers[slot].marker:SetSolidColor(ColorToStr(gameInfo.PlayerOptions[slot].WheelColor))
				
				if gameInfo.PlayerOptions[slot].Team == 1 then
				
					bMP.markers[slot].teamIndicator:SetSolidColor('00000000')
					
				else
				
					bMP.markers[slot].teamIndicator:SetTexture(UIUtil.UIFile(teamIcons[gameInfo.PlayerOptions[slot].Team]))
					
				end
				
			else
			
				bMP.markers[slot].marker:SetSolidColor("ff777777")
				bMP.markers[slot].teamIndicator:SetSolidColor('00000000')
				
			end
			
		end

		if gameInfo.ClosedSlots[slot] ~= nil then
		
			local textOverlay = Text(bMP.markers[slot].markerOverlay)
			
			textOverlay:SetFont(UIUtil.bodyFont, 14)
			textOverlay:SetColor("Crimson")
			textOverlay:SetText("X")
			
			LayoutHelpers.AtCenterIn(textOverlay, bMP.markers[slot].markerOverlay)
			
		end
		
	end
	
end -- NewShowMapPositions(...)

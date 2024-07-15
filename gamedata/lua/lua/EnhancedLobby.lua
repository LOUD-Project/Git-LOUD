---  File     :  /lua/EnhancedLobby.lua
---  Author(s): Michael Robbins aka Sorian
---  Summary  : Functions to support the Lobby Enhancement Mod.

local MapUtil       = import('/lua/ui/maputil.lua')
local Mods          = import('/lua/mods.lua')

local GPGrestrictedUnits    = import('/lua/lemlobbyoptions.lua').GPGrestrictedUnits
local GPGsortOrder          = import('/lua/lemlobbyoptions.lua').GPGsortOrder
local GPGOptions            = import('/lua/lemlobbyoptions.lua').GPGOptions

local versionstrings = import('/lua/lemlobbyoptions.lua').versionstrings

function GetLEMVersion(short)

	if short then
		return 'LEM4.5'
	end
	
	return 'LEM 4.5 - 16 Player'
end

function VersionLoc(la)

	if versionstrings[la] then
		return versionstrings[la]
	end
	
	return versionstrings['us']
end

function GetActiveModLocation( mod_Id )

	local activeMods = GetActiveMods()
	
	for i, mod in activeMods do
	
		if mod_Id == mod.uid then
			return mod.location
		end
	end
	
	return false
end


function CheckMapHasMarkers(scenario)

	if not DiskGetFileInfo(scenario.save) then
		return false
	end
	
    local saveData = {}
	
    doscript('/lua/dataInit.lua', saveData)
    doscript(scenario.save, saveData)

	if saveData and saveData.Scenario and saveData.Scenario.MasterChain and
	saveData.Scenario.MasterChain['_MASTERCHAIN_'] and saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers then
		for marker,data in saveData.Scenario.MasterChain['_MASTERCHAIN_'].Markers do
			if string.find( string.lower(marker), 'landpn') then
				return true
			end
		end
	else
		WARN('Map '..scenario.name..' has no marker chain')
	end
	
	return false
end


function GetLobbyOptions()

	local activeMods = GetActiveMods()
	local options = GPGOptions
	
	local OptionFiles = DiskFindFiles('/lua/CustomOptions', '*.lua')
	
	for i, v in OptionFiles do

        local tempfile = import(v).LobbyGlobalOptions
		
		for s, t in tempfile do
		
			table.insert(options, t)
			
		end
		
	end
	
	for k, mod in activeMods do
	
		local OptionFiles = DiskFindFiles(mod.location..'/lua/CustomOptions', '*.lua')
		
		for i, v in OptionFiles do

			local tempfile = import(v).LobbyGlobalOptions
			
			for s, t in tempfile do
			
                LOG("*AI DEBUG Custom Lobby Option from mod "..repr(mod.name).." "..repr(t.label))

				table.insert(options, t)
				
			end
			
		end
		
	end
	
	return options
	
end


function IsSim()
	
	if not rawget(_G, 'GetCurrentUIState') then
		return true
	end
	
	return false
end


function GetActiveMods()

	if IsSim() then
		return __active_mods
	end
	
	return Mods.GetGameMods()
end


function GetRestrictedUnits()

	local activeMods = GetActiveMods()

	local options = GPGrestrictedUnits
	
	local OptionFiles = DiskFindFiles('/lua/CustomUnitRestrictions', '*.lua')
	
	for i, v in OptionFiles do
	
        local tempfile = import(v).UnitRestrictions
		
		for s, t in tempfile do	
		
			options[s] = t
			
		end
		
	end
	
	for k, mod in activeMods do
	
		local OptionFiles = DiskFindFiles(mod.location..'/lua/CustomUnitRestrictions', '*.lua')
		
		for i, v in OptionFiles do
		
			local tempfile = import(v).UnitRestrictions
			
			for s, t in tempfile do	
			
				options[s] = t
				
			end
			
		end
		
	end
	
	return options	
	
end

function GetSortOrder()

	local activeMods = GetActiveMods()
	local options = GPGsortOrder
	
	local OptionFiles = DiskFindFiles('/lua/CustomSortOrder', '*.lua')
	
	for i, v in OptionFiles do
	
        local tempfile = import(v).SortOrder
		
		for s, t in tempfile do	
		
			table.insert(options, t)
			
		end
		
	end
	
	for k, mod in activeMods do
	
		local OptionFiles = DiskFindFiles(mod.location..'/lua/CustomSortOrder', '*.lua')
		
		for i, v in OptionFiles do
		
			local tempfile = import(v).SortOrder
			
			for s, t in tempfile do	
			
				table.insert(options, t)
				
			end
			
		end
		
	end
	
	return options	
	
end

function GetAIList()

    local aitypes = {}

    local AIFiles = DiskFindFiles('/lua/AI/CustomAIs_v2', '*.lua')
    local AIFilesold = DiskFindFiles('/lua/AI/CustomAIs', '*.lua')

    function AddAIData(tempfile)

        if tempfile then

            for s, tAIData in tempfile do
            
                if not aitypes[tAIData.key] then

                    --LOG('*AI DEBUG Adding AI with name '..repr(tAIData))    ---..(tAIData.Name or 'nil'))

                    table.insert(aitypes, { key = tAIData.key, name = tAIData.name })
                    
                end

            end
        end
    end

    --Load Custom AIs - old style
    for i, v in AIFilesold do
    
        if import(v).AILIST then

            AddAIData(import(v).AIList)
        
        end

    end

    --Load Custom AIs
    for i, v in AIFiles do
    
        if import(v).AI.AIList then

            AddAIData(import(v).AI.AIList)
            
        end

    end

    --Load Custom Cheating AIs - old style
    for i, v in AIFilesold do
    
        if import(v).CheatAIList then

            AddAIData(import(v).CheatAIList)
            
        end

    end

    --Load Custom Cheating AIs
    for i, v in AIFiles do
    
        if import(v).AI.CheatAIList then

            AddAIData(import(v).AI.CheatAIList)
        
        end

    end

    --Support for custom AIs via mods
    local activeMods = GetActiveMods()

    if activeMods then

        for k, mod in activeMods do

            local AIFiles = DiskFindFiles(mod.location..'/lua/AI/CustomAIs_v2', '*.lua')

            if AIFiles then

                for i, v in AIFiles do
                
                    LOG("*AI DEBUG Active Mod AI "..repr(v))
                    
                    AddAIData(import(v).AI.AIList)
                    AddAIData(import(v).AI.CheatAIList)
                end
            end

        end
    end
    
    return aitypes

end

function GetCustomTooltips()

	local activeMods = GetActiveMods()
	local tooltips = {}
	
	local AIFiles = DiskFindFiles('/lua/AI/CustomAITooltips', '*.lua')
	
	--Load Custom AI Tooltips
	for i, v in AIFiles do
        local tempfile = import(v)
		if tempfile.Tooltips then
			for s, t in tempfile.Tooltips do	
				tooltips[s] = t
			end
		end
	end

	for k, mod in activeMods do
		local OptionFiles = DiskFindFiles(mod.location..'/lua/AI/CustomAITooltips', '*.lua')
		for i, v in OptionFiles do
			local tempfile = import(v)
			if tempfile.Tooltips then
				for s, t in tempfile.Tooltips do	
					tooltips[s] = t
				end
			end
		end
	end
	
	return tooltips
end

function BroadcastAIInfo(ishost)

	--Add chat message for each custom AI
	local AIFiles = DiskFindFiles('/lua/AI/CustomAIs_v2', '*.lua')
	
	local broadchat = ""
	
    for i, v in AIFiles do
	
		--LOG("*AI DEBUG file is "..repr(i))
        local tempfile = import(v).AI
		
		if tempfile.Name and tempfile.Version then
			broadchat = broadchat..tempfile.Name.." "..tempfile.Version.."; "
		end
	end
	
	if broadchat != "" then
	
		if ishost then
			import('/lua/ui/lobby/lobby.lua').PublicChat("("..GetLEMVersion(true)..") Is using: "..broadchat)
		end
		
	else
		import('/lua/ui/lobby/lobby.lua').PublicChat("("..GetLEMVersion(true)..") Is not using any AIs")
	end
end

function GetLEMData()

	-- Add chat message for each custom AI
	local AIFiles = DiskFindFiles('/lua/AI/CustomAIs_v2', '*.lua')
	
	local data = {}
	
	-- insert the LEM version
	table.insert(data, GetLEMVersion(true))
	
	-- insert the MOD versions
    for i, v in AIFiles do
        local tempfile = import(v).AI
		if tempfile.Name and tempfile.Version then
			table.insert(data, tempfile.Name..' '..tempfile.Version)
		end
	end

	return data
end
--*****************************************************************************
--* File: lua/keymap/keymapper.lua
--* Author: Chris Blackwell
--* Summary: Utility functions to map keys to actions
--*
--* Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************

local Prefs = import('/lua/user/prefs.lua')

LOG("*AI DEBUG Loading Keymapper")



function GetDefaultKeyMap(includeDebugKeys)
    local ret = {}
    local defaultKeyMap = import('defaultKeyMap.lua').defaultKeyMap
    local debugKeyMap = import('defaultKeyMap.lua').debugKeyMap
    
    for k,v in defaultKeyMap do
        ret[k] = v
    end
    
    if (DebugFacilitiesEnabled() == true) or (includeDebugKeys == true) then
        for k,v in debugKeyMap do
            ret[k] = v
        end
    end
    
    return ret
end

function GetUserKeyMap(includeDebugKeys)
    local ret = {}
    local userKeyMap = Prefs.GetFromCurrentProfile("UserKeyMap")
    
    if not userKeyMap then return nil end
    
    for k,v in userKeyMap do
        ret[k] = v
    end
    
    if userKeyMap and ((DebugFacilitiesEnabled() == true) or (includeDebugKeys == true)) then
        local userDebugKeyMap = Prefs.GetFromCurrentProfile("UserDebugKeyMap")
        if userDebugKeyMap then
            for k,v in userDebugKeyMap do
                ret[k] = v 
            end
        end
    end
    return ret
end

function GetCurrentKeyMap(includeDebugKeys)
    return GetUserKeyMap(includeDebugKeys) or GetDefaultKeyMap(includeDebugKeys)
end

function SetUserKeyMapping(key, oldKey, action)

    --LOG("*AI DEBUG keymapper SetUserKeyMapping for "..repr(action) )

    local newMap = GetCurrentKeyMap()
    
    newMap[key] = action
    newMap[oldKey] = nil
    
    Prefs.SetToCurrentProfile("UserKeyMap", newMap)

    -- GAZ UI --
    -- this retrieves the GAZ debug key maps
    local debugKeyMap = import('defaultKeyMap.lua').debugKeyMap
    
    -- and writes them to the profile
	Prefs.SetToCurrentProfile("UserDebugKeyMap", debugKeyMap)    
end

function ClearUserKeyMap()

    --LOG("*AI DEBUG keymapper ClearUserKeyMap")
    
    Prefs.SetToCurrentProfile("UserKeyMap", nil)
    Prefs.SetToCurrentProfile("UserDebugKeyMap", nil)
end


function GetKeyActions(includeDebugKeys)

    --LOG("*AI DEBUG keymapper GetKeyActions - include debug is "..repr(includeDebugKeys))
    
    local ret = {}

    local keyActions = import('keyactions.lua').keyActions
    local debugKeyActions = import('keyactions.lua').debugKeyActions
    
    for k,v in keyActions do
        ret[k] = v
    end
    
    if (DebugFacilitiesEnabled() == true) or (includeDebugKeys == true) then
        for k,v in debugKeyActions do
            ret[k] = v
        end
    end

    local userActions = Prefs.GetFromCurrentProfile("UserKeyActions")
    
    if userActions != nil then
        for k,v in userActions do
            ret[k] = v
        end
    end
    
    return ret
end

function SetUserKeyAction(actionName, actionTable)

    local newActions = Prefs.GetFromCurrentProfile("UserKeyActions") or {}
    
    --LOG("*AI DEBUG keymapper SetUserKeyActions for "..repr(actionName).." using table "..repr(actionTable))
    
    newActions[actionName] = actionTable
    Prefs.SetToCurrentProfile("UserKeyActions", newActions)
end

function ClearUserKeyActions()
    Prefs.SetToCurrentProfile("UserKeyActions", nil)
end

-- returns keys mapped to actions
function GetKeyMappings(includeDebugKeys)

    local currentKeyMap = GetCurrentKeyMap(includeDebugKeys)
    local keyActions = GetKeyActions(includeDebugKeys)    
    local keyMap = {}
    
    --LOG("*AI DEBUG keymapper GetKeyMappings - include debug keys is "..repr(includeDebugKeys))

    -- set up default mapping
    for key, action in currentKeyMap do
    
        --LOG("*AI DEBUG loading Key Action "..repr(key).." "..repr(action))
        
        keyMap[key] = keyActions[action]
        
        if keyMap[key] == nil then
            --WARN("Key action not found " .. action .. " for key " .. key)
        end
    end
    
    return keyMap
end

-- returns action names mapped to keys
function GetKeyLookup()

    local currentKeyMap = GetCurrentKeyMap(true)
    
    -- get default keys
    local ret = {}
    
    for k,v in currentKeyMap do
        ret[v] = k    
    end

    return ret
end

-- returns a table of raw (windows) key codes mapped to key names
function GetKeyCodeLookup()

    local ret = {}
    
    local keyCodeTable = import('/lua/keymap/keyNames.lua').keyNames
    
    for k, v in keyCodeTable do
        local codeInt = STR_xtoi(k)
        ret[codeInt] = v
    end
    
    return ret
end

-- given a key in string form, checks to see if it's already in the key map
function IsKeyInMap(key, map)

    -- given a key string makes it always ctrl-shift-alt-key for comparison
    -- returns a table with modifier keys extracted
    local function NormalizeKey(inKey)
    
        local retVal = {}
        local keyNames = import('/lua/keymap/keyNames.lua').keyNames
        local modKeys = {[keyNames['11']] = true, -- ctrl
                         [keyNames['10']] = true, -- shift
                         [keyNames['12']] = true, -- alt
                        }
                        
        local startpos = 1
        
        while startpos do
        
            local fst, lst = string.find(inKey, "-", startpos)
            local str
            
            if fst then
                str = string.sub(inKey, startpos, fst - 1)
                startpos = lst + 1
            else
                str = string.sub(inKey, startpos, string.len(inKey))
                startpos = nil
            end
            
            if modKeys[str] then
                retVal[str] = true
            else
                retVal["key"] = str
            end
        end
        
        return retVal
    end

    local compKeyCombo = NormalizeKey(key)   
    
    for keyCombo, action in map do
    
        local curKeyCombo = NormalizeKey(keyCombo)
        
        if table.equal(curKeyCombo, compKeyCombo) then
            return true
        end    
    end
    
    return false
end


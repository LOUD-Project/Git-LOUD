--- The global function SessionIsMultiplayer does not recognize DirectIP matches as multiplayer matches.
 -- This may lead to unexpected results, e.g. load/save buttons shown in the game menu.

-- Keep a reference to the actual function
local OriginalSessionIsMultiplayer = _G.SessionIsMultiplayer

-- The corrected implementation
local PatchedSessionIsMultiplayer = function()

    -- Keep the functioning part
    if OriginalSessionIsMultiplayer() then
        return true
    end

    -- if there are at least two human players, then it is always a multiplayer game.
    local foundHuman = false
    for index, playerInfo in GetArmiesTable().armiesTable do
        if playerInfo.human then
            if foundHuman then
                -- Found two humans, we don't need to look at the rest of the players.
                return true
            end
            foundHuman = true
        end
    end
    return false
end

-- Create cache for actual value
local Cached = PatchedSessionIsMultiplayer()

-- Override global function to return our cache
_G.SessionIsMultiplayer = function()
    return Cached
end

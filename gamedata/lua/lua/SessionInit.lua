-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--

-- This is the user-side session specific top-level lua initialization
-- file.  It is loaded into a fresh lua state when a new session is
-- initialized.

LOG("*DEBUG SessionInit")

InitialRegistration = true

-- start loading UI side --
doscript '/lua/userInit.lua'

-- Add UI-only mods to the list of mods to use
for i,m in ipairs(import('/lua/mods.lua').GetUiMods()) do
    table.insert(__active_mods, m)
end

table.sort(__active_mods, function(a,b) return a.name < b.name end )
 
LOG("*DEBUG Active mods in session: ")

for _,mod in __active_mods do
    LOG( "     "..mod.name )
end

doscript '/lua/UserSync.lua'

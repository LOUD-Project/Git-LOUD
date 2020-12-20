-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--
-- This is the top-level lua initialization file. It is run at initialization time
-- to set up all lua state.

LOG("*DEBUG Mohodata GlobalInit")

-- Uncomment this to turn on allocation tracking, so that memreport() in /lua/system/profile.lua
-- does something useful.
--debug.trackallocations(true)

-- Set up global diskwatch table (you can add callbacks to it to be notified of disk changes)
__diskwatch = {}

-- Set up custom Lua weirdness
doscript '/lua/system/config.lua'


-- Load system modules
LOG("*AI DEBUG     Implementing Import")
doscript '/lua/system/import.lua'

LOG("*AI DEBUG     Implementing Utils")
doscript '/lua/system/utils.lua'

LOG("*AI DEBUG     Implementing REPR functions")
doscript '/lua/system/repr.lua'

LOG("*AI DEBUG     Loading Class FUnctions")
doscript '/lua/system/class.lua'

LOG("*AI DEBUG     Defining TRASHBAG Class")
doscript '/lua/system/trashbag.lua'

LOG("*AI DEBUG     Localization begins")
doscript '/lua/system/Localization.lua'

LOG("*AI DEBUG     Creating MULTIEVENT Class")
doscript '/lua/system/MultiEvent.lua'

LOG("*AI DEBUG     Loading COLLAPSE functions")
doscript '/lua/system/collapse.lua'


-- Classes exported from the engine are in the 'moho' table. But they aren't full
-- classes yet, just lists of exported methods and base classes. Turn them into
-- real classes.
for name,cclass in moho do
    --SPEW('C->lua ',name)
    ConvertCClassToLuaClass(cclass)
end


-- Flag initial loading of blueprints
InitialRegistration = true

LOG("*AI DEBUG     Setup Platoon Template Structure")
-- Load Platoon Template systems
doscript '/lua/system/GlobalPlatoonTemplate.lua'

LOG("*AI DEBUG     Setup Builder Template Structure")
-- Load Builder system
doscript '/lua/system/GlobalBuilderTemplate.lua'

LOG("*AI DEBUG     Setup Builder Group Structure")
-- Load Builder Group systems
doscript '/lua/system/GlobalBuilderGroup.lua'

LOG("*AI DEBUG     Setup BaseBuilder Template Structure")
-- Load Global Base Templates
doscript '/lua/system/GlobalBaseTemplate.lua'

InitialRegistration = false
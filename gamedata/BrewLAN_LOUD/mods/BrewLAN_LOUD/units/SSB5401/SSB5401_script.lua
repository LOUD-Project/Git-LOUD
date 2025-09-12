--------------------------------------------------------------------------------
-- Summary  :  Stargate Script
--------------------------------------------------------------------------------    
local TeleportUnit = import('/lua/defaultunits.lua').TeleportUnit

local StargateDialing = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/StargateDialing.lua').StargateDialing

TeleportUnit = StargateDialing(TeleportUnit) 

SSB5401 = Class(TeleportUnit) {}

TypeClass = SSB5401

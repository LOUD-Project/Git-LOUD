--------------------------------------------------------------------------------
-- Summary  :  Stargate Script
--------------------------------------------------------------------------------    
local TeleportUnit = import('/lua/defaultunits.lua').TeleportUnit

local StargateDialing = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/StargateDialing.lua').StargateDialing

TeleportUnit = StargateDialing(TeleportUnit) 

SSB5401 = Class(TeleportUnit) {

    OnCreate = function(self)

        if self:GetCurrentLayer() ~= 'Land' then
            self:HideBone('XSB0304', false)
        end

        TeleportUnit.OnCreate(self)

    end,

}

TypeClass = SSB5401

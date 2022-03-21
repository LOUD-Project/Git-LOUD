local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon
local CDFLaserDisintegratorWeapon = import('/lua/cybranweapons.lua').CDFLaserDisintegratorWeapon02

XRA0305 = Class(CAirUnit) {
    
    Weapons = {
        Missiles1 = Class(CAAMissileNaniteWeapon) {},
        Disintegrator01 = Class(CDFLaserDisintegratorWeapon) {},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_StealthToggle', true)
    end,
}
TypeClass = XRA0305
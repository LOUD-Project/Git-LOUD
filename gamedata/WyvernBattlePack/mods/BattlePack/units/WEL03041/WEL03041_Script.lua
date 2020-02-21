local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon

WEL03041 = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) {
        }
    },
	
	OnCreate = function(self)
        TLandUnit.OnCreate(self)
        self:HideBone('AATurret_Yaw', true)
    end,
	
	OnStopBeingBuilt = function(self,builder,layer)
        TLandUnit.OnStopBeingBuilt(self,builder,layer)
        self:HideBone('AATurret_Yaw', true)
    end,
}

TypeClass = WEL03041
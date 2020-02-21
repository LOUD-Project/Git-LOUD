local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local cWeapons = import('/lua/cybranweapons.lua')

local CDFLaserDisintegratorWeapon = cWeapons.CDFLaserDisintegratorWeapon01


WRL0305 = Class(CWalkingLandUnit) {
    Weapons = {
        MainGun = Class(CDFLaserDisintegratorWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
    
       CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
       
       self:SetMaintenanceConsumptionActive()
    end,
    
}

TypeClass = WRL0305
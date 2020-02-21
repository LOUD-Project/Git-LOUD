local CLandUnit = import('/lua/cybranunits.lua').CLandUnit
local CDFElectronBolterWeapon = import('/lua/cybranweapons.lua').CDFElectronBolterWeapon

WRL0301 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CDFElectronBolterWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
       CLandUnit.OnStopBeingBuilt(self,builder,layer)
       self:SetMaintenanceConsumptionActive()
    end,

}

TypeClass = WRL0301
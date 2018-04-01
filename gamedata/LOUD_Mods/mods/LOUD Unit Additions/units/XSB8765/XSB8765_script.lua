local SMassStorageUnit = import('/lua/seraphimunits.lua').SMassStorageUnit
local SWeapons = import('/lua/seraphimweapons.lua')
local SIFCommanderDeathWeapon = SWeapons.SIFCommanderDeathWeapon

XSB8765 = Class(SMassStorageUnit) {

    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        SMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -6.875, 0, 0, 0))
    end,
}

TypeClass = XSB8765
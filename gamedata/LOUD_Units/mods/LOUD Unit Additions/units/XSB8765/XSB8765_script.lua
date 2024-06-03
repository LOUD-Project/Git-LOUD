local SMassStorageUnit = import('/lua/seraphimunits.lua').SMassStorageUnit

local SIFCommanderDeathWeapon = import('/lua/seraphimweapons.lua').SIFCommanderDeathWeapon

XSB8765 = Class(SMassStorageUnit) {

    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        SMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -4.5, 0, 0, 0))
    end,
}

TypeClass = XSB8765
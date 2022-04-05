local AEnergyStorageUnit = import('/lua/defaultunits.lua').StructureUnit

local AWeapons = import('/lua/aeonweapons.lua')

local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon

UAB8765 = Class(AEnergyStorageUnit) {

    Weapons = {
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
        AEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Side_Pods', 'ENERGY', 0, 0, 0, 0, 0, 2))
        self.Trash:Add(CreateStorageManip(self, 'Center_Pod', 'ENERGY', 0, 0, 0, 0, 0, 0.667))
		self.Trash:Add(CreateRotator(self, 'Side_Pods', 'z', nil, 1.5, 0.1, 1.5))
    end,

}

TypeClass = UAB8765
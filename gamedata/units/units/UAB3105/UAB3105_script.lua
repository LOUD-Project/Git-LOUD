local AEnergyStorageUnit = import('/lua/aeonunits.lua').AEnergyStorageUnit

UAB1105 = Class(AEnergyStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        AEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Side_Pods', 'ENERGY', 0, 0, 0, 0, 0, .54))
        self.Trash:Add(CreateStorageManip(self, 'Center_Pod', 'ENERGY', 0, 0, 0, 0, 0, .54))
    end,

}

TypeClass = UAB1105
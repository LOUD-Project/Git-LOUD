local AEnergyStorageUnit = import('/lua/defaultunits.lua').StructureUnit

UAB1105 = Class(AEnergyStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        AEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Side_Pods', 'ENERGY', 0, 0, 0, 0, 0, .3))
        self.Trash:Add(CreateStorageManip(self, 'Center_Pod', 'ENERGY', 0, 0, 0, 0, 0, .3))
    end,

}

TypeClass = UAB1105
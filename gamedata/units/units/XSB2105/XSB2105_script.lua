local SEnergyStorageUnit = import('/lua/defaultnits.lua').StructureUnit

XSB1105 = Class(SEnergyStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        SEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -0.98, 0, 0, 0))
    end,

}

TypeClass = XSB1105
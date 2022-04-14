local SEnergyStorageUnit = import('/lua/defaultunits.lua').StructureUnit

XSB1105 = Class(SEnergyStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        SEnergyStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -1.26, 0, 0, 0))
    end,

}

TypeClass = XSB1105
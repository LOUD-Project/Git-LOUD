local SMassStorageUnit = import('/lua/seraphimunits.lua').SMassStorageUnit

XSB1106 = Class(SMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        SMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'MASS', 0, 0, -1.35, 0, 0, 0))
    end,
}

TypeClass = XSB1106
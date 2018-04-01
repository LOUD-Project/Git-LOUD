local TMassStorageUnit = import('/lua/terranunits.lua').TMassStorageUnit

UEB1106 = Class(TMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        TMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Block', 'MASS', 0, 0, -0.42, 0, 0, 0))
    end,
}

TypeClass = UEB1106
local TMassStorageUnit = import('/lua/terranunits.lua').TMassStorageUnit

BEB1106 = Class(TMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        TMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, 0.6))
		self.Trash:Add(CreateStorageManip(self, 'Energy', 'ENERGY', 0, 0, 0, 0, 0, 0.7))
    end,
}

TypeClass = BEB1106
local SMassStorageUnit = import('/lua/defaultunits.lua').StructureUnit

BSB1106 = Class(SMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        SMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, .41))
		self.Trash:Add(CreateStorageManip(self, 'energy', 'ENERGY', 0, 0, 0, 0, 0, .6))
    end,
}

TypeClass = BSB1106
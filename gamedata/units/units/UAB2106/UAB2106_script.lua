

local AMassStorageUnit = import('/lua/aeonunits.lua').AMassStorageUnit

UAB1106 = Class(AMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
        AMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'MASS', 0, 0, 0, 0, 0, .574))
    end,

    AnimThread = function(self)
        
    end,
}

TypeClass = UAB1106
local CMassStorageUnit = import('/lua/defaultunits.lua').StructureUnit

BRB1106 = Class(CMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
    
        CMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        
        self:ForkThread(self.AnimThread)

    end,

    AnimThread = function(self)
        local sliderManip = CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, .55)
		local sliderManip2 = CreateStorageManip(self, 'Energy', 'ENERGY', 0, 0, 0, 0, 0, 0.6)
    end,
}

TypeClass = BRB1106
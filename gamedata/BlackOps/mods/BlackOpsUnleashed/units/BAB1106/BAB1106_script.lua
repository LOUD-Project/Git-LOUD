local AMassStorageUnit = import('/lua/defaultunits.lua').StructureUnit

local TrashAdd = TrashBag.Add

BAB1106 = Class(AMassStorageUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
    
        AMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        
        TrashAdd( self.Trash, CreateStorageManip(self, 'M_Storage_1', 'MASS', 0, 0, 0, 0, 0, .7) )
		TrashAdd( self.Trash, CreateStorageManip(self, 'M_Storage_2', 'MASS', 0, 0, 0, 0, 0, .41) )
		TrashAdd( self.Trash, CreateStorageManip(self, 'E_Storage', 'ENERGY', 0, 0, 0, 0, 0, .6) )
		TrashAdd( self.Trash, CreateRotator(self, 'Rotator', 'y', nil, 0, 15, 80) )
    end,
}

TypeClass = BAB1106
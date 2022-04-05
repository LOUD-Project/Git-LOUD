local TEnergyStorageUnit = import('/lua/defaultunits.lua').StructureUnit

UEB1105 = Class(TEnergyStorageUnit) {

    OnCreate = function(self)
        TEnergyStorageUnit.OnCreate(self)
        self.Trash:Add(CreateStorageManip(self, 'B01', 'ENERGY', 0, 0, -0.72, 0, 0, 0))
    end,

}

TypeClass = UEB1105
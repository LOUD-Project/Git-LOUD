local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Cannon = import('/lua/seraphimweapons.lua').SDFHeavyQuarnonCannon

BSB2306 = Class(SStructureUnit) {
    Weapons = {
        Turret = Class(Cannon) {},
    },
}

TypeClass = BSB2306
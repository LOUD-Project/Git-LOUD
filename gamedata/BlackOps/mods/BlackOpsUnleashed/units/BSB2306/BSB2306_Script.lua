local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SDFHeavyQuarnonCannon = import('/lua/seraphimweapons.lua').SDFHeavyQuarnonCannon

BSB2306 = Class(SStructureUnit) {
    Weapons = {
        Turret = Class(SDFHeavyQuarnonCannon) {},
    },
}

TypeClass = BSB2306
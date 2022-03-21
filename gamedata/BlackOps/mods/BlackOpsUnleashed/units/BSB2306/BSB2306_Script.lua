local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFHeavyQuarnonCannon = SeraphimWeapons.SDFHeavyQuarnonCannon

BSB2306 = Class(SStructureUnit) {
    Weapons = {
        Turret = Class(SDFHeavyQuarnonCannon) {
       },
    },
}

TypeClass = BSB2306
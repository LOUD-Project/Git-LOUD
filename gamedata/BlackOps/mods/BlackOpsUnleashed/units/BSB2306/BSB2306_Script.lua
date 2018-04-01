
local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFHeavyQuarnonCannon = SeraphimWeapons.SDFHeavyQuarnonCannon

BSB2306 = Class(SStructureUnit) {
    Weapons = {
        Turret = Class(SDFHeavyQuarnonCannon) {
       },
    },
}

TypeClass = BSB2306
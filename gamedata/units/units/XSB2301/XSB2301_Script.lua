local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SDFUltraChromaticBeamGenerator = import('/lua/seraphimweapons.lua').SDFUltraChromaticBeamGenerator

XSB2301 = Class(SStructureUnit) {
    Weapons = {
        MainGun = Class(SDFUltraChromaticBeamGenerator) {}
    },
}

TypeClass = XSB2301
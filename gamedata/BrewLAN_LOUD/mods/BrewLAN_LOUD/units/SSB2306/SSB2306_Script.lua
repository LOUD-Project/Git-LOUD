local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local SDFAireauWeapon = import ('/lua/seraphimweapons.lua').SDFAireauWeapon

SSB2306 = Class(SStructureUnit) {
    Weapons = {
        MainGun = Class(SDFAireauWeapon) {},
    },
}

TypeClass = SSB2306

local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local WeaponsFile = import ('/lua/seraphimweapons.lua')
local SDFAireauWeapon = WeaponsFile.SDFAireauWeapon

SSB2306 = Class(SStructureUnit) {
    Weapons = {
        MainGun = Class(SDFAireauWeapon) {},
    },
}

TypeClass = SSB2306

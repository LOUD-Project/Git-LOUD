local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtillerySonanceShellWeapon = import('/lua/aeonweapons.lua').AIFArtillerySonanceShellWeapon

UAB2302 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFArtillerySonanceShellWeapon) {},
    },
	
}

TypeClass = UAB2302
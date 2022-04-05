local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon

UAB2303 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFArtilleryMiasmaShellWeapon) {},
    },
}

TypeClass = UAB2303
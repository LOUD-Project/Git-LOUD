local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon

LAB2320 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFArtilleryMiasmaShellWeapon) {},
        MainGun1 = Class(AIFArtilleryMiasmaShellWeapon) {},
        MainGun2 = Class(AIFArtilleryMiasmaShellWeapon) {},
    },
}

TypeClass = LAB2320
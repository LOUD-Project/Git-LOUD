local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon

SAB2103 = Class(AStructureUnit) {

    Weapons = {
        MainGun = Class(AIFArtilleryMiasmaShellWeapon) {},
    },
}

TypeClass = SAB2103

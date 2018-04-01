
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit
local ADFGravitonProjectorWeapon = import('/lua/aeonweapons.lua').ADFGravitonProjectorWeapon

UAB2101 = Class(AStructureUnit) {
    Weapons = {
        MainGun = Class(ADFGravitonProjectorWeapon) {},
    },
}

TypeClass = UAB2101
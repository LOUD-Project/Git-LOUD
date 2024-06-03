local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

UAB2304 = Class(AStructureUnit) {

    Weapons = {
        AAMissileRack = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = UAB2304
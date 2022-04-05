local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAAZealotMissileWeapon = import('/lua/aeonweapons.lua').AAAZealotMissileWeapon

UAB2304 = Class(AStructureUnit) {
    Weapons = {
        AntiAirMissiles = Class(AAAZealotMissileWeapon) {},
    },
}

TypeClass = UAB2304
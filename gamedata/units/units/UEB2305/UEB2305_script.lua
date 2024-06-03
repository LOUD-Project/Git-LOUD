local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TIFStrategicMissileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

UEB2305 = Class(TStructureUnit) {
    Weapons = {
        NukeMissiles = Class(TIFStrategicMissileWeapon) {},
    },
}

TypeClass = UEB2305

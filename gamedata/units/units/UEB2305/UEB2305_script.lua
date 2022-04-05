local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TIFStrategicMissileWeapon = import('/lua/terranweapons.lua').TIFStrategicMissileWeapon

UEB2305 = Class(TStructureUnit) {
    Weapons = {
        NukeMissiles = Class(TIFStrategicMissileWeapon) {},
    },
}

TypeClass = UEB2305

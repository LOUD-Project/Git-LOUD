local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TIFStrategicMissileWeapon = import('/lua/terranweapons.lua').TIFStrategicMissileWeapon

UEB2305 = Class(TStructureUnit) {
    Weapons = {
        NukeMissiles = Class(TIFStrategicMissileWeapon) {},
    },
}

TypeClass = UEB2305

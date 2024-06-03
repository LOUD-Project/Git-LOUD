local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CIFMissileStrategicWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

URB2305 = Class(CStructureUnit) {
    Weapons = {
        NukeMissiles = Class(CIFMissileStrategicWeapon) {},
    },
    
}

TypeClass = URB2305

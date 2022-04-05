
local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local CIFMissileStrategicWeapon = import('/lua/cybranweapons.lua').CIFMissileStrategicWeapon

URB2305 = Class(CStructureUnit) {
    Weapons = {
        NukeMissiles = Class(CIFMissileStrategicWeapon) {},
    },
    
}

TypeClass = URB2305

local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CIFNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CIFNaniteTorpedoWeapon

SRA0106 = Class(CAirUnit) {
    DestroySeconds = 7.5,          
    Weapons = {
        Bomb = Class(CIFNaniteTorpedoWeapon) {},
    },
}
TypeClass = SRA0106

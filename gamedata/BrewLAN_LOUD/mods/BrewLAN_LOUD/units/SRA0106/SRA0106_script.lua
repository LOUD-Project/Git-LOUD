local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CIFNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CIFNaniteTorpedoWeapon

SRA0106 = Class(CAirUnit) {

    Weapons = {
        Torpedo = Class(CIFNaniteTorpedoWeapon) {},
    },
    
}
TypeClass = SRA0106

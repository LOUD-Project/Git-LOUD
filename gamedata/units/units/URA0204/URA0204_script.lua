local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CIFNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CIFNaniteTorpedoWeapon

URA0204 = Class(CAirUnit) {

    Weapons = {
	
        Bomb = Class(CIFNaniteTorpedoWeapon) {},
		
    },
	
}

TypeClass = URA0204
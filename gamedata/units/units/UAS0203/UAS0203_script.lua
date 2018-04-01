local ASubUnit = import('/lua/aeonunits.lua').ASubUnit
local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon

UAS0203 = Class(ASubUnit) {

    Weapons = {
	
        Torpedo = Class(AANChronoTorpedoWeapon) {},
		
    },
	
}

TypeClass = UAS0203
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local CDFHeavyMicrowaveLaserGeneratorCom = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom

BRMT1EXPD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
		},
    },
}

TypeClass = BRMT1EXPD
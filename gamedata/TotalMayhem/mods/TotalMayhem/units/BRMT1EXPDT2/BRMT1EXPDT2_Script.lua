local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFHeavyMicrowaveLaserGeneratorCom = CybranWeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom

BRMT1EXPDT2 = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
		},
    },
}

TypeClass = BRMT1EXPDT2
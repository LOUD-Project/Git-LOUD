local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFHeavyMicrowaveLaserGeneratorCom = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom

BRMT1EXPD = Class(TStructureUnit) {

    Weapons = {
        MainGun = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
    },
}

TypeClass = BRMT1EXPD
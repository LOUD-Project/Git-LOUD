local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon
local CDFHeavyMicrowaveLaserGenerator = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGenerator

URB2306 = Class(CStructureUnit) {
    Weapons = {
        MainGun = Class(CDFHeavyMicrowaveLaserGenerator) {},
        Laser = Class(CDFLaserHeavyWeapon) {}
    },
}
TypeClass = URB2306
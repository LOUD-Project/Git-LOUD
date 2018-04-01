
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon


URB2101 = Class(CStructureUnit) {

    Weapons = {
        MainGun = Class(CDFLaserHeavyWeapon) {}
    },
}

TypeClass = URB2101

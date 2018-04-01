
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local CDFLaserPulseLightWeapon = import('/lua/cybranweapons.lua').CDFLaserPulseLightWeapon

URL0106 = Class(CWalkingLandUnit) {
    Weapons = {
        MainGun = Class(CDFLaserPulseLightWeapon) {},
    },
}

TypeClass = URL0106
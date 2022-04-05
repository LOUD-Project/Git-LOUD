local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

--local CDFLaserPulseLightWeapon = import('/lua/cybranweapons.lua').CDFLaserPulseLightWeapon

URL0106 = Class(CWalkingLandUnit) {

    Weapons = {
        MainGun = Class(import('/lua/cybranweapons.lua').CDFLaserPulseLightWeapon) {},
    },
}

TypeClass = URL0106
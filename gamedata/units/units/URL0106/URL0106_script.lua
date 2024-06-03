local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

URL0106 = Class(CWalkingLandUnit) {

    Weapons = {
        MainGun = Class(import('/lua/cybranweapons.lua').CDFLaserPulseLightWeapon) {},
    },
}

TypeClass = URL0106
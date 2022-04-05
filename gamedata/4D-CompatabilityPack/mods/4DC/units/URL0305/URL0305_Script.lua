local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CDFLaserDisintegratorWeapon = import('/lua/cybranweapons.lua').CDFLaserDisintegratorWeapon01

URL0305 = Class(CWalkingLandUnit) {
    Weapons = {
        MainGun = Class(CDFLaserDisintegratorWeapon) {},
    },    
}

TypeClass = URL0305
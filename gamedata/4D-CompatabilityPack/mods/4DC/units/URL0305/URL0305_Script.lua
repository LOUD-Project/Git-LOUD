local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local cWeapons = import('/lua/cybranweapons.lua')
local CDFLaserDisintegratorWeapon = cWeapons.CDFLaserDisintegratorWeapon01

URL0305 = Class(CWalkingLandUnit) {
    Weapons = {
        MainGun = Class(CDFLaserDisintegratorWeapon) {},
    },    
}

TypeClass = URL0305
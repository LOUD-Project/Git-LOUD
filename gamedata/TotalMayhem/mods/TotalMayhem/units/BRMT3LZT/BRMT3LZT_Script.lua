local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CDFHeavyDisintegratorWeapon = import('/lua/cybranweapons.lua').CDFHeavyDisintegratorWeapon

BRMT3LZT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(CDFHeavyDisintegratorWeapon) {},
    },
}

TypeClass = BRMT3LZT
local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local CWeapons = import('/lua/cybranweapons.lua')
local CDFHeavyDisintegratorWeapon = CWeapons.CDFHeavyDisintegratorWeapon

BRMT3LZT = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(CDFHeavyDisintegratorWeapon) {},
    },
}

TypeClass = BRMT3LZT
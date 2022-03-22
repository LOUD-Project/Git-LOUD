local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

BROT1BT = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {},
    },
}

TypeClass = BROT1BT
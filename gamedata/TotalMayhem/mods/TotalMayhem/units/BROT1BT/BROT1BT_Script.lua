local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

BROT1BT = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {},
    },
}

TypeClass = BROT1BT
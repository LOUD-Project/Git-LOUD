local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

BROT1BT = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.4},
    },
}

TypeClass = BROT1BT
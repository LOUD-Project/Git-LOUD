local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

BROT1ML = Class(TLandUnit) {

    Weapons = {
        Rockets = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.4 },
    },
}

TypeClass = BROT1ML
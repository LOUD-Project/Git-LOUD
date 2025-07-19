local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local Rocket = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon

BROT1ML = Class(TLandUnit) {

    Weapons = {
        Rockets = Class(Rocket) { FxMuzzleFlashScale = 0.25 },
    },
}

TypeClass = BROT1ML
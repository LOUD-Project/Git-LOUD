local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

BRNT3ABB = Class(TWalkingLandUnit) {

    Weapons = {
        topguns = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.0 },
        guns = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.0 },
    },
}

TypeClass = BRNT3ABB
local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

BRNT3ABB = Class(TWalkingLandUnit) {

    Weapons = {

        topguns = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.25 },

        guns = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },
    },
}

TypeClass = BRNT3ABB
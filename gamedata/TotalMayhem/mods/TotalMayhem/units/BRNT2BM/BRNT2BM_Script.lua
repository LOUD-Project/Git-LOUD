local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon  = WeaponsFile.TDFLandGaussCannonWeapon
local TAMPhalanxWeapon      = WeaponsFile.TAMPhalanxWeapon

WeaponsFile = nil

BRNT2BM = Class(TWalkingLandUnit) {

    Weapons = {
	
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.3 },
        gatling = Class(TAMPhalanxWeapon) { FxMuzzleFlashScale = 0.25 },

    },
}

TypeClass = BRNT2BM
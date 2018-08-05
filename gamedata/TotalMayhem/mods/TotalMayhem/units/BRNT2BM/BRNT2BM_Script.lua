
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local WeaponsFile = import('/lua/terranweapons.lua')
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TAMPhalanxWeapon = WeaponsFile.TAMPhalanxWeapon

BRNT2BM = Class(TWalkingLandUnit) {

    Weapons = {
	
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },
        gatling = Class(TAMPhalanxWeapon) {},

    },
}

TypeClass = BRNT2BM
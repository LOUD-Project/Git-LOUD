
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local WeaponsFile = import('/lua/terranweapons.lua')
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TAMPhalanxWeapon = WeaponsFile.TAMPhalanxWeapon

BRNT2BM = Class(TWalkingLandUnit) {

    Weapons = {
        rocket1 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.5,
        },
        gatling1 = Class(TAMPhalanxWeapon) {},
        gatling2 = Class(TAMPhalanxWeapon) {},
        gatling3 = Class(TAMPhalanxWeapon) {},
        gatling4 = Class(TAMPhalanxWeapon) {},
    },
}

TypeClass = BRNT2BM
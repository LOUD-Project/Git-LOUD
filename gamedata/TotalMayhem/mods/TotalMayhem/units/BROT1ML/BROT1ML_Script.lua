local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

BROT1ML = Class(TLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.5,
		},
    },
}

TypeClass = BROT1ML
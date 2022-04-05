local SHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon

XSL0203 = Class(SHoverLandUnit) {
    Weapons = {
        TauCannon01 = Class(SDFThauCannon){
			FxMuzzleFlashScale = 0.5,
        },
    },
}
TypeClass = XSL0203
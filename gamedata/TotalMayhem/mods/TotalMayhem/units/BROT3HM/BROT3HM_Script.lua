local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')

BROT3HM = Class(CWalkingLandUnit) {

    Weapons = {

        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.2,   
            FxMuzzleFlash = EffectTemplate.AOblivionCannonMuzzleFlash02,
		}, 

        MainGun2 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.5,   
            FxMuzzleFlash = EffectTemplate.AIFBallisticMortarFlash02,
		}, 
    },
}

TypeClass = BROT3HM
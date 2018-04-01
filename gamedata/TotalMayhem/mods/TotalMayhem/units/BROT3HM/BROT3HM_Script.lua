
local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')

BROT3HM = Class(CWalkingLandUnit) {

    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.2,   
            FxMuzzleFlash = EffectTemplate.AOblivionCannonMuzzleFlash02,
		}, 
        MainGun2 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 1,   
            FxMuzzleFlash = EffectTemplate.AIFBallisticMortarFlash02,
		}, 
    },
}

TypeClass = BROT3HM
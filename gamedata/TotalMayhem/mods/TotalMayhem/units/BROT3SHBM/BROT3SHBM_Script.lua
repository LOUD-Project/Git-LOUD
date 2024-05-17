local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TIFCommanderDeathWeapon   = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon
local TDFGaussCannonWeapon      = import('/lua/terranweapons.lua').TDFLandGaussCannonWeapon
local MicrowaveLaser            = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom

local AIFBallisticMortarFlash02 = import('/lua/EffectTemplates.lua').AIFBallisticMortarFlash02

BROT3SHBM = Class(AWalkingLandUnit) {

    Weapons = {

        MainGun     = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.5, FxMuzzleFlash = AIFBallisticMortarFlash02 },
		
        Laser       = Class(MicrowaveLaser) {},
		
        EMPgun      = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
		
        robottalk   = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
    }, 
    
}
TypeClass = BROT3SHBM
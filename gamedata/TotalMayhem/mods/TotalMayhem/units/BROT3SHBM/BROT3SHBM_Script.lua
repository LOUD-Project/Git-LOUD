local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CDFHeavyMicrowaveLaserGeneratorCom = CybranWeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom

local EffectTemplate = import('/lua/EffectTemplates.lua')

BROT3SHBM = Class(AWalkingLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 1.5,
            FxMuzzleFlash = EffectTemplate.AIFBallisticMortarFlash02,
        },
		
        Laser = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
		
        EMPgun = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
		
        robottalk = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0 },
    }, 
    
    OnStopBeingBuilt = function(self,builder,layer)
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
      
        if self:GetAIBrain().BrainType == 'Human' and IsUnit(self) then
            self:SetWeaponEnabledByLabel('robottalk', false)
        else
            self:SetWeaponEnabledByLabel('robottalk', true)
        end      
    end,
    
}
TypeClass = BROT3SHBM
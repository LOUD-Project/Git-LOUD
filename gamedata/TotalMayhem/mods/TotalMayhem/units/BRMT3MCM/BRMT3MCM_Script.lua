local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/cybranweapons.lua')
local WeaponsFile2 = import('/lua/terranweapons.lua')

local CDFElectronBolterWeapon = WeaponsFile.CDFElectronBolterWeapon
local TDFRiotWeapon = WeaponsFile2.TDFRiotWeapon
local CCannonMolecularWeapon = WeaponsFile.CCannonMolecularWeapon
local TIFCommanderDeathWeapon = WeaponsFile2.TIFCommanderDeathWeapon
local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtils = import('/lua/effectutilities.lua')

BRMT3MCM = Class(CWalkingLandUnit) {

    Weapons = {
        HeavyBolter = Class(CDFElectronBolterWeapon) {
	},
        HeavyBoltera = Class(CDFElectronBolterWeapon) {
	},
        HeavyBolterb = Class(CDFElectronBolterWeapon) {
	},
        robottalk = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0,
	},
        HeavyBolter2 = Class(CDFElectronBolterWeapon) {
	},
        HeavyBolter2a = Class(CDFElectronBolterWeapon) {
	},
        HeavyBolter2b = Class(CDFElectronBolterWeapon) {
	},
        mgweapon = Class(TDFRiotWeapon) {
            FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
			            FxMuzzleFlashScale = 0.75, 
        },
        lefthandweapon = Class(CCannonMolecularWeapon) {
            FxMuzzleFlashScale = 1.2,
	},
        righthandweapon = Class(CCannonMolecularWeapon) {
            FxMuzzleFlashScale = 1.2,
	},
        rocket1 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.3,
	},
        rocket2 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.3,
	},
        rocket3 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.3,
	},
        rocket4 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.3,
	},
        DeathWeapon = Class(TIFCommanderDeathWeapon) {
	},
    },
OnStopBeingBuilt = function(self,builder,layer)
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
      
      if self:GetAIBrain().BrainType == 'Human' and IsUnit(self) then
         self:SetWeaponEnabledByLabel('robottalk', false)
      else
         self:SetWeaponEnabledByLabel('robottalk', true)
      end      
    end,
}

TypeClass = BRMT3MCM
local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/cybranweapons.lua')
local WeaponsFile2 = import('/lua/terranweapons.lua')
local CDFElectronBolterWeapon = WeaponsFile.CDFElectronBolterWeapon
local TDFRiotWeapon = WeaponsFile2.TDFRiotWeapon
local CCannonMolecularWeapon = WeaponsFile.CCannonMolecularWeapon
local CDFHeavyMicrowaveLaserGeneratorCom = WeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom
local TIFCommanderDeathWeapon = WeaponsFile2.TIFCommanderDeathWeapon
local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtils = import('/lua/effectutilities.lua')
local RobotTalkFile = import('/lua/cybranweapons.lua')
local CIFGrenadeWeapon = RobotTalkFile.CIFGrenadeWeapon

BRMT3MCM2 = Class(CWalkingLandUnit) {

    Weapons = {
        robottalk = Class(CIFGrenadeWeapon) {
            FxMuzzleFlashScale = 0,
	},
        mgweapon = Class(TDFRiotWeapon) {
            FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
			            FxMuzzleFlashScale = 0.75, 
        },
        lefthandweapon = Class(CCannonMolecularWeapon) {
            FxMuzzleFlash = EffectTemplate.CHvyProtonCannonMuzzleflash,
            FxMuzzleFlashScale = 1.6,
	},
        righthandweapon = Class(CCannonMolecularWeapon) {
            FxMuzzleFlash = EffectTemplate.CHvyProtonCannonMuzzleflash,
            FxMuzzleFlashScale = 1.6,
	},
        rocket1 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.7,
	},
        rocket2 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.7,
	},
        rocket3 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.7,
	},
        rocket4 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlashScale = 0.7,
	},
        laserfire = Class(CDFHeavyMicrowaveLaserGeneratorCom) {
	},
        HeavyBolter = Class(CCannonMolecularWeapon) {
            FxMuzzleFlashScale = 2.15,
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

TypeClass = BRMT3MCM2
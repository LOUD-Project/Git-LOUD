local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile2 = import('/lua/terranweapons.lua')
local CWeapons = import('/lua/cybranweapons.lua')

local CIFCommanderDeathWeapon   = CWeapons.CIFCommanderDeathWeapon

local CDFParticleCannonWeapon   = CWeapons.CDFParticleCannonWeapon
local CDFProtonCannonWeapon     = CWeapons.CDFProtonCannonWeapon

local DualLaser                 = CWeapons.CDFHeavyMicrowaveLaserGeneratorCom
local MissileArray              = CWeapons.CIFMissileLoaWeapon
local CAAMissileNaniteWeapon    = CWeapons.CAAMissileNaniteWeapon

local TDFGaussCannonWeapon  = WeaponsFile2.TDFLandGaussCannonWeapon

--local TDFRiotWeapon         = WeaponsFile2.TDFRiotWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

--local EffectUtils = import('/lua/effectutilities.lua')
--local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
--local CSoothSayerAmbient = import('/lua/EffectTemplates.lua').CSoothSayerAmbient

BRMT3AVA = Class(CWalkingLandUnit) {
   
    Weapons = {
        
        TopTurret1      = Class(CDFProtonCannonWeapon) {FxMuzzleFlashScale = 0.5,FxMuzzleFlash = EffectTemplate.CArtilleryFlash01},
        TopTurret2      = Class(CDFProtonCannonWeapon) {FxMuzzleFlashScale = 0.5,FxMuzzleFlash = EffectTemplate.CArtilleryFlash01},
        NoseTurret      = Class(CDFProtonCannonWeapon) {FxMuzzleFlashScale = 2.1,FxMuzzleFlash = EffectTemplate.CElectronBolterMuzzleFlash01},
        NoseRockets     = Class(TDFGaussCannonWeapon) {FxMuzzleFlashScale = 0},        
        
        BG1             = Class(DualLaser) {},
        BG2             = Class(DualLaser) {},
        BG3             = Class(DualLaser) {},
        BG4             = Class(DualLaser) {},
        
        Missiles        = Class(MissileArray) {FxMuzzleFlashScale = 0},
        
        AAMissiles       = Class(CAAMissileNaniteWeapon) {},
        
        --mgweapon        = Class(TDFRiotWeapon) {FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,FxMuzzleFlashScale = 0.75},
        --laser1w         = Class(CDFParticleCannonWeapon) {},
        --laser2w         = Class(CDFParticleCannonWeapon) {},
        --missilebig = Class(TDFGaussCannonWeapon) {FxMuzzleFlashScale = 0},

        robottalk       = Class(TDFGaussCannonWeapon) {FxMuzzleFlashScale = 0},
        DeathWeapon     = Class(CIFCommanderDeathWeapon) {},
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

TypeClass = BRMT3AVA
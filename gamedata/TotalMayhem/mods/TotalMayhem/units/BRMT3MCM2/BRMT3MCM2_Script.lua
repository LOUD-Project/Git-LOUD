local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile   = import('/lua/cybranweapons.lua')
local WeaponsFile2  = import('/lua/terranweapons.lua')

local CCannonMolecularWeapon    = WeaponsFile.CCannonMolecularWeapon
local MicrowaveLaser            = WeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom

local TIFCommanderDeathWeapon   = WeaponsFile2.TIFCommanderDeathWeapon
local TDFGaussCannonWeapon      = WeaponsFile2.TDFLandGaussCannonWeapon
local TDFRiotWeapon             = WeaponsFile2.TDFRiotWeapon

WeaponsFile = nil
WeaponsFile2 = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRMT3MCM2 = Class(CWalkingLandUnit) {

    Weapons = {
        
        rockets     = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },

        ArmCannon   = Class(CCannonMolecularWeapon) { FxMuzzleFlashScale = 1.2, FxMuzzleFlash = EffectTemplate.CHvyProtonCannonMuzzleflash },

        mgweapon    = Class(TDFRiotWeapon) { FxMuzzleFlashScale = 0.75, FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank },

        lasers      = Class(MicrowaveLaser) {},
		
        robottalk   = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0},        

        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        local bp = self:GetBlueprint().Defense.AntiMissile
		
        local antiMissile = MissileRedirect {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
		
        self.Trash:Add(antiMissile)
        self.UnitComplete = true
    end,

}

TypeClass = BRMT3MCM2
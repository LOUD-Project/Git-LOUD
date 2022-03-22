local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile2 = import('/lua/terranweapons.lua')
local CWeapons = import('/lua/cybranweapons.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CIFCommanderDeathWeapon = CWeapons.CIFCommanderDeathWeapon
local CDFParticleCannonWeapon = CWeapons.CDFParticleCannonWeapon
local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon
local TDFRiotWeapon = WeaponsFile2.TDFRiotWeapon
local CDFProtonCannonWeapon = CWeapons.CDFProtonCannonWeapon


BRMT3AVA = Class(CWalkingLandUnit) {

    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
		
        TopTurretCannon = Class(CDFProtonCannonWeapon) { FxMuzzleFlashScale = 4.1	},
		
        FrontTurretCannon = Class(CDFProtonCannonWeapon) { FxMuzzleFlashScale = 4.1 },
		
        laser1w = Class(CDFParticleCannonWeapon) {},
		
        laser2w = Class(CDFParticleCannonWeapon) {},
		
        mgweapon = Class(TDFRiotWeapon) {
			FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
			FxMuzzleFlashScale = 0.75, 
        },
		
        rocket1 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.1 },
		
        rocket2 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.1 },

    },

}

TypeClass = BRMT3AVA
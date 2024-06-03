local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local TDFGaussCannonWeapon  = WeaponsFile.TDFLandGaussCannonWeapon
local TDFHiroPlasmaCannon   = WeaponsFile.TDFHiroPlasmaCannon
local TDFRiotWeapon         = WeaponsFile.TDFRiotWeapon

WeaponsFile = nil

BRNT3BLASP = Class(TWalkingLandUnit) {

    Weapons = {

        laser = Class(TDFHiroPlasmaCannon) { FxMuzzleFlashScale = 0.01 },

        gauss = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.5 },
		
        rocket = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.45 },

        Riotgun = Class(TDFRiotWeapon) {
		
            FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
            FxMuzzleFlashScale = 0.25, 
			
        },

    },
}

TypeClass = BRNT3BLASP
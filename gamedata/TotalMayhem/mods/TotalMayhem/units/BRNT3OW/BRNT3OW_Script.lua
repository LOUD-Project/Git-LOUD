local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TDFRiotWeapon = WeaponsFile.TDFRiotWeapon
local TAAFlakArtilleryCannon = WeaponsFile.TAAFlakArtilleryCannon

local EffectTemplate = import('/lua/EffectTemplates.lua')

BRNT3OW = Class(TWalkingLandUnit) {

    Weapons = {
        Riotgun = Class(TDFRiotWeapon) {
            FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
		    FxMuzzleFlashScale = 0.75, 
        },
		
        topgunaa = Class(TAAFlakArtilleryCannon) {},
		
        rocket = Class(TDFGaussCannonWeapon) {
		    FxMuzzleFlashScale = 0.45, 
        },
    },
}

TypeClass = BRNT3OW
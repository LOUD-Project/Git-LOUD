local TMobileFactoryUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon
local TAAFlakArtilleryCannon = WeaponsFile.TAAFlakArtilleryCannon
local TIFCruiseMissileLauncher = WeaponsFile.TIFCruiseMissileLauncher
local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon
local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TDFRiotWeapon = WeaponsFile.TDFRiotWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')


WEL0401 = Class(TMobileFactoryUnit) {

	Weapons = {
    
        Turret = Class(TDFGaussCannonWeapon) {},
        
        Riotgun = Class(TDFRiotWeapon) { FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank },

		MainGun = Class(TIFArtilleryWeapon) { FxMuzzleFlashScale = 1.5 },
        
		AAGun = Class(TAAFlakArtilleryCannon) { PlayOnlyOneSoundCue = true },
        
		Rockets = Class(TIFCruiseMissileLauncher) {},
        
		TMD = Class(TDFHiroPlasmaCannon) {},
    },
}

TypeClass = WEL0401
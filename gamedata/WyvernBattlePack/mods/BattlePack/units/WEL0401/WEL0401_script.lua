local TMobileFactoryUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local Artillery = WeaponsFile.TIFArtilleryWeapon
local Flak      = WeaponsFile.TAAFlakArtilleryCannon
local Cruise    = WeaponsFile.TIFCruiseMissileLauncher
local Hiro      = WeaponsFile.TDFHiroPlasmaCannon
local Cannon    = WeaponsFile.TDFLandGaussCannonWeapon
local Riot      = WeaponsFile.TDFRiotWeapon

WeaponsFile = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')


WEL0401 = Class(TMobileFactoryUnit) {

	Weapons = {
        Turret      = Class(Cannon) {},
        Riotgun     = Class(Riot) { FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank },
		MainGun     = Class(Artillery) { FxMuzzleFlashScale = 1.3 },
		AAGun       = Class(Flak) { PlayOnlyOneSoundCue = true },
		Rockets     = Class(Cruise) {},
		TMD         = Class(Hiro) {},
    },
}

TypeClass = WEL0401
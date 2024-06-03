local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/cybranweapons.lua')

local CDFProtonCannonWeapon     = WeaponsFile.CDFProtonCannonWeapon
local CDFParticleCannonWeapon   = WeaponsFile.CDFParticleCannonWeapon

WeaponsFile = nil

BRMT2MEDM = Class(CWalkingLandUnit) {

    Weapons = {
	
        MainGun = Class(CDFParticleCannonWeapon) {},
		
        ParticleMortar1 = Class(CDFProtonCannonWeapon) { FxMuzzleFlashScale = 0.3 },
    },
}

TypeClass = BRMT2MEDM
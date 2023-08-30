local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local WeaponsFile = import('/lua/terranweapons.lua')

local EffectTemplate = import('/lua/EffectTemplates.lua')

local TSAMLauncher = WeaponsFile.TSAMLauncher
local TDFLightPlasmaCannonWeapon = WeaponsFile.TDFLightPlasmaCannonWeapon

BRNT3SHPD = Class(TStructureUnit) {

    Weapons = {

        GaussCannon = Class(TDFGaussCannonWeapon) {

            FxMuzzleFlash = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,
            FxMuzzleFlashScale = 1.1, 
        },     
		
        TurretGun = Class(TDFLightPlasmaCannonWeapon) {},

        SAM = Class(TSAMLauncher) {},
    },
}

TypeClass = BRNT3SHPD
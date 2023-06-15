local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local WeaponsFile = import('/lua/terranweapons.lua')

local EffectTemplate = import('/lua/EffectTemplates.lua')

local TSAMLauncher = WeaponsFile.TSAMLauncher
local TDFLightPlasmaCannonWeapon = WeaponsFile.TDFLightPlasmaCannonWeapon

BRNT3SHPD = Class(TStructureUnit) {
    Weapons = {
        Gauss01 = Class(TDFGaussCannonWeapon) {
            FxMuzzleFlash = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,
            FxMuzzleFlashScale = 1.2, 
        },     

        MissileRack01 = Class(TSAMLauncher) {},
		
        SmallTurretGun01 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun02 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun03 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun04 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun05 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun06 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun07 = Class(TDFLightPlasmaCannonWeapon) {},
        SmallTurretGun08 = Class(TDFLightPlasmaCannonWeapon) {},
    },
}

TypeClass = BRNT3SHPD
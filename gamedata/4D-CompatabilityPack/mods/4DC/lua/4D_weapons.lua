
-- Local Weapon Files --
local WeaponFile = import('/lua/sim/defaultweapons.lua')
local KamikazeWeapon = WeaponFile.KamikazeWeapon
local BareBonesWeapon = WeaponFile.BareBonesWeapon

-- Projectiles --
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon

-- Collision Beams --
local CollisionBeamFile = import('/lua/defaultcollisionbeams.lua')
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon

-- Aeon Collision Beams --
--local DisruptorBeamCollisionBeam = CollisionBeamFile.DisruptorBeamCollisionBeam
--local PhasonLaserCollisionBeam = CollisionBeamFile.PhasonLaserCollisionBeam
--local QuantumBeamGeneratorCollisionBeam = CollisionBeamFile.QuantumBeamGeneratorCollisionBeam
--local TractorClawCollisionBeam = CollisionBeamFile.TractorClawCollisionBeam

-- Effects& Explosions Files --
local EffectTemplate = import('/lua/EffectTemplates.lua')
--local Explosion = import('/lua/defaultexplosions.lua')

-- Custom Files --
local Custom_4D_BeamFile = import('/mods/4DC/lua/4D_defaultcollisionbeams.lua')
--local Custom_4D_EffectTemplate = import('/mods/4DC/lua/4D_EffectTemplates.lua')

-- Aeon Files --
xsl031a_LightningWeapon = Class(DefaultBeamWeapon) {
    BeamType = Custom_4D_BeamFile.xsl031a_LightningBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {}, 
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.75,
}

ArrowMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = { '/effects/emitters/aeon_missile_launch_02_emit.bp', },
}

LaserPhalanxWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/flash_04_emit.bp',
    },
}

BFGShellWeapon = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {  
        '/effects/emitters/aeon_sonance_muzzle_01_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_02_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_03_emit.bp',
    },
    FxMuzzleFlashScale = 1.5,        
}


-- UEF Files --
Over_ChargeProjectile = Class(DefaultProjectileWeapon) {}

Rapid_PlasmaProjectile = Class(DefaultProjectileWeapon) {}

TAMPhalanxWeapon2 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TPhalanxGunMuzzleFlash,   
}
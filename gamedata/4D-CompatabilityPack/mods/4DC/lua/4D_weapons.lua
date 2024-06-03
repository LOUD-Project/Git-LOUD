local DefaultProjectileWeapon = import('/lua/sim/defaultweapons.lua').DefaultProjectileWeapon

ArrowMissileWeapon          = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/aeon_missile_launch_02_emit.bp'} }

LaserPhalanxWeapon          = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/flash_04_emit.bp'} }

BFGShellWeapon              = Class(DefaultProjectileWeapon) { FxChargeMuzzleFlash = {'/effects/emitters/aeon_sonance_muzzle_01_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_02_emit.bp',
        '/effects/emitters/aeon_sonance_muzzle_03_emit.bp',
    },
    FxMuzzleFlashScale = 1.5,        
}

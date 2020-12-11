--
-- script for projectile UEFBuild01
--
UEFBuild01 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {

    FxTrails = {
        '/effects/emitters/build_terran_glow_01_emit.bp',
        '/effects/emitters/build_sparks_blue_01_emit.bp',
    },
}

TypeClass = UEFBuild01


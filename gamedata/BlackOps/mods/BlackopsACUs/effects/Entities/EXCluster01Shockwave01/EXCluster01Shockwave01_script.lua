--
-- script for projectile BoneAttached
--
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

EXCluster01Shockwave01 = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/nuke_blanket_smoke_02_emit.bp',},
    FxTrailScale = 0.03125,-- Exavier Modified Scale
    FxTrailOffset = 0,
}

TypeClass = EXCluster01Shockwave01
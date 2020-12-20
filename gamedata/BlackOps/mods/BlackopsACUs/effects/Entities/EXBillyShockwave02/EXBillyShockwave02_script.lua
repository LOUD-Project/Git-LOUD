--
-- script for projectile BoneAttached
--
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

EXBillyShockwave02 = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/nuke_blanket_smoke_01_emit.bp',},
    FxTrailScale = 0.25,-- Exavier Modified Scale
    FxTrailOffset = 0,
}

TypeClass = EXBillyShockwave02
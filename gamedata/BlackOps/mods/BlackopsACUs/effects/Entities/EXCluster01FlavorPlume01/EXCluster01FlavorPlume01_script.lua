--
-- UEF Nuke Flavor Plume effect
--
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

EXCluster01FlavorPlume01 = Class(EmitterProjectile) {
    FxTrails = EffectTemplate.TNukeFlavorPlume01,
    FxTrailScale = 0.03125,-- Exavier Added Scale
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactWater = {},
    FxImpactUnderWater = {},
    FxImpactNone = {},
}

TypeClass = EXCluster01FlavorPlume01


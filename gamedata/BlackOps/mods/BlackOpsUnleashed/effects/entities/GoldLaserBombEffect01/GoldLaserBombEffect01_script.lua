local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

GoldLaserBombEffect01 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
	FxTrails = BlackOpsEffectTemplate.GoldLaserBombPlumeFxTrails01,
	FxTrailScale = 0.1,
}
TypeClass = GoldLaserBombEffect01


local EffectTemplate = import('/lua/EffectTemplates.lua')

SBOZhanaseeBombEffect01 = Class(import('/lua/sim/defaultprojectiles.lua').MultiPolyTrailProjectile) {
	FxTrails = {},
	PolyTrails = EffectTemplate.SZhanaseeBombHitSpiralFxPolyTrails,
	PolyTrailOffset = {0},   
}
TypeClass = SBOZhanaseeBombEffect01

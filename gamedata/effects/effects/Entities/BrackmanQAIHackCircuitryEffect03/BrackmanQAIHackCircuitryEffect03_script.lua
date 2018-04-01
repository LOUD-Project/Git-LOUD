
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

BrackmanQAIHackCircuitryEffect03 = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = true,
	FxTrajectoryAligned= true,
	FxTrails = EffectTemplate.CBrackmanQAIHackCircuitryEffectFxtrailsALL[3],
}
TypeClass = BrackmanQAIHackCircuitryEffect03

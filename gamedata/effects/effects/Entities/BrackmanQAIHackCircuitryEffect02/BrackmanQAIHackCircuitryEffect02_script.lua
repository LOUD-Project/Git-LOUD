
local EffectTemplate = import('/lua/EffectTemplates.lua')
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

BrackmanQAIHackCircuitryEffect02 = Class(EmitterProjectile) {
	FxImpactTrajectoryAligned = true,
	FxTrajectoryAligned= true,
	FxTrails = EffectTemplate.CBrackmanQAIHackCircuitryEffectFxtrailsALL[2],
}
TypeClass = BrackmanQAIHackCircuitryEffect02

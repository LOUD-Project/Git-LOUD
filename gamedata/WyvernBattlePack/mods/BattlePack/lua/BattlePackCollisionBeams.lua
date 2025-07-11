local SCCollisionBeam = import('/lua/defaultcollisionbeams.lua').SCCollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

StarAdderLaserCollisionBeam02 = Class(SCCollisionBeam) {
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/effects/emitters/microwave_laser_beam_02_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
	FxBeamEndPointScale = 0.2,
}

local SChronatronCannon = import('/lua/seraphimprojectiles.lua').SChronatronCannon

local ChronatronBlastAttackAOE = import('/lua/EffectTemplates.lua').SChronatronCannonBlastAttackAOE 
local CreateEmitterAtEntity = CreateEmitterAtEntity

SDFChronatronCannon01 = Class(SChronatronCannon) {
	FxImpactTrajectoryAligned = false,
	
    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
		local launcher = self:GetLauncher()
		if launcher and launcher:HasEnhancement( 'BlastAttack' ) then
		
			local CreateEmitterAtEntity = CreateEmitterAtEntity
			
			for k, v in ChronatronBlastAttackAOE do
				emit = CreateEmitterAtEntity(self,army,v)
			end
		end
		SChronatronCannon.CreateImpactEffects( self, army, EffectTable, EffectScale )
	end,
}
TypeClass = SDFChronatronCannon01
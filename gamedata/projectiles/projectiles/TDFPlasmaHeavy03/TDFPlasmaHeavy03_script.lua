local THeavyPlasmaCannonProjectile = import('/lua/terranprojectiles.lua').THeavyPlasmaCannonProjectile

local CreateLightParticle = CreateLightParticle
local CreateEmitterAtEntity = CreateEmitterAtEntity

TDFPlasmaHeavy03 = Class(THeavyPlasmaCannonProjectile) {

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )
		local launcher = self:GetLauncher()
		if launcher and launcher:HasEnhancement( 'HighExplosiveOrdnance' ) then
			CreateLightParticle( self, -1, army, 2.0, 9, 'ring_08', 'ramp_white_03' ) 
			CreateEmitterAtEntity(self,army,'/effects/emitters/terran_subcommander_aoe_01_emit.bp')
		end
		THeavyPlasmaCannonProjectile.CreateImpactEffects( self, army, EffectTable, EffectScale )
	end,
}
TypeClass = TDFPlasmaHeavy03


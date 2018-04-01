ADFReactonCannon01 = Class(import('/lua/aeonprojectiles.lua').AReactonCannonProjectile) {

    CreateImpactEffects = function( self, army, EffectTable, EffectScale )

        # Brute51: This is a visual enhancement rather than a bug fix, although I guess you can call it that aswell.
        # This displays an effect when the SCU has the AOE enhancement. The UEF ACU does this, why not the Aeon SCU?
        # no bug fix number in v4 or earlier (yet?)

        local launcher = self:GetLauncher()
		
        if launcher and launcher:HasEnhancement( 'StabilitySuppressant' ) then
		
            CreateEmitterAtEntity(self,army,'/effects/emitters/aeon_commander_overcharge_hit_01_emit.bp')
			
        end

    end,

}

TypeClass = ADFReactonCannon01
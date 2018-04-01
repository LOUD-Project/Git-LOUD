local ADepthChargeProjectile = import('/lua/aeonprojectiles.lua').ADepthChargeProjectile

AANDepthCharge01 = Class(ADepthChargeProjectile) {

    FxEnterWater= { '/effects/emitters/water_splash_plume_01_emit.bp' },

    OnImpact = function(self, TargetType, TargetEntity)

        ADepthChargeProjectile.OnImpact(self, TargetType, TargetEntity)
		
    end,
}

TypeClass = AANDepthCharge01
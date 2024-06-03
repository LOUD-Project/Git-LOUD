local TTorpedoShipProjectile = import('/lua/terranprojectiles.lua').TTorpedoShipProjectile

TorpedoShipTerran02 = Class(TTorpedoShipProjectile) {

    FxSplashScale = 1,

    FxExitWaterEmitter = {
        '/effects/emitters/destruction_water_splash_ripples_01_emit.bp',
        '/effects/emitters/destruction_water_splash_wash_01_emit.bp',
        '/effects/emitters/destruction_water_splash_plume_01_emit.bp',
    },

    OnEnterWater = function(self)

        TTorpedoShipProjectile.OnEnterWater(self)
		
		local CreateEmitterAtEntity = CreateEmitterAtEntity

        for i in self.FxExitWaterEmitter do #splash
            CreateEmitterAtEntity(self,self:GetArmy(),self.FxExitWaterEmitter[i]):ScaleEmitter(self.FxSplashScale)
        end

        self:TrackTarget(true)
        self:StayUnderwater(true)
        self:SetTurnRate(60)
        self:SetMaxSpeed(3)
        self:SetVelocity(3)
    end,
}

TypeClass = TorpedoShipTerran02


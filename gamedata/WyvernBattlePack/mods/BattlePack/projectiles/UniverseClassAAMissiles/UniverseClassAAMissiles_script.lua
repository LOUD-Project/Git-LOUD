--
-- AA Missile for Cybrans
--
MultiPolyTrailProjectile = import('/lua/sim/DefaultProjectiles.lua').MultiPolyTrailProjectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
UniverseClassAAMissiles = Class(MultiPolyTrailProjectile) {

FxTrail = '/mods/BattlePack/effects/emitters/w_c_rkt01_p_02_glow_emit.bp',
    FxTrailOffset = 0,

        PolyTrails = {
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_01_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_07_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_08_polytrail_emit.bp',
      '/mods/BattlePack/effects/emitters/w_c_rkt01_p_09_polytrail_emit.bp',
        },
    PolyTrailOffset = {0,0,0,0},
	
    OnCreate = function(self)
        MultiPolyTrailProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    UpdateThread = function(self)
        WaitSeconds(1.5)
        self:SetMaxSpeed(80)
        self:SetAcceleration(10 + Random() * 8)
        self:ChangeMaxZigZag(0.5)
        self:ChangeZigZagFrequency(2)
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        MultiPolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
    end,
	
	FxImpactUnit = EffectTemplate.CMissileHit02,
    FxImpactProp = EffectTemplate.CMissileHit02,
    FxImpactLand = EffectTemplate.CMissileHit02,
	FxImpactAirUnit = EffectTemplate.CMissileHit02,
}

TypeClass = UniverseClassAAMissiles


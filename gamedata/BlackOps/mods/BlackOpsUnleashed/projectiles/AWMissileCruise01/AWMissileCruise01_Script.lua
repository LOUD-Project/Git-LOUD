local MiniRocketPRojectile = import('/mods/BlackOpsUnleashed/lua/BlackOpsprojectiles.lua').MiniRocketPRojectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local SingleBeamProjectile = import('/lua/sim/defaultprojectiles.lua').SingleBeamProjectile

AWMissileCruise01 = Class(MiniRocketPRojectile) {

    FxTrails = EffectTemplate.TMissileExhaust01,
    #FxTrailOffset = -0.15,
    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxAirUnitHitScale = 1,
    FxLandHitScale = 1,
    FxNoneHitScale = 1,
    FxPropHitScale = 1,
    FxProjectileHitScale = 1,
    FxProjectileUnderWaterHitScale = 1,
    FxShieldHitScale = 01,
    FxUnderWaterHitScale = 1,
    FxUnitHitScale = 1,
    FxWaterHitScale = 1,
    FxOnKilledScale = 1,
    
    OnCreate = function(self)
        MiniRocketPRojectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.2)
        self:ForkThread(self.CruiseMissileThread)
    end,

    CruiseMissileThread = function(self)
        self:SetTurnRate(180)
        WaitSeconds(2)
        self:SetTurnRate(180)
        WaitSeconds(1)
        self:SetTurnRate(360)
    end,

}
TypeClass = AWMissileCruise01